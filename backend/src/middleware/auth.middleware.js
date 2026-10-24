const jwt = require('jsonwebtoken');
const authRepository = require('../repositories/auth.repository');

/**
 * Auth Middleware — `protect`
 * Responsibility: Gate-keep routes that require an authenticated user.
 * Architecture layer: Middleware (sits between Routes and Controllers)
 *
 * Flow:
 *  1. Extract Bearer token from Authorization header
 *  2. Verify signature using JWT_SECRET
 *  3. Lookup user in DB to confirm they still exist
 *  4. Attach user object to req.user and call next()
 */
const protect = async (req, res, next) => {
  try {
    // 1. Extract token
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        status: 'error',
        message: 'Authentication required. Please provide a Bearer token.',
      });
    }

    const token = authHeader.split(' ')[1];

    // 2. Verify signature & decode
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (jwtErr) {
      const message =
        jwtErr.name === 'TokenExpiredError'
          ? 'Your session has expired. Please log in again.'
          : 'Invalid token. Please log in again.';
      return res.status(401).json({ status: 'error', message });
    }

    // 3. Confirm user still exists and is not deleted in DB
    const user = await authRepository.findUserById(decoded.sub);
    if (!user || user.fullName === 'Deleted User' || (user.email && user.email.endsWith('@deleted.wetravel.internal'))) {
      return res.status(401).json({
        status: 'error',
        message: 'This account has been deleted or no longer exists.',
      });
    }

    // 4. Attach user to request object — available in all subsequent middleware/controllers
    req.user = user;
    next();
  } catch (err) {
    next(err);
  }
};

module.exports = { protect };
