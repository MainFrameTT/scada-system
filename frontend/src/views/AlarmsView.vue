<template>
  <div class="alarms-view">
    <div class="view-header">
      <h1>🚨 Система аварий</h1>
      <div class="header-stats">
        <div class="stat-item">
          <span class="stat-number">{{ alarmsStore.alarmStats.active }}</span>
          <span class="stat-label">Активные</span>
        </div>
        <div class="stat-item critical">
          <span class="stat-number">{{ alarmsStore.alarmStats.critical }}</span>
          <span class="stat-label">Критические</span>
        </div>
        <div class="stat-item">
          <span class="stat-number">{{ alarmsStore.alarmStats.acknowledged }}</span>
          <span class="stat-label">Квитированные</span>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters-section">
      <div class="filter-group">
        <label>Статус:</label>
        <select v-model="alarmsStore.filters.state" @change="applyFilters">
          <option value="">Все статусы</option>
          <option value="ACTIVE">Активные</option>
          <option value="ACKNOWLEDGED">Квитированные</option>
          <option value="RESOLVED">Сброшенные</option>
        </select>
      </div>
      <div class="filter-group">
        <label>Важность:</label>
        <select v-model="alarmsStore.filters.severity" @change="applyFilters">
          <option value="">Все уровни</option>
          <option value="CRITICAL">Критическая</option>
          <option value="HIGH">Высокая</option>
          <option value="MEDIUM">Средняя</option>
          <option value="LOW">Низкая</option>
        </select>
      </div>
      <div class="filter-actions">
        <button @click="refreshAlarms" class="refresh-btn" :disabled="alarmsStore.loading">
          🔄 Обновить
        </button>
        <button @click="clearFilters" class="clear-btn">
          🗑️ Очистить
        </button>
      </div>
    </div>

    <!-- Error Display -->
    <div v-if="alarmsStore.error" class="error-message">
      {{ alarmsStore.error }}
      <button @click="alarmsStore.clearError" class="close-error">×</button>
    </div>

    <!-- Alarms Table -->
    <div class="alarms-table-container">
      <table class="alarms-table">
        <thead>
          <tr>
            <th>Время</th>
            <th>Авария</th>
            <th>Тег</th>
            <th>Важность</th>
            <th>Статус</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="alarm in alarmsStore.filteredAlarms" 
            :key="alarm.id"
            class="alarm-row"
            :class="`severity-${alarm.severity.toLowerCase()}`"
          >
            <td class="time-cell">
              <div class="time">{{ formatTime(alarm.triggered_at) }}</div>
              <div class="date">{{ formatDate(alarm.triggered_at) }}</div>
            </td>
            <td class="alarm-info">
              <div class="alarm-name">{{ alarm.alarm_definition_name }}</div>
              <div class="alarm-message">{{ alarm.message }}</div>
            </td>
            <td class="tag-cell">
              <span class="tag-name">{{ alarm.tag_name }}</span>
            </td>
            <td class="severity-cell">
              <span class="severity-badge" :class="alarm.severity.toLowerCase()">
                {{ getSeverityText(alarm.severity) }}
              </span>
            </td>
            <td class="status-cell">
              <span class="status-badge" :class="alarm.state.toLowerCase()">
                {{ getStateText(alarm.state) }}
              </span>
              <div v-if="alarm.acknowledged_at" class="ack-time">
                Квитировано: {{ formatTime(alarm.acknowledged_at) }}
              </div>
            </td>
            <td class="actions-cell">
              <button 
                v-if="alarm.state === 'ACTIVE'"
                @click="acknowledgeAlarm(alarm.id)"
                class="ack-btn"
                :disabled="alarmsStore.loading"
              >
                Квитировать
              </button>
              <span v-else class="no-action">—</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Empty State -->
    <div v-if="!alarmsStore.loading && alarmsStore.filteredAlarms.length === 0" class="empty-state">
      <div class="empty-icon">✅</div>
      <h3>Аварии не найдены</h3>
      <p>Все системы работают в штатном режиме</p>
    </div>

    <!-- Loading State -->
    <div v-if="alarmsStore.loading" class="loading">
      <div class="spinner"></div>
      Загрузка аварий...
    </div>

    <!-- Severity Summary -->
    <div class="severity-summary">
      <h3>Статистика по важности</h3>
      <div class="severity-cards">
        <div class="severity-card critical">
          <span class="count">{{ alarmsStore.alarmsBySeverity.CRITICAL.length }}</span>
          <span class="label">Критические</span>
        </div>
        <div class="severity-card high">
          <span class="count">{{ alarmsStore.alarmsBySeverity.HIGH.length }}</span>
          <span class="label">Высокие</span>
        </div>
        <div class="severity-card medium">
          <span class="count">{{ alarmsStore.alarmsBySeverity.MEDIUM.length }}</span>
          <span class="label">Средние</span>
        </div>
        <div class="severity-card low">
          <span class="count">{{ alarmsStore.alarmsBySeverity.LOW.length }}</span>
          <span class="label">Низкие</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useAlarmsStore } from '../stores/alarms'

