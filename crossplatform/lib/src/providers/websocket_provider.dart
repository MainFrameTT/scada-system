import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';
import '../models/tag.dart';
import '../models/alarm.dart';

// Провайдер для WebSocket сервиса
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  
  // Автоматическое подключение при инициализации
  service.connect();
  
  // Автоматическое отключение при dispose
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

// Провайдер для состояния подключения WebSocket
final webSocketConnectionProvider = StreamProvider<String>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.connectionStream;
});

// Провайдер для real-time тегов
final realTimeTagsProvider = StreamProvider<List<Tag>>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.tagsStream;
});

// Провайдер для real-time аварий
final realTimeAlarmsProvider = StreamProvider<List<Alarm>>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.alarmsStream;
});

// Провайдер для управления подписками WebSocket
final webSocketManagerProvider = Provider<WebSocketManager>((ref) {
  return WebSocketManager(ref);
});

class WebSocketManager {
  final Ref _ref;

  WebSocketManager(this._ref);

  // Подключиться к WebSocket
  Future<void> connect({String? customUrl}) async {
    final service = _ref.read(webSocketServiceProvider);
    await service.connect(customUrl: customUrl);
  }

  // Отключиться от WebSocket
  void disconnect() {
    final service = _ref.read(webSocketServiceProvider);
    service.disconnect();
  }

  // Подписаться на обновления тегов
  void subscribeToTags({List<int>? tagIds}) {
    final service = _ref.read(webSocketServiceProvider);
    service.subscribeToTags(tagIds: tagIds);
  }

  // Отписаться от тегов
  void unsubscribeFromTags() {
    final service = _ref.read(webSocketServiceProvider);
    service.unsubscribeFromTags();
  }

  // Подписаться на обновления аварий
  void subscribeToAlarms({List<int>? alarmIds}) {
    final service = _ref.read(webSocketServiceProvider);
    service.subscribeToAlarms(alarmIds: alarmIds);
  }

  // Отписаться от аварий
  void unsubscribeFromAlarms() {
    final service = _ref.read(webSocketServiceProvider);
    service.unsubscribeFromAlarms();
  }

  // Запросить обновление тегов
  void requestTagsUpdate() {
    final service = _ref.read(webSocketServiceProvider);
    service.requestTagsUpdate();
  }

  // Запросить обновление аварий
  void requestAlarmsUpdate() {
    final service = _ref.read(webSocketServiceProvider);
    service.requestAlarmsUpdate();
  }

  // Подтвердить аварию
  void acknowledgeAlarm(int alarmId, int userId) {
    final service = _ref.read(webSocketServiceProvider);
    service.acknowledgeAlarm(alarmId, userId);
  }

  // Отправить произвольное сообщение
  void sendMessage(Map<String, dynamic> message) {
    final service = _ref.read(webSocketServiceProvider);
    service.sendMessage(message);
  }

  // Проверить статус подключения
  bool get isConnected {
    final service = _ref.read(webSocketServiceProvider);
    return service.isConnected;
  }

  // Проверить статус подключения
  bool get isConnecting {
    final service = _ref.read(webSocketServiceProvider);
    return service.isConnecting;
  }
}

// Комбинированный провайдер для статуса WebSocket
final webSocketStatusProvider = Provider<WebSocketStatus>((ref) {
  final connectionState = ref.watch(webSocketConnectionProvider);
  final isConnected = ref.watch(webSocketServiceProvider).isConnected;
  final isConnecting = ref.watch(webSocketServiceProvider).isConnecting;

  return WebSocketStatus(
    connectionState: connectionState,
    isConnected: isConnected,
    isConnecting: isConnecting,
  );
});

class WebSocketStatus {
  final AsyncValue<String> connectionState;
  final bool isConnected;
  final bool isConnecting;

  WebSocketStatus({
    required this.connectionState,
    required this.isConnected,
    required this.isConnecting,
  });

  String get statusText {
    if (isConnecting) return 'Подключение...';
    if (isConnected) return 'Подключено';
    return 'Отключено';
  }

  bool get showReconnect => !isConnected && !isConnecting;
}