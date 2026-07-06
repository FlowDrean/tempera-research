import { get, post, put, del } from './request'

export function login(username, password) {
  return post('/user/login', { username, password })
}

export function register(data) {
  return post('/user/register', data)
}

export function getUserInfo() {
  return get('/user/info')
}

export function updateUserInfo(data) {
  return put('/user/info', data)
}
