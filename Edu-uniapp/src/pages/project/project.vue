<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <text class="nav-title">课题项目</text>
    </view>

    <!-- 搜索框 -->
    <view class="search-box-wrap">
      <view class="search-box">
        <SvgIcon name="search" color="#888" />
        <input class="search-input" v-model="searchKeyword" placeholder="教授 / 学科 / 学校 / 海外 / 1V1定制" @confirm="onSearch" />
      </view>
    </view>

    <!-- 筛选标签栏 -->
    <view class="filter-tabs-bar">
      <view class="filter-tab" :class="{ active: activePanel === 'field' }" @click="togglePanel('field')">
        <text>学科领域</text>
        <SvgIcon name="arrow-down" :color="activePanel === 'field' ? '#5B6CFF' : '#999'" />
      </view>
      <view class="filter-tab" :class="{ active: activePanel === 'mode' }" @click="togglePanel('mode')">
        <text>形式</text>
        <SvgIcon name="arrow-down" :color="activePanel === 'mode' ? '#5B6CFF' : '#999'" />
      </view>
      <view class="filter-tab" :class="{ active: activePanel === 'time' }" @click="togglePanel('time')">
        <text>开课时间</text>
        <SvgIcon name="arrow-down" :color="activePanel === 'time' ? '#5B6CFF' : '#999'" />
      </view>

      <!-- 学科领域面板 -->
      <view v-show="activePanel === 'field'" class="filter-panel">
        <view class="filter-options-grid">
          <view class="filter-option-tag" v-for="opt in fieldOptions" :key="opt.value"
            :class="{ selected: selectedField === opt.value }" @click="selectedField = opt.value">{{ opt.label }}</view>
        </view>
        <view class="filter-panel-btns">
          <view class="btn-reset" @click="selectedField = 'all'">重置</view>
          <view class="btn-confirm" @click="confirmPanel('field')">确定</view>
        </view>
      </view>

      <!-- 形式面板 -->
      <view v-show="activePanel === 'mode'" class="filter-panel">
        <view class="filter-options-grid">
          <view class="filter-option-tag" v-for="opt in modeOptions" :key="opt.value"
            :class="{ selected: selectedMode === opt.value }" @click="selectedMode = opt.value">{{ opt.label }}</view>
        </view>
        <view class="filter-panel-btns">
          <view class="btn-reset" @click="selectedMode = 'all'">重置</view>
          <view class="btn-confirm" @click="confirmPanel('mode')">确定</view>
        </view>
      </view>

      <!-- 开课时间面板 -->
      <view v-show="activePanel === 'time'" class="filter-panel">
        <view class="filter-month-grid">
          <view class="filter-month-tag" v-for="opt in timeOptions" :key="opt.value"
            :class="{ selected: selectedTime === opt.value }" @click="selectedTime = opt.value">{{ opt.label }}</view>
        </view>
        <view class="filter-panel-btns">
          <view class="btn-reset" @click="selectedTime = 'all'">重置</view>
          <view class="btn-confirm" @click="confirmPanel('time')">确定</view>
        </view>
      </view>
    </view>

    <!-- 遮罩 -->
    <view v-if="activePanel" class="filter-backdrop" @click="activePanel = ''"></view>

    <!-- 课程列表 -->
    <scroll-view enable-flex scroll-y class="page-content" :style="{ height: scrollHeight + 'px' }"
      refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onRefresh">
      <!-- 筛选指示条 -->
      <view v-if="filterLabel" class="filter-indicator">
        <text>当前筛选：<text class="filter-indicator-label">{{ filterLabel }}</text></text>
        <view class="filter-clear" @click="clearFilter"><SvgIcon name="close" color="#999" /></view>
      </view>

      <!-- 加载中 -->
      <view v-if="loading" class="loading-wrap">
        <text class="loading-text">加载中...</text>
      </view>

      <!-- 空状态 -->
      <view v-if="!loading && courses.length === 0" class="empty-wrap">
        <text class="empty-text">暂无课题</text>
      </view>

      <view class="course-list-padding">
        <view class="course-row-card" v-for="course in courses" :key="course.id" @click="goToDetail(course)">
          <view class="course-row-thumb"
            :style="{ backgroundImage: 'url(' + course.thumb + ')' }"
            @click.stop="previewPoster(course.thumb)">
            <view class="course-status-badge" :class="course.statusClass">{{ course.statusText }}</view>
          </view>
          <view class="course-row-info">
            <text class="course-row-title">{{ course.title }}</text>
            <view class="course-professors">
              <view class="course-prof-item" v-for="prof in course.professors" :key="prof.name">
                <text class="prof-name">{{ prof.name }}</text>
                <text class="prof-school">{{ prof.school }}</text>
              </view>
            </view>
            <view class="course-directions">
              <text class="course-dir-tag" v-for="tag in course.tags" :key="tag">{{ tag }}</text>
            </view>
            <view class="course-time-row">
              <SvgIcon name="clock" color="#999" size="11px" />
              <text class="time-value">{{ course.date }}</text>
              <text class="course-mode-tag" :class="course.modeClass">{{ course.mode }}</text>
            </view>
          </view>
        </view>
      </view>

      <view style="height: 100rpx;"></view>
    </scroll-view>

    <!-- 悬浮耳机按钮 -->
    <view class="floating-earphone-btn" @click="togglePromo">
      <image class="earphone-icon-img" src="/static/icons/小耳机图标（新）.png" mode="aspectFit" />
    </view>

    <!-- 底部导航栏 -->
    <TabBar :current="1" />
  </view>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import TabBar from '@/components/TabBar.vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { getProjectList } from '@/api/project'
