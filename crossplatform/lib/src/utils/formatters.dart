import 'package:intl/intl.dart';

class Formatters {
  // Date and Time Formatters
  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');
  static final DateFormat _fullDateTimeFormat = DateFormat('dd.MM.yyyy HH:mm:ss');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _apiDateTimeFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

  // Number Formatters
  static final NumberFormat _decimalFormat = NumberFormat.decimalPattern('ru_RU');
  static final NumberFormat _compactFormat = NumberFormat.compact(locale: 'ru_RU');
  static final NumberFormat _percentFormat = NumberFormat.percentPattern('ru_RU');

  // Currency Formatters (if needed)
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ru_RU',
    symbol: '₽',
    decimalDigits: 2,
  );

  // Date and Time Methods
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatFullDateTime(DateTime date) {
    return _fullDateTimeFormat.format(date);
  }

  static String formatApiDate(DateTime date) {
    return _apiDateFormat.format(date);
  }

  static String formatApiDateTime(DateTime date) {
    return _apiDateTimeFormat.format(date);
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${_getMinutesText(difference.inMinutes)} назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${_getHoursText(difference.inHours)} назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${_getDaysText(difference.inDays)} назад';
    } else {
      return formatDate(date);
    }
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}д ${duration.inHours.remainder(24)}ч';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}ч ${duration.inMinutes.remainder(60)}м';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}м ${duration.inSeconds.remainder(60)}с';
    } else {
      return '${duration.inSeconds}с';
    }
  }

  // Number Methods
  static String formatDecimal(num value, {int decimalDigits = 2}) {
    final formatter = NumberFormat.decimalPatternDigits(
      locale: 'ru_RU',
      decimalDigits: decimalDigits,
    );
    return formatter.format(value);
  }

  static String formatCompact(num value) {
    return _compactFormat.format(value);
  }

  static String formatPercent(double value, {int decimalDigits = 1}) {
    final formatter = NumberFormat.percentPattern('ru_RU')
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  static String formatCurrency(num value) {
    return _currencyFormat.format(value);
  }

  // Tag Value Formatters
  static String formatTagValue(double value, String dataType, {String? units}) {
    switch (dataType) {
      case 'float':
        return '${formatDecimal(value, decimalDigits: 2)}${units != null && units.isNotEmpty ? ' $units' : ''}';
      case 'integer':
        return '${value.toInt()}${units != null && units.isNotEmpty ? ' $units' : ''}';
      case 'boolean':
        return value >= 1 ? 'ВКЛ' : 'ВЫКЛ';
      case 'string':
        return value.toString();
      default:
        return '${formatDecimal(value)}${units != null && units.isNotEmpty ? ' $units' : ''}';
    }
  }

  static String formatTagValueWithPrecision(double value, String dataType, int precision, {String? units}) {
    switch (dataType) {
      case 'float':
        return '${formatDecimal(value, decimalDigits: precision)}${units != null && units.isNotEmpty ? ' $units' : ''}';
      case 'integer':
        return '${value.toInt()}${units != null && units.isNotEmpty ? ' $units' : ''}';
      case 'boolean':
        return value >= 1 ? 'ВКЛ' : 'ВЫКЛ';
      case 'string':
        return value.toStringAsFixed(precision);
      default:
        return '${formatDecimal(value, decimalDigits: precision)}${units != null && units.isNotEmpty ? ' $units' : ''}';
    }
  }

  // Quality Formatters
  static String formatQuality(int quality) {
    return '$quality%';
  }

  static String formatQualityStatus(int quality) {
    if (quality >= 90) return 'Отличное';
    if (quality >= 70) return 'Хорошее';
    if (quality >= 50) return 'Удовлетворительное';
    return 'Плохое';
  }

  // Alarm Formatters
  static String formatAlarmDuration(DateTime triggeredAt) {
    final duration = DateTime.now().difference(triggeredAt);
    return formatDuration(duration);
  }

  static String formatAlarmSeverity(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return 'Критическая';
      case 'HIGH':
        return 'Высокая';
      case 'MEDIUM':
        return 'Средняя';
      case 'LOW':
        return 'Низкая';
      default:
        return severity;
    }
  }

  static String formatAlarmState(String state) {
    switch (state) {
      case 'ACTIVE':
        return 'Активна';
      case 'ACKNOWLEDGED':
        return 'Квитирована';
      case 'RESOLVED':
        return 'Сброшена';
      default:
        return state;
    }
  }

  // File Size Formatters
  static String formatFileSize(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 Б';
    
    const suffixes = ['Б', 'КБ', 'МБ', 'ГБ', 'ТБ'];
    final i = (log(bytes) / log(1024)).floor();
    
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  // Phone Number Formatter (if needed)
  static String formatPhoneNumber(String phone) {
    if (phone.length == 11 && phone.startsWith('7')) {
      return '+7 (${phone.substring(1, 4)}) ${phone.substring(4, 7)}-${phone.substring(7, 9)}-${phone.substring(9)}';
    } else if (phone.length == 10) {
      return '+7 (${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6, 8)}-${phone.substring(8)}';
    }
    return phone;
  }

  // Text Truncation
  static String truncateText(String text, {int maxLength = 50, String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  static String truncateWithWordBoundary(String text, {int maxLength = 50, String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    
    final truncated = text.substring(0, maxLength - ellipsis.length);
    final lastSpace = truncated.lastIndexOf(' ');
    
    if (lastSpace > 0) {
      return '${truncated.substring(0, lastSpace)}$ellipsis';
    }
    
    return '$truncated$ellipsis';
  }

  // Case Conversion
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  static String toCamelCase(String text) {
    if (text.isEmpty) return text;
    
    final words = text.split(' ');
    final camelCase = words.map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join();
    
    return '${camelCase[0].toLowerCase()}${camelCase.substring(1)}';
  }

  // Validation Helpers
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(
      r'^[\+]?[0-9\s\-\(\)]{10,}$',
    );
    return phoneRegex.hasMatch(phone);
  }

  // Color Formatters
  static String formatHexColor(int color) {
    return '#${color.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static String formatRgbColor(int color) {
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;
    return 'RGB($r, $g, $b)';
  }

  // Helper Methods for Pluralization
  static String _getMinutesText(int minutes) {
    final lastDigit = minutes % 10;
    final lastTwoDigits = minutes % 100;
    
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return 'минут';
    }
    
    switch (lastDigit) {
      case 1:
        return 'минуту';
      case 2:
      case 3:
      case 4:
        return 'минуты';
      default:
        return 'минут';
    }
  }

  static String _getHoursText(int hours) {
    final lastDigit = hours % 10;
    final lastTwoDigits = hours % 100;
    
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return 'часов';
    }
    
    switch (lastDigit) {
      case 1:
        return 'час';
      case 2:
      case 3:
      case 4:
        return 'часа';
      default:
        return 'часов';
    }
  }

  static String _getDaysText(int days) {
    final lastDigit = days % 10;
    final lastTwoDigits = days % 100;
    
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return 'дней';
    }
    
    switch (lastDigit) {
      case 1:
        return 'день';
      case 2:
      case 3:
      case 4:
        return 'дня';
      default:
        return 'дней';
    }
  }

  // Temperature Conversion (if needed)
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  // Pressure Conversion (if needed)
  static double mpaToPsi(double mpa) {
    return mpa * 145.038;
  }

  static double psiToMpa(double psi) {
    return psi / 145.038;
  }

  // Flow Conversion (if needed)
  static double cubicMetersToGallons(double cubicMeters) {
    return cubicMeters * 264.172;
  }

  static double gallonsToCubicMeters(double gallons) {
    return gallons / 264.172;
  }
}

