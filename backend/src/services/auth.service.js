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

const { OAuth2Client } = require('google-auth-library');

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

/**
 * Log in or register a user via Google OAuth ID Token.
 * @param {string} idToken Google ID Token from client
 * @returns {Promise<{ user: object, token: string }>}
 */
const googleLogin = async (idToken) => {
  let googleId, email, fullName, avatarUrl;

  try {
    if (idToken.startsWith('ya29.')) {
      // Access Token flow (Flutter Web / OAuth Popup)
      const response = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
        headers: { Authorization: `Bearer ${idToken}` },
      });
      if (!response.ok) {
        const err = new Error('Invalid or expired Google Access Token.');
        err.statusCode = 401;
        throw err;
      }
      const data = await response.json();
      googleId = data.sub;
      email = data.email;
      fullName = data.name;
      avatarUrl = data.picture;

      if (data.email_verified === false) {
        const err = new Error('Google account email is not verified.');
        err.statusCode = 400;
        throw err;
      }
    } else {
      // 1. Verify Google ID Token (Mobile flow)
      const ticket = await googleClient.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID || undefined,
      });
      const payload = ticket.getPayload();
      
      googleId = payload.sub;
      email = payload.email;
      fullName = payload.name;
      avatarUrl = payload.picture;

      // Security Enforcement: Ensure email is verified by Google
      if (!payload.email_verified) {
        const err = new Error('Google account email is not verified.');
        err.statusCode = 400;
        throw err;
      }
    }
  } catch (error) {
    if (error.statusCode) throw error;
    const err = new Error('Invalid or expired Google Token.');
    err.statusCode = 401;
    throw err;
  }

  if (!email) {
    const err = new Error('Google account does not provide a valid email.');
    err.statusCode = 400;
    throw err;
  }

  // 2. Check if user already exists by googleId
  let user = await authRepository.findUserByGoogleId(googleId);

  if (!user) {
    // 3. Check if user exists by email (Account Linking)
    const existingByEmail = await authRepository.findUserByEmail(email);

    if (existingByEmail) {
      // Link Google ID to existing account
      user = await authRepository.updateUserGoogleId(existingByEmail.id, googleId);
    } else {
      // 4. Create new user with Google profile details
      const baseUsername = email.split('@')[0].replace(/[^a-zA-Z0-9_]/g, '');
      let username = baseUsername.substring(0, 40);
      
      // Ensure unique username
      const existingUsername = await authRepository.findUserByUsername(username);
      if (existingUsername) {
        username = `${username}_${Math.floor(1000 + Math.random() * 9000)}`;
      }

      user = await authRepository.createGoogleUser({
        email,
        username,
        googleId,
        fullName,
        avatarUrl,
      });
    }
  }

  // 5. Issue WeTravel app JWT
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

module.exports = { signup, login, googleLogin, getMe };
