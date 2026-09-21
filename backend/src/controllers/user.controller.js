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
      fullName,
      phone,
      dietaryPreference,
      travelStyle,
      budgetTier,
      pacePreference,
      healthConstraints,
      climateSensitivities,
      rawPreferenceNotes,
    } = req.body;

    // Ensure at least one field is being updated
    const hasPayload = [
      fullName, phone, dietaryPreference, travelStyle,
      budgetTier, pacePreference, healthConstraints,
      climateSensitivities, rawPreferenceNotes,
    ].some((v) => v !== undefined);

    if (!hasPayload) {
      return res.status(400).json({
        status: 'error',
        message: 'No fields provided to update.',
      });
    }

    const { user, profile } = await userService.updateProfile(userId, {
      fullName,
      phone,
      dietaryPreference,
      travelStyle,
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
      data: { profile: profile || {} },
    });
  } catch (err) {
    next(err);
  }
};

module.exports = { updateProfile, getProfile };
