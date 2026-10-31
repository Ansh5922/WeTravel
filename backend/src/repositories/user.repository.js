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
 * Update the User table (fullName, phone, avatarUrl).
 * @param {string} userId
 * @param {{ fullName?: string, phone?: string, avatarUrl?: string|null }} data
 * @returns {Promise<User>}
 */
const updateUser = async (userId, data) => {
  return prisma.user.update({
    where: { id: userId },
    data,
    select: {
      id: true,
      email: true,
      username: true,
      fullName: true,
      avatarUrl: true,
      phone: true,
      isPremium: true,
      updatedAt: true,
    },
  });
};

/**
 * Anonymize and delete a user's account (Play Store & GDPR compliant soft-delete).
 * Scrubs all PII, removes private profile & friendships, and preserves ledger integrity.
 * @param {string} userId
 * @returns {Promise<object>}
 */
const anonymizeAndDeleteUser = async (userId) => {
  const anonymizedEmail = `deleted_${userId}@deleted.wetravel.internal`;
  const anonymizedUsername = `deleted_${userId.replace(/-/g, '').slice(0, 12)}`;

  return prisma.$transaction(async (tx) => {
    // 1. Delete user's private profile & AI preferences
    await tx.userProfile.deleteMany({
      where: { userId },
    });

    // 2. Delete all friendship records (both sent and received)
    await tx.friendship.deleteMany({
      where: {
        OR: [
          { userId },
          { friendId: userId },
        ],
      },
    });

    // 3. Delete pending trip invitations sent by this user
    await tx.tripInvite.deleteMany({
      where: { inviterId: userId },
    });

    // 4. Scrub all Personally Identifiable Information (PII) from user record
    const updatedUser = await tx.user.update({
      where: { id: userId },
      data: {
        fullName: 'Deleted User',
        email: anonymizedEmail,
        username: anonymizedUsername,
        passwordHash: null,
        googleId: null,
        avatarUrl: null,
        phone: null,
        isPremium: false,
      },
      select: {
        id: true,
        fullName: true,
        email: true,
        updatedAt: true,
      },
    });

    return updatedUser;
  });
};


/**
 * Find a user by ID.
 * @param {string} userId
 * @returns {Promise<User|null>}
 */
const findUserById = async (userId) => {
  return prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      email: true,
      username: true,
      fullName: true,
      avatarUrl: true,
      phone: true,
      isPremium: true,
      createdAt: true,
      updatedAt: true,
    },
  });
};

/**
 * Find a user by username (case-insensitive search).
 * @param {string} username
 * @returns {Promise<User|null>}
 */
const findUserByUsername = async (username) => {
  return prisma.user.findFirst({
    where: {
      username: {
        equals: username,
        mode: 'insensitive',
      },
    },
    select: {
      id: true,
      email: true,
      username: true,
      fullName: true,
    },
  });
};

module.exports = {
  findUserById,
  findUserByUsername,
  findProfileByUserId,
  upsertProfile,
  updateUser,
  anonymizeAndDeleteUser,
};
