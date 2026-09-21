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
  return prisma.user.findUnique({
    where: { email },
  });
};

/**
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

module.exports = {
  findUserByEmail,
  findUserById,
  findUserByUsername,
  createUser,
};

