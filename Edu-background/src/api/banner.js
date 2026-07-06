import request from './request'

export function getBannerList(params) {
  return request.get('/banner/admin/list', { params })
}

export function createBanner(data) {
  return request.post('/banner', data)
}

export function updateBanner(id, data) {
  return request.put(`/banner/${id}`, data)
}

export function deleteBanner(id) {
  return request.delete(`/banner/${id}`)
}
