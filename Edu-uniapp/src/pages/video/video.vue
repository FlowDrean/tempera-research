<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <text class="nav-title">坦培拉专访</text>
    </view>

    <!-- 搜索框 -->
    <view class="search-box-wrap">
      <view class="search-box">
        <SvgIcon name="search" color="#888" />
        <input type="text" placeholder="搜索教授或课题名称" v-model="keyword" />
      </view>
    </view>

    <!-- 视频列表 -->
    <scroll-view enable-flex scroll-y class="page-content" :style="{ height: scrollHeight + 'px' }"
      refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onRefresh">
      <view class="video-grid-list">
        <view class="video-card-row" v-for="v in filteredList" :key="v.id" @click="goPlay(v)">
          <view class="video-thumb-container" :style="{ backgroundImage: 'url(' + v.cover + ')' }">
            <view class="video-play-icon-overlay">
              <SvgIcon name="play" color="#fff" />
            </view>
            <view class="video-duration-tag">{{ v.duration || '--:--' }}</view>
          </view>
          <view class="video-info-container">
            <text class="video-row-title">{{ v.title }}</text>
            <text class="video-row-author">{{ v.professorName }} · {{ v.professorSchool }}</text>
            <text class="video-row-views">播放量 {{ v.views || 0 }}</text>
          </view>
        </view>
      </view>

      <!-- 空状态 -->
      <view v-if="!loading && filteredList.length === 0" class="empty-wrap">
        <text class="empty-text">{{ keyword ? '未搜索到相关视频' : '暂无视频' }}</text>
      </view>

      <view style="height: 100rpx;"></view>
    </scroll-view>

    <!-- 底部导航栏 -->
    <TabBar :current="2" />
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import TabBar from '@/components/TabBar.vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { getVideoList } from '@/api/video'
import { resolveImageUrl } from '@/api/request'

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const scrollHeight = computed(() => windowHeight - statusBarHeight - 100)

const keyword = ref('')
const refreshing = ref(false)
const loading = ref(false)
const list = ref([])

function goPlay(v) {
  uni.navigateTo({ url: '/pages/video-player/video-player?id=' + v.id })
}

const filteredList = computed(() => {
  if (!keyword.value) return list.value
  const kw = keyword.value.toLowerCase()
  return list.value.filter(v =>
    (v.title && v.title.toLowerCase().includes(kw)) ||
    (v.professorName && v.professorName.toLowerCase().includes(kw)) ||
    (v.professorSchool && v.professorSchool.toLowerCase().includes(kw))
  )
})

onMounted(async () => {
  await loadData()
})

async function loadData() {
  loading.value = true
  try {
    const data = await getVideoList({ page: 1, size: 50 })
    const records = data?.records || []
    list.value = records.map(v => ({
      ...v,
      cover: resolveImageUrl(v.cover)
    }))
  } catch {
    list.value = []
  } finally {
    loading.value = false
  }
}

const onRefresh = async () => {
  refreshing.value = true
  await loadData()
  refreshing.value = false
  uni.showToast({ title: '已刷新', icon: 'none', duration: 1000 })
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

/* ========== 导航栏 ========== */
.nav-bar {
  height: 44px;
  background: transparent;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 16px;
  position: relative;
  z-index: 61;
  flex-shrink: 0;
}

.nav-title {
  font-size: 16px;
  font-weight: bold;
  color: var(--text-main);
}

/* ========== 搜索框 ========== */
.search-box-wrap {
  padding: 10px 14px;
  flex-shrink: 0;
}

.search-box {
  flex: 1;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 18px;
  height: 36px;
  display: flex;
  align-items: center;
  padding: 0 14px;
  gap: 6px;
  border: 1px solid rgba(255, 255, 255, 0.5);

  input {
    border: none;
    background: transparent;
    outline: none;
    flex: 1;
    font-size: 13px;
    color: var(--text-main);
  }
}

.search-icon {
  font-size: 16px;
  color: #888;
}

/* ========== 页面内容 ========== */
.page-content {
  padding-top: 0;
}

.empty-wrap {
  display: flex; align-items: center; justify-content: center; padding: 60rpx 0;
}
.empty-text { font-size: 14px; color: #999; }

/* ========== 视频列表 ========== */
.video-grid-list {
  padding: 12px 14px;
}

.video-card-row {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 10px;
  padding: 12px;
  display: flex;
  gap: 14px;
  margin-bottom: 12px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.video-thumb-container {
  width: 120px;
  height: 75px;
  border-radius: 6px;
  background-color: #222;
  background-size: cover;
  background-position: center;
  position: relative;
  flex-shrink: 0;
}

.video-play-icon-overlay {
  position: absolute;
  inset: 0;
  margin: auto;
  width: 28px;
  height: 28px;
  background: rgba(0, 0, 0, 0.5);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
}

.play-icon-text {
  font-size: 12px;
}

.video-duration-tag {
  position: absolute;
  right: 6px;
  bottom: 6px;
  background: rgba(0, 0, 0, 0.6);
  color: #fff;
  font-size: 9px;
  padding: 1px 4px;
  border-radius: 2px;
}

.video-info-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.video-row-title {
  font-size: 13px;
  font-weight: bold;
  color: var(--text-main);
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.video-row-author {
  font-size: 11px;
  color: var(--text-sub);
  margin-top: 4px;
}

.video-row-views {
  font-size: 11px;
  color: var(--text-sub);
}
</style>
