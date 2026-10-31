const express = require('express');
const path = require('path');
const fs = require('fs');
const tripRepository = require('../repositories/trip.repository');
const userRepository = require('../repositories/user.repository');
const bcrypt = require('bcryptjs');

const router = express.Router();

/**
 * Helper to escape HTML characters to prevent XSS in rendered web pages.
 */
function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

/**
 * GET /trips/join/:token & GET /join/:token
 * Public landing page for joining a trip via shared WhatsApp/SMS/web link.
 * Includes OpenGraph tags for rich WhatsApp previews, deep link launch button, and trip code copy.
 */
const handleJoinLanding = async (req, res) => {
  const token = req.params.token || '';
  const cleanToken = token.trim();

  let trip = null;
  const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(cleanToken);

  if (isUuid) {
    try {
      trip = await tripRepository.findTripById(cleanToken);
    } catch (_) {}
  }

  if (!trip) {
    try {
      const invite = await tripRepository.findInviteByToken(cleanToken);
      trip = invite?.group;
    } catch (_) {}
  }

  const tripName = trip?.name || 'Group Trip';
  const coverImage = trip?.coverImageUrl || 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=1200';
  const memberCount = trip?.members?.length || 1;

  let formattedDates = 'Upcoming Adventure';
  if (trip?.tripStartDate) {
    const s = new Date(trip.tripStartDate);
    const options = { month: 'short', day: 'numeric' };
    if (trip?.tripEndDate) {
      const e = new Date(trip.tripEndDate);
      formattedDates = `${s.toLocaleDateString('en-US', options)} – ${e.toLocaleDateString('en-US', options)}`;
    } else {
      formattedDates = s.toLocaleDateString('en-US', options);
    }
  }

  const deepLinkApp = `wetravel://trips/join/${encodeURIComponent(cleanToken)}`;

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Join "${escapeHtml(tripName)}" on WeTravel</title>
  
  <!-- OpenGraph tags for rich WhatsApp, Telegram, iMessage previews -->
  <meta property="og:title" content="Join trip to ${escapeHtml(tripName)} on WeTravel">
  <meta property="og:description" content="You're invited to join ${escapeHtml(tripName)} (${escapeHtml(formattedDates)})! Vote on stays, plan itineraries, and split costs effortlessly.">
  <meta property="og:image" content="${escapeHtml(coverImage)}">
  <meta property="og:url" content="https://wetravel-server.duckdns.org/trips/join/${encodeURIComponent(cleanToken)}">
  <meta property="og:type" content="website">
  
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background-color: #FAF9F6;
      color: #0F172A;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      padding: 16px;
    }
    .card {
      background: #FFFFFF;
      border-radius: 24px;
      max-width: 440px;
      width: 100%;
      overflow: hidden;
      box-shadow: 0 12px 36px rgba(0, 78, 100, 0.12);
      border: 1px solid #E2E8F0;
    }
    .cover {
      position: relative;
      height: 180px;
      background: url("${escapeHtml(coverImage)}") center/cover no-repeat;
    }
    .cover-overlay {
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      background: linear-gradient(180deg, rgba(0,0,0,0.2) 0%, rgba(0,78,100,0.85) 100%);
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      padding: 16px 20px;
    }
    .brand {
      display: flex;
      align-items: center;
      gap: 8px;
      color: #FFFFFF;
      font-weight: 800;
      font-size: 18px;
    }
    .brand span {
      background: #F59E0B;
      color: #FFFFFF;
      padding: 2px 8px;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 700;
    }
    .cover-info {
      color: #FFFFFF;
    }
    .cover-info h1 {
      font-size: 24px;
      font-weight: 800;
      line-height: 1.2;
    }
    .cover-info p {
      font-size: 13.5px;
      opacity: 0.9;
      margin-top: 4px;
    }
    .content {
      padding: 24px 20px;
    }
    .badge-row {
      display: flex;
      gap: 10px;
      margin-bottom: 18px;
    }
    .badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: #F1F5F9;
      color: #334155;
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 12.5px;
      font-weight: 600;
    }
    .btn-primary {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      width: 100%;
      text-align: center;
      background: #004E64;
      color: #FFFFFF;
      text-decoration: none;
      padding: 14px 20px;
      border-radius: 16px;
      font-size: 16px;
      font-weight: 700;
      transition: background 0.2s;
      border: none;
      cursor: pointer;
    }
    .btn-primary:hover {
      background: #003848;
    }
    .download-banner {
      margin-top: 14px;
      background: #F0FDF4;
      border: 1px solid #BBF7D0;
      border-radius: 16px;
      padding: 14px 16px;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    .download-text strong {
      display: block;
      font-size: 13.5px;
      color: #166534;
      margin-bottom: 2px;
    }
    .download-text span {
      font-size: 12px;
      color: #15803D;
    }
    .btn-playstore {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      background: #0F172A;
      color: #FFFFFF;
      text-decoration: none;
      padding: 12px 16px;
      border-radius: 12px;
      font-size: 14px;
      font-weight: 700;
      transition: background 0.2s;
    }
    .btn-playstore:hover {
      background: #1E293B;
    }
    .btn-download {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      background: #004E64;
      color: #FFFFFF;
      text-decoration: none;
      padding: 11px 16px;
      border-radius: 12px;
      font-size: 13.5px;
      font-weight: 600;
      transition: background 0.2s;
    }
    .btn-download:hover {
      background: #003848;
    }
    .code-box {
      margin-top: 18px;
      background: #F8FAFC;
      border: 1px dashed #CBD5E1;
      border-radius: 14px;
      padding: 14px;
      text-align: center;
    }
    .code-label {
      font-size: 12px;
      color: #64748B;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .code-val {
      font-family: monospace;
      font-size: 14px;
      font-weight: 700;
      color: #004E64;
      margin: 6px 0;
      word-break: break-all;
    }
    .btn-copy {
      background: #FFFFFF;
      border: 1px solid #CBD5E1;
      color: #004E64;
      padding: 6px 14px;
      border-radius: 10px;
      font-size: 12.5px;
      font-weight: 600;
      cursor: pointer;
      margin-top: 4px;
    }
    .btn-copy:hover {
      background: #F1F5F9;
    }
    .instructions {
      margin-top: 18px;
      font-size: 13px;
      color: #475569;
      line-height: 1.5;
    }
    .instructions ol {
      padding-left: 18px;
      margin-top: 6px;
    }
    .instructions li {
      margin-bottom: 4px;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="cover">
      <div class="cover-overlay">
        <div class="brand">
          ✈ WeTravel
          <span>Trip Invite</span>
        </div>
        <div class="cover-info">
          <h1>${escapeHtml(tripName)}</h1>
          <p>${escapeHtml(formattedDates)}</p>
        </div>
      </div>
    </div>
    <div class="content">
      <div class="badge-row">
        <div class="badge">👥 ${memberCount} member${memberCount > 1 ? 's' : ''}</div>
        <div class="badge">📍 Active Trip</div>
      </div>

      <!-- App Installed Option -->
      <a href="${deepLinkApp}" class="btn-primary" id="openBtn">
        Open in WeTravel App →
      </a>

      <!-- App Not Installed / Download Options -->
      <div class="download-banner">
        <div class="download-text">
          <strong>Don't have the WeTravel app yet?</strong>
          <span>Install from Google Play or download the Android APK to join</span>
        </div>
        <div style="display:flex; flex-direction:column; gap:8px;">
          <!-- Google Play Store Button -->
          <a href="${process.env.PLAY_STORE_URL || 'https://play.google.com/store/apps/details?id=com.example.frontend'}" class="btn-playstore" id="playStoreBtn" target="_blank">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M3.609 1.814L13.793 12 3.61 22.186c-.365-.36-.61-.91-.61-1.571V3.385c0-.66.245-1.21.609-1.571zm11.305 11.306l2.12-2.12-11.89-6.73 9.77 8.85zm0 1.76l-9.77 8.85 11.89-6.73-2.12-2.12zm1.18-1.18l3.19-1.81c1.03-.58 1.03-1.54 0-2.12l-3.19-1.81-1.74 1.74 1.74 2z"/></svg>
            Get it on Google Play
          </a>

          <!-- Direct APK Download Button -->
          <a href="/download/app" class="btn-download" id="downloadBtn">
            📥 Download Android APK
          </a>
        </div>
      </div>

      <div class="code-box">
        <div class="code-label">Trip Invite Code</div>
        <div class="code-val" id="tokenText">${escapeHtml(cleanToken)}</div>
        <button class="btn-copy" id="copyBtn" onclick="copyToken()">📋 Copy Code</button>
      </div>

      <div class="instructions">
        <strong>How to join:</strong>
        <ol>
          <li>Install and open the <strong>WeTravel</strong> app</li>
          <li>On the Home screen, tap <strong>"Join a Trip"</strong></li>
          <li>Paste the invite code above and tap <strong>Join Trip</strong>!</li>
        </ol>
      </div>
    </div>
  </div>

  <script>
    function copyToken() {
      const text = document.getElementById('tokenText').innerText;
      const copyBtn = document.getElementById('copyBtn');
      navigator.clipboard.writeText(text).then(() => {
        if (copyBtn) copyBtn.innerText = '✅ Code Copied!';
        setTimeout(() => {
          if (copyBtn) copyBtn.innerText = '📋 Copy Code';
        }, 2500);
      }).catch(() => {
        prompt('Copy your trip code:', text);
      });
    }

    // Attempt automatic deep link navigation on mobile devices
    if (/android|iphone|ipad/i.test(navigator.userAgent)) {
      setTimeout(() => {
        window.location.href = "${deepLinkApp}";
      }, 500);
    }
  </script>
</body>
</html>`;

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(html);
};

router.get('/trips/join/:token', handleJoinLanding);
router.get('/join/:token', handleJoinLanding);

/**
 * GET /download/app & GET /download/apk
 * Direct APK download route with local file serving and GitHub Release fallback.
 */
router.get(['/download/app', '/download/apk'], (req, res) => {
  const localApk = path.join(__dirname, '../../public/app-release.apk');
  const backendApk = path.join(__dirname, '../public/app-release.apk');
  const rootApk = path.join(__dirname, '../../../frontend/build/app/outputs/apk/release/app-release.apk');

  if (fs.existsSync(localApk)) {
    return res.download(localApk, 'WeTravel.apk');
  }
  if (fs.existsSync(backendApk)) {
    return res.download(backendApk, 'WeTravel.apk');
  }
  if (fs.existsSync(rootApk)) {
    return res.download(rootApk, 'WeTravel.apk');
  }

  // Fallback to GitHub releases repository
  return res.redirect('https://github.com/Ansh5922/WeTravel/releases');
});

/**
 * GET /.well-known/assetlinks.json
 * Android App Links digital asset links to enable direct HTTPS link opening without browser chooser.
 */
router.get('/.well-known/assetlinks.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.json([
    {
      relation: ['delegate_permission/common.handle_all_urls'],
      target: {
        namespace: 'android_app',
        package_name: 'com.example.frontend',
        sha256_cert_fingerprints: [
          'A9:5A:A4:53:BA:06:F9:50:52:CB:BE:1E:B9:44:A2:37:67:BC:E4:3A:BD:2A:E6:AB:66:11:E3:B4:3C:B9:27:7C',
          'FA:C6:17:45:DC:09:03:78:6F:B9:ED:E6:2A:96:2B:39:9F:73:48:F0:BB:6F:89:9B:83:32:66:75:91:03:3B:9C'
        ]
      }
    }
  ]);
});

/**
 * GET /delete-account
 * Public web account deletion portal required by Google Play Store.
 */
router.get('/delete-account', (req, res) => {
  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Delete Account & Data | WeTravel</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background-color: #FAF9F6;
      color: #0F172A;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      padding: 16px;
    }
    .card {
      background: #FFFFFF;
      border-radius: 20px;
      max-width: 480px;
      width: 100%;
      padding: 28px 24px;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
      border: 1px solid #E2E8F0;
    }
    .brand {
      color: #004E64;
      font-size: 20px;
      font-weight: 800;
      margin-bottom: 8px;
    }
    h1 {
      font-size: 22px;
      font-weight: 700;
      color: #DC2626;
      margin-bottom: 10px;
    }
    p {
      font-size: 14px;
      color: #475569;
      line-height: 1.5;
      margin-bottom: 16px;
    }
    .danger-box {
      background: #FEF2F2;
      border: 1px solid #FECACA;
      border-radius: 12px;
      padding: 14px;
      margin-bottom: 20px;
      font-size: 13px;
      color: #991B1B;
      line-height: 1.45;
    }
    .form-group {
      margin-bottom: 16px;
    }
    label {
      display: block;
      font-size: 13px;
      font-weight: 600;
      color: #334155;
      margin-bottom: 6px;
    }
    input[type="email"], input[type="password"] {
      width: 100%;
      padding: 12px 14px;
      border: 1px solid #CBD5E1;
      border-radius: 10px;
      font-size: 14px;
    }
    input:focus {
      outline: none;
      border-color: #DC2626;
    }
    .btn-delete {
      width: 100%;
      background: #DC2626;
      color: #FFFFFF;
      padding: 14px;
      border: none;
      border-radius: 12px;
      font-size: 15px;
      font-weight: 700;
      cursor: pointer;
    }
    .btn-delete:hover {
      background: #B91C1C;
    }
    .footer-note {
      font-size: 12px;
      color: #94A3B8;
      text-align: center;
      margin-top: 16px;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="brand">✈ WeTravel</div>
    <h1>Account & Data Deletion Portal</h1>
    <p>In accordance with Google Play Store policies and privacy laws (GDPR/CCPA), you may permanently delete your WeTravel account and all associated personal data.</p>
    
    <div class="danger-box">
      <strong>Warning:</strong> Deleting your account will permanently remove your profile, personal preferences, and uploaded photos. Historical shared group expense records will be anonymized to preserve accurate accounting for your travel group.
    </div>

    <form method="POST" action="/delete-account">
      <div class="form-group">
        <label>Account Email</label>
        <input type="email" name="email" required placeholder="name@example.com">
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" required placeholder="Enter your password to confirm">
      </div>
      <button type="submit" class="btn-delete">Permanently Delete My Account & Data</button>
    </form>

    <div class="footer-note">
      For support inquiries, email rashimeenameher97@gmail.com
    </div>
  </div>
</body>
</html>`;
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(html);
});

