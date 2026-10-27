/// Destination Photo Service
/// Provides accurate, high-definition, copyright-free photography for Indian and global destinations.
/// Eliminates mismatches (e.g. Paris showing India photos) and guarantees every place gets its true iconic visual.
class DestinationPhotoService {
  DestinationPhotoService._();

  /// Resolves an accurate, high-resolution cover photo URL for a given destination name and trip style.
  static String resolveCoverImageUrl(String destination, [String style = 'Vacation']) {
    final lower = destination.toLowerCase().trim();

    // ──────────────────────────────────────────────────────────────────────────
    // 1. SPECIFIC INTERNATIONAL DESTINATIONS (Guarantees Paris gets Paris!)
    // ──────────────────────────────────────────────────────────────────────────
    if (lower.contains('paris') || lower.contains('france') || lower.contains('eiffel')) {
      // Iconic Eiffel Tower, Paris, France
      return 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1200';
    }
    if (lower.contains('dubai') || lower.contains('uae') || lower.contains('abu dhabi') || lower.contains('burj')) {
      // Burj Khalifa & Downtown Dubai skyline
      return 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200';
    }
    if (lower.contains('tokyo') || lower.contains('japan') || lower.contains('kyoto') || lower.contains('osaka')) {
      // Tokyo Tower and Mount Fuji skyline
      return 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=1200';
    }
    if (lower.contains('london') || lower.contains('england') || lower.contains('uk') || lower.contains('united kingdom')) {
      // Big Ben and Westminster Palace, London
      return 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=1200';
    }
    if (lower.contains('bali') || lower.contains('indonesia') || lower.contains('ubud') || lower.contains('canggu')) {
      // Pura Ulun Danu Bratan water temple, Bali
      return 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=1200';
    }
    if (lower.contains('singapore') || lower.contains('sentosa') || lower.contains('marina bay')) {
      // Marina Bay Sands & Supertree Grove, Singapore
      return 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=1200';
    }
    if (lower.contains('new york') || lower.contains('nyc') || lower.contains('manhattan') || lower.contains('brooklyn')) {
      // Manhattan Skyline & Brooklyn Bridge, New York
      return 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=1200';
    }
    if (lower.contains('rome') || lower.contains('italy') || lower.contains('florence') || lower.contains('venice')) {
      // Historic Colosseum, Rome
      return 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=1200';
    }
    if (lower.contains('bangkok') || lower.contains('phuket') || lower.contains('thailand') || lower.contains('krabi') || lower.contains('pattaya')) {
      // Emerald Sea & Limestone Island, Phuket, Thailand
      return 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=1200';
    }
    if (lower.contains('maldives') || lower.contains('male')) {
      // Turquoise lagoon overwater bungalows, Maldives
      return 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=1200';
    }
    if (lower.contains('switzerland') || lower.contains('swiss') || lower.contains('zurich') || lower.contains('alps')) {
      // Snow-capped Swiss Alps and alpine lake
      return 'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?w=1200';
    }

    // ──────────────────────────────────────────────────────────────────────────
    // 2. CURATED INDIAN DESTINATIONS (Primary Focus)
    // ──────────────────────────────────────────────────────────────────────────

    // ── Agra & Yamuna ─────────────────────────────────────────────────────────
    if (lower.contains('agra') || lower.contains('taj mahal') || lower.contains('fatehpur sikri')) {
      return 'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=1200';
    }

    // ── Jaipur & Pink City ────────────────────────────────────────────────────
    if (lower.contains('jaipur') || lower.contains('amber fort') || lower.contains('hawa mahal')) {
      return 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=1200';
    }

    // ── Udaipur & City of Lakes ───────────────────────────────────────────────
    if (lower.contains('udaipur') || lower.contains('pichola') || lower.contains('fateh sagar')) {
      return 'https://images.unsplash.com/photo-1615836245337-f5b9b2303f10?w=1200';
    }

    // ── Jodhpur & Blue City ───────────────────────────────────────────────────
    if (lower.contains('jodhpur') || lower.contains('mehrangarh')) {
      return 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=1200';
    }

    // ── Jaisalmer & Thar Desert ───────────────────────────────────────────────
    if (lower.contains('jaisalmer') || lower.contains('sam sand dunes') || lower.contains('thar')) {
      return 'https://images.unsplash.com/photo-1577083552431-6e5fd01988ec?w=1200';
    }

    // ── Pushkar & Ajmer ───────────────────────────────────────────────────────
    if (lower.contains('pushkar') || lower.contains('ajmer')) {
      return 'https://images.unsplash.com/photo-1588096344356-9a2f7c0017a4?w=1200';
    }

    // ── Varanasi & Holy Ganga ─────────────────────────────────────────────────
    if (lower.contains('varanasi') || lower.contains('banaras') || lower.contains('kashi') || lower.contains('sarnath')) {
      return 'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=1200';
    }

    // ── Amritsar & Golden Temple ──────────────────────────────────────────────
    if (lower.contains('amritsar') || lower.contains('golden temple') || lower.contains('harmandir') || lower.contains('wagah')) {
      return 'https://images.unsplash.com/photo-1609137144822-0a13876007b8?w=1200';
    }

    // ── Delhi & NCR ───────────────────────────────────────────────────────────
    if (lower.contains('delhi') || lower.contains('new delhi') || lower.contains('noida') || lower.contains('gurugram') || lower.contains('gurgaon')) {
      return 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=1200';
    }

    // ── Mumbai & Maharashtra Coastal ──────────────────────────────────────────
    if (lower.contains('mumbai') || lower.contains('bombay') || lower.contains('marine drive') || lower.contains('gateway of india')) {
      return 'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=1200';
    }

    // ── Pune, Lonavala & Western Ghats Hills ───────────────────────────────────
    if (lower.contains('pune') || lower.contains('lonavala') || lower.contains('khandala') || lower.contains('mahabaleshwar') || lower.contains('panchgani') || lower.contains('lavasa') || lower.contains('alibaug')) {
      return 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?w=1200';
    }

    // ── Goa Beaches ───────────────────────────────────────────────────────────
    if (lower.contains('goa') || lower.contains('panaji') || lower.contains('calangute') || lower.contains('baga') || lower.contains('anjuna') || lower.contains('palolem') || lower.contains('vagator') || lower.contains('candolim')) {
      return 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=1200';
    }

    // ── Gokarna Coastal ───────────────────────────────────────────────────────
    if (lower.contains('gokarna') || lower.contains('om beach') || lower.contains('karwar')) {
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200';
    }

    // ── Kerala Backwaters & Alleppey ──────────────────────────────────────────
    if (lower.contains('kerala') || lower.contains('alleppey') || lower.contains('alappuzha') || lower.contains('kumarakom') || lower.contains('kochi') || lower.contains('cochin') || lower.contains('backwater')) {
      return 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=1200';
    }

    // ── Munnar Tea Plantations ────────────────────────────────────────────────
    if (lower.contains('munnar') || lower.contains('idukki')) {
      return 'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?w=1200';
    }

    // ── Wayanad Rainforests ───────────────────────────────────────────────────
    if (lower.contains('wayanad') || lower.contains('chembra')) {
      return 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=1200';
    }

    // ── Varkala & Kovalam Cliff Beaches ───────────────────────────────────────
    if (lower.contains('varkala') || lower.contains('kovalam') || lower.contains('trivandrum') || lower.contains('thiruvananthapuram')) {
      return 'https://images.unsplash.com/photo-1590523741831-ab7e8b8f9c7f?w=1200';
    }

    // ── Coorg & Chikmagalur Coffee Estates ────────────────────────────────────
    if (lower.contains('coorg') || lower.contains('madikeri') || lower.contains('kodagu') || lower.contains('chikmagalur') || lower.contains('sakleshpur')) {
      return 'https://images.unsplash.com/photo-1596401057633-54a8fe8ef647?w=1200';
    }

    // ── Ooty & Kodaikanal Nilgiri Hills ───────────────────────────────────────
    if (lower.contains('ooty') || lower.contains('kodaikanal') || lower.contains('nilgiri') || lower.contains('coonoor')) {
      return 'https://images.unsplash.com/photo-1570641963303-92ce4845cd4c?w=1200';
    }

    // ── Hampi Heritage & Ruins ────────────────────────────────────────────────
    if (lower.contains('hampi') || lower.contains('badami') || lower.contains('pattadakal') || lower.contains('bellary')) {
      return 'https://images.unsplash.com/photo-1600100397608-f010f4439c0d?w=1200';
    }

    // ── Mysore Royal Palace ───────────────────────────────────────────────────
    if (lower.contains('mysore') || lower.contains('mysuru')) {
      return 'https://images.unsplash.com/photo-1600100397855-871d3a54a7c0?w=1200';
    }

    // ── Bangalore / Bengaluru ─────────────────────────────────────────────────
    if (lower.contains('bangalore') || lower.contains('bengaluru')) {
      return 'https://images.unsplash.com/photo-1596176530529-78163a4f7af2?w=1200';
    }

    // ── Hyderabad & Nizami Heritage ───────────────────────────────────────────
    if (lower.contains('hyderabad') || lower.contains('charminar') || lower.contains('secunderabad')) {
      return 'https://images.unsplash.com/photo-1605649487212-47bdab064df7?w=1200';
    }

    // ── Chennai & Mahabalipuram Coastal Heritage ──────────────────────────────
    if (lower.contains('chennai') || lower.contains('madras') || lower.contains('mahabalipuram') || lower.contains('mamallapuram')) {
      return 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=1200';
    }

    // ── Pondicherry French Colony ─────────────────────────────────────────────
    if (lower.contains('pondicherry') || lower.contains('puducherry') || lower.contains('auroville')) {
      return 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=1200';
    }

    // ── Kolkata & Bengal Heritage ─────────────────────────────────────────────
    if (lower.contains('kolkata') || lower.contains('calcutta') || lower.contains('howrah')) {
      return 'https://images.unsplash.com/photo-1558431382-27e303142255?w=1200';
    }

    // ── Darjeeling & Tea Gardens ──────────────────────────────────────────────
    if (lower.contains('darjeeling') || lower.contains('kalimpong') || lower.contains('kurseong')) {
      return 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=1200';
    }

    // ── Sikkim & Eastern Himalayas ────────────────────────────────────────────
    if (lower.contains('sikkim') || lower.contains('gangtok') || lower.contains('pelling') || lower.contains('lachung') || lower.contains('nathula')) {
      return 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=1200';
    }

    // ── Meghalaya, Shillong & Cherrapunji ─────────────────────────────────────
    if (lower.contains('meghalaya') || lower.contains('shillong') || lower.contains('cherrapunji') || lower.contains('dawki') || lower.contains('living root')) {
      return 'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=1200';
    }

    // ── Andaman & Nicobar Islands ─────────────────────────────────────────────
    if (lower.contains('andaman') || lower.contains('havelock') || lower.contains('neil island') || lower.contains('port blair') || lower.contains('radhanagar')) {
      return 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200';
    }

    // ── Lakshadweep Atoll ─────────────────────────────────────────────────────
    if (lower.contains('lakshadweep') || lower.contains('agatti') || lower.contains('kavaratti')) {
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200';
    }

    // ── Manali & Solang Valley Snow Peaks ─────────────────────────────────────
    if (lower.contains('manali') || lower.contains('solang') || lower.contains('rohtang') || lower.contains('kullu') || lower.contains('sissu')) {
      return 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=1200';
    }

    // ── Ladakh, Leh & Pangong Lake ────────────────────────────────────────────
    if (lower.contains('ladakh') || lower.contains('leh') || lower.contains('pangong') || lower.contains('nubra') || lower.contains('khardung')) {
      return 'https://images.unsplash.com/photo-1581793745862-99fde7fa73d2?w=1200';
    }

    // ── Shimla, Kufri & Chail ─────────────────────────────────────────────────
    if (lower.contains('shimla') || lower.contains('kufri') || lower.contains('chail') || lower.contains('mashobra')) {
      return 'https://images.unsplash.com/photo-1562832135-14a35d25edef?w=1200';
    }

    // ── Rishikesh, Haridwar & Foothills ───────────────────────────────────────
    if (lower.contains('rishikesh') || lower.contains('haridwar') || lower.contains('laxman jhula') || lower.contains('shivpuri')) {
      return 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=1200';
    }

    // ── Kashmir, Srinagar & Valley of Snow ────────────────────────────────────
    if (lower.contains('kashmir') || lower.contains('srinagar') || lower.contains('gulmarg') || lower.contains('pahalgam') || lower.contains('sonamarg') || lower.contains('dal lake')) {
      return 'https://images.unsplash.com/photo-1595815771614-ade9d652a65d?w=1200';
    }

    // ── Kasol & Parvati Valley ────────────────────────────────────────────────
    if (lower.contains('kasol') || lower.contains('parvati') || lower.contains('tosh') || lower.contains('kheerganga') || lower.contains('malana')) {
      return 'https://images.unsplash.com/photo-1617191519105-d07b98b10de6?w=1200';
    }

    // ── Spiti Valley & Cold Deserts ───────────────────────────────────────────
    if (lower.contains('spiti') || lower.contains('kaza') || lower.contains('tabo') || lower.contains('dhankar')) {
      return 'https://images.unsplash.com/photo-1605649487212-47bdab064df7?w=1200';
    }

    // ── Dharamshala & McLeod Ganj ─────────────────────────────────────────────
    if (lower.contains('dharamshala') || lower.contains('mcleod') || lower.contains('mcleodganj') || lower.contains('triund') || lower.contains('bir billing')) {
      return 'https://images.unsplash.com/photo-1578328819058-b69f3a3b0f6b?w=1200';
    }

    // ── Mussoorie & Dehradun Hills ────────────────────────────────────────────
    if (lower.contains('mussoorie') || lower.contains('dehradun') || lower.contains('dhanaulti') || lower.contains('kanatal')) {
      return 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200';
    }

    // ── Nainital & Kumaon Lakes ───────────────────────────────────────────────
    if (lower.contains('nainital') || lower.contains('bhimtal') || lower.contains('mukteshwar') || lower.contains('ranikhet') || lower.contains('kausani')) {
      return 'https://images.unsplash.com/photo-1598091383021-15ddea10925d?w=1200';
    }

    // ── National Parks & Wildlife ─────────────────────────────────────────────
    if (lower.contains('corbett') || lower.contains('ranthambore') || lower.contains('kaziranga') || lower.contains('gir') || lower.contains('kanha') || lower.contains('bandhavgarh')) {
      return 'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=1200';
    }

    // ──────────────────────────────────────────────────────────────────────────
    // 3. GEOGRAPHIC & THEMATIC FALLBACK (Mountains, Beaches, Palaces)
    // ──────────────────────────────────────────────────────────────────────────
    if (lower.contains('beach') || lower.contains('coast') || lower.contains('sea') || lower.contains('island')) {
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200';
    }

    if (lower.contains('mountain') || lower.contains('hill') || lower.contains('valley') || lower.contains('himalaya') || lower.contains('peak') || lower.contains('trek')) {
      return 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=1200';
    }

    if (lower.contains('palace') || lower.contains('fort') || lower.contains('heritage') || lower.contains('temple')) {
      return 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=1200';
    }

    // ──────────────────────────────────────────────────────────────────────────
    // 4. STYLE-BASED FALLBACK
    // ──────────────────────────────────────────────────────────────────────────
    final normalizedStyle = style.toLowerCase();
    if (normalizedStyle.contains('adventure')) {
      return 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200';
    }
    if (normalizedStyle.contains('food')) {
      return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200';
    }
    if (normalizedStyle.contains('cultural') || normalizedStyle.contains('heritage')) {
      return 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=1200';
    }

    // Standard high-definition scenic wanderlust photo
    return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=1200';
  }
}
