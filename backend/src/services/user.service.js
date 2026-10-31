const userRepository = require('../repositories/user.repository');
const imagekitService = require('./imagekit.service');

/**
 * User Service
 * Responsibility: Business logic for user profile management.
 * Architecture layer: Service (calls Repository + AI sidecar)
 *
 * KEY DESIGN: Node.js saves to DB → responds to client immediately →
 * fires a background (fire-and-forget) request to FastAPI for embeddings.
 * The client NEVER waits for the AI.
 */

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

/**
 * Fire-and-forget background call to FastAPI to generate preference embeddings.
 * This runs AFTER the HTTP response has already been sent to the client.
 *
 * @param {string} userId
 * @param {object} profile - The saved UserProfile document
 */
const triggerEmbeddingGeneration = (userId, profile) => {
  // Build a human-readable preference text for the embedding model
  const preferenceText = buildPreferenceText(profile);

  // Use the shared JWT_SECRET to sign an internal service token
  // so FastAPI's protect middleware accepts this internal request
  const jwt = require('jsonwebtoken');
  const internalToken = jwt.sign(
    { sub: userId, internal: true },
    process.env.JWT_SECRET,
    { expiresIn: '5m' }
  );

  // Fire-and-forget: NO await. If AI fails, it doesn't affect the user.
  fetch(`${AI_SERVICE_URL}/api/ai/embeddings/preferences`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${internalToken}`,
    },
    body: JSON.stringify({
      user_id: userId,
      preference_text: preferenceText,
      raw_profile: profile,
    }),
  })
    .then(async (res) => {
      if (!res.ok) {
        const body = await res.text();
        console.error(`[AI Embedding] Failed for user ${userId}: ${res.status} — ${body}`);
      } else {
        console.log(`[AI Embedding] ✅ Embedding generated for user ${userId}`);
      }
    })
    .catch((err) => {
      // Log the error silently — never propagate to user response
      console.error(`[AI Embedding] Network error for user ${userId}:`, err.message);
    });
};

/**
 * Converts structured profile data into a natural language string
 * suitable for embedding generation.
 * @param {object} profile
 * @returns {string}
 */
const buildPreferenceText = (profile) => {
  const parts = [];

  if (profile.travelStyle) parts.push(`Travel style: ${profile.travelStyle}`);
  if (profile.budget !== undefined && profile.budget !== null) {
    parts.push(`Daily budget: $${profile.budget}`);
  } else if (profile.budgetTier) {
    parts.push(`Budget tier: ${profile.budgetTier}`);
  }
  if (profile.pacePreference) parts.push(`Preferred pace: ${profile.pacePreference}`);
  if (profile.dietaryPreference) parts.push(`Dietary preference: ${profile.dietaryPreference}`);
  if (profile.healthConstraints) {
    parts.push(`Health constraints: ${JSON.stringify(profile.healthConstraints)}`);
  }
  if (profile.climateSensitivities) {
    parts.push(`Climate sensitivities: ${JSON.stringify(profile.climateSensitivities)}`);
  }
  if (profile.rawPreferenceNotes) {
    parts.push(`Additional notes: ${profile.rawPreferenceNotes}`);
  }

  return parts.join('. ');
};

/**
 * Update user basic info (fullName, phone) and/or profile preferences.
 * Responds immediately after DB save; embedding generation runs in background.
 *
 * @param {string} userId - The authenticated user's ID from req.user
 * @param {{
 *   fullName?: string,
 *   phone?: string,
 *   dietaryPreference?: string,
 *   travelStyle?: string,
 *   budget?: number,
 *   budgetTier?: string,
 *   pacePreference?: string,
 *   healthConstraints?: object,
 *   climateSensitivities?: object,
 *   rawPreferenceNotes?: string
 * }} data
 * @returns {Promise<{ user: object, profile: object }>}
 */
const updateProfile = async (userId, data) => {
  // Separate user-level fields from profile-level fields
  const userFields = {};
  const profileFields = {};

  const userKeys = ['fullName', 'phone', 'avatarUrl'];

  // Username validation & uniqueness check
  if (data.username !== undefined) {
    const rawUsername = typeof data.username === 'string' ? data.username.trim() : '';
    if (!rawUsername) {
      const err = new Error('Username cannot be empty.');
      err.statusCode = 400;
      throw err;
    }

    if (!/^[a-zA-Z0-9_]{3,30}$/.test(rawUsername)) {
      const err = new Error('Username must be 3-30 characters and contain only letters, numbers, and underscores.');
      err.statusCode = 400;
      throw err;
    }

    const existing = await userRepository.findUserByUsername(rawUsername);
    if (existing && existing.id !== userId) {
      const err = new Error(`Username "@${rawUsername}" is already taken. Please choose another.`);
      err.statusCode = 409;
      throw err;
    }

    userFields.username = rawUsername;
  }
  const profileKeys = [
    'age',
    'dietaryPreference',
    'travelStyle',
    'budget',
    'budgetTier',
    'pacePreference',
    'healthConstraints',
    'climateSensitivities',
    'rawPreferenceNotes',
  ];

  for (const key of userKeys) {
    if (data[key] !== undefined) userFields[key] = data[key];
  }
  for (const key of profileKeys) {
    if (data[key] !== undefined) profileFields[key] = data[key];
  }

  // 1. Update User table if any user-level fields were provided
  let updatedUser = null;
  if (Object.keys(userFields).length > 0) {
    updatedUser = await userRepository.updateUser(userId, userFields);
  }

  // 2. Upsert UserProfile table if any preference fields were provided
  let updatedProfile = null;
  if (Object.keys(profileFields).length > 0) {
    updatedProfile = await userRepository.upsertProfile(userId, profileFields);
  }

  // 3. ─── FIRE AND FORGET ─────────────────────────────────────────────────
  //    Trigger AI embedding generation in background WITHOUT awaiting it.
  //    The HTTP response to the client is sent before this resolves.
  if (updatedProfile) {
    triggerEmbeddingGeneration(userId, updatedProfile);
  }

  // Ensure updated user object is always returned
  const finalUser = updatedUser || (await userRepository.findUserById(userId));
  return { user: finalUser, profile: updatedProfile };
};

/**
 * Get a user's full profile.
 * @param {string} userId
 * @returns {Promise<object|null>}
 */
const getProfile = async (userId) => {
  return userRepository.findProfileByUserId(userId);
};

/**
 * Delete a user's account and scrub personal data.
 * Complies with Play Store & GDPR data deletion policies.
 * @param {string} userId
 * @returns {Promise<object>}
 */
const deleteAccount = async (userId) => {
  return userRepository.anonymizeAndDeleteUser(userId);
};

/**
 * Update authenticated user's avatar URL directly.
 * Pass null or empty string to remove avatar.
 * @param {string} userId
 * @param {string|null} avatarUrl
 */
const updateAvatar = async (userId, avatarUrl) => {
  return userRepository.updateUser(userId, { avatarUrl: avatarUrl || null });
};

/**
 * Get ImageKit CDN client-upload authentication parameters.
 */
const getAvatarUploadAuth = () => {
  return imagekitService.getAuthParams();
};

module.exports = {
  updateProfile,
  getProfile,
  deleteAccount,
  updateAvatar,
  getAvatarUploadAuth,
};
