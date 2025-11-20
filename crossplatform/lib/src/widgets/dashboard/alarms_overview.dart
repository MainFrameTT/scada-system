import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/alarm.dart';
import '../../providers/alarms_provider.dart';
import '../../theme/app_theme.dart';

class AlarmsOverview extends ConsumerWidget {
  final List<Alarm> alarms;

  const AlarmsOverview({super.key, required this.alarms});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criticalAlarms = alarms.where((a) => a.isCritical).toList();
    final highAlarms = alarms.where((a) => a.isHigh).toList();
    final otherAlarms = alarms.where((a) => a.isMedium || a.isLow).toList();

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
                  Icons.warning_amber_rounded,
                  color: AppTheme.criticalColor,
                  size: 24.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Активные аварии',
                  style: AppTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: AppTheme.criticalColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    alarms.length.toString(),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.criticalColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to alarms screen
                  },
                  child: Text(
                    'Все аварии',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.infoColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16.0),

            // Critical Alarms
            if (criticalAlarms.isNotEmpty) ...[
              _AlarmSeveritySection(
                title: 'Критические',
                alarms: criticalAlarms,
                color: AppTheme.criticalColor,
                icon: Icons.error_outline,
              ),
              const SizedBox(height: 16.0),
            ],

            // High Alarms
            if (highAlarms.isNotEmpty) ...[
              _AlarmSeveritySection(
                title: 'Высокие',
                alarms: highAlarms,
                color: AppTheme.warningColor,
                icon: Icons.warning_amber,
              ),
              const SizedBox(height: 16.0),
            ],

            // Other Alarms
            if (otherAlarms.isNotEmpty)
              _AlarmSeveritySection(
                title: 'Средние и низкие',
                alarms: otherAlarms,
                color: AppTheme.normalColor,
                icon: Icons.info_outline,
              ),

            // Empty state
            if (alarms.isEmpty)
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48.0,
            color: Colors.green.withOpacity(0.7),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Нет активных аварий',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Все системы работают в штатном режиме',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlarmSeveritySection extends ConsumerWidget {
  final String title;
  final List<Alarm> alarms;
  final Color color;
  final IconData icon;

  const _AlarmSeveritySection({
    required this.title,
    required this.alarms,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 18.0,
            ),
            const SizedBox(width: 6.0),
            Text(
              title,
              style: AppTheme.bodyLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                alarms.length.toString(),
                style: AppTheme.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12.0),

        // Alarms list
        Column(
          children: alarms.take(3).map((alarm) => _AlarmCard(alarm: alarm)).toList(),
        ),

        // Show more indicator
        if (alarms.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '+ ещё ${alarms.length - 3} аварий',
              style: AppTheme.caption.copyWith(
                color: Colors.white54,
              ),
            ),
          ),
      ],
    );
  }
}

class _AlarmCard extends ConsumerWidget {
  final Alarm alarm;

  const _AlarmCard({required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _getAlarmColor(alarm).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: _getAlarmColor(alarm).withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Alarm icon
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: _getAlarmColor(alarm).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAlarmIcon(alarm),
              size: 14.0,
              color: _getAlarmColor(alarm),
            ),
          ),

          const SizedBox(width: 12.0),

          // Alarm info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.alarmDefinitionName,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  alarm.message,
                  style: AppTheme.caption.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: _getAlarmColor(alarm).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        alarm.tagName,
                        style: AppTheme.caption.copyWith(
                          color: _getAlarmColor(alarm),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      alarm.durationText,
                      style: AppTheme.caption.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Acknowledge button
          if (alarm.canAcknowledge)
            IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: AppTheme.infoColor,
                size: 20.0,
              ),
              onPressed: () {
                _showAcknowledgeDialog(context, ref, alarm);
              },
            ),
        ],
      ),
    );
  }

  Color _getAlarmColor(Alarm alarm) {
    if (alarm.isCritical) return AppTheme.criticalColor;
    if (alarm.isHigh) return AppTheme.warningColor;
    return AppTheme.normalColor;
  }

  IconData _getAlarmIcon(Alarm alarm) {
    if (alarm.isCritical) return Icons.error_outline;
    if (alarm.isHigh) return Icons.warning_amber;
    return Icons.info_outline;
  }

  void _showAcknowledgeDialog(BuildContext context, WidgetRef ref, Alarm alarm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.cardColor,
        title: Text(
          'Квитирование аварии',
          style: AppTheme.titleLarge,
        ),
        content: Text(
          'Вы уверены, что хотите квитировать аварию "${alarm.alarmDefinitionName}"?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(alarmsProvider.notifier).acknowledgeAlarm(alarm.id, 1);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.infoColor,
            ),
            child: Text(
              'Квитировать',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}