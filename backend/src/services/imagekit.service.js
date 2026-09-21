const crypto = require('crypto');

/**
 * ImageKit Service — WeTravel Backend
 * Layer: Service (external CDN wrapper)
 * Generates auth params for direct frontend uploads using HMAC-SHA1.
 */

/**
 * Generate authentication parameters for direct browser → ImageKit upload.
 * ImageKit auth formula:
 *   token: unique string / UUID
 *   expire: UNIX timestamp in seconds (default: 30 minutes from now)
 *   signature: HMAC-SHA1(privateKey, token + expire) in hex
 */
const getAuthParams = () => {
  const publicKey  = process.env.IMAGEKIT_PUBLIC_KEY;
  const privateKey = process.env.IMAGEKIT_PRIVATE_KEY;
  const urlEndpoint = process.env.IMAGEKIT_URL_ENDPOINT;

  const token  = crypto.randomUUID();
  const expire = Math.floor(Date.now() / 1000) + 1800; // 30 minutes validity

  const signature = crypto
    .createHmac('sha1', privateKey)
    .update(token + str(expire))
    .digest('hex');

  return {
    token,
    expire,
    signature,
    publicKey,
    urlEndpoint,
  };
};

function str(val) {
  return String(val);
}

module.exports = { getAuthParams };
