<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">注册账号</text>
      <view class="nav-action"></view>
    </view>

    <scroll-view enable-flex scroll-y class="page-content" :style="{ height: scrollHeight + 'px' }">
      <view class="register-form-wrap">
        <view class="register-form">
          <view class="form-input-group">
            <text class="input-label">手机号</text>
            <input class="form-input" type="number" v-model="phone" placeholder="请输入手机号" maxlength="11" />
          </view>

          <view class="form-input-group">
            <text class="input-label">用户名</text>
            <input class="form-input" v-model="username" placeholder="请设置用户名" />
          </view>

          <view class="form-input-group">
            <text class="input-label">密码</text>
            <input class="form-input" v-model="password" type="password" placeholder="请设置密码（至少6位）" />
          </view>

          <view class="form-input-group">
            <text class="input-label">确认密码</text>
            <input class="form-input" v-model="confirmPassword" type="password" placeholder="请再次输入密码" />
          </view>

          <view class="register-btn" @click="onRegister" :class="{ disabled: loading }">
            <text>{{ loading ? '注册中...' : '注册' }}</text>
          </view>
        </view>

        <view class="register-footer">
          <text>已有账号？</text>
          <text class="login-link" @click="goBack">立即登录</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { useUserStore } from '@/stores/user'
import { register } from '@/api/user.js'

const userStore = useUserStore()

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const scrollHeight = computed(() => windowHeight - statusBarHeight - 88)

const phone = ref('')
const username = ref('')
const password = ref('')
const confirmPassword = ref('')
const loading = ref(false)

const phoneReg = /^1[3-9]\d{9}$/

const goBack = () => {
  uni.navigateBack()
}

const onRegister = async () => {
  if (!phoneReg.test(phone.value)) {
    uni.showToast({ title: '请输入正确的手机号', icon: 'none' })
    return
  }
  if (!username.value.trim()) {
    uni.showToast({ title: '请设置用户名', icon: 'none' })
    return
  }
  if (password.value.length < 6) {
    uni.showToast({ title: '密码至少6位', icon: 'none' })
    return
  }
  if (password.value !== confirmPassword.value) {
    uni.showToast({ title: '两次密码不一致', icon: 'none' })
    return
  }

  loading.value = true
  try {
    // 1. 注册
    await register({
      username: username.value.trim(),
      password: password.value,
      phone: phone.value
    })

    // 2. 注册成功后通过 store 自动登录
    const success = await userStore.login(username.value.trim(), password.value)
    if (success) {
      uni.showToast({ title: '注册成功', icon: 'success' })
      setTimeout(() => {
        uni.switchTab({ url: '/pages/user/user' })
      }, 800)
    }
  } catch (e) {
    if (e && e.message) {
      uni.showToast({ title: e.message, icon: 'none' })
    }
  } finally {
    loading.value = false
  }
}
</script>

<style lang="scss" scoped>
.page-container {
  height: 100vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background: linear-gradient(to bottom, #DAD7FF, #ffffff);
}

.nav-bar {
  height: 44px;
  background: transparent;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  position: relative;
  z-index: 61;
  flex-shrink: 0;
}

.nav-action {
  display: flex;
  align-items: center;
}

.nav-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
}

.page-content {
  flex: 1;
}

.register-form-wrap {
  padding: 40rpx 48rpx 60rpx;
}

.register-form {
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

.register-btn {
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

.register-btn.disabled {
  opacity: 0.5;
}

.register-footer {
  display: flex;
  justify-content: center;
  margin-top: 40rpx;
  font-size: 26rpx;
  color: #999;
  gap: 8rpx;
}

.login-link {
  color: #5B6CFF;
}
</style>
