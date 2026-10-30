const userService = require('../services/user.service');

/**
 * User Controller
 * Responsibility: HTTP request/response handling for user profile endpoints.
 * Architecture layer: Controller (between Routes ↔ Service)
 *
 * Rules:
 *  - Extract and validate input from req.body
 *  - Call service methods
 *  - Send HTTP response
 *  - NEVER contain business logic
 */

/**
 * PATCH /api/users/profile
 * Update authenticated user's profile and preferences.
 * Returns immediately after DB save. AI embedding runs in background.
 */
const updateProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const {
      username,
      fullName,
      phone,
      avatarUrl,
      dietaryPreference,
      travelStyle,
      budget,
      dailyBudget,
      budgetAmount,
      budgetTier,
      pacePreference,
      healthConstraints,
      climateSensitivities,
      rawPreferenceNotes,
    } = req.body;

    // Extract single numerical value for user's budget preference
    const rawBudget = budget !== undefined ? budget : (dailyBudget !== undefined ? dailyBudget : budgetAmount);
    const parsedBudget = rawBudget !== undefined && rawBudget !== null ? parseFloat(rawBudget) : undefined;

    // Ensure at least one field is being updated
    const hasPayload = [
      username, fullName, phone, avatarUrl, dietaryPreference, travelStyle,
      parsedBudget, budgetTier, pacePreference, healthConstraints,
      climateSensitivities, rawPreferenceNotes,
    ].some((v) => v !== undefined && !Number.isNaN(v));

    if (!hasPayload) {
      return res.status(400).json({
        status: 'error',
        message: 'No fields provided to update.',
      });
    }

    const { user, profile } = await userService.updateProfile(userId, {
      username: username !== undefined ? (username ? username.trim() : '') : undefined,
      fullName,
      phone,
      avatarUrl: avatarUrl !== undefined ? (avatarUrl ? avatarUrl.trim() : null) : undefined,
      dietaryPreference,
      travelStyle,
      budget: parsedBudget,
      budgetTier,
      pacePreference,
      healthConstraints,
      climateSensitivities,
      rawPreferenceNotes,
    });

    res.status(200).json({
      status: 'success',
      message: 'Profile updated. Preference embeddings are being generated in the background.',
      data: {
        ...(user && { user }),
        ...(profile && { profile }),
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/users/profile
 * Get authenticated user's current profile and preferences.
 */
const getProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const profile = await userService.getProfile(userId);

    res.status(200).json({
      status: 'success',
      data: {
        user: req.user,
        profile: profile || {},
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * PATCH /api/users/avatar
 * Update or remove authenticated user's profile photo.
 */
const updateAvatar = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { avatarUrl } = req.body;

    if (avatarUrl !== undefined && avatarUrl !== null && typeof avatarUrl !== 'string') {
      return res.status(400).json({
        status: 'error',
        message: 'avatarUrl must be a valid URL string or null.',
      });
    }

    const user = await userService.updateAvatar(userId, avatarUrl ? avatarUrl.trim() : null);

    res.status(200).json({
      status: 'success',
      message: user.avatarUrl ? 'Profile photo updated successfully.' : 'Profile photo removed.',
      data: { user },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/users/avatar/auth
 * Get ImageKit CDN client-upload authentication parameters for direct photo upload.
 */
const getAvatarUploadAuth = (req, res, next) => {
  try {
    const authParams = userService.getAvatarUploadAuth();
    res.status(200).json({
      status: 'success',
      data: authParams,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /api/users/account
 * Delete authenticated user's account and scrub personal data.
 * Returns confirmation of successful anonymization/deletion.
 */
const deleteAccount = async (req, res, next) => {
  try {
    const userId = req.user.id;
    await userService.deleteAccount(userId);

    res.status(200).json({
      status: 'success',
      message: 'Account deleted successfully and personal data anonymized.',
    });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/users/request-deletion
 * Public web form endpoint for requesting account and data deletion (Play Store web requirement).
 */
const requestDeletion = async (req, res, next) => {
  try {
    const { email, reason } = req.body;
    if (!email || !email.includes('@')) {
      return res.status(400).json({
        status: 'error',
        message: 'A valid email address is required.',
      });
    }

    console.log(`📋 [Data Deletion Request] Email: ${email.trim().toLowerCase()} | Reason: ${reason || 'Not specified'}`);

    // Always return safe success message to prevent email enumeration
    res.status(200).json({
      status: 'success',
      message: 'Deletion request received. If an account is associated with this email, our data team will verify and process the erasure within 14–30 business days.',
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  updateProfile,
  getProfile,
  updateAvatar,
  getAvatarUploadAuth,
  deleteAccount,
  requestDeletion,
};
