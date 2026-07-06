<template>
  <view class="tab-bar" v-if="visible">
    <view
      v-for="(tab, index) in tabs"
      :key="index"
      class="tab-item"
      :class="{ active: selected === index }"
      @click="switchTab(index)"
    >
      <view class="tab-icon">
        <image
          :src="selected === index ? tabIcons[index].active : tabIcons[index].normal"
          class="tab-icon-img"
          mode="aspectFit"
        />
      </view>
      <text class="tab-label">{{ tab.label }}</text>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'

const tabs = [
  { label: '首页', page: '/pages/home/home' },
  { label: '课题', page: '/pages/project/project' },
  { label: '专访视频', page: '/pages/video/video' },
  { label: '我的', page: '/pages/user/user' }
]

const tabIcons = [
  { normal: '/static/icons/tab-home.png', active: '/static/icons/tab-home-active.png' },
  { normal: '/static/icons/tab-project.png', active: '/static/icons/tab-project-active.png' },
  { normal: '/static/icons/tab-video.png', active: '/static/icons/tab-video-active.png' },
  { normal: '/static/icons/tab-user.png', active: '/static/icons/tab-user-active.png' }
]

const selected = ref(0)

const hidePages = [
  'project-detail', 'competition-detail', 'research-detail',
  'video-player', 'apply', 'apply-success', 'login'
]

const visible = computed(() => {
  try {
    const pages = getCurrentPages()
    if (pages.length > 0) {
      const route = pages[pages.length - 1].route || ''
      if (hidePages.some(p => route.includes(p))) return false
      // 更新选中状态
      const idx = tabs.findIndex(t => route.includes(t.page.split('/').pop() || ''))
      if (idx >= 0) selected.value = idx
    }
  } catch (e) { /* ignore */ }
  return true
})

function switchTab(index) {
  if (selected.value === index) return
  selected.value = index
  uni.switchTab({ url: tabs[index].page })
}
</script>

<style lang="scss" scoped>
.tab-bar {
  height: 52px;
  display: flex;
  justify-content: space-around;
  align-items: center;
  position: fixed;
  bottom: 8px;
  left: 12px;
  right: 12px;
  z-index: 9999;
  background: linear-gradient(to bottom, #DAD7FF, #ffffff);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  padding-bottom: env(safe-area-inset-bottom, 0);
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #333333;
  font-size: 11px;
  flex: 1;
  height: 100%;
  cursor: pointer;
  gap: 3px;

  &.active {
    color: #5B6CFF;
    font-weight: 700;
  }
}

.tab-icon {
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tab-icon-img {
  width: 20px;
  height: 20px;
}

.tab-label {
  font-size: 10px;
}
</style>
