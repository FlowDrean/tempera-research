<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">专访详情</text>
      <view class="nav-action"></view>
    </view>

    <!-- 加载中 -->
    <view v-if="loading" class="loading-wrap">
      <text class="loading-text">加载中...</text>
    </view>

    <!-- 内容 -->
    <scroll-view v-else-if="video" enable-flex scroll-y class="page-content" :style="{ height: scrollHeight + 'px' }">
      <!-- 无视频地址提示 -->
      <view v-if="!video.src" class="video-player-frame" :style="{ backgroundImage: 'url(' + video.cover + ')' }">
        <view class="video-no-source">
          <text class="no-source-text">暂无视频源</text>
        </view>
      </view>
      <!-- 视频播放框 -->
      <view v-else-if="!playing" class="video-player-frame" :style="{ backgroundImage: 'url(' + video.cover + ')' }">
        <view class="video-center-play" @click="playing = true">
          <SvgIcon name="play" color="#fff" />
        </view>
        <view class="video-player-controls">
          <text class="time-text">00:00 / {{ video.duration || '--:--' }}</text>
          <SvgIcon name="fullscreen" color="#fff" />
        </view>
      </view>
      <video
        v-else
        class="video-player-frame"
        :src="video.src"
        :poster="video.cover"
        controls
        autoplay
        object-fit="contain"
      />

      <!-- 视频信息 -->
      <view class="detail-main-box">
        <text class="detail-title">{{ video.title }}</text>
        <text class="detail-title-en" v-if="video.titleEn">{{ video.titleEn }}</text>
        <text class="detail-author">{{ video.author }}</text>
        <text class="detail-views">播放量 {{ video.views || 0 }}</text>
        <text class="detail-date" v-if="video.date">{{ video.date }}</text>
      </view>

      <!-- 标签行 -->
      <view class="video-tabs-row">
        <view class="video-tab" :class="{ active: activeTab === 'intro' }" @click="activeTab = 'intro'">
          专访简介
        </view>
        <view class="video-tab" :class="{ active: activeTab === 'professor' }" @click="activeTab = 'professor'">
          教授介绍
        </view>
      </view>

      <!-- 专访简介 -->
      <view v-show="activeTab === 'intro'" class="detail-section-block">
        <view class="detail-section-title">
          <text class="zh">专访简介</text><text class="en">Interview Profile</text>
        </view>
        <text class="detail-section-content">{{ video.introduction || '暂无简介' }}</text>
      </view>

      <!-- 教授介绍 -->
      <view v-show="activeTab === 'professor'" class="detail-section-block">
        <view class="detail-section-title">
          <text class="zh">教授介绍</text><text class="en">Faculty Profile</text>
        </view>
        <view class="instructor-profile-card">
          <view class="instructor-avatar" :style="{ backgroundImage: 'url(' + video.profAvatar + ')' }"></view>
          <view class="instructor-detail-info">
            <text class="instructor-name">{{ video.profName || '教授' }}</text>
            <text class="instructor-bio">{{ video.profBio || '暂无介绍' }}</text>
          </view>
        </view>
      </view>

      <view style="height: 100rpx;"></view>
    </scroll-view>

    <!-- 加载失败 -->
    <view v-else class="loading-wrap">
      <text class="loading-text">视频不存在或已被删除</text>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { getVideoDetail } from '@/api/video'
import { resolveImageUrl } from '@/api/request'

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const scrollHeight = ref(windowHeight - statusBarHeight - 44)

const goBack = () => uni.navigateBack()

const playing = ref(false)
const activeTab = ref('intro')
const loading = ref(true)
const video = ref(null)

