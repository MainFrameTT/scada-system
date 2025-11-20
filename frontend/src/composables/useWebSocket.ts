import { ref, onMounted, onUnmounted } from 'vue'

interface WebSocketMessage {
  type: string
  data?: any
  message?: string
}

export function useWebSocket() {
  const socket = ref<WebSocket | null>(null)
  const isConnected = ref(false)
  const lastMessage = ref<WebSocketMessage | null>(null)

  const connect = () => {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
    const wsUrl = `${protocol}//${window.location.host}/ws/tags/`
    
    try {
      socket.value = new WebSocket(wsUrl)
      
      socket.value.onopen = () => {
        isConnected.value = true
        console.log('WebSocket connected')
      }
      
      socket.value.onmessage = (event) => {
        try {
          lastMessage.value = JSON.parse(event.data)
          console.log('WebSocket message:', lastMessage.value)
        } catch (error) {
          console.error('Error parsing WebSocket message:', error)
        }
      }
      
      socket.value.onclose = () => {
        isConnected.value = false
        console.log('WebSocket disconnected')
        // Attempt to reconnect after 5 seconds
        setTimeout(connect, 5000)
      }
      
      socket.value.onerror = (error) => {
        console.error('WebSocket error:', error)
        isConnected.value = false
      }
    } catch (error) {
      console.error('Failed to create WebSocket connection:', error)
    }
  }

  const send = (message: WebSocketMessage) => {
    if (socket.value && isConnected.value) {
      socket.value.send(JSON.stringify(message))
    }
  }

  const subscribeToTags = () => {
    send({
      type: 'subscribe_tags',
      action: 'subscribe_tags'
    })
  }

  const subscribeToAlarms = () => {
    send({
      type: 'subscribe_alarms', 
      action: 'subscribe_alarms'
    })
  }

  onMounted(() => {
    connect()
  })

  onUnmounted(() => {
    if (socket.value) {
      socket.value.close()
    }
  })

  return {
    isConnected,
    lastMessage,
    send,
    subscribeToTags,
    subscribeToAlarms
  }
}