const prisma = require('../repositories/prisma.client');
const chatRepo = require('../repositories/chat.repository');
const imagekitService = require('./imagekit.service');
const axios = require('axios');

/**
 * Chat Service — WeTravel Backend
 * Layer: Service (business logic for chat, polls, images, retention)
 */

// ── Messages ────────────────────────────────────────────────────────────────

const getMessages = async (userId, groupId, before) => {
  // Verify user is a member of the group
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });

  const messages = await chatRepo.getMessages(groupId, before);
  return messages.reverse(); // Return oldest-first for the client
};

const saveTextMessage = async (groupId, senderId, content) => {
  if (!content || !content.trim()) throw Object.assign(new Error('Message content cannot be empty.'), { statusCode: 400 });
  return chatRepo.saveMessage({ groupId, senderId, messageType: 'text', content: content.trim() });
};

const saveImageMessage = async (groupId, senderId, imageUrl, fileName) => {
  if (!imageUrl) throw Object.assign(new Error('imageUrl is required.'), { statusCode: 400 });
  return chatRepo.saveMessage({
    groupId,
    senderId,
    messageType: 'image',
    content: fileName || 'Image',
    imageUrl,
  });
};

// ── ImageKit Auth ────────────────────────────────────────────────────────────

const getImageKitAuth = async (userId, groupId) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });
  return imagekitService.getAuthParams();
};

// ── Polls ────────────────────────────────────────────────────────────────────

const createPoll = async (userId, groupId, { question, options, isAnonymous = false }) => {
  if (!question || !question.trim()) throw Object.assign(new Error('Poll question is required.'), { statusCode: 400 });
  if (!options || options.length < 2) throw Object.assign(new Error('At least 2 options are required.'), { statusCode: 400 });

  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });

  return chatRepo.createPoll({
    groupId,
    createdBy: userId,
    question: question.trim(),
    options,
    isAnonymous: Boolean(isAnonymous),
  });
};

const updatePoll = async (userId, groupId, pollId, { question, options }) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });

  const poll = await chatRepo.getPollById(pollId);
  if (!poll) throw Object.assign(new Error('Poll not found.'), { statusCode: 404 });
  if (poll.groupId !== groupId) throw Object.assign(new Error('Poll does not belong to this trip.'), { statusCode: 403 });
  if (poll.status === 'closed') throw Object.assign(new Error('Closed polls cannot be edited.'), { statusCode: 400 });

  const isAdmin = member.role === 'admin' || member.role === 'creator';
  if (poll.createdBy !== userId && !isAdmin) {
    throw Object.assign(new Error('Only the poll creator or a group admin can edit this poll.'), { statusCode: 403 });
  }

  return chatRepo.updatePoll(pollId, { question, options });
};

const deletePoll = async (userId, groupId, pollId) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });

  const poll = await chatRepo.getPollById(pollId);
  if (!poll) throw Object.assign(new Error('Poll not found.'), { statusCode: 404 });
  if (poll.groupId !== groupId) throw Object.assign(new Error('Poll does not belong to this trip.'), { statusCode: 403 });

  const isAdmin = member.role === 'admin' || member.role === 'creator';
  if (poll.createdBy !== userId && !isAdmin) {
    throw Object.assign(new Error('Only the poll creator or a group admin can delete this poll.'), { statusCode: 403 });
  }

  await chatRepo.deletePoll(pollId);
  return { message: 'Poll deleted successfully.' };
};

const voteOnPoll = async (userId, groupId, pollId, optionId) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });

  const poll = await chatRepo.getPollById(pollId);
  if (!poll) throw Object.assign(new Error('Poll not found.'), { statusCode: 404 });
  if (poll.status === 'closed') throw Object.assign(new Error('This poll is already closed.'), { statusCode: 400 });
  if (poll.groupId !== groupId) throw Object.assign(new Error('Poll does not belong to this trip.'), { statusCode: 403 });

  const validOption = poll.options.find((o) => o.id === optionId);
  if (!validOption) throw Object.assign(new Error('Invalid option.'), { statusCode: 400 });

  return chatRepo.castVote({ pollId, optionId, userId });
};

const closePoll = async (userId, groupId, pollId) => {
  const poll = await chatRepo.getPollById(pollId);
  if (!poll) throw Object.assign(new Error('Poll not found.'), { statusCode: 404 });
  if (poll.groupId !== groupId) throw Object.assign(new Error('Poll does not belong to this trip.'), { statusCode: 403 });
  if (poll.status === 'closed') throw Object.assign(new Error('Poll is already closed.'), { statusCode: 400 });

  // Only poll creator or group admin can close
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  const isAdmin = member && (member.role === 'admin' || member.role === 'creator');
  if (poll.createdBy !== userId && !isAdmin) {
    throw Object.assign(new Error('Only the poll creator or a group admin can close the poll.'), { statusCode: 403 });
  }

  const closedPoll = await chatRepo.closePoll(pollId);

  // Build result summary for AI embedding (fire-and-forget)
  const resultSummary = buildPollResultSummary(closedPoll);
  fireInteractionEmbedding(groupId, pollId, resultSummary).catch(console.error);

  return closedPoll;
};

const getPolls = async (userId, groupId) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });
  const rawPolls = await chatRepo.getPollsByGroup(groupId);

  return rawPolls.map((poll) => {
    const isAnon = Boolean(poll.isAnonymous);
    const sanitizedOptions = (poll.options || []).map((opt) => {
      const votes = opt.votes || [];
      const voters = isAnon ? [] : votes.map((v) => v.user).filter(Boolean);
      return {
        ...opt,
        voteCount: votes.length,
        voters,
        votes: isAnon ? votes.map((v) => ({ id: v.id, optionId: v.optionId })) : votes,
      };
    });

    return {
      ...poll,
      isAnonymous: isAnon,
      options: sanitizedOptions,
    };
  });
};

// ── Helpers ──────────────────────────────────────────────────────────────────

const buildPollResultSummary = (poll) => {
  const allVotes = (poll.options || []).flatMap((opt) => opt.votes || []);
  const totalVotes = allVotes.length;
  const optionSummaries = (poll.options || []).map((opt) => {
    const count = (opt.votes || []).length;
    const pct = totalVotes > 0 ? Math.round((count / totalVotes) * 100) : 0;
    return `${opt.optionText}: ${count} vote${count !== 1 ? 's' : ''} (${pct}%)`;
  });
  return `Trip poll result — "${poll.question}": ${optionSummaries.join(', ')}. Total votes: ${totalVotes}.`;
};


const fireInteractionEmbedding = async (groupId, pollId, summaryText) => {
  const AI_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';
  // Use the admin token from the shared secret for internal service calls
  const jwt = require('jsonwebtoken');
  const token = jwt.sign({ sub: 'internal-service' }, process.env.JWT_SECRET, { expiresIn: '5m' });
  try {
    await axios.post(
      `${AI_URL}/api/ai/embeddings/interaction`,
      { group_id: groupId, source_type: 'poll', source_id: pollId, summary_text: summaryText },
      {
        headers: { Authorization: `Bearer ${token}` },
        timeout: 10000,
      },
    );
  } catch (err) {
    console.error(`[Chat Service] AI embedding sync failed for poll ${pollId}: ${err.message}`);
  }
};

module.exports = {
  getMessages, saveTextMessage, saveImageMessage, getImageKitAuth,
  createPoll, updatePoll, deletePoll, voteOnPoll, closePoll, getPolls,
  buildPollResultSummary, fireInteractionEmbedding,
};
