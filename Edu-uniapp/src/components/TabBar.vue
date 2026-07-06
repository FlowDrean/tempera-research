<template>
  <view class="tab-bar">
    <view
      v-for="(tab, index) in tabs"
      :key="index"
      class="tab-item"
      :class="{ active: current === index }"
      @click="switchTab(index)"
    >
      <image
        class="tab-icon-img"
        :src="tabIcons[index][current === index ? 'active' : 'inactive']"
        mode="aspectFit"
      />
      <text class="tab-label">{{ tab.label }}</text>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  current: { type: Number, default: 0 }
})

const tabs = [
  { label: '首页', page: '/pages/home/home' },
  { label: '课题', page: '/pages/project/project' },
  { label: '专访视频', page: '/pages/video/video' },
  { label: '我的', page: '/pages/user/user' }
]

const tabIcons = [
  { active: '/static/icons/tab-home-active.png', inactive: '/static/icons/tab-home.png' },
  { active: '/static/icons/tab-project-active.png', inactive: '/static/icons/tab-project.png' },
  { active: '/static/icons/tab-video-active.png', inactive: '/static/icons/tab-video.png' },
  { active: '/static/icons/tab-user-active.png', inactive: '/static/icons/tab-user.png' }
]

function switchTab(index) {
  if (props.current === index) return
  uni.switchTab({ url: tabs[index].page })
}
</script>

<style lang="scss" scoped>
.tab-bar {
  height: 50px;
  display: flex;
  justify-content: space-around;
  align-items: center;
  position: fixed;
  bottom: 30px;
  left: 10px;
  right: 10px;
  z-index: 9999;
  background: linear-gradient(to bottom, #DAD7FF, #ffffff);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  box-sizing: border-box;
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
  gap: 2px;

  &.active {
    color: #5B6CFF;
    font-weight: 700;
  }
}

.tab-icon-img {
  width: 22px;
  height: 22px;
}

.tab-label {
  font-size: 10px;
  line-height: 1;
}
</style>
