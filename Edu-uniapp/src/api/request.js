import { BASE_URL, STATIC_BASE } from './config'

/**
 * Resolve image URL: if relative path like /uploads/..., prepend server base
 */
export function resolveImageUrl(url) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/')) return STATIC_BASE + url
  return STATIC_BASE + '/' + url
}

let token = ''
let tokenKey = 'tempera_token'

export function setToken(t) {
  token = t
  if (t) {
    uni.setStorageSync(tokenKey, t)
  } else {
    uni.removeStorageSync(tokenKey)
  }
}

export function getToken() {
  if (!token) {
    token = uni.getStorageSync(tokenKey) || ''
  }
  return token
}

function request(url, method = 'GET', data = {}, header = {}) {
  const t = getToken()
  if (t) {
    header['Authorization'] = 'Bearer ' + t
  }

  return new Promise((resolve, reject) => {
    uni.request({
      url: BASE_URL + url,
      method: method,
      data: data,
      header: { 'Content-Type': 'application/json', ...header },
      success: (res) => {
        const result = res.data
        if (result.code === 200) {
          resolve(result.data)
        } else if (result.code === 401) {
          // 登录/注册接口的401是"账号或密码错误"，不跳转
          const isAuthEndpoint = url.includes('/user/login') || url.includes('/user/register')
          if (!isAuthEndpoint) {
            setToken('')
            uni.switchTab({ url: '/pages/user/user' })
          }
          uni.showToast({ title: result.message || '请先登录', icon: 'none' })
          reject(result)
        } else {
          uni.showToast({ title: result.message || '请求失败', icon: 'none' })
          reject(result)
        }
      },
      fail: (err) => {
        uni.showToast({ title: '网络错误', icon: 'none' })
        reject(err)
      }
    })
  })
}

export function get(url, params = {}) {
  const query = Object.keys(params)
    .filter(k => params[k] !== undefined && params[k] !== null && params[k] !== '')
    .map(k => `${k}=${encodeURIComponent(params[k])}`)
    .join('&')
  return request(url + (query ? '?' + query : ''), 'GET')
}

export function post(url, data = {}) {
  return request(url, 'POST', data)
}

export function put(url, data = {}) {
  return request(url, 'PUT', data)
}

export function del(url, params = {}) {
  const query = Object.keys(params)
    .filter(k => params[k] !== undefined && params[k] !== null && params[k] !== '')
    .map(k => `${k}=${encodeURIComponent(params[k])}`)
    .join('&')
  return request(url + (query ? '?' + query : ''), 'DELETE')
}

export function uploadFile(filePath) {
  return new Promise((resolve, reject) => {
    uni.uploadFile({
      url: BASE_URL + '/file/upload',
      filePath: filePath,
      name: 'file',
      header: { 'Authorization': 'Bearer ' + getToken() },
      success: (res) => {
        const result = JSON.parse(res.data)
        if (result.code === 200) {
          resolve(result.data)
        } else {
          reject(result)
        }
      },
      fail: reject
    })
  })
}
