const prisma = require('./prisma.client');

/**
 * Friend Repository
 * Responsibility: Raw DB operations for Friendship model.
 * Architecture layer: Repository → Database
 */

const SAFE_USER_SELECT = {
  id: true,
  email: true,
  username: true,
  fullName: true,
};

/**
 * Find an existing friendship record between two users (in either direction).
 */
const findFriendship = async (userId, friendId) => {
  return prisma.friendship.findFirst({
    where: {
      OR: [
        { userId, friendId },
        { userId: friendId, friendId: userId },
      ],
    },
  });
};

/**
 * Find a friendship by its ID, verifying one of the users is involved.
 */
const findFriendshipById = async (friendshipId, userId) => {
  return prisma.friendship.findFirst({
    where: {
      id: friendshipId,
      OR: [{ userId }, { friendId: userId }],
    },
    include: {
      user:   { select: SAFE_USER_SELECT },
      friend: { select: SAFE_USER_SELECT },
    },
  });
};

/**
 * Create a pending friend request from userId → friendId.
 */
const createFriendRequest = async (userId, friendId) => {
  return prisma.friendship.create({
    data: { userId, friendId, status: 'pending' },
    include: {
      friend: { select: SAFE_USER_SELECT },
    },
  });
};

/**
 * Update friendship status (accepted | rejected | blocked).
 */
const updateFriendshipStatus = async (friendshipId, status) => {
  return prisma.friendship.update({
    where: { id: friendshipId },
    data: { status },
    include: {
      user:   { select: SAFE_USER_SELECT },
      friend: { select: SAFE_USER_SELECT },
    },
  });
};

/**
 * Get all accepted friends of a user.
 */
const getAcceptedFriends = async (userId) => {
  return prisma.friendship.findMany({
    where: {
      status: 'accepted',
      OR: [{ userId }, { friendId: userId }],
    },
    include: {
      user:   { select: SAFE_USER_SELECT },
      friend: { select: SAFE_USER_SELECT },
    },
  });
};

/**
 * Get all pending friend requests received by userId.
 */
const getIncomingRequests = async (userId) => {
  return prisma.friendship.findMany({
    where: { friendId: userId, status: 'pending' },
    include: {
      user: { select: SAFE_USER_SELECT }, // the sender
    },
  });
};

module.exports = {
  findFriendship,
  findFriendshipById,
  createFriendRequest,
  updateFriendshipStatus,
  getAcceptedFriends,
  getIncomingRequests,
};
