import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tags_provider.dart';
import '../../theme/app_theme.dart';

class TagsFilterBar extends ConsumerWidget {
  final String? selectedObjectType;
  final String? selectedPipelineObject;
  final Function(String? objectType, String? pipelineObject) onFilterChanged;

  const TagsFilterBar({
    super.key,
    required this.selectedObjectType,
    required this.selectedPipelineObject,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsState = ref.watch(tagsProvider);
    final objectTypes = _getUniqueObjectTypes(tagsState.tags);
    final pipelineObjects = _getUniquePipelineObjects(tagsState.tags);

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
              Expanded(
                child: _buildPipelineObjectFilter(pipelineObjects),
              ),
              const SizedBox(width: 12.0),
              _buildClearButton(),
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
        labelText: 'Тип объекта',
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
              child: Text('Все типы'),
            ),
            ...objectTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
          ],
          onChanged: (value) {
            onFilterChanged(value, selectedPipelineObject);
          },
        ),
      ),
    );
  }

  Widget _buildPipelineObjectFilter(List<String> pipelineObjects) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Объект',
        labelStyle: AppTheme.bodyMedium.copyWith(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPipelineObject,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
          style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          dropdownColor: AppTheme.darkTheme.cardColor,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Все объекты'),
            ),
            ...pipelineObjects.map((object) {
              return DropdownMenuItem(
                value: object,
                child: Text(object),
              );
            }).toList(),
          ],
          onChanged: (value) {
            onFilterChanged(selectedObjectType, value);
          },
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return IconButton(
      icon: Icon(
        Icons.clear_all,
        color: (selectedObjectType != null || selectedPipelineObject != null)
            ? AppTheme.infoColor
            : Colors.white30,
      ),
      onPressed: (selectedObjectType != null || selectedPipelineObject != null)
          ? () {
              onFilterChanged(null, null);
            }
          : null,
    );
  }

  Widget _buildActiveFilters() {
    final hasActiveFilters = selectedObjectType != null || selectedPipelineObject != null;
    
    if (!hasActiveFilters) return const SizedBox.shrink();

    return Row(
      children: [
        Text(
          'Активные фильтры:',
          style: AppTheme.caption.copyWith(color: Colors.white54),
        ),
        const SizedBox(width: 8.0),
        if (selectedObjectType != null)
          _buildFilterChip('Тип: $selectedObjectType'),
        if (selectedPipelineObject != null)
          _buildFilterChip('Объект: $selectedPipelineObject'),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.infoColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          color: AppTheme.infoColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<String> _getUniqueObjectTypes(List<Tag> tags) {
    final types = tags.map((tag) => tag.objectTypeName).toSet().toList();
    types.sort();
    return types;
  }

  List<String> _getUniquePipelineObjects(List<Tag> tags) {
    final objects = tags.map((tag) => tag.pipelineObjectName).toSet().toList();
    objects.sort();
    return objects;
  }
}