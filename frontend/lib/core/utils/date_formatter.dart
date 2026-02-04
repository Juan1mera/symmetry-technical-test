
/// Utilidad para formatear fechas en español
class DateFormatter {
  // Mapeo de nombres de meses en español
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

  /// Formatea una fecha al formato: DD de MM, del AAAA, a las hh:mm
  /// Ejemplo: "15 de Enero, del 2024, a las 14:30"
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
      // Si falla intentar con diferentes formatos
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
        // Si todo falla retorna la fecha original
      }
      return dateString;
    }
  }

  /// Formatea una fecha a un formato corto
  /// Ejemplo: "15 Ene, 14:30"
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

  // Prevenir instanciación
  DateFormatter._();
}