import { resolveImageUrl } from '@/api/request'

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const FIXED_HEADER_HEIGHT = 140
const scrollHeight = computed(() => windowHeight - statusBarHeight - FIXED_HEADER_HEIGHT)

const searchKeyword = ref('')
const refreshing = ref(false)
const loading = ref(false)
const courses = ref([])

const activePanel = ref('')
const selectedField = ref('all')
const selectedMode = ref('all')
const selectedTime = ref('all')
const filterLabel = ref('')

const statusMap = { open: '招生中', full: '已满额', soon: '即将开课' }
const modeClassMap = { '线上': 'online', '线下': 'offline', '实践1V1定制': 'one2one', '混合': 'offline' }

const fieldOptions = [
  { label: '全部', value: 'all' },
  { label: '人文社科', value: '人文社科' },
  { label: '理科', value: '理科' },
  { label: '艺术科技', value: '艺术科技' },
  { label: '海外课题', value: '海外课题' }
]

const modeOptions = [
  { label: '全部', value: 'all' },
  { label: '线上', value: '线上' },
  { label: '线下', value: '线下' },
  { label: '实践1V1定制', value: '实践1V1定制' },
  { label: '混合', value: '混合' }
]

const timeOptions = [
  { label: '全部', value: 'all' },
  { label: '6月', value: '6月' },
  { label: '7月', value: '7月' },
  { label: '8月', value: '8月' },
  { label: '9月', value: '9月' },
  { label: '10月', value: '10月' },
  { label: '11月', value: '11月' },
  { label: '12月', value: '12月' }
]

// Build professor list from entity flat fields
function buildProfessors(p) {
  const profs = []
  if (p.professor1Name) {
    profs.push({ name: p.professor1Name, school: p.professor1Info || '' })
  }
  if (p.professor2Name) {
    profs.push({ name: p.professor2Name, school: p.professor2Info || '' })
  }
  if (p.professor3Name) {
    profs.push({ name: p.professor3Name, school: p.professor3Info || '' })
  }
  return profs
}

// Map API project object to card display format
function mapProjectToCard(p) {
  const status = p.enrollmentStatus || p.status || 'open'
  return {
    id: p.id,
    title: p.titleCn || '',
    thumb: resolveImageUrl(p.poster),
    statusText: statusMap[status] || '招生中',
    statusClass: status === 'full' ? 'full' : (status === 'soon' || status === 'almost_full') ? 'almost' : 'open',
    field: p.category || '',
    mode: p.mode || '',
    date: p.startDate || '',
    modeClass: modeClassMap[p.mode] || 'online',
    professors: buildProfessors(p),
    tags: (p.tags || '').split(',').filter(Boolean).map(t => t.trim())
  }
}

