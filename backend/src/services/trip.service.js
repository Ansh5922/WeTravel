const tripRepository   = require('../repositories/trip.repository');
const friendRepository = require('../repositories/friend.repository');

// Trip service handling trip groups, memberships, invitations, and consensus sync

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

// Trigger AI server in background to recompute group preference consensus
const triggerGroupPreference = (tripId, memberIds, internalToken) => {
  fetch(`${AI_SERVICE_URL}/api/ai/consensus/group-preference`, {
    method:  'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${internalToken}` },
    body:    JSON.stringify({ group_id: tripId, member_ids: memberIds }),
  })
    .then(async (res) => {
      if (!res.ok) {
        const body = await res.text();
        console.error(`[Group Preference] Failed for trip ${tripId}: ${res.status} — ${body}`);
      } else {
        console.log(`[Group Preference] ✅ Consensus updated for trip ${tripId} with ${memberIds.length} member(s)`);
      }
    })
    .catch((err) => console.error(`[Group Preference] Network error for trip ${tripId}:`, err.message));
};

// Build a short-lived internal JWT signed with shared secret
const makeInternalToken = (userId) => {
  const jwt = require('jsonwebtoken');
  return jwt.sign({ sub: userId, internal: true }, process.env.JWT_SECRET, { expiresIn: '5m' });
};

// Create a new trip; creator is automatically assigned admin role
const createTrip = async (userId, data) => {
  const trip = await tripRepository.createTrip(userId, data);

  // Fire-and-forget: seed group preference from admin's individual vector
  const token = makeInternalToken(userId);
  triggerGroupPreference(trip.id, [userId], token);

  return trip;
};

// Get trips the authenticated user belongs to
const getMyTrips = async (userId, status) => {
  const STATUS_MAP = { upcoming: 'planning', ongoing: 'ongoing', completed: 'completed' };
  const prismaStatus = STATUS_MAP[status] || undefined;
  return tripRepository.getUserTrips(userId, prismaStatus);
};

// Get trip details including members
const getTripDetails = async (userId, tripId) => {
  const trip = await tripRepository.findTripById(tripId);
  if (!trip) {
    const err = new Error('Trip not found.');
    err.statusCode = 404;
    throw err;
  }

  const membership = await tripRepository.findMembership(userId, tripId);
  if (!membership) {
    const err = new Error('You are not a member of this trip.');
    err.statusCode = 403;
    throw err;
  }

  return trip;
};

// Invite someone to a trip via friend, email, whatsapp, or shareable link
const inviteMember = async (inviterId, tripId, { type, friendId, email, phone }) => {
  // 1. Verify inviter is a member of the trip
  const membership = await tripRepository.findMembership(inviterId, tripId);
  if (!membership) {
    const err = new Error('You are not a member of this trip.');
    err.statusCode = 403;
    throw err;
  }

  // 2. For 'friend' invites — extra validations
  if (type === 'friend') {
    if (!friendId) {
      const err = new Error('friendId is required for friend invites.');
      err.statusCode = 400;
      throw err;
    }

    // Check they are actually friends
    const friendship = await friendRepository.findFriendship(inviterId, friendId);
    if (!friendship || friendship.status !== 'accepted') {
      const err = new Error('You can only invite users who are your friends.');
      err.statusCode = 403;
      throw err;
    }

    // Check invitee is not already a member
    const alreadyMember = await tripRepository.findMembership(friendId, tripId);
    if (alreadyMember) {
      const err = new Error('This user is already a member of the trip.');
      err.statusCode = 409;
      throw err;
    }
  }

  // 3. Create invite record
  const invite = await tripRepository.createInvite({
    groupId:      tripId,
    invitedBy:    inviterId,
    inviteType:   type,
    inviteeId:    type === 'friend'   ? friendId : null,
    inviteeEmail: type === 'email'    ? email    : null,
    inviteePhone: type === 'whatsapp' ? phone    : null,
  });

  return invite;
};

