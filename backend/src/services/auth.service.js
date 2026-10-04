const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const authRepository = require('../repositories/auth.repository');

/**
 * Auth Service
 * Responsibility: Business logic for signup/login.
 * Architecture layer: Service (calls Repository, returns domain objects)
 */

const SALT_ROUNDS = 12;

/**
 * Sign a JWT containing the user's id.
 * @param {string} userId
 * @returns {string} signed JWT
 */
const signToken = (userId) => {
  return jwt.sign(
    { sub: userId },                    // payload — sub = subject (standard JWT claim)
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

/**
 * Register a new user.
 * @param {{ email: string, password: string, fullName?: string, phone?: string }} data
 * @returns {Promise<{ user: object, token: string }>}
 */
const signup = async ({ email, password, username, fullName, phone }) => {
  // 1. Check if email already in use
  const existing = await authRepository.findUserByEmail(email);
  if (existing) {
    const err = new Error('Email is already registered.');
    err.statusCode = 409;
    throw err;
  }

  // 2. Check if username is already taken
  const takenUsername = await authRepository.findUserByUsername(username);
  if (takenUsername) {
    const err = new Error('Username is already taken. Please choose another.');
    err.statusCode = 409;
    throw err;
  }

  // 3. Hash the password
  const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

  // 4. Persist new user
  const user = await authRepository.createUser({ email, username, passwordHash, fullName, phone });

  // 5. Issue JWT
  const token = signToken(user.id);

  return { user, token };
};

/**
 * Log in an existing user.
 * @param {{ email: string, password: string }} credentials
 * @returns {Promise<{ user: object, token: string }>}
 */
const login = async ({ email, password }) => {
  // 1. Find user (include passwordHash for comparison)
  const userWithHash = await authRepository.findUserByEmail(email);
  if (!userWithHash) {
    const err = new Error('Invalid email or password.');
    err.statusCode = 401;
    throw err;
  }

  if (!userWithHash.passwordHash) {
    const err = new Error('This account uses a different login method.');
    err.statusCode = 401;
    throw err;
  }

  // 2. Compare password
  const isMatch = await bcrypt.compare(password, userWithHash.passwordHash);
  if (!isMatch) {
    const err = new Error('Invalid email or password.');
    err.statusCode = 401;
    throw err;
  }

  // 3. Return safe user object (strip password hash)
  const user = {
    id: userWithHash.id,
    email: userWithHash.email,
    fullName: userWithHash.fullName,
    phone: userWithHash.phone,
    isPremium: userWithHash.isPremium,
    createdAt: userWithHash.createdAt,
  };

  // 4. Issue JWT
  const token = signToken(user.id);

  return { user, token };
};

/**
 * Get the authenticated user's profile.
 * @param {string} userId
 * @returns {Promise<object>}
 */
const getMe = async (userId) => {
  const user = await authRepository.findUserById(userId);
  if (!user) {
    const err = new Error('User not found.');
    err.statusCode = 404;
    throw err;
  }
  return user;
};

module.exports = { signup, login, getMe };
