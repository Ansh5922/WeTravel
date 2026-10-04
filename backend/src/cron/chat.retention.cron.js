const cron = require('node-cron');
const chatRepo = require('../repositories/chat.repository');

/**
 * Chat Retention Cron — WeTravel Backend
 * Runs daily at 02:00 AM.
 * Deletes messages for trips where:
 *   - chatRetentionDeadline has passed
 *   - preserveChat is false (no premium member in trip)
 */

const startChatRetentionCron = () => {
  cron.schedule('0 2 * * *', async () => {
    console.log('[CRON] Running chat retention cleanup...');
    try {
      const deleted = await chatRepo.deleteExpiredMessages();
      console.log(`[CRON] Chat retention cleanup complete. Deleted ${deleted} messages.`);
    } catch (err) {
      console.error('[CRON] Chat retention cleanup failed:', err.message);
    }
  });
  console.log('⏰ [CRON] Chat retention cron scheduled (daily at 02:00 AM).');
};

module.exports = { startChatRetentionCron };
