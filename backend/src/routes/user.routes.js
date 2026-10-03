const express = require('express');
const userController = require('../controllers/user.controller');
const { protect } = require('../middleware/auth.middleware');

// User profile retrieval and preference update routes
const router = express.Router();
router.use(protect);

// GET /api/users/profile — fetch current user's profile
router.get('/profile', userController.getProfile);

// PATCH /api/users/profile — update profile and trigger background AI embedding
router.patch('/profile', userController.updateProfile);

module.exports = router;
