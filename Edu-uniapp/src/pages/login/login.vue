<template>
  <view class="page-container">
    <view class="login-form-wrap">
      <view class="login-header">
        <text class="login-logo">TEMPERA</text>
        <text class="login-subtitle">坦培拉科研</text>
      </view>

      <view class="login-form">
        <view class="form-input-group">
          <text class="input-label">手机号 / 用户名</text>
          <input class="form-input" v-model="username" placeholder="请输入手机号或用户名" />
        </view>

        <view class="form-input-group">
          <text class="input-label">密码</text>
          <input class="form-input" v-model="password" type="password" placeholder="请输入密码" />
        </view>

        <view class="login-btn" @click="onLogin" :class="{ disabled: loading }">
          <text>{{ loading ? '登录中...' : '登录' }}</text>
        </view>

        <view class="login-footer">
          <text class="register-link" @click="goRegister">还没有账号？立即注册</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

const username = ref('')
const password = ref('')
const loading = ref(false)

const onLogin = async () => {
  if (!username.value.trim()) {
    uni.showToast({ title: '请输入手机号或用户名', icon: 'none' })
    return
  }
  if (!password.value) {
    uni.showToast({ title: '请输入密码', icon: 'none' })
    return
  }

  loading.value = true
  try {
    const success = await userStore.login(username.value.trim(), password.value)
    if (success) {
      uni.showToast({ title: '登录成功', icon: 'success' })
      setTimeout(() => {
        uni.switchTab({ url: '/pages/user/user' })
      }, 800)
    }
  } catch (e) {
    // 业务错误(401)已在 request 拦截器中弹出 toast
    // 网络异常等未覆盖场景在此兜底
    if (e && e.message) {
      uni.showToast({ title: e.message, icon: 'none' })
    }
  } finally {
    loading.value = false
  }
}

const goRegister = () => {
  uni.navigateTo({ url: '/pages/register/register' })
}
</script>

<style lang="scss" scoped>
.page-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: linear-gradient(to bottom, #DAD7FF, #ffffff);
  min-height: 100vh;
}

.login-form-wrap {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 120rpx 48rpx 60rpx;
}

.login-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 80rpx;
}

.login-logo {
  font-size: 52rpx;
  font-weight: 800;
  color: #5B6CFF;
  letter-spacing: 6rpx;
}

.login-subtitle {
  font-size: 26rpx;
  color: #999;
  margin-top: 16rpx;
}

.login-form {
  width: 100%;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 24rpx;
  padding: 48rpx 32rpx;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4rpx 24rpx rgba(0, 0, 0, 0.06);
}

.form-input-group {
  margin-bottom: 32rpx;
}

.input-label {
  font-size: 26rpx;
  font-weight: 600;
  color: #333;
  display: block;
  margin-bottom: 16rpx;
}

.form-input {
  width: 100%;
  height: 92rpx;
  border: 1px solid #e8ecf1;
  border-radius: 20rpx;
  padding: 0 28rpx;
  font-size: 28rpx;
  color: #333;
  background: #fafbfc;
  box-sizing: border-box;
}

.form-input::placeholder {
  color: #c0c8d0;
}

.login-btn {
  width: 100%;
  height: 92rpx;
  background: #5B6CFF;
  border-radius: 46rpx;
  color: #fff;
  font-size: 30rpx;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 16rpx;
}

.login-btn.disabled {
  opacity: 0.5;
}

.login-footer {
  display: flex;
  justify-content: center;
  margin-top: 32rpx;
}

.register-link {
  font-size: 24rpx;
  color: #5B6CFF;
}
</style>
