import request from './request'

export function getCompetitionList(params) {
  return request.get('/competition/list', { params })
}

export function getCompetitionDetail(id) {
  return request.get(`/competition/detail/${id}`)
}

export function createCompetition(data) {
  return request.post('/competition', data)
}

export function updateCompetition(id, data) {
  return request.put(`/competition/${id}`, data)
}

export function deleteCompetition(id) {
  return request.delete(`/competition/${id}`)
}
