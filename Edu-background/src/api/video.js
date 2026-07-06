import request from './request'

/**
 * Get video list with filters and pagination
 */
export function getVideoList(params) {
  return request.get('/video/list', { params })
}

/**
 * Get video detail by ID
 */
export function getVideoDetail(id) {
  return request.get(`/video/detail/${id}`)
}

/**
 * Create a new video
 */
export function createVideo(data) {
  return request.post('/video', data)
}

/**
 * Update an existing video
 */
export function updateVideo(id, data) {
  return request.put(`/video/${id}`, data)
}

/**
 * Delete a video
 */
export function deleteVideo(id) {
  return request.delete(`/video/${id}`)
}
