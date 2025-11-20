import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tags_provider.dart';
import '../../theme/app_theme.dart';

class TagsOverview extends ConsumerWidget {
  final TagsState tagsState;

  const TagsOverview({super.key, required this.tagsState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objectTypes = tagsState.tagsByObjectType.keys.toList()..sort();

    return Card(
      margin: EdgeInsets.zero,
      color: AppTheme.darkTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.sensors_rounded,
                  color: AppTheme.infoColor,
                  size: 24.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Обзор тегов по типам объектов',
                  style: AppTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    tagsState.tags.length.toString(),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.infoColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to tags screen
                  },
                  child: Text(
                    'Все теги',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.infoColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // Object Types Grid
            if (objectTypes.isNotEmpty)
              _buildObjectTypesGrid(objectTypes, tagsState.tagsByObjectType)
            else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectTypesGrid(
      List<String> objectTypes, Map<String, List<Tags>> tagsByObjectType) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.6,
      ),
      itemCount: objectTypes.length,
      itemBuilder: (context, index) {
        final type = objectTypes[index];
        final tags = tagsByObjectType[type]!;
        return _ObjectTypeCard(
          objectType: type,
          tags: tags,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Icon(
            Icons.sensors_off_rounded,
            size: 48.0,
            color: Colors.grey.withOpacity(0.7),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Теги не найдены',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Проверьте подключение к SCADA системе',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectTypeCard extends StatelessWidget {
  final String objectType;
  final List<Tags> tags;

  const _ObjectTypeCard({
    required this.objectType,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final criticalCount = tags.where((tag) => tag.isCritical).length;
    final warningCount = tags.where((tag) => tag.isWarning).length;
    final normalCount = tags.where((tag) => tag.isNormal).length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _getObjectTypeColor(objectType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _getObjectTypeColor(objectType).withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: _getObjectTypeColor(objectType).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getObjectTypeIcon(objectType),
                  size: 16.0,
                  color: _getObjectTypeColor(objectType),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  objectType,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: _getObjectTypeColor(objectType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  tags.length.toString(),
                  style: AppTheme.caption.copyWith(
                    color: _getObjectTypeColor(objectType),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // Status indicators
          Row(
            children: [
              _StatusIndicator(
                count: criticalCount,
                label: 'Крит.',
                color: AppTheme.criticalColor,
              ),
              const SizedBox(width: 8.0),
              _StatusIndicator(
                count: warningCount,
                label: 'Пред.',
                color: AppTheme.warningColor,
              ),
              const SizedBox(width: 8.0),
              _StatusIndicator(
                count: normalCount,
                label: 'Норм.',
                color: AppTheme.normalColor,
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // Sample tags
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tags.take(3).length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return _TagRow(tag: tag);
              },
            ),
          ),

          // More indicator
          if (tags.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '+ ещё ${tags.length - 3} тегов',
                style: AppTheme.caption.copyWith(
                  color: Colors.white54,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getObjectTypeColor(String objectType) {
    switch (objectType) {
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
      default:
        return AppTheme.infoColor;
    }
  }

  IconData _getObjectTypeIcon(String objectType) {
    switch (objectType) {
      case 'НПС':
        return Icons.factory_rounded;
      case 'Резервуар':
        return Icons.storage_rounded;
      case 'Насос':
        return Icons.build_rounded;
      case 'Клапан':
        return Icons.settings_rounded;
      case 'ДК':
        return Icons.speed_rounded;
      case 'ДТ':
        return Icons.thermostat_rounded;
      case 'ДР':
        return Icons.analytics_rounded;
      default:
        return Icons.device_unknown_rounded;
    }
  }
}

class _StatusIndicator extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatusIndicator({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: AppTheme.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 10.0,
              ),
            ),
            Text(
              label,
              style: AppTheme.caption.copyWith(
                color: color,
                fontSize: 8.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  final Tag tag;

  const _TagRow({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(
            width: 4.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: _getTagColor(tag),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              tag.name,
              style: AppTheme.caption.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${tag.currentValue.toStringAsFixed(1)} ${tag.engineeringUnits}',
            style: AppTheme.caption.copyWith(
              color: _getTagColor(tag),
              fontWeight: FontWeight.w600,
              fontSize: 10.0,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTagColor(Tag tag) {
    if (tag.isCritical) return AppTheme.criticalColor;
    if (tag.isWarning) return AppTheme.warningColor;
    return AppTheme.normalColor;
  }
}