import { getToken } from '@/api/request'

const WS_BASE_URL = 'ws://192.144.187.103'

let socketTask = null
let messageHandlers = []
let reconnectTimer = null
let reconnectAttempts = 0
const MAX_RECONNECT = 5
const RECONNECT_DELAY = 3000

export function connect() {
  if (socketTask) return

  const token = getToken()
  if (!token) {
    console.error('WebSocket: no token')
    return
  }

  socketTask = uni.connectSocket({
    url: `${WS_BASE_URL}/ws/chat?token=${token}`,
    complete: () => {}
  })

  socketTask.onOpen(() => {
    reconnectAttempts = 0
    console.log('WebSocket connected')
  })

  socketTask.onMessage((res) => {
    try {
      const data = JSON.parse(res.data)
      messageHandlers.forEach(handler => handler(data))
    } catch (e) {
      console.error('WebSocket parse error:', e)
    }
  })

  socketTask.onClose(() => {
    console.log('WebSocket closed')
    socketTask = null
    if (reconnectAttempts < MAX_RECONNECT) {
      reconnectAttempts++
      console.log(`WebSocket reconnecting ${reconnectAttempts}/${MAX_RECONNECT}...`)
      reconnectTimer = setTimeout(() => {
        if (socketTask) return
        connect()
      }, RECONNECT_DELAY)
    }
  })

  socketTask.onError((err) => {
    console.error('WebSocket error:', err)
  })
}

export function send(data) {
  if (socketTask) {
    socketTask.send({
      data: JSON.stringify(data),
      fail: (err) => console.error('WebSocket send error:', err)
    })
  }
}

export function onMessage(handler) {
  messageHandlers.push(handler)
  return () => {
    messageHandlers = messageHandlers.filter(h => h !== handler)
  }
}

export function close() {
  if (reconnectTimer) {
    clearTimeout(reconnectTimer)
    reconnectTimer = null
  }
  reconnectAttempts = MAX_RECONNECT
  if (socketTask) {
    socketTask.close()
    socketTask = null
  }
}
