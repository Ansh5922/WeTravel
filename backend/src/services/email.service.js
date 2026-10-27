const axios = require('axios');

/**
 * Email Service
 * Responsibility: Transactional email dispatch for password reset, invites, and notifications.
 * Providers:
 *   - Production: Resend REST API (https://resend.com) via RESEND_API_KEY
 *   - Development / Staging fallback: Clean console logging box with full link & OTP
 */

const RESEND_API_URL = 'https://api.resend.com/emails';
const DEFAULT_FROM = process.env.EMAIL_FROM || 'WeTravel <onboarding@resend.dev>';
const APP_BASE_URL = process.env.APP_BASE_URL || 'https://wetravel-server.duckdns.org';

/**
 * Generate responsive HTML email for password reset.
 */
const buildPasswordResetHtml = ({ name, otp, resetUrl }) => {
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Your WeTravel Password</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #F8F9FA; margin: 0; padding: 20px; color: #1E293B; }
    .container { max-width: 540px; margin: 0 auto; background: #FFFFFF; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.06); }
    .header { background: linear-gradient(135deg, #FF5A36 0%, #E04824 100%); padding: 36px 30px; text-align: center; color: #FFFFFF; }
    .header h1 { margin: 0; font-size: 26px; font-weight: 700; letter-spacing: -0.5px; }
    .content { padding: 36px 32px; }
    .greeting { font-size: 18px; font-weight: 600; margin-bottom: 12px; }
    .text { font-size: 15px; line-height: 1.6; color: #475569; margin-bottom: 24px; }
    .otp-box { background: #FFF4F0; border: 2px dashed #FF5A36; border-radius: 12px; padding: 20px; text-align: center; margin-bottom: 28px; }
    .otp-label { font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #FF5A36; margin-bottom: 6px; }
    .otp-code { font-size: 36px; font-weight: 800; letter-spacing: 8px; color: #1E293B; font-family: monospace; }
    .divider { display: flex; align-items: center; text-align: center; margin: 28px 0; color: #94A3B8; font-size: 13px; }
    .button-wrap { text-align: center; margin-bottom: 28px; }
    .button { display: inline-block; background-color: #FF5A36; color: #FFFFFF !important; text-decoration: none; font-weight: 600; font-size: 15px; padding: 14px 32px; border-radius: 10px; box-shadow: 0 4px 12px rgba(255,90,54,0.3); }
    .footer { padding: 20px 32px 32px; border-top: 1px solid #F1F5F9; font-size: 12px; color: #94A3B8; text-align: center; line-height: 1.5; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>WeTravel</h1>
    </div>
    <div class="content">
      <div class="greeting">Hi ${name || 'Traveler'},</div>
      <div class="text">
        We received a request to reset the password for your WeTravel account. Use the verification code below in your mobile app, or tap the button to reset directly.
      </div>

      <!-- 6-digit OTP Block -->
      <div class="otp-box">
        <div class="otp-label">Verification Code (Valid for 15 minutes)</div>
        <div class="otp-code">${otp}</div>
      </div>

      <!-- Direct Reset Link Button -->
      <div class="button-wrap">
        <a href="${resetUrl}" class="button" target="_blank">Reset Password Directly</a>
      </div>

      <div class="text" style="font-size: 13px; color: #64748B;">
        If you did not request a password reset, you can safely ignore this email. Your current password will remain unchanged.
      </div>
    </div>
    <div class="footer">
      WeTravel Inc. • Collaborative Group Travel Made Simple<br>
      This is an automated security message. Please do not reply directly.
    </div>
  </div>
</body>
</html>
  `.trim();
};

/**
 * Send password reset email containing both 6-digit OTP and reset link.
 * @param {{ to: string, name: string, otp: string, resetToken: string }} params
 */
const sendPasswordResetEmail = async ({ to, name, otp, resetToken }) => {
  const resetUrl = `${APP_BASE_URL}/auth/reset-password?token=${encodeURIComponent(resetToken)}&email=${encodeURIComponent(to)}`;
  const htmlContent = buildPasswordResetHtml({ name, otp, resetUrl });
  const subject = `${otp} is your WeTravel password reset code`;

  // 1. If RESEND_API_KEY is configured, dispatch real email
  if (process.env.RESEND_API_KEY) {
    try {
      const response = await axios.post(
        RESEND_API_URL,
        {
          from: DEFAULT_FROM,
          to: [to],
          subject,
          html: htmlContent,
        },
        {
          headers: {
            Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          timeout: 8000,
        }
      );
      console.log(`📧 [EMAIL] Password reset email delivered to ${to} (ID: ${response.data?.id})`);
      return { success: true, provider: 'resend', id: response.data?.id };
    } catch (err) {
      console.error(`[EMAIL] Resend delivery failed for ${to}:`, err.response?.data || err.message);
      // Fall through to console logging so flow never breaks in staging
    }
  }

  // 2. Development / Staging fallback: High-visibility terminal output
  console.log('\n' + '═'.repeat(70));
  console.log(`📬 [DEV EMAIL DISPATCH] Password Reset Instructions`);
  console.log(`👤 Recipient:  ${to} (${name || 'Traveler'})`);
  console.log(`🔢 6-Digit OTP: ${otp} (Expires in 15 mins)`);
  console.log(`🔗 Direct Link: ${resetUrl}`);
  console.log('═'.repeat(70) + '\n');

  return { success: true, provider: 'console', otp, resetUrl };
};

module.exports = {
  sendPasswordResetEmail,
};
