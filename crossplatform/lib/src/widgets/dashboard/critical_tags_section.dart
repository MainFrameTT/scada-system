import 'package:flutter/material.dart';
import '../../models/tag.dart';
import '../../theme/app_theme.dart';

class CriticalTagsSection extends StatelessWidget {
  final List<Tag> tags;

  const CriticalTagsSection({
    super.key,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🚨 Критические теги',
              style: AppTheme.headlineMedium.copyWith(
                fontSize: 20.0,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppTheme.criticalColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                '${tags.length}',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.criticalColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildCriticalTagsList(),
      ],
    );
  }

  Widget _buildCriticalTagsList() {
    return Column(
      children: tags.take(5).map((tag) => _buildCriticalTagCard(tag)).toList(),
    );
  }

  Widget _buildCriticalTagCard(Tag tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: AppTheme.criticalColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppTheme.criticalColor.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: AppTheme.criticalColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.criticalColor,
            size: 20.0,
          ),
        ),
        title: Text(
          tag.name,
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          tag.pipelineObjectName,
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              tag.formattedValue,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.criticalColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${tag.normalizedValue.toStringAsFixed(1)} норм.',
              style: AppTheme.caption.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}