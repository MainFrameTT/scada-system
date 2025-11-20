import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/tag.dart';
import '../models/alarm.dart';
import '../utils/constants.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamController<List<Tag>> _tagsController = StreamController.broadcast();
  StreamController<List<Alarm>> _alarmsController = StreamController.broadcast();
  StreamController<String> _connectionController = StreamController.broadcast();
  StreamController<Map<String, dynamic>> _rawMessageController = StreamController.broadcast();

  bool _isConnected = false;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  // Public streams
  Stream<List<Tag>> get tagsStream => _tagsController.stream;
  Stream<List<Alarm>> get alarmsStream => _alarmsController.stream;
  Stream<String> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get rawMessageStream => _rawMessageController.stream;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  Future<void> connect({String? customUrl}) async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    _connectionController.add('connecting');

    try {
      final url = customUrl ?? AppConstants.websocketBaseUrl;
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionController.add('connected');
      
      print('WebSocket connected to $url');

    } catch (e) {
      _handleError(e);
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    
    _channel?.sink.close(status.goingAway);
    _channel = null;
    
    _isConnected = false;
    _isConnecting = false;
    _connectionController.add('disconnected');
    
    print('WebSocket disconnected');
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      _rawMessageController.add(data);

      final type = data['type'];
      final payload = data['data'] ?? {};

      switch (type) {
        case 'tags_update':
          _handleTagsUpdate(payload);
          break;
        case 'alarms_update':
          _handleAlarmsUpdate(payload);
          break;
        case 'tag_update':
          _handleSingleTagUpdate(payload);
          break;
        case 'alarm_triggered':
          _handleAlarmTriggered(payload);
          break;
        case 'alarm_acknowledged':
          _handleAlarmAcknowledged(payload);
          break;
        case 'alarm_resolved':
          _handleAlarmResolved(payload);
          break;
        case 'ping':
          _sendPong();
          break;
        default:
          print('Unknown WebSocket message type: $type');
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void _handleTagsUpdate(dynamic payload) {
    try {
      if (payload is List) {
        final tags = payload.map((tagData) => Tag.fromJson(tagData)).toList();
        _tagsController.add(tags);
      }
    } catch (e) {
      print('Error parsing tags update: $e');
    }
  }

  void _handleAlarmsUpdate(dynamic payload) {
    try {
      if (payload is List) {
        final alarms = payload.map((alarmData) => Alarm.fromJson(alarmData)).toList();
        _alarmsController.add(alarms);
      }
    } catch (e) {
      print('Error parsing alarms update: $e');
    }
  }

  void _handleSingleTagUpdate(dynamic payload) {
    try {
      final tag = Tag.fromJson(payload);
      // For single tag updates, we might want to handle differently
      // For now, just add to the stream as a list with one element
      _tagsController.add([tag]);
    } catch (e) {
      print('Error parsing single tag update: $e');
    }
  }

  void _handleAlarmTriggered(dynamic payload) {
    try {
      final alarm = Alarm.fromJson(payload);
      _alarmsController.add([alarm]);
      // You might want to show a notification here
      _showAlarmNotification(alarm);
    } catch (e) {
      print('Error parsing alarm triggered: $e');
    }
  }

  void _handleAlarmAcknowledged(dynamic payload) {
    try {
      final alarm = Alarm.fromJson(payload);
      _alarmsController.add([alarm]);
    } catch (e) {
      print('Error parsing alarm acknowledged: $e');
    }
  }

  void _handleAlarmResolved(dynamic payload) {
    try {
      final alarm = Alarm.fromJson(payload);
      _alarmsController.add([alarm]);
    } catch (e) {
      print('Error parsing alarm resolved: $e');
    }
  }

  void _sendPong() {
    sendMessage({
      'type': 'pong',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        print('Error sending WebSocket message: $e');
      }
    }
  }

  void subscribeToTags({List<int>? tagIds}) {
    sendMessage({
      'type': 'subscribe',
      'channel': 'tags',
      'tag_ids': tagIds,
    });
  }

  void unsubscribeFromTags() {
    sendMessage({
      'type': 'unsubscribe',
      'channel': 'tags',
    });
  }

  void subscribeToAlarms({List<int>? alarmIds}) {
    sendMessage({
      'type': 'subscribe',
      'channel': 'alarms',
      'alarm_ids': alarmIds,
    });
  }

  void unsubscribeFromAlarms() {
    sendMessage({
      'type': 'unsubscribe',
      'channel': 'alarms',
    });
  }

  void requestTagsUpdate() {
    sendMessage({
      'type': 'request_update',
      'channel': 'tags',
    });
  }

  void requestAlarmsUpdate() {
    sendMessage({
      'type': 'request_update',
      'channel': 'alarms',
    });
  }

  void acknowledgeAlarm(int alarmId, int userId) {
    sendMessage({
      'type': 'acknowledge_alarm',
      'alarm_id': alarmId,
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _isConnecting = false;
    _connectionController.add('error');
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    print('WebSocket disconnected');
    _isConnected = false;
    _isConnecting = false;
    _connectionController.add('disconnected');
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null) return;

    _reconnectAttempts++;
    final delay = _calculateReconnectDelay();

    print('Scheduling reconnect in ${delay.inSeconds} seconds (attempt $_reconnectAttempts)');

    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      if (!_isConnected) {
        connect();
      }
    });
  }

  Duration _calculateReconnectDelay() {
    if (_reconnectAttempts == 0) return Duration.zero;
    
    final baseDelay = AppConstants.websocketReconnectDelay;
    final maxDelay = Duration(seconds: 60);
    
    // Exponential backoff with jitter
    final exponentialDelay = baseDelay * _reconnectAttempts;
    final jitter = Duration(milliseconds: (Random().nextDouble() * 1000).round());
    
    final totalDelay = exponentialDelay + jitter;
    
    return totalDelay > maxDelay ? maxDelay : totalDelay;
  }

  void _showAlarmNotification(Alarm alarm) {
    // This would integrate with your notification system
    // For now, just print to console
    print('🚨 ALARM: ${alarm.alarmDefinitionName} - ${alarm.message}');
  }

  Future<void> dispose() async {
    disconnect();
    await _tagsController.close();
    await _alarmsController.close();
    await _connectionController.close();
    await _rawMessageController.close();
  }
}

// Helper class for WebSocket message types
class WebSocketMessageTypes {
  static const String tagsUpdate = 'tags_update';
  static const String alarmsUpdate = 'alarms_update';
  static const String tagUpdate = 'tag_update';
  static const String alarmTriggered = 'alarm_triggered';
  static const String alarmAcknowledged = 'alarm_acknowledged';
  static const String alarmResolved = 'alarm_resolved';
  static const String ping = 'ping';
  static const String pong = 'pong';
  static const String subscribe = 'subscribe';
  static const String unsubscribe = 'unsubscribe';
  static const String requestUpdate = 'request_update';
  static const String acknowledgeAlarm = 'acknowledge_alarm';
}

// Random number generator for jitter
class Random {
  static final _random = math.Random();
  
  static double nextDouble() => _random.nextDouble();
}