import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api'

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    // Add auth token if available
    const token = localStorage.getItem('auth_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized access
      localStorage.removeItem('auth_token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export interface Tag {
  id: number
  name: string
  description: string
  data_type: string
  engineering_units: string
  min_value: number
  max_value: number
  current_value: number
  current_quality: number
  pipeline_object_name: string
  object_type_name: string
  object_index: string
  km_mark: number
}

export interface Alarm {
  id: number
  alarm_definition_name: string
  tag_name: string
  message: string
  severity: string
  state: string
  triggered_at: string
  acknowledged_at: string | null
  acknowledged_by_name: string | null
}

export interface PipelineObject {
  id: number
  name: string
  index: string
  object_type_name: string
  location: string
  km_mark: number
  description: string
}

export interface TagValue {
  id: number
  tag: number
  tag_name: string
  value: number
  quality: number
  timestamp: string
}

export interface ApiResponse<T> {
  count?: number
  next?: string
  previous?: string
  results: T[]
}

// API methods
export const apiService = {
  // Tags
  getTags: (params?: any): Promise<ApiResponse<Tag>> =>
    api.get('/tags/', { params }).then(res => res.data),

  getTag: (id: number): Promise<Tag> =>
    api.get(`/tags/${id}/`).then(res => res.data),

  getTagHistory: (tagId: number, startTime?: string, endTime?: string): Promise<TagValue[]> =>
    api.get('/tag-values/', { 
      params: { tag_id: tagId, start_time: startTime, end_time: endTime }
    }).then(res => res.data),

  // Alarms
  getAlarms: (params?: any): Promise<ApiResponse<Alarm>> =>
    api.get('/alarms/', { params }).then(res => res.data),

  getActiveAlarms: (): Promise<{ items: Alarm[], total: number }> =>
    api.get('/alarms/active/').then(res => res.data),

  acknowledgeAlarm: (alarmId: number, userId: number): Promise<any> =>
    api.post(`/alarms/${alarmId}/acknowledge/`, { acknowledged_by: userId }),

  // Pipeline Objects
  getPipelineObjects: (params?: any): Promise<ApiResponse<PipelineObject>> =>
    api.get('/pipeline-objects/', { params }).then(res => res.data),

  getObjectTypes: (): Promise<ApiResponse<any>> =>
    api.get('/object-types/').then(res => res.data),
}

export default api