import { get } from './request'

export function getChatHistory(page = 1, size = 50) {
  return get('/chat/history', { page, size })
}

export function getConversations() {
  return get('/chat/conversations')
}
