class DateFormatter {
  static String formatIsoDate(String isoString) {
    return isoString.split('T').first;
  }
}
