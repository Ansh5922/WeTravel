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
      fullName: true,
      phone: true,
      isPremium: true,
      createdAt: true,
    },
  });
};

/**
 * Create a new user record.
 * @param {{ email: string, passwordHash: string, fullName?: string, phone?: string }} data
 * @returns {Promise<User>}
 */
const createUser = async ({ email, passwordHash, fullName, phone }) => {
  return prisma.user.create({
    data: {
      email,
      passwordHash,
      fullName,
      phone,
    },
    select: {
      id: true,
      email: true,
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
  createUser,
};
