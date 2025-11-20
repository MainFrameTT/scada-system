import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag.dart';
import '../services/api_service.dart';

// Tags State
class TagsState {
  final List<Tag> tags;
  final bool isLoading;
  final String? error;
  final Map<int, List<TagValue>> tagHistory;

  const TagsState({
    required this.tags,
    required this.isLoading,
    this.error,
    required this.tagHistory,
  });

  TagsState copyWith({
    List<Tag>? tags,
    bool? isLoading,
    String? error,
    Map<int, List<TagValue>>? tagHistory,
  }) {
    return TagsState(
      tags: tags ?? this.tags,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tagHistory: tagHistory ?? this.tagHistory,
    );
  }

  // Helper methods
  List<Tag> get criticalTags =>
      tags.where((tag) => tag.isCritical).toList();

  List<Tag> get warningTags =>
      tags.where((tag) => tag.isWarning).toList();

  List<Tag> get normalTags =>
      tags.where((tag) => tag.isNormal).toList();

  Map<String, List<Tag>> get tagsByObjectType {
    final grouped = <String, List<Tag>>{};
    for (final tag in tags) {
      final type = tag.objectTypeName;
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(tag);
    }
    return grouped;
  }

  Tag? getTagById(int id) {
    try {
      return tags.firstWhere((tag) => tag.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Tags Notifier
class TagsNotifier extends StateNotifier<TagsState> {
  final ApiService apiService;

  TagsNotifier({required this.apiService})
      : super(const TagsState(
          tags: [],
          isLoading: false,
          tagHistory: {},
        ));

  // Fetch all tags
  Future<void> fetchTags({String? objectType, String? pipelineObject}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final tags = await apiService.getTags(
        objectType: objectType,
        pipelineObject: pipelineObject,
      );
      state = state.copyWith(tags: tags, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки тегов: $error',
      );
    }
  }

  // Fetch single tag
  Future<void> fetchTag(int id) async {
    try {
      final tag = await apiService.getTag(id);
      final updatedTags = List<Tag>.from(state.tags);
      final index = updatedTags.indexWhere((t) => t.id == id);
      
      if (index >= 0) {
        updatedTags[index] = tag;
      } else {
        updatedTags.add(tag);
      }
      
      state = state.copyWith(tags: updatedTags);
    } catch (error) {
      state = state.copyWith(
        error: 'Ошибка загрузки тега: $error',
      );
    }
  }

  // Fetch tag history
  Future<void> fetchTagHistory(int tagId, {int hours = 24}) async {
    try {
      final endTime = DateTime.now();
      final startTime = endTime.subtract(Duration(hours: hours));
      
      final history = await apiService.getTagHistory(
        tagId,
        startTime: startTime,
        endTime: endTime,
      );
      
      final updatedHistory = Map<int, List<TagValue>>.from(state.tagHistory);
      updatedHistory[tagId] = history;
      
      state = state.copyWith(tagHistory: updatedHistory);
    } catch (error) {
      state = state.copyWith(
        error: 'Ошибка загрузки истории тега: $error',
      );
    }
  }

  // Update tag value (for WebSocket updates)
  void updateTagValue(int tagId, double value, int quality) {
    final updatedTags = state.tags.map((tag) {
      if (tag.id == tagId) {
        return tag.copyWith(
          currentValue: value,
          currentQuality: quality,
        );
      }
      return tag;
    }).toList();

    state = state.copyWith(tags: updatedTags);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final tagsProvider = StateNotifierProvider<TagsNotifier, TagsState>((ref) {
  return TagsNotifier(apiService: apiService);
});

// Filtered tags providers
final filteredTagsProvider = Provider<List<Tag>>((ref) {
  final state = ref.watch(tagsProvider);
  return state.tags;
});

final criticalTagsProvider = Provider<List<Tag>>((ref) {
  final state = ref.watch(tagsProvider);
  return state.criticalTags;
});

final tagsByObjectTypeProvider = Provider<Map<String, List<Tag>>>((ref) {
  final state = ref.watch(tagsProvider);
  return state.tagsByObjectType;
});

final tagByIdProvider = Provider.family<Tag?, int>((ref, id) {
  final state = ref.watch(tagsProvider);
  return state.getTagById(id);
});

final tagHistoryProvider = Provider.family<List<TagValue>, int>((ref, tagId) {
  final state = ref.watch(tagsProvider);
  return state.tagHistory[tagId] ?? [];
});

// Loading state provider
final tagsLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(tagsProvider);
  return state.isLoading;
});

// Error state provider
final tagsErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(tagsProvider);
  return state.error;
});