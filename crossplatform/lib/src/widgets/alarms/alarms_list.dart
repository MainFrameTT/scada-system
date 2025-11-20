import 'package:flutter/material.dart';
import '../../models/alarm.dart';
import '../../theme/app_theme.dart';

class AlarmsList extends StatelessWidget {
  final List<Alarm> alarms;
  final Function(int) onAcknowledgeAlarm;

  const AlarmsList({
    super.key,
    required this.alarms,
    required this.onAcknowledgeAlarm,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final alarm = alarms[index];
          return AlarmListItem(
            alarm: alarm,
            onAcknowledge: () => onAcknowledgeAlarm(alarm.id),
          );
        },
        childCount: alarms.length,
      ),
    );
  }
}

class AlarmListItem extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onAcknowledge;

  const AlarmListItem({
    super.key,
    required this.alarm,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with severity and time
          _buildHeader(),
          
          // Alarm content
          _buildContent(),
          
          // Actions (if active)
          if (alarm.canAcknowledge) _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _getHeaderColor(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: Row(
        children: [
          // Severity indicator
          Container(
            width: 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              color: _getSeverityColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12.0),
          
          // Severity text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: _getSeverityColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              alarm.severityText,
              style: AppTheme.caption.copyWith(
                color: _getSeverityColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Time information
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(alarm.triggeredAt),
                style: AppTheme.caption.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDate(alarm.triggeredAt),
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

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alarm name
          Text(
            alarm.alarmDefinitionName,
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8.0),
          
          // Alarm message
          Text(
            alarm.message,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 12.0),
          
          // Tag and status info
          Row(
            children: [
              // Tag info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тег:',
                      style: AppTheme.caption.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                    Text(
                      alarm.tagName,
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Статус:',
                      style: AppTheme.caption.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        alarm.stateText,
                        style: AppTheme.caption.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Duration information for active alarms
          if (alarm.isActive) ...[
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14.0,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'Длительность: ${alarm.durationText}',
                    style: AppTheme.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Acknowledgment information
          if (alarm.isAcknowledged && alarm.acknowledgedByName != null) ...[
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14.0,
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      'Квитировал: ${alarm.acknowledgedByName!}',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ),
                  if (alarm.acknowledgedAt != null)
                    Text(
                      _formatTime(alarm.acknowledgedAt!),
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.infoColor.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12.0),
          bottomRight: Radius.circular(12.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAcknowledge,
              icon: const Icon(Icons.check_circle_outline, size: 16.0),
              label: const Text('Квитировать'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.infoColor,
                side: BorderSide(color: AppTheme.infoColor),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (alarm.severity) {
      case 'CRITICAL':
        return AppTheme.criticalColor.withOpacity(0.05);
      case 'HIGH':
        return AppTheme.warningColor.withOpacity(0.05);
      case 'MEDIUM':
        return Colors.orange.withOpacity(0.05);
      case 'LOW':
        return AppTheme.normalColor.withOpacity(0.05);
      default:
        return AppTheme.darkTheme.cardColor!;
    }
  }

  Color _getBorderColor() {
    switch (alarm.severity) {
      case 'CRITICAL':
        return AppTheme.criticalColor.withOpacity(0.3);
      case 'HIGH':
        return AppTheme.warningColor.withOpacity(0.3);
      case 'MEDIUM':
        return Colors.orange.withOpacity(0.3);
      case 'LOW':
        return AppTheme.normalColor.withOpacity(0.3);
      default:
        return Colors.white.withOpacity(0.1);
    }
  }

  Color _getShadowColor() {
    switch (alarm.severity) {
      case 'CRITICAL':
        return AppTheme.criticalColor.withOpacity(0.1);
      case 'HIGH':
        return AppTheme.warningColor.withOpacity(0.1);
      case 'MEDIUM':
        return Colors.orange.withOpacity(0.1);
      case 'LOW':
        return AppTheme.normalColor.withOpacity(0.1);
      default:
        return Colors.black.withOpacity(0.1);
    }
  }

  Color _getHeaderColor() {
    switch (alarm.severity) {
      case 'CRITICAL':
        return AppTheme.criticalColor.withOpacity(0.1);
      case 'HIGH':
        return AppTheme.warningColor.withOpacity(0.1);
      case 'MEDIUM':
        return Colors.orange.withOpacity(0.1);
      case 'LOW':
        return AppTheme.normalColor.withOpacity(0.1);
      default:
        return Colors.white.withOpacity(0.05);
    }
  }

  Color _getSeverityColor() {
    switch (alarm.severity) {
      case 'CRITICAL':
        return AppTheme.criticalColor;
      case 'HIGH':
        return AppTheme.warningColor;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return AppTheme.normalColor;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor() {
    switch (alarm.state) {
      case 'ACTIVE':
        return AppTheme.criticalColor;
      case 'ACKNOWLEDGED':
        return AppTheme.infoColor;
      case 'RESOLVED':
        return AppTheme.normalColor;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }
}