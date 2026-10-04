const crypto = require('crypto');
const prisma  = require('./prisma.client');

/**
 * Trip Repository
 * Responsibility: Raw DB operations for TripGroup, GroupMember, TripInvite.
 * Architecture layer: Repository → Database
 */

const SAFE_USER_SELECT = {
  id: true,
  email: true,
  username: true,
  fullName: true,
};

/** Create a trip and add the creator as admin in a single transaction. */
const createTrip = async (userId, { name, tripStartDate, tripEndDate, coverImageUrl }) => {
  return prisma.$transaction(async (tx) => {
    const trip = await tx.tripGroup.create({
      data: {
        name,
        createdBy: userId,
        tripStartDate: tripStartDate ? new Date(tripStartDate) : null,
        tripEndDate:   tripEndDate   ? new Date(tripEndDate)   : null,
        coverImageUrl,
      },
    });

    await tx.groupMember.create({
      data: { groupId: trip.id, userId, role: 'admin' },
    });

    return trip;
  });
};

/** Find trip by ID with its member list. */
const findTripById = async (tripId) => {
  return prisma.tripGroup.findUnique({
    where: { id: tripId },
    include: {
      members: { include: { user: { select: SAFE_USER_SELECT } } },
    },
  });
};

/** Get all trips a user belongs to, optionally filtered by TripStatus. */
const getUserTrips = async (userId, status) => {
  const where = { members: { some: { userId } } };
  if (status) where.status = status;

  return prisma.tripGroup.findMany({
    where,
    include: {
      members: { include: { user: { select: SAFE_USER_SELECT } } },
    },
    orderBy: { tripStartDate: 'asc' },
  });
};

/** Check if a user is a member of a trip. */
const findMembership = async (userId, groupId) => {
  return prisma.groupMember.findFirst({ where: { userId, groupId } });
};

/** Add a user as a member (default role: member). */
const addMember = async (userId, groupId, role = 'member') => {
  return prisma.groupMember.create({ data: { userId, groupId, role } });
};

/** Create an invite record with a unique 64-char hex token. */
const createInvite = async ({ groupId, invitedBy, inviteType, inviteeId, inviteeEmail, inviteePhone }) => {
  const inviteToken = crypto.randomBytes(32).toString('hex'); // 64-char unique token
  const expiresAt   = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days

  return prisma.tripInvite.create({
    data: {
      groupId,
      invitedBy,
      inviteType,
      inviteToken,
      expiresAt,
      inviteeId:    inviteeId    || null,
      inviteeEmail: inviteeEmail || null,
      inviteePhone: inviteePhone || null,
    },
    include: {
      group:   { select: { id: true, name: true } },
      inviter: { select: SAFE_USER_SELECT },
    },
  });
};

/** Find a valid (pending + not expired) invite by token. */
const findInviteByToken = async (token) => {
  return prisma.tripInvite.findFirst({
    where: {
      inviteToken: token,
      status:      'pending',
      expiresAt:   { gt: new Date() },
    },
    include: {
      group:   { select: { id: true, name: true } },
      inviter: { select: SAFE_USER_SELECT },
    },
  });
};

/** Find a direct invite by ID for a specific recipient. */
const findDirectInviteById = async (inviteId, userId) => {
  return prisma.tripInvite.findFirst({
    where: {
      id:         inviteId,
      inviteeId:  userId,
      status:     'pending',
      expiresAt:  { gt: new Date() },
    },
    include: { group: { select: { id: true, name: true } } },
  });
};

/** Get all pending invites for a trip (admin view). */
const getTripInvites = async (groupId) => {
  return prisma.tripInvite.findMany({
    where:   { groupId, status: 'pending' },
    include: {
      inviter: { select: SAFE_USER_SELECT },
      invitee: { select: SAFE_USER_SELECT },
    },
  });
};

/** Get all pending direct invites received by a user. */
const getMyInvites = async (userId) => {
  return prisma.tripInvite.findMany({
    where: { inviteeId: userId, status: 'pending', expiresAt: { gt: new Date() } },
    include: {
      group:   { select: { id: true, name: true } },
      inviter: { select: SAFE_USER_SELECT },
    },
  });
};

/** Update invite status. */
const updateInviteStatus = async (inviteId, status) => {
  return prisma.tripInvite.update({ where: { id: inviteId }, data: { status } });
};

/** Find the group consensus profile for a trip. */
const findConsensus = async (groupId) => {
  return prisma.groupConsensusProfile.findUnique({ where: { groupId } });
};

/**
 * Upsert the group consensus profile with admin-overridden fields.
 * Admin can set computedBudgetRange, hardConstraints and lock the profile.
 */
const upsertConsensus = async (groupId, lastEditedBy, data) => {
  return prisma.groupConsensusProfile.upsert({
    where:  { groupId },
    update: { ...data, lastEditedBy, isLockedByAdmin: true },
    create: { groupId, lastEditedBy, isLockedByAdmin: true, ...data },
  });
};

/** Update a group member's role (e.g. promote to admin). */
const updateMemberRole = async (groupId, targetUserId, role) => {
  return prisma.groupMember.updateMany({
    where: { groupId, userId: targetUserId },
    data:  { role },
  });
};

module.exports = {
  createTrip,
  findTripById,
  getUserTrips,
  findMembership,
  addMember,
  createInvite,
  findInviteByToken,
  findDirectInviteById,
  getTripInvites,
  getMyInvites,
  updateInviteStatus,
  findConsensus,
  upsertConsensus,
  updateMemberRole,
};
