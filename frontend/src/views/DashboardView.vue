<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <h1>Дашборд SCADA</h1>
      <div class="header-stats">
        <div class="stat-card">
          <div class="stat-value">{{ tagsStore.tags.length }}</div>
          <div class="stat-label">Всего тегов</div>
        </div>
        <div class="stat-card critical">
          <div class="stat-value">{{ tagsStore.criticalTags.length }}</div>
          <div class="stat-label">Критические</div>
        </div>
        <div class="stat-card warning">
          <div class="stat-value">{{ alarmsStore.alarmStats.active }}</div>
          <div class="stat-label">Активные аварии</div>
        </div>
      </div>
    </div>

    <div class="dashboard-content">
      <!-- Critical Alarms Section -->
      <div class="section">
        <h2>⚡ Активные аварии</h2>
        <div class="alarms-grid">
          <div 
            v-for="alarm in alarmsStore.activeAlarms.slice(0, 6)" 
            :key="alarm.id"
            class="alarm-card"
            :class="`severity-${alarm.severity.toLowerCase()}`"
          >
            <div class="alarm-header">
              <span class="alarm-title">{{ alarm.alarm_definition_name }}</span>
              <span class="alarm-severity">{{ getSeverityText(alarm.severity) }}</span>
            </div>
            <div class="alarm-message">{{ alarm.message }}</div>
            <div class="alarm-footer">
              <span class="alarm-tag">{{ alarm.tag_name }}</span>
              <span class="alarm-time">{{ formatTime(alarm.triggered_at) }}</span>
            </div>
            <button 
              @click="acknowledgeAlarm(alarm.id)"
              class="acknowledge-btn"
            >
              Квитировать
            </button>
          </div>
        </div>
      </div>

      <!-- Tags Overview Section -->
      <div class="section">
        <h2>📊 Обзор тегов по типам объектов</h2>
        <div class="tags-overview">
          <div 
            v-for="(typeTags, typeName) in tagsStore.tagsByObjectType" 
            :key="typeName"
            class="type-card"
          >
            <h3>{{ typeName }}</h3>
            <div class="type-stats">
              <span class="tag-count">{{ typeTags.length }} тегов</span>
              <div class="tag-values">
                <div 
                  v-for="tag in typeTags.slice(0, 3)" 
                  :key="tag.id"
                  class="tag-value"
                >
                  <span class="tag-name">{{ tag.name }}</span>
                  <span 
                    class="tag-value-display"
                    :class="getValueClass(tag)"
                  >
                    {{ tag.current_value }} {{ tag.engineering_units }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Critical Tags Section -->
      <div class="section" v-if="tagsStore.criticalTags.length > 0">
        <h2>🚨 Критические теги</h2>
        <div class="critical-tags">
          <div 
            v-for="tag in tagsStore.criticalTags" 
            :key="tag.id"
            class="critical-tag"
          >
            <div class="critical-tag-info">
              <span class="tag-name">{{ tag.name }}</span>
              <span class="tag-object">{{ tag.pipeline_object_name }}</span>
            </div>
            <div 
              class="critical-value"
              :class="getValueClass(tag)"
            >
              {{ tag.current_value }} {{ tag.engineering_units }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="tagsStore.loading || alarmsStore.loading" class="loading">
      Загрузка данных...
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useTagsStore } from '../stores/tags'
import { useAlarmsStore } from '../stores/alarms'

const tagsStore = useTagsStore()
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

const formatTime = (timestamp: string) => {
  return new Date(timestamp).toLocaleTimeString('ru-RU')
}

const getValueClass = (tag: any) => {
  const value = tag.current_value
  const min = tag.min_value
  const max = tag.max_value
  const range = max - min
  const normalized = (value - min) / range
  
  if (normalized < 0.1 || normalized > 0.9) {
    return 'critical-value'
  } else if (normalized < 0.2 || normalized > 0.8) {
    return 'warning-value'
  }
  return 'normal-value'
}

const acknowledgeAlarm = (alarmId: number) => {
  alarmsStore.acknowledgeAlarm(alarmId)
}

onMounted(async () => {
  await Promise.all([
    tagsStore.fetchTags(),
    alarmsStore.fetchActiveAlarms()
  ])
})
</script>

<style scoped>
.dashboard {
  max-width: 1200px;
  margin: 0 auto;
}

.dashboard-header {
  margin-bottom: 2rem;
}

.dashboard-header h1 {
  font-size: 2rem;
  color: #f8fafc;
  margin-bottom: 1rem;
}

.header-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: #1e293b;
  padding: 1.5rem;
  border-radius: 0.5rem;
  border-left: 4px solid #3b82f6;
  text-align: center;
}