// Fetch courses from API
async function fetchCourses() {
  loading.value = true
  try {
    const params = { page: 1, size: 50 }
    if (selectedField.value !== 'all') params.category = selectedField.value
    if (selectedMode.value !== 'all') params.mode = selectedMode.value
    if (selectedTime.value !== 'all') {
      // Map month label like "7月" to "2026-07"
      const monthNum = selectedTime.value.replace('月', '')
      params.startDate = `2026-${monthNum.padStart(2, '0')}`
    }
    if (searchKeyword.value.trim()) params.keyword = searchKeyword.value.trim()

    const res = await getProjectList(params)
    courses.value = (res.records || []).map(mapProjectToCard)
  } catch (e) {
    console.error('Fetch courses failed:', e)
  } finally {
    loading.value = false
  }
}

const togglePanel = (key) => {
  activePanel.value = activePanel.value === key ? '' : key
}

const confirmPanel = (type) => {
  const parts = []
  if (selectedField.value !== 'all') parts.push('学科领域：' + selectedField.value)
  if (selectedMode.value !== 'all') parts.push('形式：' + selectedMode.value)
  if (selectedTime.value !== 'all') parts.push('开课时间：' + selectedTime.value)
  filterLabel.value = parts.join(' | ')
  activePanel.value = ''
  fetchCourses()
}

const clearFilter = () => {
  selectedField.value = 'all'
  selectedMode.value = 'all'
  selectedTime.value = 'all'
  filterLabel.value = ''
  fetchCourses()
}

const onSearch = () => {
  fetchCourses()
}

const goToDetail = (course) => {
  uni.navigateTo({ url: `/pages/project-detail/project-detail?id=${course.id}` })
}

const previewPoster = (url) => {
  uni.previewImage({ urls: [url] })
}

const onRefresh = () => {
  refreshing.value = true
  fetchCourses().finally(() => {
    refreshing.value = false
  })
}

// 监听来自首页的筛选事件
onMounted(() => {
  fetchCourses()
  uni.$on('filterField', (field) => {
    selectedField.value = field
    filterLabel.value = '学科领域：' + field
    fetchCourses()
  })
  uni.$on('filterMode', (mode) => {
    selectedMode.value = mode
    filterLabel.value = '形式：' + mode
    fetchCourses()
  })
})

onUnmounted(() => {
  uni.$off('filterField')
  uni.$off('filterMode')
})

const togglePromo = () => {
  uni.navigateTo({ url: '/pages/promo/promo' })
}
</script>

<style lang="scss" scoped>
.page-container {
  height: 100vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background-color: #eef1f5;
  position: relative;
}

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

.search-box-wrap {
  padding: 10px 14px;
  display: flex;
  align-items: center;
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
}

.search-input {
  flex: 1;
  border: none;
  background: transparent;
  outline: none;
  font-size: 13px;
  color: var(--text-main);
}

.search-icon {
  font-size: 16px;
  color: #888;
}

.filter-tabs-bar {
  display: flex;
  height: 40px;
  align-items: center;
  position: relative;
  z-index: 59;
  background: transparent;
  flex-shrink: 0;
}

.filter-tab {
  flex: 1;
  text-align: center;
  font-size: 13px;
  color: #555;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 4px;
  transition: color 0.2s;
}

.filter-tab.active {
  color: #5B6CFF;
  font-weight: 600;
}
.filter-tab.active text {
  color: #5B6CFF;
}

.arrow { font-size: 12px; }

.filter-backdrop {
  position: fixed;
  top: 200px;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 58;
  background: rgba(0, 0, 0, 0.45);
}

.filter-panel {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  box-sizing: border-box;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  z-index: 60;
  padding: 16px 14px 12px;
}

.filter-options-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
}

.filter-month-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
}

.filter-option-tag {
  padding: 8px 0;
  border-radius: 16px;
  font-size: 12px;
  color: #555;
  background: #f2f3f5;
  text-align: center;
}

.filter-option-tag.selected {
  background: #5B6CFF;
  color: #ffffff;
  font-weight: 600;
}

.filter-month-tag {
  padding: 10px 0;
  border-radius: 20px;
  font-size: 13px;
  color: #555;
  background: #f2f3f5;
  text-align: center;
}

.filter-month-tag.selected {
  background: #5B6CFF;
  color: #ffffff;
  font-weight: 600;
}

.filter-panel-btns {
  display: flex;
  gap: 10px;
  margin-top: 14px;
}

