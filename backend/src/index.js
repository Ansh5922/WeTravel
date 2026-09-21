require('dotenv').config();

const express = require('express');
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const { errorHandler } = require('./middleware/error.middleware');

const app = express();
const PORT = process.env.PORT || 3000;

// ── Global Middleware ─────────────────────────────────────────────────────────
app.use(express.json());               // Parse JSON request bodies
app.use(express.urlencoded({ extended: true }));

// ── Health Check ──────────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'WeTravel Backend', timestamp: new Date().toISOString() });
});

// ── Routes ────────────────────────────────────────────────────────────────────
// Architecture: Client → Routes → Middleware → Controllers → Services → Repositories → DB
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

// ── 404 Handler ───────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ status: 'error', message: `Route ${req.method} ${req.path} not found.` });
});

// ── Global Error Handler (must be last!) ──────────────────────────────────────
app.use(errorHandler);

// ── Start Server ──────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`✅  WeTravel Backend running on http://localhost:${PORT}`);
  console.log(`📦  Environment: ${process.env.NODE_ENV}`);
});

