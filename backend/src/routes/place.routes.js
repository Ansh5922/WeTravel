const express = require('express');
const placeController = require('../controllers/place.controller');
const { protect } = require('../middleware/auth.middleware');

/**
 * Place Router
 * Mount: /api/places
 */
const router = express.Router();

// Allow authenticated users to search destinations
router.use(protect);

router.get('/autocomplete', placeController.autocomplete);

module.exports = router;
