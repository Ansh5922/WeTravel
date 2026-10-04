const tripService = require('../services/trip.service');

/**
 * Trip Controller
 * Responsibility: HTTP request/response handling for trip endpoints.
 * Architecture layer: Controller
 */

/** POST /api/trips */
const createTrip = async (req, res, next) => {
  try {
    const { name, tripStartDate, tripEndDate, coverImageUrl } = req.body;
    if (!name) {
      return res.status(400).json({ status: 'error', message: 'Trip name is required.' });
    }
    const trip = await tripService.createTrip(req.user.id, { name, tripStartDate, tripEndDate, coverImageUrl });
    res.status(201).json({ status: 'success', message: 'Trip created. You are the admin.', data: { trip } });
  } catch (err) { next(err); }
};

/** GET /api/trips  — optional ?status=upcoming|ongoing|completed */
const getMyTrips = async (req, res, next) => {
  try {
    const trips = await tripService.getMyTrips(req.user.id, req.query.status);
    res.status(200).json({ status: 'success', data: { trips } });
  } catch (err) { next(err); }
};

/** GET /api/trips/:tripId */
const getTripDetails = async (req, res, next) => {
  try {
    const trip = await tripService.getTripDetails(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: { trip } });
  } catch (err) { next(err); }
};

/** POST /api/trips/:tripId/invite */
const inviteMember = async (req, res, next) => {
  try {
    const { type, friendId, email, phone } = req.body;

    if (!['friend', 'email', 'whatsapp', 'link'].includes(type)) {
      return res.status(400).json({
        status: 'error',
        message: 'type must be one of: friend, email, whatsapp, link',
      });
    }

    const invite = await tripService.inviteMember(req.user.id, req.params.tripId, { type, friendId, email, phone });

    // Build the shareable join URL (frontend deep link)
    const joinUrl = `${process.env.APP_BASE_URL || 'https://wetravel.app'}/trips/join/${invite.inviteToken}`;

    res.status(201).json({
      status: 'success',
      message: type === 'friend'
        ? 'Invite sent to your friend directly.'
        : `Share this link via ${type}: ${joinUrl}`,
      data: { invite, joinUrl },
    });
  } catch (err) { next(err); }
};

/** POST /api/trips/join/:token */
const joinViaToken = async (req, res, next) => {
  try {
    const result = await tripService.joinViaToken(req.user.id, req.params.token);
    res.status(200).json({ status: 'success', message: `You have joined "${result.trip.name}"!`, data: result });
  } catch (err) { next(err); }
};

/** PATCH /api/trips/invites/:inviteId */
const respondToInvite = async (req, res, next) => {
  try {
    const { action } = req.body;
    if (!['accept', 'reject'].includes(action)) {
      return res.status(400).json({ status: 'error', message: 'action must be "accept" or "reject".' });
    }
    const result = await tripService.respondToInvite(req.user.id, req.params.inviteId, action);
    res.status(200).json({ status: 'success', ...result });
  } catch (err) { next(err); }
};

/** GET /api/trips/:tripId/invites */
const getTripInvites = async (req, res, next) => {
  try {
    const invites = await tripService.getTripInvites(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: { invites } });
  } catch (err) { next(err); }
};

/** GET /api/trips/invites/me */
const getMyInvites = async (req, res, next) => {
  try {
    const invites = await tripService.getMyInvites(req.user.id);
    res.status(200).json({ status: 'success', data: { invites } });
  } catch (err) { next(err); }
};

/** GET /api/trips/:tripId/consensus */
const getConsensus = async (req, res, next) => {
  try {
    const consensus = await tripService.getConsensus(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: { consensus } });
  } catch (err) { next(err); }
};

/** PATCH /api/trips/:tripId/consensus  — admin only */
const updateConsensus = async (req, res, next) => {
  try {
    const { computedBudgetRange, hardConstraints } = req.body;
    const consensus = await tripService.updateConsensus(req.user.id, req.params.tripId, {
      computedBudgetRange,
      hardConstraints,
    });
    res.status(200).json({ status: 'success', message: 'Group preference updated.', data: { consensus } });
  } catch (err) { next(err); }
};

/** PATCH /api/trips/:tripId/members/:targetUserId/role  — admin only */
const assignRole = async (req, res, next) => {
  try {
    const { role } = req.body;
    if (!['admin', 'member'].includes(role)) {
      return res.status(400).json({ status: 'error', message: 'role must be "admin" or "member".' });
    }
    const result = await tripService.assignRole(
      req.user.id,
      req.params.tripId,
      req.params.targetUserId,
      role,
    );
    res.status(200).json({ status: 'success', ...result });
  } catch (err) { next(err); }
};

module.exports = { createTrip, getMyTrips, getTripDetails, inviteMember, joinViaToken, respondToInvite, getTripInvites, getMyInvites, getConsensus, updateConsensus, assignRole };
