import 'package:flutter/material.dart';
import '../../models/tag.dart';
import '../../theme/app_theme.dart';
import 'tag_card.dart';

class TagsGrid extends StatelessWidget {
  final List<Tag> tags;
  final Function(Tag) onTagSelected;

  const TagsGrid({
    super.key,
    required this.tags,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppTheme.isMobile(context);
    final crossAxisCount = _getCrossAxisCount(context);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: _getChildAspectRatio(context),
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tag = tags[index];
          return TagCard(
            tag: tag,
            onTap: () => onTagSelected(tag),
          );
        },
        childCount: tags.length,
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 1200) return 4; // Large desktop
    if (width > 800) return 3;  // Desktop
    if (width > 600) return 2;  // Tablet
    return 1; // Mobile
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 1200) return 1.2; // Large desktop - wider cards
    if (width > 800) return 1.1;  // Desktop
    if (width > 600) return 1.0;  // Tablet
    return 1.3; // Mobile - taller cards for better readability
  }
}

class TagCard extends StatelessWidget {
  final Tag tag;
  final VoidCallback onTap;

  const TagCard({
    super.key,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getCardColor(),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: _getBorderColor(),
          width: 2.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tag.name,
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      tag.objectTypeName,
                      style: AppTheme.caption.copyWith(
                        color: _getTypeColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8.0),

              // Description
              Text(
                tag.description,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white70,
                  fontSize: 12.0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12.0),

              // Current value
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            tag.currentValue.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: _getValueColor(),
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            tag.engineeringUnits,
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white70,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Качество: ${tag.currentQuality}%',
                        style: AppTheme.caption.copyWith(
                          color: _getQualityColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12.0),

              // Object info
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 12.0,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      tag.pipelineObjectName,
                      style: AppTheme.caption.copyWith(
                        color: Colors.white54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4.0),

              // Limits bar
              _buildLimitsBar(),

              const SizedBox(height: 4.0),

              // Limits labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tag.minValue.toStringAsFixed(1),
                    style: AppTheme.caption.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    tag.maxValue.toStringAsFixed(1),
                    style: AppTheme.caption.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitsBar() {
    final normalizedValue = tag.normalizedValue;
    final percentage = normalizedValue.clamp(0.0, 1.0) * 100;

    return Container(
      height: 6.0,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
          // Value indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getLimitBarColors(),
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: FractionallySizedBox(
              widthFactor: normalizedValue.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: _getValueColor(),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            ),
          ),
          // Current value marker
          Positioned(
            left: '${percentage.clamp(0.0, 100.0)}%',
            child: Container(
              width: 2.0,
              height: 8.0,
              color: Colors.white,
              margin: const EdgeInsets.only(top: -1.0),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor() {
    if (tag.isCritical) {
      return AppTheme.criticalColor.withOpacity(0.05);
    } else if (tag.isWarning) {
      return AppTheme.warningColor.withOpacity(0.05);
    }
    return AppTheme.darkTheme.cardColor!;
  }

  Color _getBorderColor() {
    if (tag.isCritical) {
      return AppTheme.criticalColor.withOpacity(0.3);
    } else if (tag.isWarning) {
      return AppTheme.warningColor.withOpacity(0.3);
    }
    return Colors.white.withOpacity(0.1);
  }

  Color _getValueColor() {
    if (tag.isCritical) {
      return AppTheme.criticalColor;
    } else if (tag.isWarning) {
      return AppTheme.warningColor;
    }
    return AppTheme.normalColor;
  }

  Color _getQualityColor() {
    if (tag.currentQuality >= 90) return AppTheme.normalColor;
    if (tag.currentQuality >= 70) return AppTheme.warningColor;
    return AppTheme.criticalColor;
  }

  Color _getTypeColor() {
    switch (tag.objectTypeName) {
      case 'НПС':
        return AppTheme.npsColor;
      case 'Резервуар':
        return AppTheme.tankColor;
      case 'Насос':
        return AppTheme.pumpColor;
      case 'Клапан':
        return AppTheme.valveColor;
      default:
        return AppTheme.sensorColor;
    }
  }

  List<Color> _getLimitBarColors() {
    if (tag.isCritical) {
      return [AppTheme.criticalColor, AppTheme.criticalColor.withOpacity(0.7)];
    } else if (tag.isWarning) {
      return [AppTheme.warningColor, AppTheme.warningColor.withOpacity(0.7)];
    }
    return [AppTheme.normalColor, AppTheme.normalColor.withOpacity(0.7)];
  }
}