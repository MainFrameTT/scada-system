class PipelineObject {
  final int id;
  final String name;
  final String index;
  final String objectTypeName;
  final String location;
  final double kmMark;
  final String description;

  const PipelineObject({
    required this.id,
    required this.name,
    required this.index,
    required this.objectTypeName,
    required this.location,
    required this.kmMark,
    required this.description,
  });

  factory PipelineObject.fromJson(Map<String, dynamic> json) {
    return PipelineObject(
      id: json['id'] as int,
      name: json['name'] as String,
      index: json['index'] as String,
      objectTypeName: json['object_type_name'] as String,
      location: json['location'] as String,
      kmMark: (json['km_mark'] as num).toDouble(),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'index': index,
      'object_type_name': objectTypeName,
      'location': location,
      'km_mark': kmMark,
      'description': description,
    };
  }

  PipelineObject copyWith({
    int? id,
    String? name,
    String? index,
    String? objectTypeName,
    String? location,
    double? kmMark,
    String? description,
  }) {
    return PipelineObject(
      id: id ?? this.id,
      name: name ?? this.name,
      index: index ?? this.index,
      objectTypeName: objectTypeName ?? this.objectTypeName,
      location: location ?? this.location,
      kmMark: kmMark ?? this.kmMark,
      description: description ?? this.description,
    );
  }

  // Helper methods
  String get displayName => '$objectTypeName $index - $name';

  String get formattedKmMark => '${kmMark.toStringAsFixed(1)} км';

  String get icon {
    switch (objectTypeName) {
      case 'НПС':
        return '🏭';
      case 'Резервуар':
        return '🛢️';
      case 'Насос':
        return '⚙️';
      case 'Клапан':
        return '🔧';
      case 'ДК':
        return '📊';
      case 'ДТ':
        return '🌡️';
      case 'ДР':
        return '📈';
      case 'ЗК':
        return '🚪';
      default:
        return '🏗️';
    }
  }

  int get priority {
    switch (objectTypeName) {
      case 'НПС':
        return 1;
      case 'Резервуар':
        return 2;
      case 'Насос':
        return 3;
      case 'Клапан':
        return 4;
      case 'ДК':
      case 'ДТ':
      case 'ДР':
        return 5;
      case 'ЗК':
        return 6;
      default:
        return 7;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PipelineObject && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PipelineObject(id: $id, $displayName, $formattedKmMark)';
  }
}

class ObjectType {
  final int id;
  final String name;
  final String description;

  const ObjectType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ObjectType.fromJson(Map<String, dynamic> json) {
    return ObjectType(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ObjectType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ObjectType(id: $id, $name)';
  }
}

class TagTemplate {
  final int id;
  final int objectTypeId;
  final String objectTypeName;
  final String nameTemplate;
  final String descriptionTemplate;
  final String dataType;
  final String engineeringUnits;
  final double minValue;
  final double maxValue;

  const TagTemplate({
    required this.id,
    required this.objectTypeId,
    required this.objectTypeName,
    required this.nameTemplate,
    required this.descriptionTemplate,
    required this.dataType,
    required this.engineeringUnits,
    required this.minValue,
    required this.maxValue,
  });

  factory TagTemplate.fromJson(Map<String, dynamic> json) {
    return TagTemplate(
      id: json['id'] as int,
      objectTypeId: json['object_type'] as int,
      objectTypeName: json['object_type_name'] as String,
      nameTemplate: json['name_template'] as String,
      descriptionTemplate: json['description_template'] as String,
      dataType: json['data_type'] as String,
      engineeringUnits: json['engineering_units'] as String,
      minValue: (json['min_value'] as num).toDouble(),
      maxValue: (json['max_value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object_type': objectTypeId,
      'object_type_name': objectTypeName,
      'name_template': nameTemplate,
      'description_template': descriptionTemplate,
      'data_type': dataType,
      'engineering_units': engineeringUnits,
      'min_value': minValue,
      'max_value': maxValue,
    };
  }

  String generateTagName(String objectIndex) {
    return nameTemplate.replaceAll('{index}', objectIndex);
  }

  String generateTagDescription(String objectIndex) {
    return descriptionTemplate.replaceAll('{index}', objectIndex);
  }

  @override
  String toString() {
    return 'TagTemplate(id: $id, $nameTemplate, $objectTypeName)';
  }
}