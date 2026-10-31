const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const authRepository = require('../repositories/auth.repository');
const emailService = require('./email.service');

// ── In-Memory Password Reset OTP & Token Store ────────────────────────────────
// Stores active reset requests: email -> { userId, otpHash, resetToken, expiresAt, attempts, lastRequestedAt }
const resetStore = new Map();
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // 1 request per 60s per email
const OTP_TTL_MS = 15 * 60 * 1000;      // 15 minutes validity
const MAX_OTP_ATTEMPTS = 5;

// Periodically clean expired reset requests (unref so it doesn't block shutdown)
const cleanupTimer = setInterval(() => {
  const now = Date.now();
  for (const [email, record] of resetStore.entries()) {
    if (now > record.expiresAt) {
      resetStore.delete(email);
    }
  }
}, 5 * 60 * 1000);
cleanupTimer.unref();

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

  // 4. Defensive resolution: fallback to username if fullName is empty
  const resolvedFullName = (fullName && fullName.trim()) || username;

  // 5. Persist new user
  const user = await authRepository.createUser({
    email,
    username,
    passwordHash,
    fullName: resolvedFullName,
    phone,
  });

  // 6. Issue JWT
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
  let isNewUser = false;
  const normalizedEmail = email.toLowerCase().trim();

  if (!user) {
    // 3. Check if user exists by email (Account Linking)
    const existingByEmail = await authRepository.findUserByEmail(normalizedEmail);

    if (existingByEmail) {
      // Link Google ID to existing account
      user = await authRepository.updateUserGoogleId(existingByEmail.id, googleId);
    } else {
      // 4. Create new user with Google profile details
      isNewUser = true;
      const baseUsername = normalizedEmail.split('@')[0].replace(/[^a-zA-Z0-9_]/g, '');
      let username = baseUsername.substring(0, 40);
      
      // Ensure unique username
      const existingUsername = await authRepository.findUserByUsername(username);
      if (existingUsername) {
        username = `${username}_${Math.floor(1000 + Math.random() * 9000)}`;
      }

      const resolvedFullName = (fullName && fullName.trim()) || username;

      user = await authRepository.createGoogleUser({
        email: normalizedEmail,
        username,
        googleId,
        fullName: resolvedFullName,
        avatarUrl,
      });
    }
  }

  // 5. Check if user has an existing preferences profile in DB
  const userProfile = await authRepository.findUserProfileByUserId(user.id);

  // Set preference screen only when user is signing in for the first time and does not have an account already
  const isFirstTimeUser = Boolean(isNewUser && !userProfile);

  // 6. Issue WeTravel app JWT
  const token = signToken(user.id);

  return { user, token, isNewUser, isFirstTimeUser };
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

/**
 * Initiate password reset by generating a secure 6-digit OTP and reset token.
 * Dispatches via emailService (Resend in prod, Console box in dev).
 * @param {string} email
 * @returns {Promise<{ message: string }>}
 */
const forgotPassword = async (email) => {
  const normalizedEmail = email.trim().toLowerCase();

  // Rate limiting check
  const existing = resetStore.get(normalizedEmail);
  if (existing && Date.now() - existing.lastRequestedAt < RATE_LIMIT_WINDOW_MS) {
    const waitSeconds = Math.ceil((RATE_LIMIT_WINDOW_MS - (Date.now() - existing.lastRequestedAt)) / 1000);
    const err = new Error(`Please wait ${waitSeconds} seconds before requesting another code.`);
    err.statusCode = 429;
    throw err;
  }

  // Find user by email
  const user = await authRepository.findUserByEmail(normalizedEmail);

  // Security: Do not reveal if email exists (prevent user enumeration)
  if (!user) {
    return {
      message: 'If an account exists with this email, password reset instructions have been sent.',
    };
  }

  // Generate 6-digit numeric OTP and 15-minute signed JWT
  const otp = crypto.randomInt(100000, 999999).toString();
  const resetToken = jwt.sign(
    { sub: user.id, email: user.email, purpose: 'password_reset' },
    process.env.JWT_SECRET,
    { expiresIn: '15m' }
  );

  // Store hashed OTP in memory (SHA-256)
  const otpHash = crypto.createHash('sha256').update(otp).digest('hex');
  resetStore.set(normalizedEmail, {
    userId: user.id,
    otpHash,
    resetToken,
    expiresAt: Date.now() + OTP_TTL_MS,
    attempts: 0,
    lastRequestedAt: Date.now(),
  });

  // Dispatch email (fire-and-forget logging errors internally)
  emailService
    .sendPasswordResetEmail({
      to: user.email,
      name: user.fullName || user.username || 'Traveler',
      otp,
      resetToken,
    })
    .catch((err) => console.error('[Auth Service] Email dispatch error:', err.message));

  return {
    message: 'If an account exists with this email, password reset instructions have been sent.',
  };
};

