const prisma = require('./prisma.client');

// User repository for User and UserProfile database operations

// Get a user's profile by user ID
const findProfileByUserId = async (userId) => {
  return prisma.userProfile.findUnique({
    where: { userId },
  });
};

// Upsert a user's profile (create if not exists, update if exists)
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

// Update the User table (fullName, phone)
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
