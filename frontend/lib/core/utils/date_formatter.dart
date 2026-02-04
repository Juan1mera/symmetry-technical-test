
/// Utility for formatting dates into human-readable strings
class DateFormatter {
  // Month names for display
  static const Map<int, String> _monthNames = {
    1: 'Enero',
    2: 'Febrero',
    3: 'Marzo',
    4: 'Abril',
    5: 'Mayo',
    6: 'Junio',
    7: 'Julio',
    8: 'Agosto',
    9: 'Septiembre',
    10: 'Octubre',
    11: 'Noviembre',
    12: 'Diciembre',
  };

  /// Formats a date into a specific format: DD of MM, YYYY, at HH:mm
  /// Example: "15 of January, 2024, at 14:30"
  static String formatToSpanish(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      
      int day = date.day;
      String month = _monthNames[date.month] ?? '';
      int year = date.year;
      String hour = date.hour.toString().padLeft(2, '0');
      String minute = date.minute.toString().padLeft(2, '0');
      
      return '$day de $month, del $year, a las $hour:$minute';
    } catch (e) {
      // If initial parsing fails, try splitting by the ISO separator
      try {
        final parts = dateString.split('T');
        if (parts.length >= 2) {
          DateTime date = DateTime.parse(dateString);
          int day = date.day;
          String month = _monthNames[date.month] ?? '';
          int year = date.year;
          String hour = date.hour.toString().padLeft(2, '0');
          String minute = date.minute.toString().padLeft(2, '0');
          
          return '$day de $month, del $year, a las $hour:$minute';
        }
      } catch (e) {
        // If all parsing attempts fail, return the original string
      }
      return dateString;
    }
  }

  /// Formats a date to a short preview version
  /// Example: "15 Jan, 14:30"
  static String formatToShort(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      
      int day = date.day;
      String month = _monthNames[date.month]?.substring(0, 3) ?? '';
      String hour = date.hour.toString().padLeft(2, '0');
      String minute = date.minute.toString().padLeft(2, '0');
      
      return '$day $month, $hour:$minute';
    } catch (e) {
      return dateString;
    }
  }

  // Private constructor to prevent instantiation
  DateFormatter._();
}
