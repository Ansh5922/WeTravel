const placeService = require('../services/place.service');

/**
 * Place Controller
 * Responsibility: HTTP request/response handling for destination search & autocomplete.
 * Architecture layer: Controller
 */

/**
 * GET /api/places/autocomplete?query=...&limit=...
 */
const autocomplete = async (req, res, next) => {
  try {
    const { query, limit } = req.query;

    if (!query || typeof query !== 'string' || query.trim().length < 2) {
      return res.status(200).json({
        status: 'success',
        data: { places: [] },
      });
    }

    const parsedLimit = Math.min(Math.max(parseInt(limit, 10) || 6, 1), 15);
    const places = await placeService.autocompletePlaces(query, parsedLimit);

    res.status(200).json({
      status: 'success',
      data: { places },
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  autocomplete,
};