.btn-reset {
  flex: 1;
  height: 34px;
  line-height: 34px;
  border-radius: 17px;
  font-size: 13px;
  background: #f2f3f5;
  color: #666;
  text-align: center;
}

.btn-confirm {
  flex: 1;
  height: 34px;
  line-height: 34px;
  border-radius: 17px;
  font-size: 13px;
  background: #5B6CFF;
  color: #fff;
  text-align: center;
}

.page-content {
  flex: 1;
  padding-top: 0;
}

.filter-indicator {
  margin: 0 14px 10px;
  padding: 8px 12px;
  background: var(--primary-light);
  border-radius: 8px;
  font-size: 12px;
  color: var(--primary-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.filter-indicator-label { font-weight: 600; }

.filter-clear {
  color: #999;
  font-size: 14px;
}

.loading-wrap {
  display: flex; justify-content: center; padding: 40px 0;
}
.loading-text { font-size: 13px; color: #999; }

.empty-wrap {
  display: flex; justify-content: center; padding: 80px 0;
}
.empty-text { font-size: 14px; color: #999; }

.course-list-padding {
  padding: 0 10px;
}

.course-row-card {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 12px;
  padding: 6px 10px 2px 8px;
  display: flex;
  gap: 10px;
  margin-bottom: 12px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  align-items: flex-start;
  height: 180px;
  overflow: hidden;
}

.course-row-thumb {
  width: 110px;
  height: 172px;
  border-radius: 12px;
  background-color: #eee;
  background-size: cover;
  background-position: center;
  flex-shrink: 0;
  position: relative;
}

.course-status-badge {
  position: absolute;
  top: 0;
  left: 0;
  font-size: 10px;
  padding: 3px 8px;
  border-radius: 0 0 6px 0;
  font-weight: 600;
  color: #fff;
  white-space: nowrap;
}

.course-status-badge.open {
  background: rgba(91, 108, 255, 0.75);
  backdrop-filter: blur(4px);
}

.course-status-badge.almost {
  background: rgba(240, 160, 32, 0.75);
  backdrop-filter: blur(4px);
}

.course-status-badge.full {
  background: rgba(224, 80, 80, 0.75);
  backdrop-filter: blur(4px);
}

.course-row-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  gap: 2px;
  min-width: 0;
  padding-left: 8px;
}

.course-row-title {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-main);
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-align: left;
  margin-bottom: 0;
  min-height: 39px;
}

.course-professors {
  display: flex;
  flex-direction: column;
  gap: 0;
  margin-bottom: 0;
}

.course-prof-item {
  font-size: 11px;
  color: #555;
  line-height: 1.3;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1px;
  padding: 3px 0;
  border-bottom: 1px solid #aaaaaa;
}

.course-prof-item:last-child {
  border-bottom: none;
}

.prof-name {
  font-weight: 600;
  color: #333;
  white-space: nowrap;
}

.prof-school {
  color: #666;
  font-size: 11px;
  font-weight: 500;
}

.course-directions {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 4px;
  max-height: 44px;
  overflow: hidden;
}

.course-dir-tag {
  font-size: 10px;
  padding: 3px 8px;
  border-radius: 3px;
  background: #f0f6f5;
  color: #5B6CFF;
  white-space: nowrap;
  text-align: center;
}

.course-time-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 11px;
  color: #999;
  margin-top: auto;
}

.time-label {
  font-size: 11px;
  color: #999;
}

.time-value {
  color: #555;
  font-weight: 500;
}

.course-mode-tag {
  font-size: 10px;
  padding: 2px 8px;
  border-radius: 10px;
  font-weight: 500;
  flex-shrink: 0;
}

.course-mode-tag.online {
  background: #e6f4f2;
  color: var(--primary-color);
}

.course-mode-tag.offline {
  background: #fff3e0;
  color: #ff9800;
}

.course-mode-tag.one2one {
  background: #f3e8ff;
  color: #7c3aed;
}

/* ========== 悬浮耳机按钮 ========== */
.floating-earphone-btn {
  position: fixed;
  bottom: 94px;
  right: 20px;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(to bottom, #DAD7FF, #ffffff);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.6);
  z-index: 80;
}

.earphone-icon-img {
  width: 28px;
  height: 28px;
}
</style>
