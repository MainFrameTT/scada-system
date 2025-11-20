class Tag {
  final int id;
  final String name;
  final String description;
  final String dataType;
  final String engineeringUnits;
  final double minValue;
  final double maxValue;
  final double currentValue;
  final int currentQuality;
  final String pipelineObjectName;
  final String objectTypeName;
  final String objectIndex;
  final double kmMark;
  final bool isArchived;

  const Tag({
    required this.id,
    required this.name,
    required this.description,
    required this.dataType,
    required this.engineeringUnits,
    required this.minValue,
    required this.maxValue,
    required this.currentValue,
    required this.currentQuality,
    required this.pipelineObjectName,
    required this.objectTypeName,
    required this.objectIndex,
    required this.kmMark,
    required this.isArchived,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      dataType: json['data_type'] as String,
      engineeringUnits: json['engineering_units'] as String,
      minValue: (json['min_value'] as num).toDouble(),
      maxValue: (json['max_value'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      currentQuality: json['current_quality'] as int,
      pipelineObjectName: json['pipeline_object_name'] as String,
      objectTypeName: json['object_type_name'] as String,
      objectIndex: json['object_index'] as String,
      kmMark: (json['km_mark'] as num).toDouble(),
      isArchived: json['is_archived'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'data_type': dataType,
      'engineering_units': engineeringUnits,
      'min_value': minValue,
      'max_value': maxValue,
      'current_value': currentValue,
      'current_quality': currentQuality,
      'pipeline_object_name': pipelineObjectName,
      'object_type_name': objectTypeName,
      'object_index': objectIndex,
      'km_mark': kmMark,
      'is_archived': isArchived,
    };
  }

  Tag copyWith({
    int? id,
    String? name,
    String? description,
    String? dataType,
    String? engineeringUnits,
    double? minValue,
    double? maxValue,
    double? currentValue,
    int? currentQuality,
    String? pipelineObjectName,
    String? objectTypeName,
    String? objectIndex,
    double? kmMark,
    bool? isArchived,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dataType: dataType ?? this.dataType,
      engineeringUnits: engineeringUnits ?? this.engineeringUnits,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      currentValue: currentValue ?? this.currentValue,
      currentQuality: currentQuality ?? this.currentQuality,
      pipelineObjectName: pipelineObjectName ?? this.pipelineObjectName,
      objectTypeName: objectTypeName ?? this.objectTypeName,
      objectIndex: objectIndex ?? this.objectIndex,
      kmMark: kmMark ?? this.kmMark,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  // Helper methods
  bool get isCritical {
    final normalized = (currentValue - minValue) / (maxValue - minValue);
    return normalized < 0.1 || normalized > 0.9;
  }

  bool get isWarning {
    final normalized = (currentValue - minValue) / (maxValue - minValue);
    return (normalized >= 0.1 && normalized < 0.2) || 
           (normalized > 0.8 && normalized <= 0.9);
  }

  bool get isNormal {
    return !isCritical && !isWarning;
  }

  double get normalizedValue {
    return (currentValue - minValue) / (maxValue - minValue);
  }

  String get formattedValue {
    return '$currentValue $engineeringUnits';
  }

  String get qualityStatus {
    if (currentQuality >= 90) return 'Отличное';
    if (currentQuality >= 70) return 'Хорошее';
    if (currentQuality >= 50) return 'Удовлетворительное';
    return 'Плохое';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Tag(id: $id, name: $name, value: $currentValue $engineeringUnits)';
  }
}

class TagValue {
  final int id;
  final int tagId;
  final String tagName;
  final double value;
  final int quality;
  final DateTime timestamp;

  const TagValue({
    required this.id,
    required this.tagId,
    required this.tagName,
    required this.value,
    required this.quality,
    required this.timestamp,
  });

  factory TagValue.fromJson(Map<String, dynamic> json) {
    return TagValue(
      id: json['id'] as int,
      tagId: json['tag'] as int,
      tagName: json['tag_name'] as String,
      value: (json['value'] as num).toDouble(),
      quality: json['quality'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag': tagId,
      'tag_name': tagName,
      'value': value,
      'quality': quality,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TagValue(tag: $tagName, value: $value, time: $timestamp)';
  }
}