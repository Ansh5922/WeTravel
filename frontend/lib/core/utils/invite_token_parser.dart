/// Utilities for parsing and sanitizing invite tokens from URLs and inputs.
class InviteTokenParser {
  InviteTokenParser._();

  /// Extracts a clean token or trip ID from raw input, whether it is a full URL,
  /// a deep link, or a raw token.
  ///
  /// Examples:
  /// - `https://wetravel.app/trips/join/abc-123` -> `abc-123`
  /// - `wetravel://trips/join/abc-123?ref=wa` -> `abc-123`
  /// - `abc-123` -> `abc-123`
  static String parse(String rawInput) {
    var clean = rawInput.trim();
    if (clean.isEmpty) return '';

    // Strip trailing query parameters
    if (clean.contains('?')) {
      clean = clean.split('?').first;
    }
    // Strip trailing slash
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }

    // If it contains slashes, extract the last path segment
    if (clean.contains('/')) {
      final uri = Uri.tryParse(clean);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        clean = uri.pathSegments.last;
      } else {
        final segments = clean.split('/').where((s) => s.isNotEmpty).toList();
        if (segments.isNotEmpty) {
          clean = segments.last;
        }
      }
    }

    return clean.trim();
  }
}
