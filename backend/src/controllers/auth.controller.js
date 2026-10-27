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
    if (!email || !password || !username || !fullName) {
      return res.status(400).json({
        status: 'error',
        message: 'Full name, email, password, and username are required.',
      });
    }

    const trimmedFullName = typeof fullName === 'string' ? fullName.trim() : '';
    if (trimmedFullName.length < 2 || trimmedFullName.length > 100) {
      return res.status(400).json({
        status: 'error',
        message: 'Full name must be between 2 and 100 characters.',
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

    const { user, token } = await authService.signup({
      email,
      password,
      username,
      fullName: trimmedFullName,
      phone,
    });

    res.status(201).json({
      status: 'success',
      message: 'Account created successfully.',
      data: {
        user,
        token,
        isNewUser: true,
        isFirstTimeUser: true,
      },
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
      data: {
        user,
        token,
        isNewUser: false,
        isFirstTimeUser: false,
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/auth/google
 */
const googleLogin = async (req, res, next) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({
        status: 'error',
        message: 'Google idToken is required.',
      });
    }

    const { user, token, isNewUser, isFirstTimeUser } = await authService.googleLogin(idToken);

    res.status(200).json({
      status: 'success',
      message: 'Logged in with Google successfully.',
      data: {
        user,
        token,
        isNewUser: Boolean(isNewUser),
        isFirstTimeUser: Boolean(isFirstTimeUser),
      },
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

/**
 * POST /api/auth/forgot-password
 */
const forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email || typeof email !== 'string' || !email.includes('@')) {
      return res.status(400).json({
        status: 'error',
        message: 'A valid email address is required.',
      });
    }

    const result = await authService.forgotPassword(email);

    res.status(200).json({
      status: 'success',
      message: result.message,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/auth/reset-password
 */
const resetPassword = async (req, res, next) => {
  try {
    const { email, otp, token, newPassword, password } = req.body;

    const result = await authService.resetPassword({
      email,
      otp,
      token,
      newPassword,
      password,
    });

    res.status(200).json({
      status: 'success',
      message: result.message,
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  signup,
  login,
  googleLogin,
  getMe,
  forgotPassword,
  resetPassword,
};
