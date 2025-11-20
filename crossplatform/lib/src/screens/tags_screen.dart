import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tags_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/tags/tags_filter_bar.dart';
import '../widgets/tags/tags_grid.dart';
import '../widgets/tags/tag_details_dialog.dart';

class TagsScreen extends ConsumerStatefulWidget {
  const TagsScreen({super.key});

  @override
  ConsumerState<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends ConsumerState<TagsScreen> {
  String? _selectedObjectType;
  String? _selectedPipelineObject;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    await ref.read(tagsProvider.notifier).fetchTags(
      objectType: _selectedObjectType,
      pipelineObject: _selectedPipelineObject,
    );
  }

  void _onFilterChanged({String? objectType, String? pipelineObject}) {
    setState(() {
      _selectedObjectType = objectType;
      _selectedPipelineObject = pipelineObject;
    });
    _loadTags();
  }

  void _onTagSelected(Tag tag) {
    showDialog(
      context: context,
      builder: (context) => TagDetailsDialog(tag: tag),
    );
  }

  Future<void> _refreshTags() async {
    await _loadTags();
  }

  @override
  Widget build(BuildContext context) {
    final tagsState = ref.watch(tagsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshTags,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              title: Text(
                '📈 Управление тегами',
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
                  onPressed: _refreshTags,
                ),
              ],
            ),

            // Filter Bar
            SliverToBoxAdapter(
              child: TagsFilterBar(
                selectedObjectType: _selectedObjectType,
                selectedPipelineObject: _selectedPipelineObject,
                onFilterChanged: _onFilterChanged,
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

            // Tags Grid
            if (!tagsState.isLoading && tagsState.error == null)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getHorizontalPadding(context),
                  vertical: 16.0,
                ),
                sliver: TagsGrid(
                  tags: tagsState.tags,
                  onTagSelected: _onTagSelected,
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
          Icons.tag_faces,
          size: 80.0,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 16.0),
        Text(
          'Теги не найдены',
          style: AppTheme.titleLarge.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Попробуйте изменить фильтры или обновить данные',
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}