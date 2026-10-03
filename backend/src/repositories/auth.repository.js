const prisma = require('./prisma.client');

// Auth repository for User table database queries

// Find a user by their email address
const findUserByEmail = async (email) => {
  return prisma.user.findUnique({
    where: { email },
  });
};

// Find a user by their UUID
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

// Find a user by their unique username
const findUserByUsername = async (username) => {
  return prisma.user.findUnique({
    where: { username },
    select: { id: true, email: true, username: true, fullName: true },
  });
};

// Create a new user record
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
