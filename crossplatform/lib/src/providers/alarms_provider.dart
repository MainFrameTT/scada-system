import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alarm.dart';
import '../services/api_service.dart';

// Alarms State
class AlarmsState {
  final List<Alarm> alarms;
  final List<Alarm> activeAlarms;
  final bool isLoading;
  final String? error;
  final String? stateFilter;
  final String? severityFilter;

  const AlarmsState({
    required this.alarms,
    required this.activeAlarms,
    required this.isLoading,
    this.error,
    this.stateFilter,
    this.severityFilter,
  });

  AlarmsState copyWith({
    List<Alarm>? alarms,
    List<Alarm>? activeAlarms,
    bool? isLoading,
    String? error,
    String? stateFilter,
    String? severityFilter,
  }) {
    return AlarmsState(
      alarms: alarms ?? this.alarms,
      activeAlarms: activeAlarms ?? this.activeAlarms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stateFilter: stateFilter ?? this.stateFilter,
      severityFilter: severityFilter ?? this.severityFilter,
    );
  }

  // Helper methods
  List<Alarm> get filteredAlarms {
    var filtered = alarms;
    
    if (stateFilter != null && stateFilter!.isNotEmpty) {
      filtered = filtered.where((alarm) => alarm.state == stateFilter).toList();
    }
    
    if (severityFilter != null && severityFilter!.isNotEmpty) {
      filtered = filtered.where((alarm) => alarm.severity == severityFilter).toList();
    }
    
    return filtered;
  }

  Map<String, List<Alarm>> get alarmsBySeverity {
    final grouped = <String, List<Alarm>>{
      'CRITICAL': [],
      'HIGH': [],
      'MEDIUM': [],
      'LOW': [],
    };
    
    for (final alarm in alarms) {
      if (grouped.containsKey(alarm.severity)) {
        grouped[alarm.severity]!.add(alarm);
      }
    }
    
    return grouped;
  }

  AlarmStats get stats {
    return AlarmStats(
      total: alarms.length,
      active: alarms.where((a) => a.isActive).length,
      acknowledged: alarms.where((a) => a.isAcknowledged).length,
      resolved: alarms.where((a) => a.isResolved).length,
      critical: alarms.where((a) => a.isCritical).length,
      high: alarms.where((a) => a.isHigh).length,
      medium: alarms.where((a) => a.isMedium).length,
      low: alarms.where((a) => a.isLow).length,
    );
  }
}

// Alarm Statistics
class AlarmStats {
  final int total;
  final int active;
  final int acknowledged;
  final int resolved;
  final int critical;
  final int high;
  final int medium;
  final int low;

  const AlarmStats({
    required this.total,
    required this.active,
    required this.acknowledged,
    required this.resolved,
    required this.critical,
    required this.high,
    required this.medium,
    required this.low,
  });
}

// Alarms Notifier
class AlarmsNotifier extends StateNotifier<AlarmsState> {
  final ApiService apiService;

  AlarmsNotifier({required this.apiService})
      : super(const AlarmsState(
          alarms: [],
          activeAlarms: [],
          isLoading: false,
        ));

  // Fetch all alarms with optional filtering
  Future<void> fetchAlarms({String? state, String? severity}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final alarms = await apiService.getAlarms(
        state: state,
        severity: severity,
      );
      state = state.copyWith(
        alarms: alarms,
        isLoading: false,
        stateFilter: state,
        severityFilter: severity,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки аварий: $error',
      );
    }
  }

  // Fetch active alarms only
  Future<void> fetchActiveAlarms() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final activeAlarms = await apiService.getActiveAlarms();
      state = state.copyWith(
        activeAlarms: activeAlarms,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки активных аварий: $error',
      );
    }
  }

  // Acknowledge alarm
  Future<void> acknowledgeAlarm(int alarmId, int userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await apiService.acknowledgeAlarm(alarmId, userId);
      
      // Update local state
      final updatedAlarms = state.alarms.map((alarm) {
        if (alarm.id == alarmId) {
          return alarm.copyWith(
            state: 'ACKNOWLEDGED',
            acknowledgedAt: DateTime.now(),
          );
        }
        return alarm;
      }).toList();

      final updatedActiveAlarms = state.activeAlarms
          .where((alarm) => alarm.id != alarmId)
          .toList();

      state = state.copyWith(
        alarms: updatedAlarms,
        activeAlarms: updatedActiveAlarms,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка квитирования аварии: $error',
      );
    }
  }

  // Add or update alarm (for WebSocket updates)
  void updateAlarm(Alarm alarm) {
    final alarmIndex = state.alarms.indexWhere((a) => a.id == alarm.id);
    final activeAlarmIndex = state.activeAlarms.indexWhere((a) => a.id == alarm.id);

    final updatedAlarms = List<Alarm>.from(state.alarms);
    final updatedActiveAlarms = List<Alarm>.from(state.activeAlarms);

    if (alarmIndex >= 0) {
      updatedAlarms[alarmIndex] = alarm;
    } else {
      updatedAlarms.insert(0, alarm);
    }

    if (alarm.isActive) {
      if (activeAlarmIndex >= 0) {
        updatedActiveAlarms[activeAlarmIndex] = alarm;
      } else {
        updatedActiveAlarms.insert(0, alarm);
      }
    } else {
      if (activeAlarmIndex >= 0) {
        updatedActiveAlarms.removeAt(activeAlarmIndex);
      }
    }

    state = state.copyWith(
      alarms: updatedAlarms,
      activeAlarms: updatedActiveAlarms,
    );
  }

  // Set filters
  void setFilters({String? state, String? severity}) {
    state = state.copyWith(
      stateFilter: state,
      severityFilter: severity,
    );
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      stateFilter: null,
      severityFilter: null,
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final alarmsProvider = StateNotifierProvider<AlarmsNotifier, AlarmsState>((ref) {
  return AlarmsNotifier(apiService: apiService);
});

// Filtered alarms provider
final filteredAlarmsProvider = Provider<List<Alarm>>((ref) {
  final state = ref.watch(alarmsProvider);
  return state.filteredAlarms;
});

// Active alarms provider
final activeAlarmsProvider = Provider<List<Alarm>>((ref) {
  final state = ref.watch(alarmsProvider);
  return state.activeAlarms;
});

// Alarms by severity provider
final alarmsBySeverityProvider = Provider<Map<String, List<Alarm>>>((ref) {
  final state = ref.watch(alarmsProvider);
  return state.alarmsBySeverity;
});

// Alarm stats provider
final alarmStatsProvider = Provider<AlarmStats>((ref) {
  final state = ref.watch(alarmsProvider);
  return state.stats;
});

// Loading state provider
final alarmsLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(alarmsProvider);
  return state.isLoading;
});

// Error state provider
final alarmsErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(alarmsProvider);
  return state.error;
});

// Filter providers
final alarmsStateFilterProvider = Provider<String?>((ref) {
  final state = ref.watch(alarmsProvider);
  return state.stateFilter;
});

final alarmsSeverityFilterProvider = Provider<String?>((ref) {
  final state = ref.watch(alarmsProvider);
  return state.severityFilter;
});