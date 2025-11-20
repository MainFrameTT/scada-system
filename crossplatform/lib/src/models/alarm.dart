class Alarm {
  final int id;
  final String name;
  final String message;
  final String severity;
  final String state;
  final DateTime timestamp;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final int? acknowledgedBy;
  final String? tagName;
  final int? tagId;
  final String? objectName;
  final double? value;
  final double? threshold;

  Alarm({
    required this.id,
    required this.name,
    required this.message,
    required this.severity,
    required this.state,
    required this.timestamp,
    this.acknowledgedAt,
    this.resolvedAt,
    this.acknowledgedBy,
    this.tagName,
    this.tagId,
    this.objectName,
    this.value,
    this.threshold,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'MEDIUM',
      state: json['state'] ?? 'ACTIVE',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      acknowledgedAt: json['acknowledged_at'] != null 
          ? DateTime.parse(json['acknowledged_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      acknowledgedBy: json['acknowledged_by'],
      tagName: json['tag_name'],
      tagId: json['tag_id'],
      objectName: json['object_name'],
      value: (json['value'] ?? 0.0).toDouble(),
      threshold: (json['threshold'] ?? 0.0).toDouble(),
    );
  }

  Alarm copyWith({
    int? id,
    String? name,
    String? message,
    String? severity,
    String? state,
    DateTime? timestamp,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
    int? acknowledgedBy,
    String? tagName,
    int? tagId,
    String? objectName,
    double? value,
    double? threshold,
  }) {
    return Alarm(
      id: id ?? this.id,
      name: name ?? this.name,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      state: state ?? this.state,
      timestamp: timestamp ?? this.timestamp,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      tagName: tagName ?? this.tagName,
      tagId: tagId ?? this.tagId,
      objectName: objectName ?? this.objectName,
      value: value ?? this.value,
      threshold: threshold ?? this.threshold,
    );
  }

  // Helper getters
  bool get isActive => state == 'ACTIVE';
  bool get isAcknowledged => state == 'ACKNOWLEDGED';
  bool get isResolved => state == 'RESOLVED';

  bool get isCritical => severity == 'CRITICAL';
  bool get isHigh => severity == 'HIGH';
  bool get isMedium => severity == 'MEDIUM';
  bool get isLow => severity == 'LOW';

  String get alarmDefinitionName => name;

   
  String get durationText {
    final now = DateTime.now();
    final duration = now.difference(timestamp);
    
    if (duration.inDays > 0) {
      return '${duration.inDays}д ${duration.inHours.remainder(24)}ч';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}ч ${duration.inMinutes.remainder(60)}м';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}м';
    } else {
      return '${duration.inSeconds}с';
    }
  }

  bool get canAcknowledge => isActive && !isAcknowledged;

  DateTime get triggeredAt => timestamp;

  String get stateText {
    switch (state) {
      case 'ACTIVE':
        return 'Активна';
      case 'ACKNOWLEDGED':
        return 'Квитирована';
      case 'RESOLVED':
        return 'Разрешена';
      default:
        return state;
    }
  }

  String? get acknowledgedByName => acknowledgedBy != null ? 'Оператор $acknowledgedBy' : null;
}

  String get statusText {
    switch (state) {
      case 'ACTIVE':
        return 'Активна';
      case 'ACKNOWLEDGED':
        return 'Квитирована';
      case 'RESOLVED':
        return 'Разрешена';
      default:
        return state;
    }
  }

  String get severityText {
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
}