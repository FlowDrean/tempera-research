import request from './request'

export function getApplicationList(params) {
  return request.get('/application/list', { params })
}

export function updateApplicationStatus(id, data) {
  return request.put(`/application/${id}/status`, data)
}
