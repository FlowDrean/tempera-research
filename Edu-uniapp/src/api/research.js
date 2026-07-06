import { get } from './request'

export function getResearchTourList(params) {
  return get('/research-tour/list', params)
}

export function getResearchTourDetail(id) {
  return get('/research-tour/detail/' + id)
}