const alarmsStore = useAlarmsStore()

const getSeverityText = (severity: string) => {
  const severityMap: Record<string, string> = {
    'CRITICAL': 'Критическая',
    'HIGH': 'Высокая',
    'MEDIUM': 'Средняя',
    'LOW': 'Низкая'
  }
  return severityMap[severity] || severity
}

const getStateText = (state: string) => {
  const stateMap: Record<string, string> = {
    'ACTIVE': 'Активна',
    'ACKNOWLEDGED': 'Квитирована',
    'RESOLVED': 'Сброшена'
  }
  return stateMap[state] || state
}

const formatTime = (timestamp: string) => {
  return new Date(timestamp).toLocaleTimeString('ru-RU')
}

const formatDate = (timestamp: string) => {
  return new Date(timestamp).toLocaleDateString('ru-RU')
}

const applyFilters = () => {
  alarmsStore.fetchAlarms()
}

const clearFilters = () => {
  alarmsStore.clearFilters()
  alarmsStore.fetchAlarms()
}

const refreshAlarms = () => {
  alarmsStore.fetchAlarms()
}

const acknowledgeAlarm = (alarmId: number) => {
  if (confirm('Вы уверены, что хотите квитировать эту аварию?')) {
    alarmsStore.acknowledgeAlarm(alarmId)
  }
}

onMounted(() => {
  alarmsStore.fetchAlarms()
})
</script>

<style scoped>
.alarms-view {
  max-width: 1200px;
  margin: 0 auto;
}

.view-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.view-header h1 {
  color: #f8fafc;
  font-size: 2rem;
}

.header-stats {
  display: flex;
  gap: 1.5rem;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1rem;
  background: #1e293b;
  border-radius: 0.5rem;
  min-width: 100px;
}

.stat-item.critical {
  background: #7f1d1d;
}

.stat-number {
  font-size: 1.5rem;
  font-weight: bold;
  color: #f8fafc;
}

