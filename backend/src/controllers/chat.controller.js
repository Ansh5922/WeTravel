const chatService = require('../services/chat.service');

/**
 * Chat Controller — WeTravel Backend
 * Layer: Controller (HTTP request/response for REST chat APIs)
 */

/** GET /api/trips/:tripId/chat/messages */
const getMessages = async (req, res, next) => {
  try {
    const messages = await chatService.getMessages(req.user.id, req.params.tripId, req.query.before);
    res.status(200).json({ status: 'success', data: { messages } });
  } catch (err) { next(err); }
};

/** GET /api/trips/:tripId/chat/imagekit-auth */
const getImageKitAuth = async (req, res, next) => {
  try {
    const auth = await chatService.getImageKitAuth(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: auth });
  } catch (err) { next(err); }
};

/** POST /api/trips/:tripId/chat/image */
const confirmImageMessage = async (req, res, next) => {
  try {
    const { imageUrl, fileName } = req.body;
    if (!imageUrl) return res.status(400).json({ status: 'error', message: 'imageUrl is required.' });
    const message = await chatService.saveImageMessage(req.params.tripId, req.user.id, imageUrl, fileName);
    res.status(201).json({ status: 'success', data: { message } });
  } catch (err) { next(err); }
};

/** POST /api/trips/:tripId/chat/polls */
const createPoll = async (req, res, next) => {
  try {
    const { question, options } = req.body;
    const poll = await chatService.createPoll(req.user.id, req.params.tripId, { question, options });
    res.status(201).json({ status: 'success', message: 'Poll created.', data: { poll } });
  } catch (err) { next(err); }
};

/** POST /api/trips/:tripId/chat/polls/:pollId/vote */
const castVote = async (req, res, next) => {
  try {
    const { optionId } = req.body;
    if (!optionId) return res.status(400).json({ status: 'error', message: 'optionId is required.' });
    const vote = await chatService.voteOnPoll(req.user.id, req.params.tripId, req.params.pollId, optionId);
    res.status(200).json({ status: 'success', message: 'Vote recorded.', data: { vote } });
  } catch (err) { next(err); }
};

/** PATCH /api/trips/:tripId/chat/polls/:pollId/close */
const closePoll = async (req, res, next) => {
  try {
    const poll = await chatService.closePoll(req.user.id, req.params.tripId, req.params.pollId);
    res.status(200).json({ status: 'success', message: 'Poll closed. Results sent to AI for preference update.', data: { poll } });
  } catch (err) { next(err); }
};

/** GET /api/trips/:tripId/chat/polls */
const getPolls = async (req, res, next) => {
  try {
    const polls = await chatService.getPolls(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: { polls } });
  } catch (err) { next(err); }
};

module.exports = { getMessages, getImageKitAuth, confirmImageMessage, createPoll, castVote, closePoll, getPolls };