.stat-card.critical {
  border-left-color: #ef4444;
}

.stat-card.warning {
  border-left-color: #f59e0b;
}

.stat-value {
  font-size: 2rem;
  font-weight: bold;
  color: #f8fafc;
  margin-bottom: 0.5rem;
}

.stat-label {
  color: #94a3b8;
  font-size: 0.875rem;
}

.section {
  background: #1e293b;
  border-radius: 0.5rem;
  padding: 1.5rem;
  margin-bottom: 2rem;
  border: 1px solid #334155;
}

.section h2 {
  color: #f8fafc;
  margin-bottom: 1rem;
  font-size: 1.25rem;
}

.alarms-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
}

.alarm-card {
  background: #334155;
  padding: 1rem;
  border-radius: 0.375rem;
  border-left: 4px solid #6b7280;
}

.alarm-card.severity-critical {
  border-left-color: #ef4444;
  background: #7f1d1d;
}

.alarm-card.severity-high {
  border-left-color: #f59e0b;
  background: #78350f;
}

.alarm-card.severity-medium {
  border-left-color: #eab308;
  background: #713f12;
}

.alarm-card.severity-low {
  border-left-color: #84cc16;
  background: #365314;
}

.alarm-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.alarm-title {
  font-weight: 600;
  color: #f8fafc;
}

.alarm-severity {
  font-size: 0.75rem;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  background: rgba(255, 255, 255, 0.1);
}

.alarm-message {
  color: #cbd5e1;
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
}

.alarm-footer {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
  color: #94a3b8;
  margin-bottom: 0.5rem;
}

.acknowledge-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
  cursor: pointer;
  font-size: 0.75rem;
  width: 100%;
}

.acknowledge-btn:hover {
  background: #2563eb;
}

.tags-overview {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.type-card {
  background: #334155;
  padding: 1rem;
  border-radius: 0.375rem;
  border: 1px solid #475569;
}

.type-card h3 {
  color: #f8fafc;
  margin-bottom: 0.5rem;
  font-size: 1rem;
}

.type-stats {
  color: #94a3b8;
}

.tag-count {
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
  display: block;
}

.tag-values {
  space-y: 0.25rem;
}

.tag-value {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.25rem 0;
  font-size: 0.75rem;
}

.tag-name {
  color: #cbd5e1;
}

.tag-value-display {
  font-weight: 600;
}

.normal-value {
  color: #84cc16;
}

.warning-value {
  color: #f59e0b;
}

.critical-value {
  color: #ef4444;
}

.critical-tags {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
}

.critical-tag {
  background: #7f1d1d;
  padding: 1rem;
  border-radius: 0.375rem;
  border: 1px solid #ef4444;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.critical-tag-info {
  display: flex;
  flex-direction: column;
}

.critical-tag-info .tag-name {
  font-weight: 600;
  color: #f8fafc;
}

.critical-tag-info .tag-object {
  font-size: 0.75rem;
  color: #fca5a5;
}

.loading {
  text-align: center;
  padding: 2rem;
  color: #94a3b8;
}

@media (max-width: 768px) {
  .dashboard-header h1 {
    font-size: 1.5rem;
  }
  
  .header-stats {
    grid-template-columns: 1fr;
  }
  
  .alarms-grid,
  .tags-overview,
  .critical-tags {
    grid-template-columns: 1fr;
  }
}
</style>