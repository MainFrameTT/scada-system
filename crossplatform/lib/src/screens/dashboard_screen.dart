import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tags_provider.dart';
import '../providers/alarms_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/alarms_overview.dart';
import '../widgets/dashboard/tags_overview.dart';
import '../widgets/dashboard/critical_tags_section.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      ref.read(tagsProvider.notifier).fetchTags(),
      ref.read(alarmsProvider.notifier).fetchActiveAlarms(),
    ]);
  }

  Future<void> _refreshData() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final tagsState = ref.watch(tagsProvider);
    final alarmsState = ref.watch(alarmsProvider);
    final isLoading = tagsState.isLoading || alarmsState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            // Header
            const SliverToBoxAdapter(
              child: DashboardHeader(),
            ),

            // Loading indicator
            if (isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

            // Error display
            if (tagsState.error != null)
              SliverToBoxAdapter(
                child: _buildErrorCard(tagsState.error!),
              ),

            if (alarmsState.error != null)
              SliverToBoxAdapter(
                child: _buildErrorCard(alarmsState.error!),
              ),

            // Content
            if (!isLoading && tagsState.error == null && alarmsState.error == null)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getHorizontalPadding(context),
                  vertical: 16.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Active Alarms Section
                    if (alarmsState.activeAlarms.isNotEmpty)
                      AlarmsOverview(alarms: alarmsState.activeAlarms),

                    const SizedBox(height: 24.0),

                    // Tags Overview Section
                    TagsOverview(tagsState: tagsState),

                    const SizedBox(height: 24.0),

                    // Critical Tags Section
                    if (tagsState.criticalTags.isNotEmpty)
                      CriticalTagsSection(tags: tagsState.criticalTags),
                  ]),
                ),
              ),

            // Empty state
            if (!isLoading && tagsState.tags.isEmpty && alarmsState.activeAlarms.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: _EmptyState(),
                ),
              ),
          ],
        ),
      ),

      // Floating action button for refresh
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        backgroundColor: AppTheme.infoColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: AppTheme.criticalColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppTheme.criticalColor,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  error,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  ref.read(tagsProvider.notifier).clearError();
                  ref.read(alarmsProvider.notifier).clearError();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.analytics_outlined,
          size: 80.0,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 16.0),
        Text(
          'Нет данных для отображения',
          style: AppTheme.titleLarge.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Подключитесь к SCADA системе или проверьте настройки',
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}