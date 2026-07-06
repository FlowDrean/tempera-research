import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as loginApi, getUserInfo } from '@/api/user'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('admin_token') || '')
  const userInfo = ref(null)

  const isLoggedIn = computed(() => !!token.value)
  const userName = computed(() => userInfo.value?.username || '管理员')
  const userRole = computed(() => userInfo.value?.role || 'admin')

  async function login(username, password) {
    const res = await loginApi(username, password)
    token.value = res.token
    userInfo.value = res.userInfo
    localStorage.setItem('admin_token', res.token)
    localStorage.setItem('admin_user', JSON.stringify(res.userInfo))
    return res
  }

  async function fetchUserInfo() {
    try {
      const info = await getUserInfo()
      userInfo.value = info
      localStorage.setItem('admin_user', JSON.stringify(info))
    } catch {
      // token may be expired
      logout()
    }
  }

  function restoreSession() {
    const savedToken = localStorage.getItem('admin_token')
    const savedUser = localStorage.getItem('admin_user')
    if (savedToken) {
      token.value = savedToken
      if (savedUser) {
        try {
          userInfo.value = JSON.parse(savedUser)
        } catch {
          userInfo.value = null
        }
      }
    }
  }

  function logout() {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem('admin_token')
    localStorage.removeItem('admin_user')
  }

  return { token, userInfo, isLoggedIn, userName, userRole, login, fetchUserInfo, restoreSession, logout }
})
