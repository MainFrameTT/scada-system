import 'package:flutter/material.dart';
import '../../providers/tags_provider.dart';
import '../../theme/app_theme.dart';
import 'object_card.dart';

class ObjectsGrid extends StatelessWidget {
  final TagsState tagsState;
  final String? selectedObjectType;

  const ObjectsGrid({
    super.key,
    required this.tagsState,
    this.selectedObjectType,
  });

  @override
  Widget build(BuildContext context) {
    final objects = _getFilteredObjects();
    
    if (objects.isEmpty) {
      return const SliverToBoxAdapter(
        child: _NoObjectsFound(),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: _getChildAspectRatio(context),
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final objectName = objects[index];
          return ObjectCard(
            objectName: objectName,
            tags: _getTagsForObject(objectName),
          );
        },
        childCount: objects.length,
      ),
    );
  }

  List<String> _getFilteredObjects() {
    final allObjects = _getUniquePipelineObjects();
    
    if (selectedObjectType == null) {
      return allObjects;
    }
    
    return allObjects.where((object) {
      return tagsState.tags.any((tag) => 
        tag.pipelineObjectName == object && 
        tag.objectTypeName == selectedObjectType
      );
    }).toList();
  }

  List<Tag> _getTagsForObject(String objectName) {
    return tagsState.tags
        .where((tag) => tag.pipelineObjectName == objectName)
        .toList();
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 1200) return 3; // Large desktop
    if (width > 800) return 2;  // Desktop
    return 1; // Mobile/tablet
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 1200) return 1.4; // Large desktop - wider cards
    if (width > 800) return 1.3;  // Desktop
    return 1.2; // Mobile - taller cards
  }

  List<String> _getUniquePipelineObjects() {
    final objects = tagsState.tags.map((tag) => tag.pipelineObjectName).toSet().toList();
    objects.sort();
    return objects;
  }
}

class _NoObjectsFound extends StatelessWidget {
  const _NoObjectsFound();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64.0,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16.0),
          Text(
            'Объекты не найдены',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Попробуйте изменить фильтры поиска',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}