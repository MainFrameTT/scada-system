import '../models/alarm.dart'; 
class ApiService {
  Future<dynamic> get(String url, {Map<String, String>? params}) async {
    // Заглушка для тестирования
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  Future<dynamic> post(String url, dynamic data) async {
    await Future.delayed(const Duration(seconds: 1));
    return {};
  }

  Future<dynamic> patch(String url, dynamic data) async {
    await Future.delayed(const Duration(seconds: 1));
    return {};
  }

  // Добавляем методы для аварий
  Future<List<Alarm>> getAlarms({String? state, String? severity}) async {
    await Future.delayed(const Duration(seconds: 1));
    return []; // Заглушка
  }

  Future<List<Alarm>> getActiveAlarms() async {
    await Future.delayed(const Duration(seconds: 1));
    return []; // Заглушка
  }

  Future<void> acknowledgeAlarm(int alarmId, int userId) async {
    await Future.delayed(const Duration(seconds: 1));
    // Заглушка
  }
}