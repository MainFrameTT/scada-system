import 'package:flutter/material.dart';
import '../../models/tag.dart';
import '../../theme/app_theme.dart';

class ObjectCard extends StatelessWidget {
  final String objectName;
  final List<Tag> tags;

  const ObjectCard({
    super.key,
    required this.objectName,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final criticalTags = tags.where((tag) => tag.isCritical).length;
    final warningTags = tags.where((tag) => tag.isWarning).length;
    final objectTypes = _getUniqueObjectTypes();
    final primaryObjectType = objectTypes.isNotEmpty ? objectTypes.first : '';

    return Card(
      color: AppTheme.darkTheme.cardColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          _showObjectDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with object name and status
              _buildHeader(primaryObjectType),
              const SizedBox(height: 12.0),

              // Object types
              _buildObjectTypes(objectTypes),
              const SizedBox(height: 12.0),

              // Tags statistics
              _buildTagsStatistics(),
              const SizedBox(height: 12.0),

              // Critical tags warning
              if (criticalTags > 0) _buildCriticalWarning(criticalTags),
              
              // Sample tags
              _buildSampleTags(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String primaryObjectType) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Object icon
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: _getObjectTypeColor(primaryObjectType).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              _getObjectTypeIcon(primaryObjectType),
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ),
        const SizedBox(width: 12.0),

        // Object name and info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                objectName,
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              Text(
                '${tags.length} тегов',
                style: AppTheme.caption.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            _getStatusText(),
            style: AppTheme.caption.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObjectTypes(List<String> objectTypes) {
    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      children: objectTypes.take(3).map((type) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: _getObjectTypeColor(type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: _getObjectTypeColor(type).withOpacity(0.3),
            ),
          ),
          child: Text(
            type,
            style: AppTheme.caption.copyWith(
              color: _getObjectTypeColor(type),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagsStatistics() {
    final criticalCount = tags.where((tag) => tag.isCritical).length;
    final warningCount = tags.where((tag) => tag.isWarning).length;
    final normalCount = tags.where((tag) => tag.isNormal).length;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Всего', tags.length.toString(), Icons.tag, AppTheme.infoColor),
          _buildStatItem('Крит.', criticalCount.toString(), Icons.warning, AppTheme.criticalColor),
          _buildStatItem('Пред.', warningCount.toString(), Icons.info, AppTheme.warningColor),
          _buildStatItem('Норма', normalCount.toString(), Icons.check, AppTheme.normalColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 12.0,
            color: color,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: AppTheme.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: Colors.white54,
            fontSize: 10.0,
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalWarning(int criticalCount) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppTheme.criticalColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: AppTheme.criticalColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16.0,
            color: AppTheme.criticalColor,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              '$criticalCount критических тегов',
              style: AppTheme.caption.copyWith(
                color: AppTheme.criticalColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleTags() {
    final sampleTags = tags.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Примеры тегов:',
          style: AppTheme.caption.copyWith(
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6.0),
        ...sampleTags.map((tag) => _buildTagItem(tag)).toList(),
        if (tags.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'и ещё ${tags.length - 3} тегов...',
              style: AppTheme.caption.copyWith(
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTagItem(Tag tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: _getTagStatusColor(tag),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              tag.name,
              style: AppTheme.caption.copyWith(
                color: Colors.white70,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            tag.formattedValue,
            style: AppTheme.caption.copyWith(
              color: _getTagStatusColor(tag),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showObjectDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ObjectDetailsDialog(
        objectName: objectName,
        tags: tags,
      ),
    );
  }

  List<String> _getUniqueObjectTypes() {
    final types = tags.map((tag) => tag.objectTypeName).toSet().toList();
    types.sort();
    return types;
  }

  Color _getStatusColor() {
    final criticalCount = tags.where((tag) => tag.isCritical).length;
    final warningCount = tags.where((tag) => tag.isWarning).length;

    if (criticalCount > 0) return AppTheme.criticalColor;
    if (warningCount > 0) return AppTheme.warningColor;
    return AppTheme.normalColor;
  }

  String _getStatusText() {
    final criticalCount = tags.where((tag) => tag.isCritical).length;
    final warningCount = tags.where((tag) => tag.isWarning).length;

    if (criticalCount > 0) return 'КРИТИЧЕСКИЙ';
    if (warningCount > 0) return 'ПРЕДУПРЕЖДЕНИЕ';
    return 'НОРМА';
  }

  String _getObjectTypeIcon(String type) {
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

  Color _getObjectTypeColor(String type) {
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

  Color _getTagStatusColor(Tag tag) {
    if (tag.isCritical) return AppTheme.criticalColor;
    if (tag.isWarning) return AppTheme.warningColor;
    return AppTheme.normalColor;
  }
}

class _ObjectDetailsDialog extends StatelessWidget {
  final String objectName;
  final List<Tag> tags;

  const _ObjectDetailsDialog({
    required this.objectName,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final criticalCount = tags.where((tag) => tag.isCritical).length;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: criticalCount > 0 
            ? AppTheme.criticalColor.withOpacity(0.1)
            : AppTheme.infoColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: criticalCount > 0 
                  ? AppTheme.criticalColor.withOpacity(0.2)
                  : AppTheme.infoColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🏗️', style: TextStyle(fontSize: 16.0)),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  objectName,
                  style: AppTheme.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${tags.length} тегов • ${_getUniqueObjectTypes().join(', ')}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Теги объекта:',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: ListView.builder(
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return _buildTagListItem(tag);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagListItem(Tag tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: _getTagStatusColor(tag).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: _getTagStatusColor(tag),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag.name,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  tag.description,
                  style: AppTheme.caption.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tag.formattedValue,
                style: TextStyle(
                  color: _getTagStatusColor(tag),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${tag.currentQuality}% качество',
                style: AppTheme.caption.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _getUniqueObjectTypes() {
    final types = tags.map((tag) => tag.objectTypeName).toSet().toList();
    return types;
  }

  Color _getTagStatusColor(Tag tag) {
    if (tag.isCritical) return AppTheme.criticalColor;
    if (tag.isWarning) return AppTheme.warningColor;
    return AppTheme.normalColor;
  }
}