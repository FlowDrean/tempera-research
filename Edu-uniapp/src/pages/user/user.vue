<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action"></view>
      <text class="nav-title">个人中心</text>
      <view class="nav-action"></view>
    </view>

    <scroll-view enable-flex scroll-y class="page-content" :style="{ height: scrollHeight + 'px' }">
      <!-- 个人信息头部 -->
      <view class="my-profile-header-section" @click="onProfileTap">
        <view class="my-big-avatar">
          <SvgIcon name="user" color="#fff" />
        </view>
        <view class="my-user-meta">
          <text class="meta-title">{{ displayName }}</text>
          <text class="meta-desc">{{ displayDesc }}</text>
        </view>
      </view>

      <!-- 合作计划横幅 -->
      <view class="my-cooperation-banner">
        <view>
          <text class="coop-title">加入CIS领航科研合作计划</text>
          <text class="coop-desc">1V1定制科研项目，助力学术成长</text>
        </view>
        <view class="my-cooperation-btn" @click="onApply">立即申请</view>
      </view>

      <!-- 菜单列表 -->
      <view class="my-menu-links-list">
        <view class="my-menu-row-item" @click="onMenuTap('applications')">
          <view class="my-menu-left-title">
            <SvgIcon name="file" color="#555" />
            <text>我的申请</text>
          </view>
          <SvgIcon name="arrow-right" color="#c0c4cc" />
        </view>
        <view class="my-menu-row-item" @click="onMenuTap('favorites')">
          <view class="my-menu-left-title">
            <SvgIcon name="star" color="#555" />
            <text>我的收藏</text>
          </view>
          <SvgIcon name="arrow-right" color="#c0c4cc" />
        </view>
        <view class="my-menu-row-item" @click="onMenuTap('service')">
          <view class="my-menu-left-title">
            <SvgIcon name="message" color="#555" />
            <text>联系客服</text>
          </view>
          <SvgIcon name="arrow-right" color="#c0c4cc" />
        </view>
        <view class="my-menu-row-item" @click="onMenuTap('about')">
          <view class="my-menu-left-title">
            <SvgIcon name="info" color="#555" />
            <text>关于我们</text>
          </view>
          <SvgIcon name="arrow-right" color="#c0c4cc" />
        </view>
      </view>

      <!-- 退出登录 -->
      <view v-if="userStore.isLoggedIn" class="logout-btn-box">
        <view class="logout-btn" @click="onLogout">退出登录</view>
      </view>

      <view style="height: 100rpx;"></view>
    </scroll-view>

    <!-- 底部导航栏 -->
    <TabBar :current="3" />
  </view>
</template>

<script setup>
import { computed } from 'vue'
import TabBar from '@/components/TabBar.vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const scrollHeight = computed(() => windowHeight - statusBarHeight - 88)

const displayName = computed(() => {
  if (userStore.isLoggedIn) {
    return userStore.userName
  }
  return '点击登录/注册'
})

const displayDesc = computed(() => {
  if (userStore.isLoggedIn) {
    // 登录后：显示学校和欢迎语
    if (userStore.userSchool) {
      return userStore.userSchool + ' · 欢迎回来'
    }
    return '欢迎使用坦培拉科研平台'
  }
  return '登录后享受更多服务'
})

const onProfileTap = () => {
  if (!userStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages/login/login' })
  } else {
    uni.showToast({ title: '个人资料编辑功能开发中', icon: 'none' })
  }
}

const onApply = () => {
  if (!userStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages/login/login' })
    return
  }
  uni.navigateTo({ url: '/pages/apply/apply?type=project' })
}

const onMenuTap = (type) => {
  if (type === 'applications') {
    uni.navigateTo({ url: '/pages/my-applications/my-applications' })
  } else if (type === 'favorites') {
    if (!userStore.isLoggedIn) {
      uni.navigateTo({ url: '/pages/login/login' })
      return
    }
    uni.navigateTo({ url: '/pages/my-favorites/my-favorites' })
  } else if (type === 'service') {
    if (!userStore.isLoggedIn) {
      uni.navigateTo({ url: '/pages/login/login' })
      return
    }
    uni.navigateTo({ url: '/pages/chat/chat' })
  } else if (type === 'about') {
    uni.navigateTo({ url: '/pages/promo/promo' })
  }
}

const onLogout = () => {
  uni.showModal({
    title: '提示',
    content: '确定要退出登录吗？',
    success: (res) => {
      if (res.confirm) {
        userStore.logout()
        uni.showToast({ title: '已退出登录', icon: 'none' })
      }
    }
  })
}
</script>

<style lang="scss" scoped>
.page-container {
  height: 100vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background-color: #eef1f5;
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
  width: 44px;
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

/* ========== 个人信息头部 ========== */
.my-profile-header-section {
  padding: 14px 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  margin: 10px 14px 16px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.my-big-avatar {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: #e0e4ec;
  display: flex;
  align-items: center;
  justify-content: center;
}

.my-user-meta {
  flex: 1;
}

.meta-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  display: block;
}

.meta-desc {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
  display: block;
}

/* ========== 合作计划横幅 ========== */
.my-cooperation-banner {
  margin: 4px 16px 16px;
  background: linear-gradient(to bottom, #DAD7FF, #ffffff);
  border-radius: 12px;
  padding: 14px 18px;
  color: #333;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.coop-title {
  font-size: 13px;
  font-weight: bold;
  display: block;
}

.coop-desc {
  font-size: 10px;
  opacity: 0.85;
  margin-top: 3px;
  display: block;
}

.my-cooperation-btn {
  background: #5B6CFF;
  color: #ffffff;
  font-size: 11px;
  font-weight: bold;
  padding: 5px 12px;
  border-radius: 12px;
}

/* ========== 菜单列表 ========== */
.my-menu-links-list {
  padding: 0 16px;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  margin: 10px 14px 0;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.my-menu-row-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.my-menu-row-item:last-child {
  border-bottom: none;
}

/* ========== 退出登录 ========== */
.logout-btn-box {
  padding: 24rpx 16px 0;
}

.logout-btn {
  width: 100%;
  height: 44px;
  background: rgba(255, 255, 255, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 12px;
  color: #f5222d;
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
}

.my-menu-left-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13.5px;
  color: #333;
  font-weight: 500;
}
</style>
