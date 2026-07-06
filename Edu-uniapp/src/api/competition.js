import { get } from './request'

export function getCompetitionList(params) {
  return get('/competition/list', params)
}

export function getCompetitionDetail(id) {
  return get('/competition/detail/' + id)
}
