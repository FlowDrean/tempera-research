<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">我的申请</text>
      <view class="nav-action"></view>
    </view>

    <!-- 分类 Tab -->
    <view class="filter-tabs">
      <view
        class="filter-tab-item"
        v-for="tab in tabs"
        :key="tab.value"
        :class="{ active: activeTab === tab.value }"
        @click="onTabChange(tab.value)"
      >{{ tab.label }}</view>
    </view>

    <!-- 申请列表 -->
    <scroll-view
      enable-flex
      scroll-y
      class="page-content"
      :style="{ height: scrollHeight + 'px' }"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onRefresh"
    >
      <!-- 加载中 -->
      <view v-if="loading" class="empty-state">
        <text class="empty-text">加载中...</text>
      </view>

      <!-- 空状态 -->
      <view v-else-if="filteredList.length === 0" class="empty-state">
        <SvgIcon name="file" color="#c0c4cc" size="48px" />
        <text class="empty-text">暂无申请记录</text>
        <text class="empty-hint">提交申请后会在这里显示</text>
      </view>

      <!-- 申请卡片列表 -->
      <view v-else class="app-list">
        <view class="app-card" v-for="item in filteredList" :key="item.id">
          <!-- 卡片头部：类型 + 状态 -->
          <view class="card-header">
            <view class="type-badge" :style="{ background: typeStyle[item.type]?.bg, color: typeStyle[item.type]?.color }">
              {{ typeStyle[item.type]?.label || item.type }}
            </view>
            <view class="status-badge" :style="{ background: statusStyle[item.status]?.bg, color: statusStyle[item.status]?.color }">
              {{ statusStyle[item.status]?.label || item.status }}
            </view>
          </view>

          <!-- 卡片主体信息 -->
          <view class="card-body">
            <view v-if="item.itemTitle" class="card-info-row">
              <text class="info-label">申请项目</text>
              <text class="info-value item-title-value">{{ item.itemTitle }}</text>
            </view>
            <view class="card-info-row">
              <text class="info-label">姓名</text>
              <text class="info-value">{{ item.name }}</text>
            </view>
            <view class="card-info-row">
              <text class="info-label">学历</text>
              <text class="info-value">{{ item.education }}</text>
            </view>
            <view v-if="item.fieldInterest" class="card-info-row">
              <text class="info-label">意向专业</text>
              <text class="info-value">{{ item.fieldInterest }}</text>
            </view>
            <view class="card-info-row">
              <text class="info-label">手机号</text>
              <text class="info-value">{{ maskPhone(item.phone) }}</text>
            </view>
          </view>

          <!-- 卡片底部：提交时间 -->
          <view class="card-footer">
            <SvgIcon name="clock" color="#c0c4cc" size="13px" />
            <text class="time-text">提交时间：{{ formatTime(item.submitTime) }}</text>
          </view>
        </view>
      </view>

      <view style="height: 40rpx;"></view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { getMyApplications } from '@/api/application.js'

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const scrollHeight = computed(() => windowHeight - statusBarHeight - 88 - 44)

const loading = ref(true)
const refreshing = ref(false)
const activeTab = ref('all')
const applications = ref([])

const tabs = [
  { label: '全部', value: 'all' },
  { label: '课题', value: 'project' },
  { label: '竞赛与写作', value: 'competition' },
  { label: '学术研学', value: 'research' }
]

const typeStyle = {
  project: { label: '课题', bg: '#e6f4f2', color: '#5B6CFF' },
  competition: { label: '竞赛与写作', bg: '#fff3e0', color: '#ff9800' },
  research: { label: '学术研学', bg: '#f3e8ff', color: '#9333ea' }
}

const statusStyle = {
  PENDING: { label: '审核中', bg: '#fff7e6', color: '#fa8c16' },
  APPROVED: { label: '已通过', bg: '#e6f7e6', color: '#52c41a' },
  REJECTED: { label: '已拒绝', bg: '#fff1f0', color: '#f5222d' }
}

const filteredList = computed(() => {
  if (activeTab.value === 'all') return applications.value
  return applications.value.filter(item => item.type === activeTab.value)
})

const goBack = () => {
  uni.navigateBack()
}

const onTabChange = (value) => {
  activeTab.value = value
}

const maskPhone = (phone) => {
  if (!phone) return ''
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
}

const formatTime = (time) => {
  if (!time) return ''
  return time.replace('T', ' ').substring(0, 19)
}

const fetchApplications = async () => {
  try {
    const res = await getMyApplications()
    applications.value = res.records || []
  } catch {
    // 未登录或无数据时静默处理
    applications.value = []
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

const onRefresh = () => {
  refreshing.value = true
  fetchApplications()
}

fetchApplications()
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
  background: #fff;
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

/* ========== 分类 Tab ========== */
.filter-tabs {
  display: flex;
  gap: 16rpx;
  padding: 16rpx 28rpx;
  background: #fff;
  flex-shrink: 0;
}

.filter-tab-item {
  font-size: 24rpx;
  color: #666;
  padding: 10rpx 28rpx;
  border-radius: 32rpx;
  background: #f2f3f5;
  transition: all 0.2s;
}

.filter-tab-item.active {
  background: #5B6CFF;
  color: #fff;
  font-weight: 600;
}

/* ========== 内容区 ========== */
.page-content {
  flex: 1;
}

/* ========== 空状态 ========== */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding-top: 200rpx;
  gap: 16rpx;
}

.empty-text {
  font-size: 28rpx;
  color: #999;
  margin-top: 20rpx;
}

.empty-hint {
  font-size: 22rpx;
  color: #c0c4cc;
}

/* ========== 卡片列表 ========== */
.app-list {
  padding: 20rpx 24rpx;
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.app-card {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 20rpx;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.04);
  overflow: hidden;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24rpx 28rpx 0;
}

.type-badge {
  font-size: 22rpx;
  font-weight: 600;
  padding: 6rpx 18rpx;
  border-radius: 8rpx;
}

.status-badge {
  font-size: 20rpx;
  font-weight: 500;
  padding: 4rpx 14rpx;
  border-radius: 8rpx;
}

.card-body {
  padding: 20rpx 28rpx 0;
}

.card-info-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 10rpx 0;
}

.info-label {
  font-size: 24rpx;
  color: #999;
  flex-shrink: 0;
  min-width: 100rpx;
}

.info-value {
  font-size: 26rpx;
  color: #333;
  font-weight: 500;
}

.item-title-value {
  color: #5B6CFF;
  font-weight: 600;
}

.card-footer {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 20rpx 28rpx 24rpx;
}

.time-text {
  font-size: 22rpx;
  color: #c0c4cc;
}
</style>
