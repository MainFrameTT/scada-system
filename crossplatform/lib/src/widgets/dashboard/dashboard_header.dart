import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tags_provider.dart';
import '../../providers/alarms_provider.dart';
import '../../theme/app_theme.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsState = ref.watch(tagsProvider);
    final alarmsState = ref.watch(alarmsProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A).withOpacity(0.9),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getHorizontalPadding(context),
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and connection status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SCADA Dashboard',
                        style: AppTheme.headlineLarge.copyWith(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Мониторинг нефтепровода в реальном времени',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  _buildConnectionStatus(),
                ],
              ),

              const SizedBox(height: 32.0),

              // Statistics Cards
              _buildStatisticsCards(tagsState, alarmsState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.green.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            'Подключено',
            style: AppTheme.caption.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(TagsState tagsState, AlarmsState alarmsState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(
            icon: Icons.sensors,
            value: tagsState.tags.length.toString(),
            label: 'Всего тегов',
            color: AppTheme.infoColor,
          ),
          const SizedBox(width: 12.0),
          _StatCard(
            icon: Icons.warning_amber,
            value: tagsState.criticalTags.length.toString(),
            label: 'Критические',
            color: AppTheme.criticalColor,
          ),
          const SizedBox(width: 12.0),
          _StatCard(
            icon: Icons.notifications_active,
            value: alarmsState.activeAlarms.length.toString(),
            label: 'Активные аварии',
            color: AppTheme.warningColor,
          ),
          const SizedBox(width: 12.0),
          _StatCard(
            icon: Icons.check_circle,
            value: '${tagsState.normalTags.length}/${tagsState.tags.length}',
            label: 'Нормальные',
            color: AppTheme.normalColor,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.0,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18.0,
              color: color,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            value,
            style: AppTheme.headlineMedium.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}