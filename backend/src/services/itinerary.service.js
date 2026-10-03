const axios = require('axios');
const jwt   = require('jsonwebtoken');
const prisma = require('../repositories/prisma.client');
const itineraryRepo = require('../repositories/itinerary.repository');

// Itinerary service orchestrating AI generation, selection, and mishap recovery

const AI_URL = () => process.env.AI_SERVICE_URL || 'http://localhost:8000';

const makeInternalToken = () =>
  jwt.sign({ sub: 'internal-service' }, process.env.JWT_SECRET, { expiresIn: '5m' });

const getAdminMember = async (userId, groupId) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });
  if (member.role === 'member') throw Object.assign(new Error('Only the trip admin can perform this action.'), { statusCode: 403 });
  return member;
};

// Generate itinerary variants by calling FastAPI AI engine and persisting results
const generateItineraries = async (userId, tripId, { origin, destination, startDate, endDate, memberCount, constraints = {} }) => {
  await getAdminMember(userId, tripId);

  if (!origin || !destination || !startDate || !endDate) {
    throw Object.assign(new Error('origin, destination, startDate, and endDate are required.'), { statusCode: 400 });
  }

  // Fetch group consensus for budget/pace from DB
  const consensus = await prisma.groupConsensusProfile.findUnique({ where: { groupId: tripId } });
  const groupStats = consensus?.groupStats || {};

  const token = makeInternalToken();
  try {
    const { data } = await axios.post(
      `${AI_URL()}/api/ai/itinerary/generate`,
      {
        group_id: tripId,
        origin,
        destination,
        start_date: startDate,
        end_date: endDate,
        member_count: memberCount || 2,
        group_stats: groupStats,
        constraints,
      },
      { headers: { Authorization: `Bearer ${token}` }, timeout: 120000 },
    );
    // Persist all variant itineraries to DB
    const saved = await itineraryRepo.saveItineraries(tripId, data.itineraries);
    return saved;
  } catch (err) {
    if (err.response) {
      console.error('❌ [AI Service Error Response]:', err.response.data);
      throw Object.assign(new Error(err.response.data.detail || JSON.stringify(err.response.data)), { statusCode: err.response.status || 500 });
    }
    throw err;
  }
};

// List all itineraries for a trip
const getItineraries = async (userId, tripId) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });
  return itineraryRepo.getItinerariesByGroup(tripId);
};

// Get single itinerary detail
const getItineraryById = async (userId, tripId, itineraryId) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId: tripId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });
  const itin = await itineraryRepo.getItineraryById(itineraryId);
  if (!itin || itin.groupId !== tripId) throw Object.assign(new Error('Itinerary not found.'), { statusCode: 404 });
  return itin;
};

// Admin selects an itinerary as the official trip plan
const selectItinerary = async (userId, tripId, itineraryId) => {
  await getAdminMember(userId, tripId);
  const itin = await itineraryRepo.getItineraryById(itineraryId);
  if (!itin || itin.groupId !== tripId) throw Object.assign(new Error('Itinerary not found.'), { statusCode: 404 });
  return itineraryRepo.selectItinerary(itineraryId, tripId);
};

// Admin suggests changes and triggers itinerary re-generation
const suggestChanges = async (userId, tripId, itineraryId, { origin, destination, startDate, endDate, memberCount, constraints }) => {
  await getAdminMember(userId, tripId);
  return generateItineraries(userId, tripId, { origin, destination, startDate, endDate, memberCount, constraints });
};

// Dynamically recover and re-schedule trip itinerary upon a missed event
const recoverFromMishap = async (userId, tripId, { itineraryId, missedItemId, currentTime }) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId: tripId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });

  const itin = await itineraryRepo.getItineraryById(itineraryId);
  if (!itin || itin.groupId !== tripId) throw Object.assign(new Error('Itinerary not found.'), { statusCode: 404 });

  // Mark item as missed in DB
  await itineraryRepo.markItemMissed(missedItemId);

  const token = makeInternalToken();
  const { data } = await axios.post(
    `${AI_URL()}/api/ai/itinerary/recover`,
    {
      group_id: tripId,
      itinerary: itin,
      missed_item_id: missedItemId,
      current_time: currentTime,
    },
    { headers: { Authorization: `Bearer ${token}` }, timeout: 60000 },
  );

  // Save recovery itinerary
  const saved = await itineraryRepo.saveItineraries(tripId, [data.itinerary]);
  return saved[0];
};

module.exports = { generateItineraries, getItineraries, getItineraryById, selectItinerary, suggestChanges, recoverFromMishap };
