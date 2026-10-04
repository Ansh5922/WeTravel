const authService = require('../services/auth.service');

/**
 * Auth Controller
 * Responsibility: HTTP request/response handling only.
 * Architecture layer: Controller (sits between Routes and Services)
 *
 * Rules:
 *  - Validate/extract input from req.body
 *  - Call service
 *  - Send HTTP response
 *  - NEVER contain business logic
 */

/**
 * POST /api/auth/signup
 */
const signup = async (req, res, next) => {
  try {
    const { email, password, username, fullName, phone } = req.body;

    // Basic input validation
    if (!email || !password || !username) {
      return res.status(400).json({
        status: 'error',
        message: 'Email, password, and username are required.',
      });
    }

    if (password.length < 8) {
      return res.status(400).json({
        status: 'error',
        message: 'Password must be at least 8 characters long.',
      });
    }

    if (!/^[a-zA-Z0-9_]{3,50}$/.test(username)) {
      return res.status(400).json({
        status: 'error',
        message: 'Username must be 3-50 characters and can only contain letters, numbers, and underscores.',
      });
    }

    const { user, token } = await authService.signup({ email, password, username, fullName, phone });

    res.status(201).json({
      status: 'success',
      message: 'Account created successfully.',
      data: { user, token },
    });
  } catch (err) {
    next(err); // Forward to global error handler
  }
};

/**
 * POST /api/auth/login
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Email and password are required.',
      });
    }

    const { user, token } = await authService.login({ email, password });

    res.status(200).json({
      status: 'success',
      message: 'Logged in successfully.',
      data: { user, token },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/auth/me  — protected route, requires valid JWT
 */
const getMe = async (req, res, next) => {
  try {
    // req.user is set by the protect middleware
    const user = await authService.getMe(req.user.id);

    res.status(200).json({
      status: 'success',
      data: { user },
    });
  } catch (err) {
    next(err);
  }
};

module.exports = { signup, login, getMe };
