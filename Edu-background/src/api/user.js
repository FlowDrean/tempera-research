import request from './request'

export function login(username, password) {
  return request.post('/user/login', { username, password })
}

export function getUserInfo() {
  return request.get('/user/info')
}

export function getUserList(params) {
  return request.get('/user/list', { params })
}

export function createUser(data) {
  return request.post('/user', data)
}

export function updateUser(id, data) {
  return request.put(`/user/${id}`, data)
}

export function deleteUser(id) {
  return request.delete(`/user/${id}`)
}

export function updateUserRole(id, role) {
  return request.put(`/user/${id}/role`, { role })
}
