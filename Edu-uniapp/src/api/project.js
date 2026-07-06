import { get } from './request'

export function getProjectList(params) {
  return get('/project/list', params)
}

export function getProjectDetail(id) {
  return get('/project/detail/' + id)
}

export function getFeaturedProjects() {
  return get('/project/list', { page: 1, size: 6 })
}
