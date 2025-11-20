import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { apiService, type Alarm } from '../services/api'

export const useAlarmsStore = defineStore('alarms', () => {
  const alarms = ref<Alarm[]>([])
  const activeAlarms = ref<Alarm[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const filters = ref({
    state: '',
    severity: ''
  })

  // Computed
  const alarmsBySeverity = computed(() => {
    const grouped: Record<string, Alarm[]> = {
      CRITICAL: [],
      HIGH: [],
      MEDIUM: [],
      LOW: []
    }
    
    alarms.value.forEach(alarm => {
      if (grouped[alarm.severity]) {
        grouped[alarm.severity].push(alarm)
      }
    })
    
    return grouped
  })

  const filteredAlarms = computed(() => {
    let filtered = alarms.value
    
    if (filters.value.state) {
      filtered = filtered.filter(alarm => alarm.state === filters.value.state)
    }
    
    if (filters.value.severity) {
      filtered = filtered.filter(alarm => alarm.severity === filters.value.severity)
    }
    
    return filtered
  })

  const alarmStats = computed(() => {
    const stats = {
      total: alarms.value.length,
      active: alarms.value.filter(a => a.state === 'ACTIVE').length,
      acknowledged: alarms.value.filter(a => a.state === 'ACKNOWLEDGED').length,
      critical: alarms.value.filter(a => a.severity === 'CRITICAL').length,
      high: alarms.value.filter(a => a.severity === 'HIGH').length
    }
    
    return stats
  })

  // Actions
  const fetchAlarms = async (params?: any) => {
    loading.value = true
    error.value = null
    try {
      const response = await apiService.getAlarms(params)
      alarms.value = response.results
    } catch (err: any) {
      error.value = err.message || 'Failed to fetch alarms'
      console.error('Error fetching alarms:', err)
    } finally {
      loading.value = false
    }
  }

  const fetchActiveAlarms = async () => {
    loading.value = true
    error.value = null
    try {
      const response = await apiService.getActiveAlarms()
      activeAlarms.value = response.items
    } catch (err: any) {
      error.value = err.message || 'Failed to fetch active alarms'
      console.error('Error fetching active alarms:', err)
    } finally {
      loading.value = false
    }
  }

  const acknowledgeAlarm = async (alarmId: number, userId: number = 1) => {
    loading.value = true
    error.value = null
    try {
      await apiService.acknowledgeAlarm(alarmId, userId)
      
      // Update local state
      const alarm = alarms.value.find(a => a.id === alarmId)
      if (alarm) {
        alarm.state = 'ACKNOWLEDGED'
        alarm.acknowledged_at = new Date().toISOString()
      }
      
      const activeAlarm = activeAlarms.value.find(a => a.id === alarmId)
      if (activeAlarm) {
        activeAlarms.value = activeAlarms.value.filter(a => a.id !== alarmId)
      }
    } catch (err: any) {
      error.value = err.message || 'Failed to acknowledge alarm'
      console.error('Error acknowledging alarm:', err)
    } finally {
      loading.value = false
    }
  }

  const addAlarm = (alarm: Alarm) => {
    // For WebSocket updates
    const existingIndex = alarms.value.findIndex(a => a.id === alarm.id)
    if (existingIndex >= 0) {
      alarms.value[existingIndex] = alarm
    } else {
      alarms.value.unshift(alarm)
    }
    
    if (alarm.state === 'ACTIVE') {
      const activeIndex = activeAlarms.value.findIndex(a => a.id === alarm.id)
      if (activeIndex >= 0) {
        activeAlarms.value[activeIndex] = alarm
      } else {
        activeAlarms.value.unshift(alarm)
      }
    } else {
      activeAlarms.value = activeAlarms.value.filter(a => a.id !== alarm.id)
    }
  }

  const setFilters = (newFilters: { state?: string; severity?: string }) => {
    filters.value = { ...filters.value, ...newFilters }
  }

  const clearFilters = () => {
    filters.value = { state: '', severity: '' }
  }

  const clearError = () => {
    error.value = null
  }

  return {
    // State
    alarms,
    activeAlarms,
    loading,
    error,
    filters,

    // Computed
    alarmsBySeverity,
    filteredAlarms,
    alarmStats,

    // Actions
    fetchAlarms,
    fetchActiveAlarms,
    acknowledgeAlarm,
    addAlarm,
    setFilters,
    clearFilters,
    clearError
  }
})