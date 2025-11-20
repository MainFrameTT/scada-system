class Alarm {
  final int id;
  final String alarmDefinitionName;
  final String tagName;
  final String message;
  final String severity;
  final String state;
  final DateTime triggeredAt;
  final DateTime? acknowledgedAt;
  final String? acknowledgedByName;

  const Alarm({
    required this.id,
    required this.alarmDefinitionName,
    required this.tagName,
    required this.message,
    required this.severity,
    required this.state,
    required this.triggeredAt,
    this.acknowledgedAt,
    this.acknowledgedByName,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as int,
      alarmDefinitionName: json['alarm_definition_name'] as String,
      tagName: json['tag_name'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      state: json['state'] as String,
      triggeredAt: DateTime.parse(json['triggered_at'] as String),
      acknowledgedAt: json['acknowledged_at'] != null 
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
      acknowledgedByName: json['acknowledged_by_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alarm_definition_name': alarmDefinitionName,
      'tag_name': tagName,
      'message': message,
      'severity': severity,
      'state': state,
      'triggered_at': triggeredAt.toIso8601String(),
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
      'acknowledged_by_name': acknowledgedByName,
    };
  }

  Alarm copyWith({
    int? id,
    String? alarmDefinitionName,
    String? tagName,
    String? message,
    String? severity,
    String? state,
    DateTime? triggeredAt,
    DateTime? acknowledgedAt,
    String? acknowledgedByName,
  }) {
    return Alarm(
      id: id ?? this.id,
      alarmDefinitionName: alarmDefinitionName ?? this.alarmDefinitionName,
      tagName: tagName ?? this.tagName,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      state: state ?? this.state,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedByName: acknowledgedByName ?? this.acknowledgedByName,
    );
  }

  // Helper methods
  bool get isActive => state == 'ACTIVE';
  bool get isAcknowledged => state == 'ACKNOWLEDGED';
  bool get isResolved => state == 'RESOLVED';

  bool get isCritical => severity == 'CRITICAL';
  bool get isHigh => severity == 'HIGH';
  bool get isMedium => severity == 'MEDIUM';
  bool get isLow => severity == 'LOW';

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

  String get stateText {
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

  Duration get duration {
    return DateTime.now().difference(triggeredAt);
  }

  String get durationText {
    final duration = this.duration;
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

  bool get canAcknowledge => isActive;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alarm && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Alarm(id: $id, $alarmDefinitionName, $severity, $state)';
  }
}

class AlarmDefinition {
  final int id;
  final int tagId;
  final String tagName;
  final String name;
  final String condition;
  final double triggerValue;
  final String message;
  final String severity;
  final bool isEnabled;

  const AlarmDefinition({
    required this.id,
    required this.tagId,
    required this.tagName,
    required this.name,
    required this.condition,
    required this.triggerValue,
    required this.message,
    required this.severity,
    required this.isEnabled,
  });

  factory AlarmDefinition.fromJson(Map<String, dynamic> json) {
    return AlarmDefinition(
      id: json['id'] as int,
      tagId: json['tag'] as int,
      tagName: json['tag_name'] as String,
      name: json['name'] as String,
      condition: json['condition'] as String,
      triggerValue: (json['trigger_value'] as num).toDouble(),
      message: json['message'] as String,
      severity: json['severity'] as String,
      isEnabled: json['is_enabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag': tagId,
      'tag_name': tagName,
      'name': name,
      'condition': condition,
      'trigger_value': triggerValue,
      'message': message,
      'severity': severity,
      'is_enabled': isEnabled,
    };
  }

  String get conditionText {
    switch (condition) {
      case 'GT':
        return 'Больше $triggerValue';
      case 'LT':
        return 'Меньше $triggerValue';
      case 'EQ':
        return 'Равно $triggerValue';
      case 'CHANGE':
        return 'Изменение';
      default:
        return condition;
    }
  }

  @override
  String toString() {
    return 'AlarmDefinition(id: $id, $name, $conditionText)';
  }
}