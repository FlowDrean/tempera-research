import request from './request'

export function getExploreList(params) {
  return request.get('/explore/admin/list', { params })
}

export function createExplore(data) {
  return request.post('/explore', data)
}

export function updateExplore(id, data) {
  return request.put(`/explore/${id}`, data)
}

export function deleteExplore(id) {
  return request.delete(`/explore/${id}`)
}
