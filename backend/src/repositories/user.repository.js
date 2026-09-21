const prisma = require('./prisma.client');

/**
 * User Repository
 * Responsibility: Raw database operations for User and UserProfile models.
 * Architecture layer: Repository → Database
 */

/**
 * Get a user's profile by user ID.
 * @param {string} userId
 * @returns {Promise<UserProfile|null>}
 */
const findProfileByUserId = async (userId) => {
  return prisma.userProfile.findUnique({
    where: { userId },
  });
};

/**
 * Upsert a user's profile (create if not exists, update if exists).
 * @param {string} userId
 * @param {{
 *   dietaryPreference?: string,
 *   travelStyle?: string,
 *   budgetTier?: string,
 *   pacePreference?: string,
 *   healthConstraints?: object,
 *   climateSensitivities?: object,
 *   rawPreferenceNotes?: string
 * }} data
 * @returns {Promise<UserProfile>}
 */
const upsertProfile = async (userId, data) => {
  return prisma.userProfile.upsert({
    where: { userId },
    create: {
      userId,
      ...data,
    },
    update: {
      ...data,
    },
  });
};

/**
 * Update the User table (fullName, phone).
 * @param {string} userId
 * @param {{ fullName?: string, phone?: string }} data
 * @returns {Promise<User>}
 */
const updateUser = async (userId, data) => {
  return prisma.user.update({
    where: { id: userId },
    data,
    select: {
      id: true,
      email: true,
      fullName: true,
      phone: true,
      isPremium: true,
      updatedAt: true,
    },
  });
};

module.exports = {
  findProfileByUserId,
  upsertProfile,
  updateUser,
};
