import { get, post } from './request'

export function getChatHistory(page = 1, size = 50) {
  return get('/chat/history', { page, size })
}

export function getConversations() {
  return get('/chat/conversations')
}

/**
 * HTTP 发送聊天消息（WebSocket 不可用时的备用通道）
 * @param {Object} payload - { content, msgType?, targetUserId? }
 */
export function sendChatMessage(payload) {
  return post('/chat/send', payload)
}

/**
 * HTTP 轮询新消息（WebSocket 不可用时的备用通道）
 * @param {string} since - ISO 时间字符串，拉取该时间之后的消息
 */
export function pollMessages(since) {
  return get('/chat/poll', since ? { since } : {})
}
