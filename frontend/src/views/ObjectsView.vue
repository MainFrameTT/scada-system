<template>
  <div class="objects-view">
    <div class="view-header">
      <h1>🏗️ Объекты нефтепровода</h1>
      <div class="header-stats">
        <div class="stat-item">
          <span class="stat-number">{{ objects.length }}</span>
          <span class="stat-label">Всего объектов</span>
        </div>
        <div class="stat-item">
          <span class="stat-number">{{ objectTypes.length }}</span>
          <span class="stat-label">Типов объектов</span>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters-section">
      <div class="filter-group">
        <label>Тип объекта:</label>
        <select v-model="selectedObjectType" @change="applyFilters">
          <option value="">Все типы</option>
          <option 
            v-for="type in objectTypes" 
            :key="type.id" 
            :value="type.id"
          >
            {{ type.name }}
          </option>
        </select>
      </div>
      <div class="filter-actions">
        <button @click="refreshObjects" class="refresh-btn" :disabled="loading">
          🔄 Обновить
        </button>
      </div>
    </div>

    <!-- Objects Grid -->
    <div class="objects-grid">
      <div 
        v-for="object in filteredObjects" 
        :key="object.id"
        class="object-card"
      >
        <div class="object-header">
          <div class="object-icon">
            {{ getObjectIcon(object.object_type_name) }}
          </div>
          <div class="object-info">
            <h3 class="object-name">{{ object.name }}</h3>
            <span class="object-type">{{ object.object_type_name }}</span>
          </div>
          <span class="object-index">#{{ object.index }}</span>
        </div>

        <div class="object-details">
          <div class="detail-item">
            <span class="detail-label">📍 Местоположение:</span>
            <span class="detail-value">{{ object.location }}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">📏 Километр:</span>
            <span class="detail-value">{{ object.km_mark }} км</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">📝 Описание:</span>
            <span class="detail-value">{{ object.description || 'Нет описания' }}</span>
          </div>
        </div>

        <div class="object-tags">
          <div class="tags-header">
            <span class="tags-title">Теги объекта:</span>
            <span class="tags-count">{{ getObjectTagsCount(object.id) }} тегов</span>
          </div>
          <div class="tags-list">
            <span 
              v-for="tag in getObjectTags(object.id)" 
              :key="tag.id"
              class="tag-item"
              :class="getTagStatusClass(tag)"
            >
              {{ tag.name }}
              <span class="tag-value">{{ tag.current_value }} {{ tag.engineering_units }}</span>
            </span>
          </div>
        </div>

        <div class="object-actions">
          <button @click="showObjectDetails(object)" class="action-btn details-btn">
            📊 Детали
          </button>
          <button @click="showObjectTags(object)" class="action-btn tags-btn">
            📈 Теги
          </button>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
      Загрузка объектов...
    </div>

    <!-- Empty State -->
    <div v-if="!loading && filteredObjects.length === 0" class="empty-state">
      <div class="empty-icon">🏗️</div>
      <h3>Объекты не найдены</h3>
      <p>Попробуйте изменить фильтры</p>
    </div>

    <!-- Object Types Summary -->
    <div class="types-summary">
      <h3>Распределение по типам</h3>
      <div class="types-grid">
        <div 
          v-for="type in objectTypes" 
          :key="type.id"
          class="type-card"
        >
          <div class="type-icon">{{ getObjectIcon(type.name) }}</div>
          <div class="type-info">
            <span class="type-name">{{ type.name }}</span>
            <span class="type-count">
              {{ getObjectsByType(type.id).length }} объектов
            </span>
          </div>
          <div class="type-description">
            {{ type.description }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { apiService, type PipelineObject, type ObjectType, type Tag } from '../services/api'
import { useTagsStore } from '../stores/tags'

const tagsStore = useTagsStore()

const objects = ref<PipelineObject[]>([])
const objectTypes = ref<ObjectType[]>([])
const loading = ref(false)
const selectedObjectType = ref('')

const filteredObjects = computed(() => {
  if (!selectedObjectType.value) {
    return objects.value
  }
  return objects.value.filter(obj => 
    obj.object_type_name === getTypeNameById(selectedObjectType.value)
  )
})

const getObjectIcon = (typeName: string) => {
  const icons: Record<string, string> = {
    'НПС': '🏭',
    'Резервуар': '🛢️',
    'Насос': '⚙️',
    'Клапан': '🔧',
    'ДК': '📊',
    'ДТ': '🌡️',
    'ДР': '📈',
    'ЗК': '🚪'
  }
  return icons[typeName] || '🏗️'
}

const getObjectTags = (objectId: number): Tag[] => {
  return tagsStore.tags.filter(tag => 
    tag.pipeline_object_name === objects.value.find(obj => obj.id === objectId)?.name
  )
}

const getObjectTagsCount = (objectId: number): number => {
  return getObjectTags(objectId).length
}

const getTagStatusClass = (tag: Tag) => {
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

const getObjectsByType = (typeId: string) => {
  const typeName = getTypeNameById(typeId)
  return objects.value.filter(obj => obj.object_type_name === typeName)
}

const getTypeNameById = (typeId: string) => {
  const type = objectTypes.value.find(t => t.id.toString() === typeId)
  return type?.name || ''
}

const applyFilters = () => {
  // Фильтрация происходит через computed свойство
}

const refreshObjects = async () => {
  await fetchObjects()
  await tagsStore.fetchTags()
}

const showObjectDetails = (object: PipelineObject) => {
  // В реальном приложении здесь можно открыть детальную модалку
  console.log('Object details:', object)
  alert(`Детали объекта: ${object.name}\nТип: ${object.object_type_name}\nМестоположение: ${object.location}`)
}

const showObjectTags = (object: PipelineObject) => {
  // Навигация к тегам с фильтром по объекту
  const objectTags = getObjectTags(object.id)
  if (objectTags.length > 0) {
    // В реальном приложении можно перейти на страницу тегов с фильтром
    alert(`Теги объекта ${object.name}:\n${objectTags.map(tag => `• ${tag.name}: ${tag.current_value} ${tag.engineering_units}`).join('\n')}`)
  } else {
    alert('У объекта нет тегов')
  }
}

const fetchObjects = async () => {
  loading.value = true
  try {
    const [objectsResponse, typesResponse] = await Promise.all([
      apiService.getPipelineObjects(),
      apiService.getObjectTypes()
    ])
    objects.value = objectsResponse.results
    objectTypes.value = typesResponse.results
  } catch (error) {
    console.error('Error fetching objects:', error)
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await Promise.all([
    fetchObjects(),
    tagsStore.fetchTags()
  ])
})
</script>

<style scoped>
.objects-view {
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
  min-width: 120px;
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
  min-width: 200px;
}

.filter-actions {
  margin-left: auto;
}

.refresh-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s;
}

.refresh-btn:hover:not(:disabled) {
  background: #2563eb;
}

.refresh-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.objects-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.object-card {
  background: #1e293b;
  border: 1px solid #334155;
  border-radius: 0.5rem;
  padding: 1.5rem;
  transition: all 0.2s;
}

.object-card:hover {
  border-color: #475569;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.object-header {
  display: flex;
  align-items: start;
  margin-bottom: 1rem;
  gap: 1rem;
}

.object-icon {
  font-size: 2rem;
  background: #334155;
  padding: 0.5rem;
  border-radius: 0.5rem;
  min-width: 60px;
  text-align: center;
}

.object-info {
  flex: 1;
}

.object-name {
  color: #f8fafc;
  font-size: 1.125rem;
  margin: 0 0 0.25rem 0;
  line-height: 1.2;
}

.object-type {
  color: #3b82f6;
  font-size: 0.875rem;
  font-weight: 500;
}

.object-index {
  background: #334155;
  color: #cbd5e1;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.75rem;
  font-weight: 600;
}

.object-details {
  margin-bottom: 1.5rem;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 0.75rem;
  font-size: 0.875rem;
}

.detail-label {
  color: #94a3b8;
  font-weight: 500;
  min-width: 120px;
}

.detail-value {
  color: #cbd5e1;
  text-align: right;
  flex: 1;
  margin-left: 1rem;
}

.object-tags {
  background: #0f172a;
  padding: 1rem;
  border-radius: 0.375rem;
  margin-bottom: 1.5rem;
}

.tags-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.tags-title {
  color: #f8fafc;
  font-weight: 600;
  font-size: 0.875rem;
}

.tags-count {
  color: #64748b;
  font-size: 0.75rem;
}

.tags-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.tag-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem;
  background: #1e293b;
  border-radius: 0.25rem;
  font-size: 0.75rem;
  border-left: 3px solid #334155;
}

