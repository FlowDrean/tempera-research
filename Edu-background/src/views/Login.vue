<template>
  <div class="login-page">
    <!-- Background decoration -->
    <div class="bg-decoration">
      <div class="circle circle-1"></div>
      <div class="circle circle-2"></div>
      <div class="circle circle-3"></div>
    </div>

    <div class="login-card glass-panel">
      <div class="login-header">
        <div class="logo-icon">
          <el-icon :size="36"><School /></el-icon>
        </div>
        <h1 class="logo-text">坦培拉科研</h1>
        <p class="logo-sub">TEMPERA RESEARCH</p>
      </div>

      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        class="login-form"
        @submit.prevent="handleLogin"
      >
        <el-form-item prop="username">
          <el-input
            v-model="form.username"
            placeholder="请输入用户名"
            :prefix-icon="User"
            size="large"
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="请输入密码"
            :prefix-icon="Lock"
            size="large"
            show-password
            @keyup.enter="handleLogin"
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            class="login-btn"
            :loading="loading"
            @click="handleLogin"
          >
            {{ loading ? '登录中...' : '登 录' }}
          </el-button>
        </el-form-item>
      </el-form>

      <p class="login-hint">后台管理系统 · 仅限管理员登录</p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const formRef = ref(null)
const loading = ref(false)

const form = reactive({
  username: '',
  password: ''
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleLogin() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    await userStore.login(form.username, form.password)
    ElMessage.success('登录成功')
    router.push('/dashboard')
  } catch {
    ElMessage.error('用户名或密码错误')
  } finally {
    loading.value = false
  }
}
</script>

<style lang="scss" scoped>
.login-page {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #DAD7FF 0%, #B1F0FF 50%, #eef1f5 100%);
  overflow: hidden;
  position: relative;
}

.bg-decoration {
  position: absolute;
  inset: 0;
  pointer-events: none;

  .circle {
    position: absolute;
    border-radius: 50%;
    opacity: 0.15;
  }

  .circle-1 {
    width: 400px;
    height: 400px;
    background: #5B6CFF;
    top: -100px;
    right: -100px;
  }

  .circle-2 {
    width: 300px;
    height: 300px;
    background: #B1F0FF;
    bottom: -80px;
    left: -80px;
  }

  .circle-3 {
    width: 200px;
    height: 200px;
    background: #DAD7FF;
    top: 50%;
    left: 10%;
  }
}

.login-card {
  width: 420px;
  padding: 48px 40px;
  position: relative;
  z-index: 1;
}

.login-header {
  text-align: center;
  margin-bottom: 36px;

  .logo-icon {
    width: 64px;
    height: 64px;
    margin: 0 auto 16px;
    background: linear-gradient(135deg, #5B6CFF, #B1F0FF);
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
  }

  .logo-text {
    font-size: 26px;
    font-weight: 700;
    color: #333333;
    margin-bottom: 4px;
  }

  .logo-sub {
    font-size: 12px;
    color: #999999;
    letter-spacing: 3px;
  }
}

.login-form {
  .el-input {
    --el-input-bg-color: rgba(255, 255, 255, 0.8);
  }
}

.login-btn {
  width: 100%;
  height: 44px;
  font-size: 16px;
  border-radius: 8px;
  background: linear-gradient(135deg, #5B6CFF, #7B89FF);
  border: none;

  &:hover {
    background: linear-gradient(135deg, #4A5AE0, #5B6CFF);
  }
}

.login-hint {
  text-align: center;
  font-size: 12px;
  color: #999999;
  margin-top: 16px;
}
</style>
