const userService = require('../services/user.service');

// User profile controller handling profile views and preference updates

// PATCH /api/users/profile — update profile and trigger background AI embedding
const updateProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const {
      fullName,
      phone,
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
      fullName, phone, dietaryPreference, travelStyle,
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
      fullName,
      phone,
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

// GET /api/users/profile — get authenticated user's current profile and preferences
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