/**
 * POST /delete-account
 * Form submission from public web deletion portal.
 */
router.post('/delete-account', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).send('<h3 style="font-family:sans-serif;color:red;padding:20px;">Email and password are required. <a href="/delete-account">Back</a></h3>');
  }

  try {
    const user = await userRepository.findUserByEmail(email.toLowerCase().trim());
    if (!user) {
      return res.status(404).send('<h3 style="font-family:sans-serif;color:red;padding:20px;">Account not found. <a href="/delete-account">Back</a></h3>');
    }

    const isValid = await bcrypt.compare(password, user.passwordHash);
    if (!isValid) {
      return res.status(401).send('<h3 style="font-family:sans-serif;color:red;padding:20px;">Incorrect password. <a href="/delete-account">Back</a></h3>');
    }

    await userRepository.anonymizeAndDeleteUser(user.id);
    return res.status(200).send(`
      <div style="font-family:sans-serif;max-width:440px;margin:50px auto;padding:30px;background:#fff;border-radius:16px;box-shadow:0 4px 20px rgba(0,0,0,0.1);text-align:center;">
        <h2 style="color:#16A34A;">Account Successfully Deleted</h2>
        <p style="color:#475569;margin:14px 0;">Your WeTravel account, authentication credentials, and personal data have been permanently erased from our databases.</p>
        <a href="https://wetravel-server.duckdns.org" style="color:#004E64;font-weight:bold;text-decoration:none;">Return to WeTravel</a>
      </div>
    `);
  } catch (err) {
    return res.status(500).send(`<h3 style="font-family:sans-serif;color:red;padding:20px;">Failed to delete account: ${escapeHtml(err.message)}</h3>`);
  }
});

module.exports = router;
