<template>
  <el-container class="layout-container">
    <!-- Sidebar -->
    <el-aside :width="isCollapse ? '64px' : '220px'" class="layout-aside">
      <div class="aside-header">
        <div class="logo-box" :class="{ collapsed: isCollapse }">
          <el-icon :size="24"><School /></el-icon>
          <span v-show="!isCollapse" class="logo-text">坦培拉后台</span>
        </div>
      </div>

      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :collapse-transition="false"
        router
        class="aside-menu"
      >
        <el-menu-item index="/dashboard">
          <el-icon><Odometer /></el-icon>
          <span>仪表盘</span>
        </el-menu-item>
        <el-menu-item index="/users">
          <el-icon><User /></el-icon>
          <span>用户管理</span>
        </el-menu-item>
        <el-menu-item index="/chat">
          <el-icon><ChatDotRound /></el-icon>
          <span>用户消息回复</span>
        </el-menu-item>
        <el-sub-menu index="home-mgmt">
          <template #title>
            <el-icon><HomeFilled /></el-icon>
            <span>首页管理</span>
          </template>
          <el-menu-item index="/banners">
            <el-icon><Picture /></el-icon>
            <span>轮播图管理</span>
          </el-menu-item>
          <el-menu-item index="/explores">
            <el-icon><Collection /></el-icon>
            <span>学术探索模块</span>
          </el-menu-item>
          <el-menu-item index="/promotions">
            <el-icon><Collection /></el-icon>
            <span>探索成果模块</span>
          </el-menu-item>
          <el-menu-item index="/promo">
            <el-icon><Headset /></el-icon>
            <span>宣传图管理</span>
          </el-menu-item>
        </el-sub-menu>
        <el-menu-item index="/projects">
          <el-icon><Notebook /></el-icon>
          <span>课题管理</span>
        </el-menu-item>
        <el-menu-item index="/competitions">
          <el-icon><Trophy /></el-icon>
          <span>竞赛与写作管理</span>
        </el-menu-item>
        <el-menu-item index="/researches">
          <el-icon><Promotion /></el-icon>
          <span>学术研学管理</span>
        </el-menu-item>
        <el-menu-item index="/videos">
          <el-icon><VideoCamera /></el-icon>
          <span>专访视频管理</span>
        </el-menu-item>
        <el-menu-item index="/applications">
          <el-icon><DocumentChecked /></el-icon>
          <span>申请表单管理</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <!-- Main -->
    <el-container>
      <!-- Header -->
      <el-header class="layout-header glass-card">
        <div class="header-left">
          <el-button
            :icon="Fold"
            text
            @click="isCollapse = !isCollapse"
          />
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/dashboard' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-if="currentTitle">{{ currentTitle }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <el-dropdown trigger="click">
            <div class="user-avatar">
              <el-avatar :size="32" :icon="UserFilled" />
              <span class="user-name">{{ userStore.userName }}</span>
              <el-icon><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item>
                  <el-icon><User /></el-icon>
                  {{ userStore.userName }} ({{ userStore.userRole }})
                </el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- Content -->
      <el-main class="layout-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  School, Odometer, User, HomeFilled, Picture, Collection, Notebook, Trophy, Promotion, VideoCamera, Headset,
  Fold, UserFilled, ArrowDown, SwitchButton, DocumentChecked, ChatDotRound
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const isCollapse = ref(false)

const activeMenu = computed(() => {
  const path = route.path
  if (['/banners', '/explores', '/promotions', '/promo', '/projects', '/competitions', '/researches', '/videos', '/applications'].includes(path)) return path
  return path
})

const currentTitle = computed(() => route.meta?.title || '')

function handleLogout() {
  ElMessageBox.confirm('确定要退出登录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    userStore.logout()
    router.push('/login')
  }).catch(() => {})
}
</script>

<style lang="scss" scoped>
.layout-container {
  height: 100vh;
}

.layout-aside {
  background: linear-gradient(180deg, #5B6CFF 0%, #4A5AE0 100%);
  overflow: hidden;
  transition: width 0.3s;

  .aside-header {
    height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 16px;
  }

  .logo-box {
    display: flex;
    align-items: center;
    gap: 10px;
    color: #fff;
    white-space: nowrap;

    &.collapsed {
      justify-content: center;
    }
  }

  .logo-text {
    font-size: 18px;
    font-weight: 700;
    color: #fff;
  }

  .aside-menu {
    border-right: none;
    background: transparent;

    .el-menu-item,
    :deep(.el-sub-menu__title) {
      color: rgba(255, 255, 255, 0.75);

      &:hover {
        background: rgba(255, 255, 255, 0.12);
        color: #fff;
      }

      &.is-active {
        background: rgba(255, 255, 255, 0.2);
        color: #fff;
        font-weight: 600;
      }
    }

    .el-menu-item {
      .el-icon {
        color: inherit;
      }
    }

    // Sub-menu
    :deep(.el-sub-menu) {
      .el-menu {
        background: rgba(0, 0, 0, 0.1);
      }
    }
  }
}

.layout-header {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  margin: 12px 20px 0;
  border-radius: 12px;

  .header-left {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .header-right {
    .user-avatar {
      display: flex;
      align-items: center;
      gap: 8px;
      cursor: pointer;
      padding: 4px 8px;
      border-radius: 8px;
      transition: background 0.2s;

      &:hover {
        background: rgba(91, 108, 255, 0.08);
      }

      .user-name {
        font-size: 14px;
        color: #333;
      }
    }
  }
}

.layout-main {
  padding: 20px;
  overflow-y: auto;
}
</style>
