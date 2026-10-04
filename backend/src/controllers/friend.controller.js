const friendService = require('../services/friend.service');

/**
 * Friend Controller
 * Responsibility: HTTP request/response handling for friend endpoints.
 * Architecture layer: Controller
 */

/** POST /api/friends/request */
const sendRequest = async (req, res, next) => {
  try {
    const { username } = req.body;
    if (!username) {
      return res.status(400).json({ status: 'error', message: 'username is required.' });
    }
    const friendship = await friendService.sendFriendRequest(req.user.id, username);
    res.status(201).json({ status: 'success', message: 'Friend request sent.', data: { friendship } });
  } catch (err) { next(err); }
};

/** PATCH /api/friends/request/:friendshipId */
const respondToRequest = async (req, res, next) => {
  try {
    const { friendshipId } = req.params;
    const { action } = req.body;

    if (!['accept', 'reject'].includes(action)) {
      return res.status(400).json({ status: 'error', message: 'action must be "accept" or "reject".' });
    }

    const friendship = await friendService.respondToRequest(req.user.id, friendshipId, action);
    res.status(200).json({ status: 'success', message: `Friend request ${action}ed.`, data: { friendship } });
  } catch (err) { next(err); }
};

/** GET /api/friends */
const getFriends = async (req, res, next) => {
  try {
    const friends = await friendService.getFriends(req.user.id);
    res.status(200).json({ status: 'success', data: { friends } });
  } catch (err) { next(err); }
};

/** GET /api/friends/requests */
const getPendingRequests = async (req, res, next) => {
  try {
    const requests = await friendService.getPendingRequests(req.user.id);
    res.status(200).json({ status: 'success', data: { requests } });
  } catch (err) { next(err); }
};

module.exports = { sendRequest, respondToRequest, getFriends, getPendingRequests };
