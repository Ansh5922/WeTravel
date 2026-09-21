const authRepository  = require('../repositories/auth.repository');
const friendRepository = require('../repositories/friend.repository');

/**
 * Friend Service
 * Responsibility: Business logic for friend requests.
 * Architecture layer: Service
 */

/** Send a friend request to a user identified by their username. */
const sendFriendRequest = async (requestedByUserId, targetUsername) => {
  // 1. Find target user by username
  const target = await authRepository.findUserByUsername(targetUsername);
  if (!target) {
    const err = new Error(`User with username "${targetUsername}" not found.`);
    err.statusCode = 404;
    throw err;
  }

  // 2. Cannot send request to yourself
  if (target.id === requestedByUserId) {
    const err = new Error('You cannot send a friend request to yourself.');
    err.statusCode = 400;
    throw err;
  }

  // 3. Check if friendship already exists
  const existing = await friendRepository.findFriendship(requestedByUserId, target.id);
  if (existing) {
    const messages = {
      pending:  'A friend request already exists between you and this user.',
      accepted: 'You are already friends with this user.',
      blocked:  'This friendship has been blocked.',
    };
    const err = new Error(messages[existing.status] || 'Friendship already exists.');
    err.statusCode = 409;
    throw err;
  }

  // 4. Create pending friendship
  return friendRepository.createFriendRequest(requestedByUserId, target.id);
};

/** Accept or reject an incoming friend request. */
const respondToRequest = async (userId, friendshipId, action) => {
  const friendship = await friendRepository.findFriendshipById(friendshipId, userId);
  if (!friendship) {
    const err = new Error('Friend request not found.');
    err.statusCode = 404;
    throw err;
  }

  // Only the recipient (friendId) can respond
  if (friendship.friendId !== userId) {
    const err = new Error('You can only respond to requests sent to you.');
    err.statusCode = 403;
    throw err;
  }

  if (friendship.status !== 'pending') {
    const err = new Error('This friend request has already been responded to.');
    err.statusCode = 409;
    throw err;
  }

  const newStatus = action === 'accept' ? 'accepted' : 'rejected';
  return friendRepository.updateFriendshipStatus(friendshipId, newStatus);
};

/** Get list of accepted friends for a user. */
const getFriends = async (userId) => {
  const friendships = await friendRepository.getAcceptedFriends(userId);

  // Return the "other" user from each friendship
  return friendships.map((f) => (f.userId === userId ? f.friend : f.user));
};

/** Get pending incoming friend requests. */
const getPendingRequests = async (userId) => {
  return friendRepository.getIncomingRequests(userId);
};

module.exports = { sendFriendRequest, respondToRequest, getFriends, getPendingRequests };