// Extension methods for easier usage
extension DateTimeFormatter on DateTime {
  String toFormattedDate() => Formatters.formatDate(this);
  String toFormattedTime() => Formatters.formatTime(this);
  String toFormattedDateTime() => Formatters.formatDateTime(this);
  String toFormattedFullDateTime() => Formatters.formatFullDateTime(this);
  String toRelativeTime() => Formatters.formatRelativeTime(this);
}

extension NumberFormatter on num {
  String toFormattedDecimal({int decimalDigits = 2}) => 
      Formatters.formatDecimal(this, decimalDigits: decimalDigits);
  
  String toFormattedCompact() => Formatters.formatCompact(this);
  String toFormattedPercent({int decimalDigits = 1}) => 
      Formatters.formatPercent(toDouble(), decimalDigits: decimalDigits);
  String toFormattedCurrency() => Formatters.formatCurrency(this);
}

extension StringFormatter on String {
  String toTitleCase() => Formatters.toTitleCase(this);
  String toCamelCase() => Formatters.toCamelCase(this);
  String truncate({int maxLength = 50}) => 
      Formatters.truncateText(this, maxLength: maxLength);
  String truncateWithWordBoundary({int maxLength = 50}) => 
      Formatters.truncateWithWordBoundary(this, maxLength: maxLength);
  bool get isValidEmail => Formatters.isValidEmail(this);
  bool get isValidPhone => Formatters.isValidPhone(this);
  String toFormattedPhone() => Formatters.formatPhoneNumber(this);
}