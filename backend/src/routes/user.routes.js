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

// ── Public routes (no JWT required) ──────────────────────────────────────────
// POST /api/users/request-deletion — Public web deletion request (Play Store compliant)
router.post('/request-deletion', userController.requestDeletion);

// ── Protected routes (require valid JWT) ─────────────────────────────────────
// Apply `protect` middleware to subsequent routes in this router
router.use(protect);

// GET  /api/users/profile  — fetch current user's profile
router.get('/profile', userController.getProfile);

// PATCH /api/users/profile — update profile + trigger background AI embedding
router.patch('/profile', userController.updateProfile);

// DELETE /api/users/account — permanently delete account & scrub PII (Play Store / GDPR compliant)
router.delete('/account', userController.deleteAccount);

module.exports = router;
