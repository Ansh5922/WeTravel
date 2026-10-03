const crypto = require('crypto');

// ImageKit service generating HMAC-SHA1 upload signatures for direct client uploads

// Generate authentication parameters for direct browser to ImageKit upload
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
