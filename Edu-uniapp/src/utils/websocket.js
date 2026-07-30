import { getToken } from '@/api/request'
import { WS_URL } from '@/api/config'

let socketTask = null
let messageHandlers = []
let statusHandlers = []
let reconnectTimer = null
let reconnectAttempts = 0
let _connected = false
let _domainError = false
const MAX_RECONNECT = 5
const RECONNECT_DELAY = 3000

/** 当前 WebSocket 是否已连接 */
export function isConnected() {
  return _connected
}

/** 是否因为域名未配置而无法连接（真机调试常见） */
export function isDomainError() {
  return _domainError
}

/** 注册连接状态变化回调（chat.vue 用于切换轮询模式） */
export function onStatusChange(handler) {
  statusHandlers.push(handler)
  return () => {
    statusHandlers = statusHandlers.filter(h => h !== handler)
  }
}

function notifyStatus() {
  const status = { connected: _connected, domainError: _domainError }
  statusHandlers.forEach(h => h(status))
}

function isDomainErr(err) {
  if (!err) return false
  const msg = err.errMsg || ''
  return msg.includes('url not in domain list') || msg.includes('url not in legal domain')
}

export function connect() {
  if (socketTask) return

  const token = getToken()
  if (!token) {
    console.error('WebSocket: no token')
    return
  }

  socketTask = uni.connectSocket({
    url: `${WS_URL}?token=${token}`,
    complete: () => {}
  })

  socketTask.onOpen(() => {
    _connected = true
    _domainError = false
    reconnectAttempts = 0
    notifyStatus()
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
    _connected = false
    notifyStatus()
    console.log('WebSocket closed')
    socketTask = null
    // 域名错误时不重连（重连也没用，微信校验不会通过）
    if (_domainError) return
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
    if (isDomainErr(err)) {
      _domainError = true
      _connected = false
      notifyStatus()
      // 域名未配置：停止 WebSocket，不再重连，通知 UI 切换到 HTTP 轮询
      console.warn('WebSocket: 域名未在微信后台配置，将使用 HTTP 轮询模式')
      close()
    }
  })
}

export function send(data) {
  if (socketTask && _connected) {
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
  _connected = false
  notifyStatus()
}
