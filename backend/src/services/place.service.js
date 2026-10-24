const axios = require('axios');

/**
 * Place Service
 * Responsibility: Destination search & autocomplete with in-memory caching.
 * Providers:
 *   1. Primary/Fallback: Photon OpenStreetMap Geocoding API (free, global, no API key required)
 *   2. Optional: Mapbox Geocoding API (used if MAPBOX_ACCESS_TOKEN is configured in .env)
 */

// ── In-Memory LRU Cache with TTL ──────────────────────────────────────────────
const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours
const MAX_CACHE_SIZE = 1000;
const placeCache = new Map(); // key: lowercase query string, value: { places, expiresAt }

/** Get cached results if present and unexpired. */
const getFromCache = (key) => {
  const item = placeCache.get(key);
  if (!item) return null;
  if (Date.now() > item.expiresAt) {
    placeCache.delete(key);
    return null;
  }
  return item.places;
};

/** Save results to in-memory cache, evicting oldest if capacity reached. */
const setInCache = (key, places) => {
  if (placeCache.size >= MAX_CACHE_SIZE) {
    const oldestKey = placeCache.keys().next().value;
    placeCache.delete(oldestKey);
  }
  placeCache.set(key, {
    places,
    expiresAt: Date.now() + CACHE_TTL_MS,
  });
};

// ── Providers ─────────────────────────────────────────────────────────────────

/**
 * Query Photon OpenStreetMap API.
 * Free, high-performance, open-source global geocoder.
 */
const fetchFromPhoton = async (query, limit = 6) => {
  const url = `https://photon.komoot.io/api/?q=${encodeURIComponent(query)}&limit=${limit}`;
  const response = await axios.get(url, {
    headers: { 'User-Agent': 'WeTravel-App/1.0' },
    timeout: 5000,
  });

  const features = response.data?.features || [];
  return features.map((f, index) => {
    const p = f.properties || {};
    const coords = f.geometry?.coordinates || [0, 0]; // [lng, lat] in GeoJSON

    const name = p.name || '';
    const city = p.city || p.town || p.village || (p.type === 'city' ? name : null);
    const state = p.state || p.county || null;
    const country = p.country || null;
    const countryCode = p.countrycode || null;

    // Build human-friendly display name (e.g., "Paris, Île-de-France, France")
    const parts = [name];
    if (city && city !== name) parts.push(city);
    if (state && state !== name && state !== city) parts.push(state);
    if (country) parts.push(country);

    const displayName = parts.filter(Boolean).join(', ');

    return {
      id: `photon-${p.osm_type || 'N'}-${p.osm_id || index}`,
      name,
      displayName,
      city: city || name,
      state: state || null,
      country: country || null,
      countryCode: countryCode ? countryCode.toUpperCase() : null,
      lat: coords[1],
      lng: coords[0],
    };
  });
};

/**
 * Query Mapbox Geocoding API if token is provided.
 */
const fetchFromMapbox = async (query, token, limit = 6) => {
  const url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?access_token=${token}&limit=${limit}&types=country,region,place,locality`;
  const response = await axios.get(url, { timeout: 5000 });

  const features = response.data?.features || [];
  return features.map((f) => {
    const coords = f.center || [0, 0]; // [lng, lat] in Mapbox
    const context = f.context || [];

    const countryObj = context.find((c) => c.id?.startsWith('country'));
    const regionObj = context.find((c) => c.id?.startsWith('region'));

    return {
      id: f.id,
      name: f.text || f.place_name,
      displayName: f.place_name,
      city: f.text || '',
      state: regionObj?.text || null,
      country: countryObj?.text || null,
      countryCode: countryObj?.short_code ? countryObj.short_code.toUpperCase() : null,
      lat: coords[1],
      lng: coords[0],
    };
  });
};

// ── Public Service API ────────────────────────────────────────────────────────

/**
 * Search places by query with in-memory caching.
 * @param {string} query Search input (e.g. "Par", "Tokyo", "Bali")
 * @param {number} limit Maximum results to return
 * @returns {Promise<Array<{ id, name, displayName, city, state, country, countryCode, lat, lng }>>}
 */
const autocompletePlaces = async (query, limit = 6) => {
  const normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.length < 2) {
    return [];
  }

  // 1. Check in-memory cache
  const cached = getFromCache(normalizedQuery);
  if (cached) {
    return cached;
  }

  // 2. Fetch from Mapbox (if key configured) or Photon OSM
  let places = [];
  const mapboxToken = process.env.MAPBOX_ACCESS_TOKEN;

  if (mapboxToken) {
    try {
      places = await fetchFromMapbox(query.trim(), mapboxToken, limit);
    } catch (mapboxErr) {
      console.warn('[Place Service] Mapbox request failed, falling back to Photon:', mapboxErr.message);
      places = await fetchFromPhoton(query.trim(), limit);
    }
  } else {
    places = await fetchFromPhoton(query.trim(), limit);
  }

  // 3. Cache the normalized results
  if (places.length > 0) {
    setInCache(normalizedQuery, places);
  }

  return places;
};

module.exports = {
  autocompletePlaces,
};
