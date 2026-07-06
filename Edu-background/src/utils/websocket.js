const WS_URL = 'ws://localhost:8080/ws/chat'

let socket = null
let messageHandlers = []
let reconnectTimer = null
let reconnectAttempts = 0
const MAX_RECONNECT = 5
const RECONNECT_DELAY = 3000

export function connect() {
  if (socket && socket.readyState === WebSocket.OPEN) return

  const token = localStorage.getItem('admin_token')
  if (!token) {
    console.error('WebSocket: no token')
    return
  }

  socket = new WebSocket(`${WS_URL}?token=${token}`)

  socket.onopen = () => {
    reconnectAttempts = 0
    console.log('WebSocket connected')
  }

  socket.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data)
      messageHandlers.forEach(handler => handler(data))
    } catch (e) {
      console.error('WebSocket parse error:', e)
    }
  }

  socket.onclose = () => {
    console.log('WebSocket closed')
    socket = null
    if (reconnectAttempts < MAX_RECONNECT) {
      reconnectAttempts++
      console.log(`WebSocket reconnecting ${reconnectAttempts}/${MAX_RECONNECT}...`)
      reconnectTimer = setTimeout(() => {
        if (socket && socket.readyState === WebSocket.OPEN) return
        connect()
      }, RECONNECT_DELAY)
    }
  }

  socket.onerror = (err) => {
    console.error('WebSocket error:', err)
  }
}

export function send(data) {
  if (socket && socket.readyState === WebSocket.OPEN) {
    socket.send(JSON.stringify(data))
  } else {
    console.warn('WebSocket not connected, cannot send')
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
  if (socket) {
    socket.close()
    socket = null
  }
}
