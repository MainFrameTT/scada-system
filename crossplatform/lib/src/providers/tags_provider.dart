import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag.dart';
import '../services/api_service.dart';

// Добавляем провайдер для ApiService
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Провайдер для API сервиса тегов
final tagsApiProvider = Provider<TagsApiService>((ref) {
  return TagsApiService(ref.read(apiServiceProvider));
});

class TagsApiService {
  final ApiService _apiService;

  TagsApiService(this._apiService);

  Future<List<Tag>> getTags() async {
    final response = await _apiService.get('/api/tags/');
    return (response as List).map((tagData) => Tag.fromJson(tagData)).toList();
  }

  Future<Tag> getTag(int id) async {
    final response = await _apiService.get('/api/tags/$id/');
    return Tag.fromJson(response);
  }

  Future<Tag> updateTagValue(int id, double value) async {
    final response = await _apiService.patch(
      '/api/tags/$id/',
      {'value': value},
    );
    return Tag.fromJson(response);
  }

  Future<List<TagValue>> getTagHistory(int id, {DateTime? start, DateTime? end}) async {
    String url = '/api/tags/$id/history/';
    final params = <String, String>{};
    
    if (start != null) {
      params['start'] = start.toIso8601String();
    }
    if (end != null) {
      params['end'] = end.toIso8601String();
    }
    
    final response = await _apiService.get(url, params: params);
    return (response as List).map((data) => TagValue.fromJson(data)).toList();
  }
}

// Основной провайдер для тегов
final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  final tagsApi = ref.read(tagsApiProvider);
  return await tagsApi.getTags();
});

// Провайдер для отдельного тега
final tagProvider = Provider.family<Tag?, int>((ref, id) {
  final tags = ref.watch(tagsProvider);
  return tags.when(
    data: (tags) {
      try {
        return tags.firstWhere((tag) => tag.id == id);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});