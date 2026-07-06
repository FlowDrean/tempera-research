import request from './request'

export function getResearchList(params) {
  return request.get('/research-tour/list', { params })
}

export function getResearchDetail(id) {
  return request.get(`/research-tour/detail/${id}`)
}

export function createResearch(data) {
  return request.post('/research-tour', data)
}

export function updateResearch(id, data) {
  return request.put(`/research-tour/${id}`, data)
}

export function deleteResearch(id) {
  return request.delete(`/research-tour/${id}`)
}
