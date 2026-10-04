const express = require('express');
const itineraryController = require('../controllers/itinerary.controller');
const { protect } = require('../middleware/auth.middleware');

/**
 * Itinerary Routes — WeTravel Backend
 * Layer: Routes
 */

const router = express.Router();
router.use(protect);

// Generate all variants (admin only — enforced in service)
router.post('/:tripId/itinerary/generate', itineraryController.generateItineraries);

// List all itineraries for the trip
router.get('/:tripId/itineraries', itineraryController.getItineraries);

// Get full day-by-day detail of one itinerary
router.get('/:tripId/itineraries/:id', itineraryController.getItinerary);

// Admin selects an itinerary
router.patch('/:tripId/itineraries/:id/select', itineraryController.selectItinerary);

// Admin requests re-generation with custom constraints
router.post('/:tripId/itineraries/:id/suggest', itineraryController.suggestChanges);

// Any member flags a missed event → triggers recovery
router.post('/:tripId/itineraries/mishap', itineraryController.recoverFromMishap);

module.exports = router;
