const prisma = require('./prisma.client');

/**
 * Itinerary Repository — WeTravel Backend
 * Layer: Repository → DB
 */

const saveItineraries = async (groupId, itineraries) => {
  const saved = [];
  for (const itin of itineraries) {
    const created = await prisma.itinerary.create({
      data: {
        groupId,
        generatedBy: 'ai',
        variantType: itin.variantType,
        version: itin.version || 1,
        summary: itin.summary,
        totalCostPerPerson: itin.totalCostPerPerson,
        constraints: itin.constraints || {},
        items: {
          create: itin.days.flatMap((day) =>
            day.items.map((item) => ({
              dayNumber: day.dayNumber,
              timeSlot: item.startTime || item.timeSlot || '09:00',
              startTime: item.startTime || null,
              endTime: item.endTime || null,
              activityName: item.activityName,
              description: item.description || null,
              location: item.location || null,
              transitMode: item.transitMode || null,
              estimatedCost: item.estimatedCost || 0,
              bookingRef: item.bookingRef || null,
              apiSource: item.apiSource || null,
              rawApiData: item.rawApiData || null,
            })),
          ),
        },
      },
      include: { items: true },
    });
    saved.push(created);
  }
  return saved;
};

const getItinerariesByGroup = async (groupId) => {
  return prisma.itinerary.findMany({
    where: { groupId, isActive: true },
    orderBy: { createdAt: 'desc' },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
};

const getItineraryById = async (itineraryId) => {
  return prisma.itinerary.findUnique({
    where: { id: itineraryId },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
};

const selectItinerary = async (itineraryId, groupId) => {
  // Deselect all others for the group, then select this one
  await prisma.itinerary.updateMany({
    where: { groupId, isSelected: true },
    data: { isSelected: false, selectedAt: null },
  });
  return prisma.itinerary.update({
    where: { id: itineraryId },
    data: { isSelected: true, selectedAt: new Date() },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
};

const getSelectedItinerary = async (groupId) => {
  return prisma.itinerary.findFirst({
    where: { groupId, isSelected: true },
    include: { items: { orderBy: [{ dayNumber: 'asc' }, { startTime: 'asc' }] } },
  });
};

const markItemMissed = async (itemId) => {
  return prisma.itineraryItem.update({
    where: { id: itemId },
    data: { isMissed: true },
  });
};

module.exports = {
  saveItineraries, getItinerariesByGroup, getItineraryById,
  selectItinerary, getSelectedItinerary, markItemMissed,
};
