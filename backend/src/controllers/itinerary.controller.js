const itineraryService = require('../services/itinerary.service');

/**
 * Itinerary Controller — WeTravel Backend
 * Layer: Controller
 */

/** POST /api/trips/:tripId/itinerary/generate */
const generateItineraries = async (req, res, next) => {
  try {
    const { origin, destination, startDate, endDate, memberCount, constraints } = req.body;
    const itineraries = await itineraryService.generateItineraries(req.user.id, req.params.tripId, {
      origin, destination, startDate, endDate, memberCount, constraints,
    });
    res.status(201).json({
      status: 'success',
      message: `${itineraries.length} itinerary variants generated successfully.`,
      data: { itineraries },
    });
  } catch (err) { next(err); }
};

/** GET /api/trips/:tripId/itineraries */
const getItineraries = async (req, res, next) => {
  try {
    const itineraries = await itineraryService.getItineraries(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: { itineraries } });
  } catch (err) { next(err); }
};

/** GET /api/trips/:tripId/itineraries/:id */
const getItinerary = async (req, res, next) => {
  try {
    const itinerary = await itineraryService.getItineraryById(req.user.id, req.params.tripId, req.params.id);
    res.status(200).json({ status: 'success', data: { itinerary } });
  } catch (err) { next(err); }
};

/** PATCH /api/trips/:tripId/itineraries/:id/select */
const selectItinerary = async (req, res, next) => {
  try {
    const itinerary = await itineraryService.selectItinerary(req.user.id, req.params.tripId, req.params.id);
    res.status(200).json({ status: 'success', message: 'Itinerary selected.', data: { itinerary } });
  } catch (err) { next(err); }
};

/** POST /api/trips/:tripId/itineraries/:id/suggest */
const suggestChanges = async (req, res, next) => {
  try {
    const { origin, destination, startDate, endDate, memberCount, constraints } = req.body;
    const itineraries = await itineraryService.suggestChanges(req.user.id, req.params.tripId, req.params.id, {
      origin, destination, startDate, endDate, memberCount, constraints,
    });
    res.status(201).json({ status: 'success', message: 'New itineraries generated with your changes.', data: { itineraries } });
  } catch (err) { next(err); }
};

/** POST /api/trips/:tripId/itineraries/mishap */
const recoverFromMishap = async (req, res, next) => {
  try {
    const { itineraryId, missedItemId, currentTime } = req.body;
    if (!itineraryId || !missedItemId || !currentTime) {
      return res.status(400).json({ status: 'error', message: 'itineraryId, missedItemId, and currentTime are required.' });
    }
    const recovery = await itineraryService.recoverFromMishap(req.user.id, req.params.tripId, {
      itineraryId, missedItemId, currentTime,
    });
    res.status(201).json({ status: 'success', message: 'Recovery itinerary generated.', data: { itinerary: recovery } });
  } catch (err) { next(err); }
};

module.exports = { generateItineraries, getItineraries, getItinerary, selectItinerary, suggestChanges, recoverFromMishap };