// Join a trip using an invite token (from link, email, or whatsapp)
const joinViaToken = async (userId, token) => {
  // 1. Find valid invite
  const invite = await tripRepository.findInviteByToken(token);
  if (!invite) {
    const err = new Error('Invite link is invalid or has expired.');
    err.statusCode = 404;
    throw err;
  }

  // 2. Check not already a member
  const alreadyMember = await tripRepository.findMembership(userId, invite.groupId);
  if (alreadyMember) {
    const err = new Error('You are already a member of this trip.');
    err.statusCode = 409;
    throw err;
  }

  // 3. Add user and mark invite as accepted
  await tripRepository.addMember(userId, invite.groupId);
  await tripRepository.updateInviteStatus(invite.id, 'accepted');

  // 4. Fire-and-forget: recompute group preference with all current members
  const updatedTrip = await tripRepository.findTripById(invite.groupId);
  const allMemberIds = updatedTrip.members.map((m) => m.userId);
  triggerGroupPreference(invite.groupId, allMemberIds, makeInternalToken(userId));

  return { trip: invite.group };
};

// Respond to a direct friend invite — accept or reject
const respondToInvite = async (userId, inviteId, action) => {
  const invite = await tripRepository.findDirectInviteById(inviteId, userId);
  if (!invite) {
    const err = new Error('Invite not found or has already been responded to.');
    err.statusCode = 404;
    throw err;
  }

  if (action === 'accept') {
    const alreadyMember = await tripRepository.findMembership(userId, invite.groupId);
    if (!alreadyMember) {
      await tripRepository.addMember(userId, invite.groupId);
    }
    await tripRepository.updateInviteStatus(inviteId, 'accepted');

    // Fire-and-forget: recompute group preference
    const updatedTrip = await tripRepository.findTripById(invite.groupId);
    const allMemberIds = updatedTrip.members.map((m) => m.userId);
    triggerGroupPreference(invite.groupId, allMemberIds, makeInternalToken(userId));

    return { message: 'You have joined the trip!', trip: invite.group };
  }

  await tripRepository.updateInviteStatus(inviteId, 'rejected');
  return { message: 'Invite declined.' };
};

// Get all pending invites for a trip (visible to trip members)
const getTripInvites = async (userId, tripId) => {
  const membership = await tripRepository.findMembership(userId, tripId);
  if (!membership) {
    const err = new Error('You are not a member of this trip.');
    err.statusCode = 403;
    throw err;
  }
  return tripRepository.getTripInvites(tripId);
};

// Get all pending direct invites received by the current user
const getMyInvites = async (userId) => {
  return tripRepository.getMyInvites(userId);
};

// Get the saved group consensus profile for a trip
const getConsensus = async (userId, tripId) => {
  const membership = await tripRepository.findMembership(userId, tripId);
  if (!membership) {
    const err = new Error('You are not a member of this trip.');
    err.statusCode = 403;
    throw err;
  }
  const consensus = await tripRepository.findConsensus(tripId);
  if (!consensus) {
    const err = new Error('Group preference not generated yet.');
    err.statusCode = 404;
    throw err;
  }
  return consensus;
};

// Admin manually overrides the group consensus profile
const updateConsensus = async (userId, tripId, data) => {
  const membership = await tripRepository.findMembership(userId, tripId);
  if (!membership || !['admin', 'creator'].includes(membership.role)) {
    const err = new Error('Only admins can alter the group preference.');
    err.statusCode = 403;
    throw err;
  }
  return tripRepository.upsertConsensus(tripId, userId, data);
};

// Admin assigns the admin role to another member
const assignRole = async (requestingUserId, tripId, targetUserId, role) => {
  // 1. Requesting user must be admin
  const requesterMembership = await tripRepository.findMembership(requestingUserId, tripId);
  if (!requesterMembership || !['admin', 'creator'].includes(requesterMembership.role)) {
    const err = new Error('Only admins can assign roles.');
    err.statusCode = 403;
    throw err;
  }

  // 2. Target must be a member
  const targetMembership = await tripRepository.findMembership(targetUserId, tripId);
  if (!targetMembership) {
    const err = new Error('Target user is not a member of this trip.');
    err.statusCode = 404;
    throw err;
  }

  await tripRepository.updateMemberRole(tripId, targetUserId, role);
  return { message: `User's role updated to ${role}.` };
};

module.exports = {
  createTrip,
  getMyTrips,
  getTripDetails,
  inviteMember,
  joinViaToken,
  respondToInvite,
  getTripInvites,
  getMyInvites,
  getConsensus,
  updateConsensus,
  assignRole,
};