function formatDate(dateStr) {
  if (!dateStr) return ''
  // 兼容后端返回的日期格式
  const d = new Date(dateStr)
  if (isNaN(d.getTime())) return ''
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}.${m}.${day}`
}

onMounted(async () => {
  // 从路由参数获取视频 ID
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const id = currentPage?.options?.id

  if (!id) {
    loading.value = false
    return
  }

  try {
    const data = await getVideoDetail(id)
    video.value = {
      id: data.id,
      title: data.title || '',
      titleEn: data.titleEn || '',
      cover: resolveImageUrl(data.cover),
      src: resolveImageUrl(data.url),
      duration: data.duration || '',
      author: [data.professorName, data.professorSchool].filter(Boolean).join(' · ') || '未知',
      views: data.views || 0,
      date: formatDate(data.createTime),
      introduction: data.description || '',
      profAvatar: resolveImageUrl(data.professorAvatar),
      profName: data.professorName || '特邀教授',
      profBio: data.professorBio || ''
    }
  } catch {
    video.value = null
  } finally {
    loading.value = false
  }
})
</script>

<style lang="scss" scoped>
.page-container {
  height: 100vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background-color: #eef1f5;
}

.loading-wrap {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}
.loading-text {
  font-size: 14px;
  color: #999;
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
  color: #333;
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
  padding-bottom: 60rpx;
}

.video-player-frame {
  width: calc(100% - 48rpx);
  height: 420rpx;
  margin: 0 24rpx;
  border-radius: 24rpx;
  background-color: #111;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  background-size: cover;
  background-position: center;
}

.video-center-play {
  width: 100rpx;
  height: 100rpx;
  background: rgba(0,0,0,0.7);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
}

.video-no-source {
  display: flex; align-items: center; justify-content: center;
}
.no-source-text { color: rgba(255,255,255,0.6); font-size: 14px; }

.big-play-icon {
  font-size: 36rpx;
  margin-left: 6rpx;
}

.video-player-controls {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 72rpx;
  background: linear-gradient(transparent, rgba(0,0,0,0.7));
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24rpx;
  color: #fff;
  font-size: 22rpx;
  border-radius: 0 0 24rpx 24rpx;
}

.detail-main-box {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  padding: 32rpx;
  margin: 20rpx 24rpx;
  border-radius: 24rpx;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.04);
}

.detail-title {
  font-size: 34rpx;
  font-weight: bold;
  color: #333;
  line-height: 1.4;
  margin-top: 0;
}

.detail-title-en {
  font-size: 22rpx;
  color: #5B6CFF;
  text-transform: uppercase;
  letter-spacing: 0.6rpx;
  margin-top: 8rpx;
}

.detail-author {
  font-size: 24rpx;
  color: #666;
  margin-top: 16rpx;
  display: block;
}

.detail-views {
  font-size: 24rpx;
  color: #999;
  margin-top: 4rpx;
  display: block;
}

.detail-date {
  font-size: 24rpx;
  color: #999;
  margin-top: 4rpx;
  display: block;
}

.video-tabs-row {
  display: flex;
  height: 84rpx;
  align-items: center;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  margin: 0 24rpx 20rpx;
  border-radius: 24rpx;
  border: 1px solid rgba(255, 255, 255, 0.6);
}

.video-tab {
  flex: 1;
  text-align: center;
  font-size: 26rpx;
  color: #555;
}

.video-tab.active {
  color: #5B6CFF;
  font-weight: 600;
}

.detail-section-block {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  padding: 32rpx;
  margin: 0 24rpx 20rpx;
  border-radius: 24rpx;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.04);
}

.detail-section-title {
  font-size: 30rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 24rpx;
  position: relative;
  padding-left: 20rpx;
  display: flex;
  align-items: baseline;
  gap: 16rpx;
  padding-bottom: 20rpx;
  border-bottom: 1px solid #e8e8e8;

  &::before {
    content: '';
    position: absolute;
    left: 0;
    top: 8rpx;
    width: 6rpx;
    height: 28rpx;
    background: #5B6CFF;
    border-radius: 4rpx;
  }
}

.detail-section-title .zh { font-weight: 700; }
.detail-section-title .en { font-size: 20rpx; color: #5B6CFF; font-weight: 600; }

.detail-section-content {
  font-size: 26rpx;
  color: #555;
  line-height: 1.7;
  white-space: pre-line;
}

.instructor-profile-card {
  display: flex;
  gap: 24rpx;
  align-items: flex-start;
}

.instructor-avatar {
  width: 88rpx;
  height: 88rpx;
  border-radius: 50%;
  background-color: #ddd;
  background-size: cover;
  flex-shrink: 0;
}

.instructor-detail-info {
  flex: 1;
}

.instructor-name {
  font-size: 26rpx;
  font-weight: bold;
  color: #333;
  display: block;
}

.instructor-bio {
  font-size: 22rpx;
  color: #666;
  margin-top: 8rpx;
  line-height: 1.5;
  display: block;
}
</style>
