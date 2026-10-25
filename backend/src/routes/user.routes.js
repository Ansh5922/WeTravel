const express = require('express');
const userController = require('../controllers/user.controller');
const { protect } = require('../middleware/auth.middleware');

/**
 * User Router
 * Architecture layer: Routes (entry point from HTTP)
 *
 * All user profile routes are protected — require valid JWT.
 */
const router = express.Router();

// Apply `protect` middleware to ALL routes in this router
router.use(protect);

// GET  /api/users/profile  — fetch current user's profile
router.get('/profile', userController.getProfile);

// PATCH /api/users/profile — update profile + trigger background AI embedding
router.patch('/profile', userController.updateProfile);

// GET  /api/users/avatar/auth — get ImageKit auth params for direct client upload
router.get('/avatar/auth', userController.getAvatarUploadAuth);

// PATCH /api/users/avatar — update or remove profile photo (optional)
router.patch('/avatar', userController.updateAvatar);

// DELETE /api/users/account — permanently delete account & scrub PII (Play Store / GDPR compliant)
router.delete('/account', userController.deleteAccount);

module.exports = router;
