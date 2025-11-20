class AppConstants {
  // API Constants
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const String websocketBaseUrl = 'ws://localhost:8000/ws';
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration websocketReconnectDelay = Duration(seconds: 5);

  // Storage Keys
  static const String storageThemeMode = 'theme_mode';
  static const String storageLanguage = 'language';
  static const String storageApiUrl = 'api_url';
  static const String storageAuthToken = 'auth_token';
  static const String storageUserPreferences = 'user_preferences';

  // Pagination
  static const int defaultPageSize = 50;
  static const int mobilePageSize = 20;
  static const int tabletPageSize = 30;
  static const int desktopPageSize = 50;

  // Refresh Intervals
  static const Duration tagsRefreshInterval = Duration(seconds: 30);
  static const Duration alarmsRefreshInterval = Duration(seconds: 15);
  static const Duration dashboardRefreshInterval = Duration(seconds: 10);
  static const Duration historyRefreshInterval = Duration(minutes: 5);

  // Animation Durations
  static const Duration quickAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Default Values
  static const double defaultTagMinValue = 0.0;
  static const double defaultTagMaxValue = 100.0;
  static const int defaultTagQuality = 100;
  static const int defaultHistoryHours = 24;

  // Validation
  static const int maxTagNameLength = 100;
  static const int maxTagDescriptionLength = 500;
  static const int maxAlarmMessageLength = 200;
  static const int maxObjectNameLength = 100;
}

class RouteConstants {
  static const String dashboard = '/';
  static const String tags = '/tags';
  static const String alarms = '/alarms';
  static const String objects = '/objects';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String splash = '/splash';
}

class SeverityConstants {
  static const String critical = 'CRITICAL';
  static const String high = 'HIGH';
  static const String medium = 'MEDIUM';
  static const String low = 'LOW';

  static const List<String> allSeverities = [critical, high, medium, low];

  static String getDisplayText(String severity) {
    switch (severity) {
      case critical:
        return 'Критическая';
      case high:
        return 'Высокая';
      case medium:
        return 'Средняя';
      case low:
        return 'Низкая';
      default:
        return severity;
    }
  }

  static int getPriority(String severity) {
    switch (severity) {
      case critical:
        return 1;
      case high:
        return 2;
      case medium:
        return 3;
      case low:
        return 4;
      default:
        return 5;
    }
  }
}

class AlarmStateConstants {
  static const String active = 'ACTIVE';
  static const String acknowledged = 'ACKNOWLEDGED';
  static const String resolved = 'RESOLVED';

  static const List<String> allStates = [active, acknowledged, resolved];

  static String getDisplayText(String state) {
    switch (state) {
      case active:
        return 'Активна';
      case acknowledged:
        return 'Квитирована';
      case resolved:
        return 'Сброшена';
      default:
        return state;
    }
  }
}

class DataTypeConstants {
  static const String float = 'float';
  static const String integer = 'integer';
  static const String boolean = 'boolean';
  static const String string = 'string';

  static const List<String> allDataTypes = [float, integer, boolean, string];

  static String getDisplayText(String dataType) {
    switch (dataType) {
      case float:
        return 'Дробное';
      case integer:
        return 'Целое';
      case boolean:
        return 'Логическое';
      case string:
        return 'Строка';
      default:
        return dataType;
    }
  }
}

class ObjectTypeConstants {
  static const String nps = 'НПС';
  static const String tank = 'Резервуар';
  static const String pump = 'Насос';
  static const String valve = 'Клапан';
  static const String pressureSensor = 'ДК';
  static const String temperatureSensor = 'ДТ';
  static const String flowSensor = 'ДР';
  static const String gateValve = 'ЗК';

  static const List<String> allObjectTypes = [
    nps,
    tank,
    pump,
    valve,
    pressureSensor,
    temperatureSensor,
    flowSensor,
    gateValve,
  ];

  static String getIcon(String objectType) {
    switch (objectType) {
      case nps:
        return '🏭';
      case tank:
        return '🛢️';
      case pump:
        return '⚙️';
      case valve:
        return '🔧';
      case pressureSensor:
        return '📊';
      case temperatureSensor:
        return '🌡️';
      case flowSensor:
        return '📈';
      case gateValve:
        return '🚪';
      default:
        return '🏗️';
    }
  }

  static String getDescription(String objectType) {
    switch (objectType) {
      case nps:
        return 'Нефтеперекачивающая станция';
      case tank:
        return 'Резервуар хранения нефти';
      case pump:
        return 'Насосный агрегат';
      case valve:
        return 'Запорная арматура';
      case pressureSensor:
        return 'Датчик давления';
      case temperatureSensor:
        return 'Датчик температуры';
      case flowSensor:
        return 'Датчик расхода';
      case gateValve:
        return 'Задвижка камерная';
      default:
        return 'Объект нефтепровода';
    }
  }

