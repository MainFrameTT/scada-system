import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tag.dart';
import '../models/alarm.dart';
import '../models/pipeline_object.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static const Duration timeout = Duration(seconds: 10);

  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  // Headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Helper method for HTTP requests
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParams,
    );

    final request = http.Request(method, uri);
    request.headers.addAll(_headers);

    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'HTTP error ${response.statusCode}',
        body: response.body,
      );
    }

    return response;
  }

  // Tags API
  Future<List<Tag>> getTags({
    String? objectType,
    String? pipelineObject,
  }) async {
    final params = <String, String>{};
    if (objectType != null) params['object_type'] = objectType;
    if (pipelineObject != null) params['pipeline_object'] = pipelineObject;

    final response = await _makeRequest('GET', '/tags/', queryParams: params);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    
    final results = data['results'] as List;
    return results.map((json) => Tag.fromJson(json)).toList();
  }

  Future<Tag> getTag(int id) async {
    final response = await _makeRequest('GET', '/tags/$id/');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Tag.fromJson(data);
  }

  Future<List<TagValue>> getTagHistory(
    int tagId, {
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final params = <String, String>{'tag_id': tagId.toString()};
    if (startTime != null) {
      params['start_time'] = startTime.toIso8601String();
    }
    if (endTime != null) {
      params['end_time'] = endTime.toIso8601String();
    }

    final response = await _makeRequest(
      'GET', 
      '/tag-values/', 
      queryParams: params,
    );
    
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List;
    return results.map((json) => TagValue.fromJson(json)).toList();
  }

  // Alarms API
  Future<List<Alarm>> getAlarms({
    String? state,
    String? severity,
  }) async {
    final params = <String, String>{};
    if (state != null) params['state'] = state;
    if (severity != null) params['severity'] = severity;

    final response = await _makeRequest('GET', '/alarms/', queryParams: params);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    
    final results = data['results'] as List;
    return results.map((json) => Alarm.fromJson(json)).toList();
  }

  Future<List<Alarm>> getActiveAlarms() async {
    final response = await _makeRequest('GET', '/alarms/active/');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    
    final items = data['items'] as List;
    return items.map((json) => Alarm.fromJson(json)).toList();
  }

  Future<void> acknowledgeAlarm(int alarmId, int userId) async {
    await _makeRequest(
      'POST',
      '/alarms/$alarmId/acknowledge/',
      body: {'acknowledged_by': userId},
    );
  }

  // Pipeline Objects API
  Future<List<PipelineObject>> getPipelineObjects({
    String? objectType,
  }) async {
    final params = <String, String>{};
    if (objectType != null) params['object_type'] = objectType;

    final response = await _makeRequest(
      'GET', 
      '/pipeline-objects/', 
      queryParams: params,
    );
    
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List;
    return results.map((json) => PipelineObject.fromJson(json)).toList();
  }

  Future<List<ObjectType>> getObjectTypes() async {
    final response = await _makeRequest('GET', '/object-types/');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    
    final results = data['results'] as List;
    return results.map((json) => ObjectType.fromJson(json)).toList();
  }

  // Tag Templates API
  Future<List<TagTemplate>> getTagTemplates() async {
    final response = await _makeRequest('GET', '/tag-templates/');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    
    final results = data['results'] as List;
    return results.map((json) => TagTemplate.fromJson(json)).toList();
  }

  // Dispose client when done
  void dispose() {
    client.close();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? body;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

// Singleton instance
final apiService = ApiService();