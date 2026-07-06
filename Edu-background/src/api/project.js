import request from './request'

/**
 * Get project list with filters and pagination
 */
export function getProjectList(params) {
  return request.get('/project/list', { params })
}

/**
 * Get project detail by ID
 */
export function getProjectDetail(id) {
  return request.get(`/project/detail/${id}`)
}

/**
 * Create a new project
 */
export function createProject(data) {
  return request.post('/project', data)
}

/**
 * Update an existing project
 */
export function updateProject(id, data) {
  return request.put(`/project/${id}`, data)
}

/**
 * Delete a project
 */
export function deleteProject(id) {
  return request.delete(`/project/${id}`)
}
