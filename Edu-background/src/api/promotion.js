import request from './request'

export function getPromotionList(params) {
  return request.get('/promotion/admin/list', { params })
}

export function createPromotion(data) {
  return request.post('/promotion', data)
}

export function updatePromotion(id, data) {
  return request.put(`/promotion/${id}`, data)
}

export function deletePromotion(id) {
  return request.delete(`/promotion/${id}`)
}
