const express = require('express');
const authController = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth.middleware');

/**
 * Auth Router
 * Architecture layer: Routes (entry point from HTTP, maps to controllers)
 *
 * Public routes  — no token required
 * Protected routes — require valid JWT via `protect` middleware
 */
const router = express.Router();

// ── Public ────────────────────────────────────────────────────────────────────
router.post('/signup', authController.signup);
router.post('/login', authController.login);

// ── Protected ─────────────────────────────────────────────────────────────────
router.get('/me', protect, authController.getMe);

module.exports = router;
