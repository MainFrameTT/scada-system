import 'package:flutter/material.dart';
import '../../providers/tags_provider.dart';
import '../../theme/app_theme.dart';

class ObjectTypesSummary extends StatelessWidget {
  final TagsState tagsState;
  final String? selectedObjectType;

  const ObjectTypesSummary({
    super.key,
    required this.tagsState,
    this.selectedObjectType,
  });

  @override
  Widget build(BuildContext context) {
    final objectTypes = tagsState.tagsByObjectType;
    final totalObjects = _getUniquePipelineObjects().length;
    final filteredObjects = selectedObjectType != null 
        ? _getObjectsByType(selectedObjectType!).length 
        : totalObjects;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getHorizontalPadding(context),
        vertical: 16.0,
      ),
      child: Card(
        color: AppTheme.darkTheme.cardColor,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📊 Статистика объектов',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      '$filteredObjects из $totalObjects объектов',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.infoColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Object Types Grid
              _buildObjectTypesGrid(objectTypes),
              const SizedBox(height: 16.0),

              // Additional Statistics
              _buildAdditionalStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectTypesGrid(Map<String, List<Tag>> objectTypes) {
    final sortedTypes = objectTypes.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: _getCrossAxisCount(),
      crossAxisSpacing: 12.0,
      mainAxisSpacing: 12.0,
      childAspectRatio: 3.0,
      children: sortedTypes.map((entry) {
        return _buildObjectTypeCard(entry.key, entry.value.length);
      }).toList(),
    );
  }

  Widget _buildObjectTypeCard(String type, int count) {
    final isSelected = selectedObjectType == type;
    final color = _getColorForObjectType(type);

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected ? color.withOpacity(0.5) : color.withOpacity(0.3),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () {
            // This would typically trigger a filter change
            // through a callback in a real implementation
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getIconForObjectType(type),
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                
                // Type info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        type,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$count тегов',
                        style: AppTheme.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Percentage
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    '${_calculatePercentage(count)}%',
                    style: AppTheme.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalStats() {
    final criticalTags = tagsState.criticalTags.length;
    final warningTags = tagsState.warningTags.length;
    final normalTags = tagsState.normalTags.length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Состояние тегов:',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              _buildStatusIndicator('Критические', criticalTags, AppTheme.criticalColor),
              const SizedBox(width: 12.0),
              _buildStatusIndicator('Предупреждения', warningTags, AppTheme.warningColor),
              const SizedBox(width: 12.0),
              _buildStatusIndicator('Норма', normalTags, AppTheme.normalColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: AppTheme.caption.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount() {
    // This would be responsive in a real implementation
    return 2;
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

  double _calculatePercentage(int count) {
    final total = tagsState.tags.length;
    if (total == 0) return 0.0;
    return (count / total * 100).roundToDouble();
  }

  List<String> _getUniquePipelineObjects() {
    final objects = tagsState.tags.map((tag) => tag.pipelineObjectName).toSet().toList();
    return objects;
  }

  List<String> _getObjectsByType(String type) {
    final objects = tagsState.tags
        .where((tag) => tag.objectTypeName == type)
        .map((tag) => tag.pipelineObjectName)
        .toSet()
        .toList();
    return objects;
  }
}