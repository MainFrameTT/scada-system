import 'package:flutter/material.dart';
import '../../providers/tags_provider.dart';
import '../../theme/app_theme.dart';

class ObjectsFilterBar extends StatelessWidget {
  final String? selectedObjectType;
  final Function(String?) onFilterChanged;
  final TagsState tagsState;

  const ObjectsFilterBar({
    super.key,
    required this.selectedObjectType,
    required this.onFilterChanged,
    required this.tagsState,
  });

  @override
  Widget build(BuildContext context) {
    final objectTypes = _getUniqueObjectTypes();

    return Container(
      color: AppTheme.darkTheme.cardColor,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getHorizontalPadding(context),
        vertical: 16.0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildObjectTypeFilter(objectTypes),
              ),
              const SizedBox(width: 12.0),
              _buildClearButton(),
              const SizedBox(width: 12.0),
              _buildStatsButton(),
            ],
          ),
          const SizedBox(height: 8.0),
          _buildActiveFilters(),
        ],
      ),
    );
  }

  Widget _buildObjectTypeFilter(List<String> objectTypes) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Фильтр по типу объекта',
        labelStyle: AppTheme.bodyMedium.copyWith(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedObjectType,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
          style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          dropdownColor: AppTheme.darkTheme.cardColor,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Все типы объектов'),
            ),
            ...objectTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    _getObjectTypeIcon(type),
                    const SizedBox(width: 8.0),
                    Text(type),
                    const Spacer(),
                    Text(
                      '(${_getObjectTypeCount(type)})',
                      style: AppTheme.caption.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          onChanged: onFilterChanged,
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return IconButton(
      icon: Icon(
        Icons.clear_all,
        color: selectedObjectType != null ? AppTheme.infoColor : Colors.white30,
      ),
      onPressed: selectedObjectType != null
          ? () {
              onFilterChanged(null);
            }
          : null,
      tooltip: 'Очистить фильтр',
    );
  }

  Widget _buildStatsButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppTheme.infoColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 16.0,
            color: AppTheme.infoColor,
          ),
          const SizedBox(width: 4.0),
          Text(
            '${_getFilteredObjectsCount()}',
            style: AppTheme.caption.copyWith(
              color: AppTheme.infoColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    if (selectedObjectType == null) return const SizedBox.shrink();

    return Row(
      children: [
        Text(
          'Активный фильтр:',
          style: AppTheme.caption.copyWith(color: Colors.white54),
        ),
        const SizedBox(width: 8.0),
        _buildFilterChip('Тип: $selectedObjectType'),
        const SizedBox(width: 8.0),
        Text(
          '(${_getObjectTypeCount(selectedObjectType!)} объектов)',
          style: AppTheme.caption.copyWith(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.infoColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.infoColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4.0),
          GestureDetector(
            onTap: () => onFilterChanged(null),
            child: Icon(
              Icons.close,
              size: 14.0,
              color: AppTheme.infoColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getObjectTypeIcon(String type) {
    final icon = _getIconForObjectType(type);
    final color = _getColorForObjectType(type);
    
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          icon,
          style: const TextStyle(fontSize: 12.0),
        ),
      ),
    );
  }

  String _getIconForObjectType(String type) {
    switch (type) {
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

  Color _getColorForObjectType(String type) {
    switch (type) {
      case 'НПС':
        return AppTheme.npsColor;
      case 'Резервуар':
        return AppTheme.tankColor;
      case 'Насос':
        return AppTheme.pumpColor;
      case 'Клапан':
        return AppTheme.valveColor;
      case 'ДК':
      case 'ДТ':
      case 'ДР':
        return AppTheme.sensorColor;
      case 'ЗК':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<String> _getUniqueObjectTypes() {
    final types = tagsState.tagsByObjectType.keys.toList();
    types.sort((a, b) {
      final countA = tagsState.tagsByObjectType[a]!.length;
      final countB = tagsState.tagsByObjectType[b]!.length;
      return countB.compareTo(countA); // Sort by count descending
    });
    return types;
  }

  int _getObjectTypeCount(String type) {
    return tagsState.tagsByObjectType[type]?.length ?? 0;
  }

  int _getFilteredObjectsCount() {
    if (selectedObjectType == null) {
      return _getUniquePipelineObjects().length;
    }
    return _getObjectsByType(selectedObjectType!).length;
  }

  List<String> _getUniquePipelineObjects() {
    final objects = tagsState.tags.map((tag) => tag.pipelineObjectName).toSet().toList();
    objects.sort();
    return objects;
  }

  List<String> _getObjectsByType(String type) {
    final objects = tagsState.tags
        .where((tag) => tag.objectTypeName == type)
        .map((tag) => tag.pipelineObjectName)
        .toSet()
        .toList();
    objects.sort();
    return objects;
  }
}