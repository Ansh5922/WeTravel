const prisma = require('./prisma.client');

// Chat repository for messages, polls, and message retention

const PAGE_SIZE = 50;

// Get paginated messages for a trip group
const getMessages = async (groupId, before = null) => {
  return prisma.message.findMany({
    where: {
      groupId,
      ...(before && { createdAt: { lt: new Date(before) } }),
    },
    orderBy: { createdAt: 'desc' },
    take: PAGE_SIZE,
    include: {
      sender: { select: { id: true, fullName: true, username: true } },
    },
  });
};

// Save a new chat message to database
const saveMessage = async ({ groupId, senderId, messageType, content, imageUrl = null, pollId = null }) => {
  return prisma.message.create({
    data: { groupId, senderId, messageType, content, imageUrl, pollId },
    include: {
      sender: { select: { id: true, fullName: true, username: true } },
    },
  });
};

// Create a new poll with options
const createPoll = async ({ groupId, createdBy, question, options }) => {
  return prisma.poll.create({
    data: {
      groupId,
      createdBy,
      question,
      options: {
        create: options.map((text) => ({ optionText: text })),
      },
    },
    include: { options: true, creator: { select: { id: true, fullName: true } } },
  });
};

// Get a poll by ID with options and votes
const getPollById = async (pollId) => {
  return prisma.poll.findUnique({
    where: { id: pollId },
    include: {
      options: { include: { votes: true } },
      votes: true,
      creator: { select: { id: true, fullName: true } },
    },
  });
};

// Get all polls for a trip group
const getPollsByGroup = async (groupId) => {
  return prisma.poll.findMany({
    where: { groupId },
    orderBy: { id: 'desc' },
    include: {
      options: { include: { votes: true } },
      creator: { select: { id: true, fullName: true } },
    },
  });
};

// Record or update a user's vote on a poll
const castVote = async ({ pollId, optionId, userId }) => {
  const existing = await prisma.pollVote.findFirst({ where: { pollId, userId } });
  if (existing) {
    return prisma.pollVote.update({
      where: { id: existing.id },
      data: { optionId },
    });
  }
  return prisma.pollVote.create({ data: { pollId, optionId, userId } });
};

// Close an active poll
const closePoll = async (pollId) => {
  return prisma.poll.update({
    where: { id: pollId },
    data: { status: 'closed' },
    include: {
      options: { include: { votes: true } },
      creator: { select: { id: true, fullName: true } },
    },
  });
};

// Delete a user's vote from a poll
const deletePollUserVote = async (pollId, userId) => {
  return prisma.pollVote.deleteMany({ where: { pollId, userId } });
};

// Delete expired chat messages for non-preserved trips
const deleteExpiredMessages = async () => {
  const now = new Date();
  const expiredGroups = await prisma.tripGroup.findMany({
    where: {
      preserveChat: false,
      chatRetentionDeadline: { lte: now },
    },
    select: { id: true },
  });
  const groupIds = expiredGroups.map((g) => g.id);
  if (!groupIds.length) return 0;
  const result = await prisma.message.deleteMany({ where: { groupId: { in: groupIds } } });
  return result.count;
};

module.exports = {
  getMessages, saveMessage,
  createPoll, getPollById, getPollsByGroup, castVote, closePoll, deletePollUserVote,
  deleteExpiredMessages,
};
