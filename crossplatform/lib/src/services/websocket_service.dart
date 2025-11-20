import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static const String _baseUrl = 'ws://localhost:8000/ws';
  WebSocketChannel? _channel;
  StreamController<dynamic>? _messageController;
  bool _isConnected = false;

  // Connection state stream
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  
  // Message stream
  Stream<dynamic> get messageStream =>
      _messageController?.stream ?? const Stream.empty();
  
  // Connection state stream
  Stream<bool> get connectionStream => _connectionController.stream;
  
  // Current connection state
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      // Close existing connection if any
      await disconnect();

      // Create new WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse('$_baseUrl/tags/'));
      _messageController = StreamController<dynamic>.broadcast();

      // Listen for messages
      _channel!.stream.listen(
        (dynamic message) {
          _handleMessage(message);
        },
        onError: (error) {
          _handleError(error);
        },
        onDone: () {
          _handleDisconnection();
        },
      );

      _isConnected = true;
      _connectionController.add(true);
      
      print('WebSocket connected successfully');
    } catch (error) {
      _isConnected = false;
      _connectionController.add(false);
      print('WebSocket connection failed: $error');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _connectionController.add(false);
    
    await _channel?.sink.close();
    await _messageController?.close();
    
    _channel = null;
    _messageController = null;
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (error) {
        print('Error sending WebSocket message: $error');
      }
    }
  }

  void subscribeToTags() {
    sendMessage({
      'action': 'subscribe_tags',
      'type': 'subscribe_tags',
    });
  }

  void subscribeToAlarms() {
    sendMessage({
      'action': 'subscribe_alarms', 
      'type': 'subscribe_alarms',
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message);
      _messageController?.add(decoded);
    } catch (error) {
      print('Error decoding WebSocket message: $error');
    }
  }

  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _connectionController.add(false);
    
    // Attempt to reconnect after a delay
    _scheduleReconnect();
  }

  void _handleDisconnection() {
    print('WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(false);
    
    // Attempt to reconnect after a delay
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        print('Attempting to reconnect WebSocket...');
        connect();
      }
    });
  }

  // Cleanup
  void dispose() {
    disconnect();
    _connectionController.close();
  }
}

// WebSocket message models
class WebSocketMessage {
  final String type;
  final dynamic data;
  final String? message;

  WebSocketMessage({
    required this.type,
    this.data,
    this.message,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String,
      data: json['data'],
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (data != null) 'data': data,
      if (message != null) 'message': message,
    };
  }
}

class TagUpdateMessage {
  final int tagId;
  final String tagName;
  final double value;
  final int quality;
  final DateTime timestamp;

  TagUpdateMessage({
    required this.tagId,
    required this.tagName,
    required this.value,
    required this.quality,
    required this.timestamp,
  });

  factory TagUpdateMessage.fromJson(Map<String, dynamic> json) {
    return TagUpdateMessage(
      tagId: json['tag_id'] as int,
      tagName: json['tag_name'] as String,
      value: (json['value'] as num).toDouble(),
      quality: json['quality'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class AlarmUpdateMessage {
  final int id;
  final String name;
  final String message;
  final String severity;
  final String tagName;
  final DateTime triggeredAt;

  AlarmUpdateMessage({
    required this.id,
    required this.name,
    required this.message,
    required this.severity,
    required this.tagName,
    required this.triggeredAt,
  });

  factory AlarmUpdateMessage.fromJson(Map<String, dynamic> json) {
    return AlarmUpdateMessage(
      id: json['id'] as int,
      name: json['name'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      tagName: json['tag_name'] as String,
      triggeredAt: DateTime.parse(json['triggered_at'] as String),
    );
  }
}

// Singleton instance
final webSocketService = WebSocketService();