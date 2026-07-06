import { get } from './request'

export function getVideoList(params) {
  return get('/video/list', params)
}

export function getVideoDetail(id) {
  return get('/video/detail/' + id)
}
