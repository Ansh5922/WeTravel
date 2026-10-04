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

module.exports = router;
