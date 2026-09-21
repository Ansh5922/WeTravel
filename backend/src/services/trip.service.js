const tripRepository   = require('../repositories/trip.repository');
const friendRepository = require('../repositories/friend.repository');

/**
 * Trip Service
 * Responsibility: Business logic for trip creation, membership, invites,
 *                 group consensus profiles, and member role management.
 * Architecture layer: Service
 */

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

// ── Fire-and-Forget: Group Preference Computation ─────────────────────────────
/**
 * Trigger the AI server in the background to (re-)compute the group preference
 * vector using cosine-similarity averaging of all members' individual vectors.
 *
 * Called:
 *  - After trip creation  (just the admin's vector → initial consensus)
 *  - After any member joins the trip  (all members recomputed)
 *
 * Node.js DOES NOT wait for this. The HTTP response was already sent.
 */
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

/** Build a short-lived internal JWT signed with the shared secret. */
const makeInternalToken = (userId) => {
  const jwt = require('jsonwebtoken');
  return jwt.sign({ sub: userId, internal: true }, process.env.JWT_SECRET, { expiresIn: '5m' });
};

// ── Trip CRUD ─────────────────────────────────────────────────────────────────

/** Create a new trip. Creator is automatically added as admin. */
const createTrip = async (userId, data) => {
  const trip = await tripRepository.createTrip(userId, data);

  // Fire-and-forget: seed group preference from admin's individual vector
  const token = makeInternalToken(userId);
  triggerGroupPreference(trip.id, [userId], token);

  return trip;
};

/**
 * Get trips the authenticated user belongs to.
 * @param {string} status - 'upcoming' | 'ongoing' | 'completed' | undefined (all)
 */
const getMyTrips = async (userId, status) => {
  // Map friendly names → Prisma TripStatus enum values
  const STATUS_MAP = { upcoming: 'planning', ongoing: 'ongoing', completed: 'completed' };
  const prismaStatus = STATUS_MAP[status] || undefined;
  return tripRepository.getUserTrips(userId, prismaStatus);
};

/** Get trip details including members. */
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

/**
 * Invite someone to a trip.
 *
 * Types:
 *  - 'friend'   → invite by friendId (must be friends with inviter)
 *  - 'email'    → invite by email address (generates shareable token)
 *  - 'whatsapp' → invite by phone number (generates shareable token)
 *  - 'link'     → generate a shareable join link (no specific recipient)
 *
 * Returns the invite record. For link/email/whatsapp also returns the `inviteToken`
 * which the client uses to build the shareable URL.
 */
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

/**
 * Join a trip using an invite token (from link / email / whatsapp).
 * Any authenticated user can use this endpoint with a valid token.
 */
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

  // 4. Fire-and-forget: re-compute group preference with all current members
  const updatedTrip = await tripRepository.findTripById(invite.groupId);
  const allMemberIds = updatedTrip.members.map((m) => m.userId);
  triggerGroupPreference(invite.groupId, allMemberIds, makeInternalToken(userId));

  return { trip: invite.group };
};

/**
 * Respond to a direct (friend) invite — accept or reject.
 */
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

    // Fire-and-forget: re-compute group preference
    const updatedTrip = await tripRepository.findTripById(invite.groupId);
    const allMemberIds = updatedTrip.members.map((m) => m.userId);
    triggerGroupPreference(invite.groupId, allMemberIds, makeInternalToken(userId));

    return { message: 'You have joined the trip!', trip: invite.group };
  }

  await tripRepository.updateInviteStatus(inviteId, 'rejected');
  return { message: 'Invite declined.' };
};

/** Get all pending invites for a trip (visible to trip members). */
const getTripInvites = async (userId, tripId) => {
  const membership = await tripRepository.findMembership(userId, tripId);
  if (!membership) {
    const err = new Error('You are not a member of this trip.');
    err.statusCode = 403;
    throw err;
  }
  return tripRepository.getTripInvites(tripId);
};

/** Get all pending direct invites received by the current user. */
const getMyInvites = async (userId) => {
  return tripRepository.getMyInvites(userId);
};

// ── Group Consensus ───────────────────────────────────────────────────────────

/** Get the saved group consensus profile for a trip. */
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

/**
 * Admin manually overrides the group consensus profile.
 * Sets isLockedByAdmin = true so AI re-computation won't overwrite it.
 */
const updateConsensus = async (userId, tripId, data) => {
  const membership = await tripRepository.findMembership(userId, tripId);
  if (!membership || !['admin', 'creator'].includes(membership.role)) {
    const err = new Error('Only admins can alter the group preference.');
    err.statusCode = 403;
    throw err;
  }
  return tripRepository.upsertConsensus(tripId, userId, data);
};

// ── Role Management ───────────────────────────────────────────────────────────

/**
 * Admin assigns the 'admin' role to another member.
 * Both the current and target user must be members of the trip.
 */
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
