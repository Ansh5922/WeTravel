const prisma = require('./prisma.client');

/**
 * Auth Repository
 * Responsibility: Raw database operations for User model.
 * Architecture layer: Repository (bottom of the chain above DB)
 */

/**
 * Find a user by their email address.
 * @param {string} email
 * @returns {Promise<User|null>}
 */
const findUserByEmail = async (email) => {
  return prisma.user.findFirst({
    where: {
      email: {
        equals: email.trim(),
        mode: 'insensitive',
      },
    },
  });
};

/**
 * Find a user's preferences profile by user ID.
 * @param {string} userId
 * @returns {Promise<UserProfile|null>}
 */
const findUserProfileByUserId = async (userId) => {
  return prisma.userProfile.findUnique({
    where: { userId },
  });
};

/**
 * 
 * Find a user by their UUID.
 * @param {string} id
 * @returns {Promise<User|null>}
 */
const findUserById = async (id) => {
  return prisma.user.findUnique({
    where: { id },
    select: {
      id: true,
      email: true,
      username: true,
      fullName: true,
      avatarUrl: true,
      phone: true,
      isPremium: true,
      createdAt: true,
    },
  });
};

/**
 * Find a user by their unique username.
 * @param {string} username
 * @returns {Promise<User|null>}
 */
const findUserByUsername = async (username) => {
  return prisma.user.findUnique({
    where: { username },
    select: { id: true, email: true, username: true, fullName: true },
  });
};

/**
 * Create a new user record.
 * @param {{ email: string, passwordHash: string, fullName?: string, phone?: string }} data
 * @returns {Promise<User>}
 */
const createUser = async ({ email, username, passwordHash, fullName, phone }) => {
  return prisma.user.create({
    data: {
      email,
      username,
      passwordHash,
      fullName,
      phone,
    },
    select: {
      id: true,
      email: true,
      username: true,
      fullName: true,
      phone: true,
      isPremium: true,
      createdAt: true,
    },
  });
};

/**
 * Find a user by their Google ID.
 * @param {string} googleId
 * @returns {Promise<User|null>}
 */
const findUserByGoogleId = async (googleId) => {
  return prisma.user.findUnique({
    where: { googleId },
  });
};

/**
 * Link a Google ID to an existing user record.
 * @param {string} id
 * @param {string} googleId
 * @returns {Promise<User>}
 */
const updateUserGoogleId = async (id, googleId) => {
  return prisma.user.update({
    where: { id },
    data: { googleId },
    select: {
      id: true,
      email: true,
      username: true,
      fullName: true,
      avatarUrl: true,
      phone: true,
      isPremium: true,
      createdAt: true,
    },
  });
};

/**
 * Create a new user from Google profile.
 * @param {{ email: string, username: string, googleId: string, fullName?: string, avatarUrl?: string }} data
 * @returns {Promise<User>}
 */
const createGoogleUser = async ({ email, username, googleId, fullName, avatarUrl }) => {
  return prisma.user.create({
    data: {
      email,
      username,
      googleId,
      fullName,
      avatarUrl,
    },
    select: {
      id: true,
      email: true,
      username: true,
      fullName: true,
      avatarUrl: true,
      phone: true,
      isPremium: true,
      createdAt: true,
    },
  });
};

/**
 * Update a user's password hash.
 * @param {string} userId
 * @param {string} passwordHash
 * @returns {Promise<User>}
 */
const updateUserPassword = async (userId, passwordHash) => {
  return prisma.user.update({
    where: { id: userId },
    data: { passwordHash },
    select: {
      id: true,
      email: true,
      username: true,
      fullName: true,
      updatedAt: true,
    },
  });
};

module.exports = {
  findUserByEmail,
  findUserById,
  findUserByUsername,
  findUserByGoogleId,
  findUserProfileByUserId,
  updateUserGoogleId,
  createGoogleUser,
  createUser,
  updateUserPassword,
};