.stat-label {
  color: #94a3b8;
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.filters-section {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: #1e293b;
  border-radius: 0.5rem;
  border: 1px solid #334155;
  flex-wrap: wrap;
  align-items: end;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filter-group label {
  color: #cbd5e1;
  font-size: 0.875rem;
  font-weight: 500;
}

.filter-group select {
  background: #0f172a;
  color: #f8fafc;
  border: 1px solid #334155;
  padding: 0.5rem;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  min-width: 150px;
}

.filter-actions {
  display: flex;
  gap: 0.5rem;
  margin-left: auto;
}

.refresh-btn, .clear-btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 0.375rem;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s;
}

.refresh-btn {
  background: #3b82f6;
  color: white;
}

.refresh-btn:hover:not(:disabled) {
  background: #2563eb;
}

.refresh-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.clear-btn {
  background: #6b7280;
  color: white;
}

.clear-btn:hover {
  background: #4b5563;
}

.error-message {
  background: #7f1d1d;
  color: #fecaca;
  padding: 1rem;
  border-radius: 0.375rem;
  margin-bottom: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.close-error {
  background: none;
  border: none;
  color: #fecaca;
  font-size: 1.25rem;
  cursor: pointer;
}

.alarms-table-container {
  background: #1e293b;
  border-radius: 0.5rem;
  border: 1px solid #334155;
  overflow: hidden;
  margin-bottom: 2rem;
}

.alarms-table {
  width: 100%;
  border-collapse: collapse;
}

.alarms-table th {
  background: #0f172a;
  color: #cbd5e1;
  padding: 1rem;
  text-align: left;
  font-weight: 600;
  font-size: 0.875rem;
  border-bottom: 1px solid #334155;
}

.alarms-table td {
  padding: 1rem;
  border-bottom: 1px solid #334155;
}

.alarm-row:last-child td {
  border-bottom: none;
}

.alarm-row:hover {
  background: #1e293b;
}

.alarm-row.severity-critical {
  background: #7f1d1d;
  border-left: 4px solid #ef4444;
}

.alarm-row.severity-high {
  background: #78350f;
  border-left: 4px solid #f59e0b;
}

.alarm-row.severity-medium {
  background: #713f12;
  border-left: 4px solid #eab308;
}

.alarm-row.severity-low {
  background: #365314;
  border-left: 4px solid #84cc16;
}

.time-cell {
  white-space: nowrap;
}

.time {
  color: #f8fafc;
  font-weight: 600;
  font-size: 0.875rem;
}

.date {
  color: #94a3b8;
  font-size: 0.75rem;
}

.alarm-info {
  min-width: 250px;
}

.alarm-name {
  color: #f8fafc;
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.alarm-message {
  color: #cbd5e1;
  font-size: 0.875rem;
}

.tag-cell .tag-name {
  background: #334155;
  color: #cbd5e1;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.75rem;
  font-family: monospace;
}

.severity-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.severity-badge.critical {
  background: #ef4444;
  color: white;
}

.severity-badge.high {
  background: #f59e0b;
  color: white;
}

.severity-badge.medium {
  background: #eab308;
  color: white;
}

.severity-badge.low {
  background: #84cc16;
  color: white;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
  font-size: 0.75rem;
  font-weight: 600;
}

.status-badge.active {
  background: #ef4444;
  color: white;
}

.status-badge.acknowledged {
  background: #3b82f6;
  color: white;
}

.status-badge.resolved {
  background: #10b981;
  color: white;
}

.ack-time {
  color: #94a3b8;
  font-size: 0.75rem;
  margin-top: 0.25rem;
}

.ack-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
  cursor: pointer;
  font-size: 0.75rem;
  transition: all 0.2s;
}

.ack-btn:hover:not(:disabled) {
  background: #2563eb;
}

.ack-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.no-action {
  color: #64748b;
  font-style: italic;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: #64748b;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.empty-state h3 {
  color: #94a3b8;
  margin-bottom: 0.5rem;
}

.loading {
  text-align: center;
  padding: 3rem;
  color: #94a3b8;
}

.spinner {
  border: 2px solid #334155;
  border-top: 2px solid #3b82f6;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.severity-summary {
  background: #1e293b;
  padding: 1.5rem;
  border-radius: 0.5rem;
  border: 1px solid #334155;
}

.severity-summary h3 {
  color: #f8fafc;
  margin-bottom: 1rem;
  font-size: 1.125rem;
}

.severity-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.severity-card {
  padding: 1.5rem;
  border-radius: 0.5rem;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.severity-card.critical {
  background: #7f1d1d;
  border: 1px solid #ef4444;
}

.severity-card.high {
  background: #78350f;
  border: 1px solid #f59e0b;
}

.severity-card.medium {
  background: #713f12;
  border: 1px solid #eab308;
}

.severity-card.low {
  background: #365314;
  border: 1px solid #84cc16;
}

.severity-card .count {
  font-size: 2rem;
  font-weight: bold;
  color: #f8fafc;
  margin-bottom: 0.5rem;
}

.severity-card .label {
  color: #cbd5e1;
  font-size: 0.875rem;
}

@media (max-width: 768px) {
  .view-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .header-stats {
    justify-content: space-around;
  }
  
  .filters-section {
    flex-direction: column;
  }
  
  .filter-actions {
    margin-left: 0;
    justify-content: center;
  }
  
  .alarms-table-container {
    overflow-x: auto;
  }
  
  .alarms-table {
    min-width: 800px;
  }
  
  .severity-cards {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>