  static int getPriority(String objectType) {
    switch (objectType) {
      case nps:
        return 1;
      case tank:
        return 2;
      case pump:
        return 3;
      case valve:
        return 4;
      case gateValve:
        return 5;
      case pressureSensor:
      case temperatureSensor:
      case flowSensor:
        return 6;
      default:
        return 7;
    }
  }
}

class EngineeringUnits {
  static const String pressure = 'МПа';
  static const String temperature = '°C';
  static const String flow = 'м³/ч';
  static const String level = 'м';
  static const String volume = 'м³';
  static const String percent = '%';
  static const String dimensionless = '';

  static const Map<String, String> defaultUnits = {
    'PRESSURE': pressure,
    'TEMPERATURE': temperature,
    'FLOW': flow,
    'LEVEL': level,
    'VOLUME': volume,
    'PERCENT': percent,
  };

  static String getDisplayText(String unit) {
    switch (unit) {
      case pressure:
        return 'Мегапаскали';
      case temperature:
        return 'Градусы Цельсия';
      case flow:
        return 'Кубические метры в час';
      case level:
        return 'Метры';
      case volume:
        return 'Кубические метры';
      case percent:
        return 'Проценты';
      case dimensionless:
        return 'Безразмерная';
      default:
        return unit;
    }
  }
}

class ThresholdConstants {
  static const double criticalLowerThreshold = 0.1;
  static const double criticalUpperThreshold = 0.9;
  static const double warningLowerThreshold = 0.2;
  static const double warningUpperThreshold = 0.8;

  static const int excellentQuality = 90;
  static const int goodQuality = 70;
  static const int satisfactoryQuality = 50;

  static String getQualityStatus(int quality) {
    if (quality >= excellentQuality) return 'Отличное';
    if (quality >= goodQuality) return 'Хорошее';
    if (quality >= satisfactoryQuality) return 'Удовлетворительное';
    return 'Плохое';
  }

  static Color getQualityColor(int quality) {
    if (quality >= excellentQuality) return const Color(0xFF10B981); // Normal
    if (quality >= goodQuality) return const Color(0xFFF59E0B); // Warning
    return const Color(0xFFEF4444); // Critical
  }
}

class PlatformConstants {
  static const String android = 'android';
  static const String ios = 'ios';
  static const String windows = 'windows';
  static const String linux = 'linux';
  static const String macos = 'macos';
  static const String web = 'web';

  static bool isDesktop(String platform) {
    return platform == windows || platform == linux || platform == macos;
  }

  static bool isMobile(String platform) {
    return platform == android || platform == ios;
  }

  static String getPlatformDisplayName(String platform) {
    switch (platform) {
      case android:
        return 'Android';
      case ios:
        return 'iOS';
      case windows:
        return 'Windows';
      case linux:
        return 'Linux';
      case macos:
        return 'macOS';
      case web:
        return 'Web';
      default:
        return platform;
    }
  }
}

class ErrorMessages {
  static const String networkError = 'Ошибка сети. Проверьте подключение к интернету.';
  static const String serverError = 'Ошибка сервера. Попробуйте позже.';
  static const String unauthorized = 'Неавторизованный доступ. Войдите в систему.';
  static const String forbidden = 'Доступ запрещен.';
  static const String notFound = 'Ресурс не найден.';
  static const String timeout = 'Время ожидания истекло.';
  static const String unknownError = 'Неизвестная ошибка.';
  static const String dataParseError = 'Ошибка обработки данных.';
  static const String websocketError = 'Ошибка WebSocket соединения.';

  static String getApiErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Неверный запрос.';
      case 401:
        return unauthorized;
      case 403:
        return forbidden;
      case 404:
        return notFound;
      case 408:
        return timeout;
      case 500:
        return serverError;
      case 502:
        return 'Плохой шлюз.';
      case 503:
        return 'Сервис недоступен.';
      default:
        return unknownError;
    }
  }
}

class LocalizationConstants {
  static const String defaultLanguage = 'ru';
  static const String fallbackLanguage = 'en';

  static const Map<String, String> supportedLanguages = {
    'ru': 'Русский',
    'en': 'English',
  };

  static const Map<String, String> dateFormats = {
    'ru': 'dd.MM.yyyy',
    'en': 'MM/dd/yyyy',
  };

  static const Map<String, String> timeFormats = {
    'ru': 'HH:mm',
    'en': 'hh:mm a',
  };
}