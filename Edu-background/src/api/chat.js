import request from './request'

export function getConversations() {
  return request.get('/chat/conversations')
}

export function getAdminChatHistory(targetUserId, page = 1, size = 50) {
  return request.get(`/chat/admin/history/${targetUserId}`, { params: { page, size } })
}
