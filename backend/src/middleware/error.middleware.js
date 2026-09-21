/**
 * Global Error Handler Middleware
 * Architecture layer: Middleware (terminal — catches all errors forwarded via next(err))
 *
 * All controllers forward errors using next(err).
 * This handler decides the HTTP response shape centrally.
 */
const errorHandler = (err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || 'An unexpected server error occurred.';

  if (process.env.NODE_ENV === 'development') {
    console.error(`[ERROR] ${req.method} ${req.path} →`, err);
  }

  res.status(statusCode).json({
    status: 'error',
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = { errorHandler };
