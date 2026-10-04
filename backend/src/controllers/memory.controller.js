const memoryService = require('../services/memory.service');

/**
 * Memory Controller — WeTravel Backend
 * Layer: Controller (orchestrator between HTTP & Service)
 */

/** GET /api/trips/:tripId/memories/imagekit-auth */
const getImageKitAuth = async (req, res, next) => {
  try {
    const auth = await memoryService.getImageKitAuth(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: auth });
  } catch (err) {
    next(err);
  }
};

/** POST /api/trips/:tripId/memories */
const uploadMemories = async (req, res, next) => {
  try {
    const { photos } = req.body;
    // Support single photo or photos array
    const photosArray = Array.isArray(photos) ? photos : (req.body.mediaUrl ? [req.body] : []);
    
    if (photosArray.length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Provide "photos" array or "mediaUrl" in request body.',
      });
    }

    const created = await memoryService.uploadMemories(req.user.id, req.params.tripId, photosArray);
    res.status(201).json({
      status: 'success',
      message: `${created.length} photo(s) added to the Memory Vault.`,
      data: { memories: created },
    });
  } catch (err) {
    next(err);
  }
};

/** GET /api/trips/:tripId/memories */
const getMemoriesTimeline = async (req, res, next) => {
  try {
    const result = await memoryService.getMemoriesTimeline(req.user.id, req.params.tripId);
    res.status(200).json({
      status: 'success',
      data: result,
    });
  } catch (err) {
    next(err);
  }
};

/** GET /api/trips/:tripId/memories/highlights */
const getHighlights = async (req, res, next) => {
  try {
    const highlights = await memoryService.getHighlights(req.user.id, req.params.tripId);
    res.status(200).json({
      status: 'success',
      data: { highlights },
    });
  } catch (err) {
    next(err);
  }
};

/** PATCH /api/trips/:tripId/memories/:memoryId/highlight */
const toggleHighlight = async (req, res, next) => {
  try {
    const { isHighlight } = req.body;
    const memory = await memoryService.toggleHighlight(
      req.user.id,
      req.params.tripId,
      req.params.memoryId,
      isHighlight
    );
    res.status(200).json({
      status: 'success',
      message: memory.aiHighlight ? 'Marked as highlight.' : 'Removed from highlights.',
      data: { memory },
    });
  } catch (err) {
    next(err);
  }
};

/** DELETE /api/trips/:tripId/memories/:memoryId */
const deleteMemory = async (req, res, next) => {
  try {
    const result = await memoryService.deleteMemory(
      req.user.id,
      req.params.tripId,
      req.params.memoryId
    );
    res.status(200).json({
      status: 'success',
      message: result.message,
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getImageKitAuth,
  uploadMemories,
  getMemoriesTimeline,
  getHighlights,
  toggleHighlight,
  deleteMemory,
};
