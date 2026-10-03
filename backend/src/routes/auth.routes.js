const express = require('express');
const authController = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth.middleware');

// Authentication routes for signup, login, and user profile verification
const router = express.Router();

// Public authentication routes
router.post('/signup', authController.signup);
router.post('/login', authController.login);

// Protected user identity route
router.get('/me', protect, authController.getMe);

module.exports = router;
