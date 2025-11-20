import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tags_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/objects/objects_filter_bar.dart';
import '../widgets/objects/objects_grid.dart';
import '../widgets/objects/object_types_summary.dart';

class PipelineObjectsScreen extends ConsumerStatefulWidget {
  const PipelineObjectsScreen({super.key});

  @override
  ConsumerState<PipelineObjectsScreen> createState() => _PipelineObjectsScreenState();
}

class _PipelineObjectsScreenState extends ConsumerState<PipelineObjectsScreen> {
  String? _selectedObjectType;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ref.read(tagsProvider.notifier).fetchTags();
  }

  void _onFilterChanged(String? objectType) {
    setState(() {
      _selectedObjectType = objectType;
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final tagsState = ref.watch(tagsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              title: Text(
                '🏗️ Объекты нефтепровода',
                style: AppTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.darkTheme.appBarTheme.backgroundColor,
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshData,
                ),
              ],
            ),

            // Statistics Summary
            SliverToBoxAdapter(
              child: ObjectTypesSummary(
                tagsState: tagsState,
                selectedObjectType: _selectedObjectType,
              ),
            ),

            // Filter Bar
            SliverToBoxAdapter(
              child: ObjectsFilterBar(
                selectedObjectType: _selectedObjectType,
                onFilterChanged: _onFilterChanged,
                tagsState: tagsState,
              ),
            ),

            // Error Display
            if (tagsState.error != null)
              SliverToBoxAdapter(
                child: _buildErrorCard(tagsState.error!),
              ),

            // Loading Indicator
            if (tagsState.isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

            // Objects Grid
            if (!tagsState.isLoading && tagsState.error == null)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getHorizontalPadding(context),
                  vertical: 16.0,
                ),
                sliver: ObjectsGrid(
                  tagsState: tagsState,
                  selectedObjectType: _selectedObjectType,
                ),
              ),

            // Empty State
            if (!tagsState.isLoading && tagsState.tags.isEmpty)
              const SliverFillRemaining(
                child: _EmptyState(),
              ),
          ],
        ),
      ),

      // Floating action button
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
          Icons.construction_outlined,
          size: 80.0,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 16.0),
        Text(
          'Объекты не найдены',
          style: AppTheme.titleLarge.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Проверьте подключение к SCADA системе',
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}