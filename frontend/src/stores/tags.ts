import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { apiService, type Tag, type TagValue } from '../services/api'

export const useTagsStore = defineStore('tags', () => {
  const tags = ref<Tag[]>([])
  const currentTag = ref<Tag | null>(null)
  const tagHistory = ref<TagValue[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Computed
  const tagsByObjectType = computed(() => {
    const grouped: Record<string, Tag[]> = {}
    tags.value.forEach(tag => {
      const type = tag.object_type_name
      if (!grouped[type]) {
        grouped[type] = []
      }
      grouped[type].push(tag)
    })
    return grouped
  })

  const criticalTags = computed(() => 
    tags.value.filter(tag => {
      const value = tag.current_value
      const min = tag.min_value
      const max = tag.max_value
      const range = max - min
      const normalized = (value - min) / range
      return normalized < 0.1 || normalized > 0.9
    })
  )

  // Actions
  const fetchTags = async (params?: any) => {
    loading.value = true
    error.value = null
    try {
      const response = await apiService.getTags(params)
      tags.value = response.results
    } catch (err: any) {
      error.value = err.message || 'Failed to fetch tags'
      console.error('Error fetching tags:', err)
    } finally {
      loading.value = false
    }
  }

  const fetchTag = async (id: number) => {
    loading.value = true
    error.value = null
    try {
      currentTag.value = await apiService.getTag(id)
    } catch (err: any) {
      error.value = err.message || 'Failed to fetch tag'
      console.error('Error fetching tag:', err)
    } finally {
      loading.value = false
    }
  }

  const fetchTagHistory = async (tagId: number, hours: number = 24) => {
    loading.value = true
    error.value = null
    try {
      const endTime = new Date().toISOString()
      const startTime = new Date(Date.now() - hours * 60 * 60 * 1000).toISOString()
      
      tagHistory.value = await apiService.getTagHistory(tagId, startTime, endTime)
    } catch (err: any) {
      error.value = err.message || 'Failed to fetch tag history'
      console.error('Error fetching tag history:', err)
    } finally {
      loading.value = false
    }
  }

  const updateTagValue = (tagId: number, value: number, quality: number = 100) => {
    const tag = tags.value.find(t => t.id === tagId)
    if (tag) {
      // In a real app, this would come from WebSocket
      tag.current_value = value
      tag.current_quality = quality
    }
  }

  const clearError = () => {
    error.value = null
  }

  return {
    // State
    tags,
    currentTag,
    tagHistory,
    loading,
    error,

    // Computed
    tagsByObjectType,
    criticalTags,

    // Actions
    fetchTags,
    fetchTag,
    fetchTagHistory,
    updateTagValue,
    clearError
  }
})