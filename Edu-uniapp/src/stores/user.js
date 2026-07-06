import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as apiLogin, getUserInfo } from '@/api/user'
import { setToken, getToken } from '@/api/request'

export const useUserStore = defineStore('user', () => {
  const userInfo = ref(null)
  const token = ref(getToken())
  const initialized = ref(false)

  const isLoggedIn = computed(() => !!token.value)
  const userId = computed(() => userInfo.value?.id || '')
  const role = computed(() => userInfo.value?.role || 'user')
  const isAdmin = computed(() => role.value === 'admin')
  const userName = computed(() => userInfo.value?.username || '新同学')
  const userPhone = computed(() => userInfo.value?.phone || '')
  const userEmail = computed(() => userInfo.value?.email || '')
  const userSchool = computed(() => userInfo.value?.school || '')
  const userAvatar = computed(() => userInfo.value?.avatar || '')

  async function login(username, password) {
    const res = await apiLogin(username, password)
    if (res && res.token) {
      token.value = res.token
      setToken(res.token)
      if (res.userInfo) {
        userInfo.value = res.userInfo
      }
      return true
    }
    return false
  }

  async function fetchUserInfo() {
    if (!token.value) {
      initialized.value = true
      return
    }
    try {
      const info = await getUserInfo()
      userInfo.value = info
    } catch (e) {
      console.error('Failed to fetch user info:', e)
    } finally {
      initialized.value = true
    }
  }

  async function updateProfile(data) {
    const { updateUserInfo } = await import('@/api/user')
    await updateUserInfo(data)
    await fetchUserInfo()
  }

  function logout() {
    token.value = ''
    userInfo.value = null
    setToken('')
    uni.removeStorageSync('tempera_token')
  }

  /**
   * 初始化：从 storage 恢复登录态，并拉取用户信息
   * 在 App.vue onLaunch 中调用
   */
  async function init() {
    const savedToken = getToken()
    if (savedToken) {
      token.value = savedToken
      await fetchUserInfo()
    } else {
      initialized.value = true
    }
  }

  return {
    userInfo, token, initialized, isLoggedIn, userId,
    role, isAdmin,
    userName, userPhone, userEmail, userSchool, userAvatar,
    login, fetchUserInfo, updateProfile, logout, init
  }
})
