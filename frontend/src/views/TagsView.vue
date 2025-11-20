<template>
  <div class="tags-view">
    <div class="view-header">
      <h1>📈 Управление тегами</h1>
      <div class="header-actions">
        <button 
          @click="fetchTags" 
          class="refresh-btn"
          :disabled="tagsStore.loading"
        >
          🔄 Обновить
        </button>
        <div class="filter-controls">
          <select v-model="selectedObjectType" @change="onFilterChange">
            <option value="">Все типы объектов</option>
            <option 
              v-for="type in objectTypes" 
              :key="type" 
              :value="type"
            >
              {{ type }}
            </option>
          </select>
        </div>
      </div>
    </div>

    <!-- Error Display -->
    <div v-if="tagsStore.error" class="error-message">
      {{ tagsStore.error }}
      <button @click="tagsStore.clearError" class="close-error">×</button>
    </div>

    <!-- Tags Grid -->
    <div class="tags-grid">
      <div 
        v-for="tag in tagsStore.tags" 
        :key="tag.id"
        class="tag-card"
        :class="getTagCardClass(tag)"
      >
        <div class="tag-header">
          <h3 class="tag-name">{{ tag.name }}</h3>
          <span class="tag-type">{{ tag.object_type_name }}</span>
        </div>
        
        <div class="tag-description">
          {{ tag.description }}
        </div>

        <div class="tag-value-section">
          <div class="current-value">
            <span class="value" :class="getValueClass(tag)">
              {{ tag.current_value.toFixed(2) }}
            </span>
            <span class="units">{{ tag.engineering_units }}</span>
          </div>
          <div class="value-quality">
            Качество: {{ tag.current_quality }}%
          </div>
        </div>

        <div class="tag-meta">
          <div class="meta-item">
            <span class="meta-label">Объект:</span>
            <span class="meta-value">{{ tag.pipeline_object_name }}</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">Индекс:</span>
            <span class="meta-value">{{ tag.object_index }}</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">Км:</span>
            <span class="meta-value">{{ tag.km_mark }}</span>
          </div>
        </div>

        <div class="tag-limits">
          <div class="limit-bar">
            <div 
              class="limit-fill"
              :style="getLimitBarStyle(tag)"
            ></div>
            <div class="limit-labels">
              <span>{{ tag.min_value }}</span>
              <span>{{ tag.max_value }}</span>
            </div>
          </div>
        </div>

        <div class="tag-actions">
          <button 
            @click="showTagHistory(tag)"
            class="action-btn history-btn"
          >
            📊 История
          </button>
          <button 
            @click="showTagDetails(tag)"
            class="action-btn details-btn"
          >
            ℹ️ Подробности
          </button>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="tagsStore.loading" class="loading">
      <div class="spinner"></div>
      Загрузка тегов...
    </div>

    <!-- Empty State -->
    <div v-if="!tagsStore.loading && tagsStore.tags.length === 0" class="empty-state">
      <div class="empty-icon">📊</div>
      <h3>Теги не найдены</h3>
      <p>Попробуйте изменить фильтры или обновить данные</p>
    </div>

    <!-- Tag History Modal -->
    <div v-if="showHistoryModal" class="modal-overlay" @click="closeHistoryModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>История тега: {{ selectedTag?.name }}</h2>
          <button @click="closeHistoryModal" class="close-modal">×</button>
        </div>
        <div class="modal-body">
          <div v-if="tagsStore.tagHistory.length === 0" class="no-data">
            Нет данных за выбранный период
          </div>
          <div v-else class="history-list">
            <div 
              v-for="value in tagsStore.tagHistory.slice(0, 10)" 
              :key="value.id"
              class="history-item"
            >
              <span class="history-value">{{ value.value.toFixed(2) }}</span>
              <span class="history-quality">({{ value.quality }}%)</span>
              <span class="history-time">{{ formatTime(value.timestamp) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useTagsStore } from '../stores/tags'
import type { Tag } from '../services/api'

const tagsStore = useTagsStore()

const selectedObjectType = ref('')
const showHistoryModal = ref(false)
const selectedTag = ref<Tag | null>(null)

const objectTypes = computed(() => {
  const types = new Set(tagsStore.tags.map(tag => tag.object_type_name))
  return Array.from(types).sort()
})

const getTagCardClass = (tag: Tag) => {
  const value = tag.current_value
  const min = tag.min_value
  const max = tag.max_value
  const range = max - min
  const normalized = (value - min) / range
  
  if (normalized < 0.1 || normalized > 0.9) {
    return 'critical'
  } else if (normalized < 0.2 || normalized > 0.8) {
    return 'warning'
  }
  return 'normal'
}

const getValueClass = (tag: Tag) => {
  const cardClass = getTagCardClass(tag)
  return `${cardClass}-value`
}

const getLimitBarStyle = (tag: Tag) => {
  const value = tag.current_value
  const min = tag.min_value
  const max = tag.max_value
  const percentage = ((value - min) / (max - min)) * 100
  return {
    width: `${Math.max(0, Math.min(100, percentage))}%`
  }
}

const onFilterChange = () => {
  const params: any = {}
  if (selectedObjectType.value) {
    params.object_type = selectedObjectType.value
  }
  tagsStore.fetchTags(params)
}

const fetchTags = () => {
  tagsStore.fetchTags()
}

const showTagHistory = async (tag: Tag) => {
  selectedTag.value = tag
  showHistoryModal.value = true
  await tagsStore.fetchTagHistory(tag.id)
}

const showTagDetails = (tag: Tag) => {
  // В реальном приложении здесь можно открыть детальную модалку
  console.log('Tag details:', tag)
  alert(`Детали тега: ${tag.name}\nЗначение: ${tag.current_value} ${tag.engineering_units}`)
}

const closeHistoryModal = () => {
  showHistoryModal.value = false
  selectedTag.value = null
}

const formatTime = (timestamp: string) => {
  return new Date(timestamp).toLocaleString('ru-RU')
}

onMounted(() => {
  tagsStore.fetchTags()
})
</script>

<style scoped>
.tags-view {
  max-width: 1400px;
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

.header-actions {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.refresh-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
  cursor: pointer;
  font-size: 0.875rem;
}

.refresh-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.refresh-btn:hover:not(:disabled) {
  background: #2563eb;
}

.filter-controls select {
  background: #1e293b;
  color: #f8fafc;
  border: 1px solid #334155;
  padding: 0.5rem;
  border-radius: 0.375rem;
  font-size: 0.875rem;
}

.error-message {
  background: #7f1d1d;
  color: #fecaca;
  padding: 1rem;
  border-radius: 0.375rem;
  margin-bottom: 1rem;
  display: flex;
  justify-content: between;
  align-items: center;
}

.close-error {
  background: none;
  border: none;
  color: #fecaca;
  font-size: 1.25rem;
  cursor: pointer;
  margin-left: auto;
}

.tags-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.tag-card {
  background: #1e293b;
  border: 1px solid #334155;
  border-radius: 0.5rem;
  padding: 1.5rem;
  transition: all 0.2s;
}

.tag-card:hover {
  border-color: #475569;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.tag-card.critical {
  border-left: 4px solid #ef4444;
}

.tag-card.warning {
  border-left: 4px solid #f59e0b;
}

.tag-card.normal {
  border-left: 4px solid #10b981;
}

.tag-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 1rem;
}

.tag-name {
  color: #f8fafc;
  font-size: 1.125rem;
  margin: 0;
  word-break: break-word;
}

.tag-type {
  background: #334155;
  color: #cbd5e1;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.75rem;
  white-space: nowrap;
}

.tag-description {
  color: #94a3b8;
  font-size: 0.875rem;
  margin-bottom: 1rem;
  line-height: 1.4;
}

.tag-value-section {
  background: #0f172a;
  padding: 1rem;
  border-radius: 0.375rem;
  margin-bottom: 1rem;
  text-align: center;
}

.current-value {
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.value {
  font-size: 2rem;
  font-weight: bold;
}

.units {
  color: #94a3b8;
  font-size: 1rem;
}

.critical-value {
  color: #ef4444;
}

.warning-value {
  color: #f59e0b;
}

.normal-value {
  color: #10b981;
}

.value-quality {
  color: #64748b;
  font-size: 0.875rem;
}

.tag-meta {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.meta-item {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
}

.meta-label {
  color: #64748b;
}

.meta-value {
  color: #cbd5e1;
  font-weight: 500;
}

.tag-limits {
  margin-bottom: 1rem;
}

.limit-bar {
  background: #334155;
  height: 6px;
  border-radius: 3px;
  position: relative;
  margin-bottom: 0.5rem;
}

.limit-fill {
  height: 100%;
  border-radius: 3px;
  background: #3b82f6;
  transition: width 0.3s;
}

.tag-card.critical .limit-fill {
  background: #ef4444;
}

.tag-card.warning .limit-fill {
  background: #f59e0b;
}

.limit-labels {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
  color: #64748b;
}

.tag-actions {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  flex: 1;
  padding: 0.5rem;
  border: none;
  border-radius: 0.25rem;
  cursor: pointer;
  font-size: 0.75rem;
  transition: all 0.2s;
}

.history-btn {
  background: #3b82f6;
  color: white;
}

.history-btn:hover {
  background: #2563eb;
}

.details-btn {
  background: #6b7280;
  color: white;
}

.details-btn:hover {
  background: #4b5563;
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

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: #1e293b;
  border-radius: 0.5rem;
  width: 90%;
  max-width: 500px;
  max-height: 80vh;
  overflow: hidden;
  border: 1px solid #334155;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #334155;
}

.modal-header h2 {
  color: #f8fafc;
  margin: 0;
  font-size: 1.25rem;
}

.close-modal {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
}

.close-modal:hover {
  color: #f8fafc;
}

.modal-body {
  padding: 1.5rem;
  max-height: 400px;
  overflow-y: auto;
}

.no-data {
  text-align: center;
  color: #64748b;
  padding: 2rem;
}

.history-list {
  space-y: 0.5rem;
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  background: #0f172a;
  border-radius: 0.375rem;
  font-size: 0.875rem;
}

.history-value {
  color: #f8fafc;
  font-weight: 600;
}

.history-quality {
  color: #94a3b8;
}

.history-time {
  color: #64748b;
  font-size: 0.75rem;
}

@media (max-width: 768px) {
  .view-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .header-actions {
    justify-content: space-between;
  }
  
  .tags-grid {
    grid-template-columns: 1fr;
  }
  
  .tag-meta {
    grid-template-columns: 1fr;
  }
  
  .modal-content {
    width: 95%;
    margin: 1rem;
  }
}
</style>