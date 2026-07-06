<template>
  <div class="dashboard">
    <h2 class="section-title">仪表盘</h2>
    <p class="welcome-text">欢迎回来，{{ userStore.userName }}</p>

    <!-- Quick Links -->
    <el-row :gutter="20" class="quick-links">
      <el-col :xs="24" :sm="12" :md="8">
        <el-card class="link-card" shadow="hover" @click="$router.push('/users')">
          <div class="link-content">
            <el-icon :size="40" color="#5B6CFF"><User /></el-icon>
            <div>
              <h4>用户管理</h4>
              <p>查看和管理所有注册用户</p>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8">
        <el-card class="link-card" shadow="hover" @click="$router.push('/chat')">
          <div class="link-content">
            <el-icon :size="40" color="#67c23a"><ChatDotRound /></el-icon>
            <div>
              <h4>用户消息回复</h4>
              <p>实时查看和回复用户咨询</p>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8">
        <el-card class="link-card" shadow="hover" @click="$router.push('/banners')">
          <div class="link-content">
            <el-icon :size="40" color="#e6a23c"><Picture /></el-icon>
            <div>
              <h4>首页管理</h4>
              <p>管理轮播图与推广卡片</p>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8">
        <el-card class="link-card" shadow="hover" @click="$router.push('/projects')">
          <div class="link-content">
            <el-icon :size="40" color="#409EFF"><Notebook /></el-icon>
            <div>
              <h4>课题管理</h4>
              <p>管理科研课题项目</p>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8">
        <el-card class="link-card" shadow="hover" @click="$router.push('/applications')">
          <div class="link-content">
            <el-icon :size="40" color="#19be6b"><DocumentChecked /></el-icon>
            <div>
              <h4>申请表单管理</h4>
              <p>查看和处理报名申请</p>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8">
        <el-card class="link-card" shadow="hover" @click="$router.push('/videos')">
          <div class="link-content">
            <el-icon :size="40" color="#722ed1"><VideoCamera /></el-icon>
            <div>
              <h4>专访视频管理</h4>
              <p>管理教授专访视频</p>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { User, Picture, ChatDotRound, Notebook, VideoCamera, DocumentChecked } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
</script>

<style lang="scss" scoped>
.dashboard .welcome-text { color: #666; margin: 8px 0 24px; font-size: 15px; }

.quick-links {
  .link-card {
    cursor: pointer; margin-bottom: 16px; border-radius: 12px; transition: all 0.25s;
    &:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(91,108,255,0.15); }
    .link-content {
      display: flex; align-items: center; gap: 16px;
      h4 { font-size: 16px; color: #333; margin-bottom: 4px; }
      p { font-size: 13px; color: #999; }
    }
  }
}
</style>
