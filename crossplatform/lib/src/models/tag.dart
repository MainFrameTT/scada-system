class Tag {
  final int id;
  final String name;
  final String description;
  final double value;
  final String unit;
  final String objectTypeName;
  final String pipelineObjectName;
  final DateTime timestamp;
  final int quality;
  final double minValue;
  final double maxValue;
  final String dataType;
  final int objectIndex;
  final double kmMark;
  final String engineeringUnits;

   Tag({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.objectTypeName,
    required this.pipelineObjectName,
    required this.timestamp,
    required this.quality,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.dataType = 'Analog',
    this.objectIndex = 0,
    this.kmMark = 0.0,
    this.engineeringUnits = '',
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      objectTypeName: json['object_type_name'] ?? '',
      pipelineObjectName: json['pipeline_object_name'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      quality: json['quality'] ?? 0,
      minValue: (json['min_value'] ?? 0.0).toDouble(),
      maxValue: (json['max_value'] ?? 100.0).toDouble(),
      dataType: json['data_type'] ?? 'Analog',
      objectIndex: json['object_index'] ?? 0,
      kmMark: (json['km_mark'] ?? 0.0).toDouble(),
      engineeringUnits: json['engineering_units'] ?? '',
    );
  }

  // Геттеры для вычисляемых свойств
  double get normalizedValue {
    if (maxValue - minValue == 0) return 0.0;
    return ((value - minValue) / (maxValue - minValue)) * 100;
  }

  String get formattedValue => '$value $unit';

  bool get isCritical => quality < 70;
  bool get isWarning => quality >= 70 && quality < 90;
  bool get isNormal => quality >= 90;

  double get currentValue => value;
  int get currentQuality => quality;
}

class TagValue {
  final double value;
  final DateTime timestamp;
  final int quality;

  TagValue({
    required this.value,
    required this.timestamp,
    required this.quality,
  });

  factory TagValue.fromJson(Map<String, dynamic> json) {
    return TagValue(
      value: (json['value'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      quality: json['quality'] ?? 0,
    );
  }
}