.tag-item.critical {
  border-left-color: #ef4444;
  background: #7f1d1d;
}

.tag-item.warning {
  border-left-color: #f59e0b;
  background: #78350f;
}

.tag-item.normal {
  border-left-color: #10b981;
  background: #064e3b;
}

.tag-value {
  color: #cbd5e1;
  font-weight: 600;
  font-family: monospace;
}

.object-actions {
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

.details-btn {
  background: #3b82f6;
  color: white;
}

.details-btn:hover {
  background: #2563eb;
}

.tags-btn {
  background: #6b7280;
  color: white;
}

.tags-btn:hover {
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

.types-summary {
  background: #1e293b;
  padding: 1.5rem;
  border-radius: 0.5rem;
  border: 1px solid #334155;
}

.types-summary h3 {
  color: #f8fafc;
  margin-bottom: 1rem;
  font-size: 1.125rem;
}

.types-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1rem;
}

.type-card {
  background: #0f172a;
  padding: 1.5rem;
  border-radius: 0.5rem;
  border: 1px solid #334155;
  display: flex;
  align-items: center;
  gap: 1rem;
  transition: all 0.2s;
}

.type-card:hover {
  border-color: #475569;
  transform: translateY(-1px);
}

.type-icon {
  font-size: 2rem;
  background: #334155;
  padding: 0.5rem;
  border-radius: 0.5rem;
  min-width: 60px;
  text-align: center;
}

.type-info {
  flex: 1;
}

.type-name {
  color: #f8fafc;
  font-weight: 600;
  display: block;
  margin-bottom: 0.25rem;
}

.type-count {
  color: #94a3b8;
  font-size: 0.875rem;
}

.type-description {
  color: #64748b;
  font-size: 0.75rem;
  line-height: 1.4;
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
  }
  
  .objects-grid {
    grid-template-columns: 1fr;
  }
  
  .object-header {
    flex-direction: column;
    text-align: center;
  }
  
  .object-icon {
    align-self: center;
  }
  
  .detail-item {
    flex-direction: column;
    gap: 0.25rem;
  }
  
  .detail-value {
    text-align: left;
    margin-left: 0;
  }
  
  .types-grid {
    grid-template-columns: 1fr;
  }
}
</style>