/**
 * Reset user password using either 6-digit OTP or signed resetToken.
 * @param {{ email?: string, otp?: string, token?: string, newPassword?: string, password?: string }} params
 */
const resetPassword = async ({ email, otp, token, newPassword, password }) => {
  const targetPassword = newPassword || password;

  if (!targetPassword || typeof targetPassword !== 'string' || targetPassword.length < 8) {
    const err = new Error('Password must be at least 8 characters long.');
    err.statusCode = 400;
    throw err;
  }

  let targetUserId = null;
  let targetEmail = null;

  // 1. Verify via signed resetToken (Magic link flow)
  if (token) {
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (jwtErr) {
      const err = new Error(
        jwtErr.name === 'TokenExpiredError'
          ? 'Reset link has expired. Please request a new one.'
          : 'Invalid or corrupted reset link.'
      );
      err.statusCode = 400;
      throw err;
    }

    if (decoded.purpose !== 'password_reset') {
      const err = new Error('Invalid token purpose.');
      err.statusCode = 400;
      throw err;
    }

    targetUserId = decoded.sub;
    targetEmail = decoded.email ? decoded.email.toLowerCase() : null;
  }
  // 2. Verify via 6-digit OTP + Email (Mobile App flow)
  else if (email && otp) {
    targetEmail = email.trim().toLowerCase();
    const record = resetStore.get(targetEmail);

    if (!record || Date.now() > record.expiresAt) {
      resetStore.delete(targetEmail);
      const err = new Error('Verification code has expired or is invalid. Please request a new one.');
      err.statusCode = 400;
      throw err;
    }

    // Check brute-force attempts
    if (record.attempts >= MAX_OTP_ATTEMPTS) {
      resetStore.delete(targetEmail);
      const err = new Error('Too many failed verification attempts. Please request a new code.');
      err.statusCode = 429;
      throw err;
    }

    const providedOtpHash = crypto.createHash('sha256').update(otp.trim()).digest('hex');
    if (providedOtpHash !== record.otpHash) {
      record.attempts += 1;
      const remaining = MAX_OTP_ATTEMPTS - record.attempts;
      const err = new Error(`Invalid verification code. ${remaining} attempt(s) remaining.`);
      err.statusCode = 400;
      throw err;
    }

    targetUserId = record.userId;
  } else {
    const err = new Error('Either a valid reset token or email and 6-digit code must be provided.');
    err.statusCode = 400;
    throw err;
  }

  // 3. Hash the new password securely
  const passwordHash = await bcrypt.hash(targetPassword, SALT_ROUNDS);

  // 4. Update the user password in DB
  await authRepository.updateUserPassword(targetUserId, passwordHash);

  // 5. Invalidate the reset record
  if (targetEmail) {
    resetStore.delete(targetEmail);
  }

  return {
    message: 'Password has been reset successfully. Please log in with your new password.',
  };
};

module.exports = {
  signup,
  login,
  googleLogin,
  getMe,
  forgotPassword,
  resetPassword,
};
