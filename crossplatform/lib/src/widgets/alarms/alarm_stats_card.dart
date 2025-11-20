import 'package:flutter/material.dart';
import '../../providers/alarms_provider.dart';
import '../../theme/app_theme.dart';

class AlarmStatsCard extends StatelessWidget {
  final AlarmStats stats;

  const AlarmStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
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
                    '📊 Статистика аварий',
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
                      'Всего: ${stats.total}',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.infoColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Main Statistics Grid
              _buildMainStatsGrid(),
              const SizedBox(height: 16.0),

              // Severity Breakdown
              _buildSeverityBreakdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.0,
      mainAxisSpacing: 12.0,
      childAspectRatio: 2.5,
      children: [
        _buildStatItem(
          'Активные',
          stats.active.toString(),
          Icons.warning_amber_rounded,
          stats.active > 0 ? AppTheme.criticalColor : AppTheme.normalColor,
        ),
        _buildStatItem(
          'Квитированные',
          stats.acknowledged.toString(),
          Icons.check_circle_outline,
          AppTheme.infoColor,
        ),
        _buildStatItem(
          'Сброшенные',
          stats.resolved.toString(),
          Icons.verified_outlined,
          AppTheme.normalColor,
        ),
        _buildStatItem(
          'Критические',
          stats.critical.toString(),
          Icons.error_outline,
          AppTheme.criticalColor,
        ),
      ],
    );
  }

  Widget _buildSeverityBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Распределение по важности:',
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            _buildSeverityChip('Критические', stats.critical, AppTheme.criticalColor),
            const SizedBox(width: 8.0),
            _buildSeverityChip('Высокие', stats.high, AppTheme.warningColor),
            const SizedBox(width: 8.0),
            _buildSeverityChip('Средние', stats.medium, Colors.orange),
            const SizedBox(width: 8.0),
            _buildSeverityChip('Низкие', stats.low, AppTheme.normalColor),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.0,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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
}