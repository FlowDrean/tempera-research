<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">学术研学</text>
    </view>

    <!-- 搜索框 -->
    <view class="search-box-wrap">
      <view class="search-box">
        <SvgIcon name="search" color="#888" />
        <input class="search-input" v-model="searchKeyword" placeholder="搜索研学项目或院校" @confirm="onSearch" />
      </view>
    </view>

    <!-- 筛选标签栏 -->
    <view class="filter-tabs-bar">
      <view class="filter-tab" :class="{ active: activePanel === 'country' }" @click="togglePanel('country')">
        <text>国家</text>
        <SvgIcon name="arrow-down" :color="activePanel === 'country' ? '#5B6CFF' : '#999'" />
      </view>
      <view class="filter-tab" :class="{ active: activePanel === 'season' }" @click="togglePanel('season')">
        <text>时间</text>
        <SvgIcon name="arrow-down" :color="activePanel === 'season' ? '#5B6CFF' : '#999'" />
      </view>

      <!-- 国家面板 -->
      <view v-show="activePanel === 'country'" class="filter-panel">
        <view class="filter-options-grid">
          <view class="filter-option-tag" v-for="opt in countryOptions" :key="opt.value"
            :class="{ selected: selectedCountry === opt.value }" @click="selectedCountry = opt.value">{{ opt.label }}</view>
        </view>
        <view class="filter-panel-btns">
          <view class="btn-reset" @click="selectedCountry = 'all'">重置</view>
          <view class="btn-confirm" @click="confirmPanel('country')">确定</view>
        </view>
      </view>

      <!-- 时间面板 -->
      <view v-show="activePanel === 'season'" class="filter-panel">
        <view class="filter-options-grid">
          <view class="filter-option-tag" v-for="opt in seasonOptions" :key="opt.value"
            :class="{ selected: selectedSeason === opt.value }" @click="selectedSeason = opt.value">{{ opt.label }}</view>
        </view>
        <view class="filter-panel-btns">
          <view class="btn-reset" @click="selectedSeason = 'all'">重置</view>
          <view class="btn-confirm" @click="confirmPanel('season')">确定</view>
        </view>
      </view>
    </view>

    <!-- 遮罩 -->
    <view v-if="activePanel" class="filter-backdrop" @click="activePanel = ''"></view>

    <!-- 研学列表 -->
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
      <view v-if="!loading && list.length === 0" class="empty-wrap">
        <text class="empty-text">暂无研学项目</text>
      </view>

      <view class="course-list-padding">
        <view class="course-row-card" v-for="r in list" :key="r.id" @click="goDetail(r.id)">
          <view class="course-row-thumb"
            :style="{ backgroundImage: 'url(' + r.poster + ')' }"
            @click.stop="previewPoster(r.poster)">
            <view class="course-status-badge" :class="'status-' + r.status">{{ statusMap[r.status] || '招生中' }}</view>
          </view>
          <view class="course-row-info">
            <text class="course-row-title">{{ r.titleCn }}</text>
            <text class="course-row-title-en">{{ r.titleEn }}</text>
            <view class="comp-list-meta">
              <view class="comp-list-meta-item">
                <text class="mlabel">带队导师：</text>
                <text class="mvalue">{{ r.instructorName }}</text>
              </view>
            </view>
            <view class="course-time-row">
              <text class="time-label">导师院校：</text>
              <text class="time-value">{{ r.instructorTitle }}</text>
            </view>
            <view class="course-time-row">
              <text class="time-label">招生对象：</text>
              <text class="time-value">{{ r.targetAudience }}</text>
              <text class="course-mode-tag online">研学</text>
            </view>
            <view class="course-directions">
              <text class="course-dir-tag" v-for="t in r.tags" :key="t">{{ t }}</text>
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
  </view>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { getResearchTourList } from '@/api/research'
import { resolveImageUrl } from '@/api/request'

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const FIXED_HEADER_HEIGHT = 140
const scrollHeight = computed(() => windowHeight - statusBarHeight - FIXED_HEADER_HEIGHT)

const searchKeyword = ref('')
const refreshing = ref(false)
const loading = ref(false)
const list = ref([])

const activePanel = ref('')
const selectedCountry = ref('all')
const selectedSeason = ref('all')
const filterLabel = ref('')

const statusMap = { open: '招生中', almost_full: '名额紧张', full: '已满额' }

const countryOptions = [
  { label: '全部', value: 'all' },
  { label: '中国', value: '中国' },
  { label: '美国', value: '美国' },
  { label: '欧洲', value: '欧洲' },
  { label: '英国', value: '英国' },
  { label: '东南亚', value: '东南亚' }
]

const seasonOptions = [
  { label: '全部', value: 'all' },
  { label: '春假', value: '春假' },
  { label: '暑假', value: '暑假' },
  { label: '秋季', value: '秋季' },
  { label: '寒假', value: '寒假' }
]

// Map API entity to card display format
function mapResearchToCard(r) {
  const tags = []
  if (r.country) tags.push(r.country)
  if (r.season) tags.push(r.season)
  if (r.location) tags.push(r.location)

  return {
    id: r.id,
    titleCn: r.titleCn || '',
    titleEn: r.titleEn || '',
    poster: resolveImageUrl(r.poster),
    status: r.status || 'open',
    instructorName: r.instructorName || '',
    instructorTitle: r.instructorTitle || r.school || '',
    targetAudience: r.targetAudience || '',
    country: r.country || '',
    season: r.season || '',
    tags: tags
  }
}

// Fetch research tours from API
async function fetchList() {
  loading.value = true
  try {
    const params = { page: 1, size: 50 }
    if (selectedCountry.value !== 'all') params.country = selectedCountry.value
    if (selectedSeason.value !== 'all') params.season = selectedSeason.value
    if (searchKeyword.value.trim()) params.keyword = searchKeyword.value.trim()

    const res = await getResearchTourList(params)
    list.value = (res.records || []).map(mapResearchToCard)
  } catch (e) {
    console.error('Fetch research tours failed:', e)
  } finally {
    loading.value = false
  }
}

const togglePanel = (key) => {
  activePanel.value = activePanel.value === key ? '' : key
}

const confirmPanel = (type) => {
  const parts = []
  if (selectedCountry.value !== 'all') parts.push('国家：' + selectedCountry.value)
  if (selectedSeason.value !== 'all') parts.push('时间：' + selectedSeason.value)
  filterLabel.value = parts.join(' | ')
  activePanel.value = ''
  fetchList()
}

const clearFilter = () => {
  selectedCountry.value = 'all'
  selectedSeason.value = 'all'
  filterLabel.value = ''
  fetchList()
}

const onSearch = () => {
  fetchList()
}

const goDetail = (id) => {
  uni.navigateTo({ url: '/pages/research-detail/research-detail?id=' + id })
}

const goBack = () => {
  uni.navigateBack()
}

const previewPoster = (url) => {
  uni.previewImage({ urls: [url] })
}

const onRefresh = () => {
  refreshing.value = true
  fetchList().finally(() => {
    refreshing.value = false
  })
}

onMounted(() => {
  fetchList()
  uni.$on('filterResearchCountry', (country) => {
    selectedCountry.value = country
    filterLabel.value = '国家：' + country
    fetchList()
  })
  uni.$on('filterResearchSeason', (season) => {
    selectedSeason.value = season
    filterLabel.value = '时间：' + season
    fetchList()
  })
})

onUnmounted(() => {
  uni.$off('filterResearchCountry')
  uni.$off('filterResearchSeason')
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

/* ========== 导航栏 ========== */
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
  color: #333333;
}

.nav-title {
  font-size: 16px;
  font-weight: bold;
  color: #333333;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
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
}

.search-input {
  flex: 1;
  border: none;
  background: transparent;
  outline: none;
  font-size: 13px;
  color: var(--text-main);
}

/* ========== 筛选标签栏 ========== */
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

/* ========== 筛选面板遮罩 ========== */
.filter-backdrop {
  position: fixed;
  top: 200px;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 58;
  background: rgba(0, 0, 0, 0.45);
}

/* ========== 筛选面板 ========== */
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

/* ========== 筛选指示条 ========== */
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

/* ========== 加载和空状态 ========== */
.loading-wrap {
  display: flex; justify-content: center; padding: 40px 0;
}
.loading-text { font-size: 13px; color: #999; }

.empty-wrap {
  display: flex; justify-content: center; padding: 80px 0;
}
.empty-text { font-size: 14px; color: #999; }

/* ========== 页面内容 ========== */
.page-content {
  flex: 1;
  padding-top: 0;
}

.course-list-padding {
  padding: 0 10px;
}

/* ========== 课程卡片 ========== */
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

.status-open {
  background: rgba(91, 108, 255, 0.75);
  backdrop-filter: blur(4px);
}

.status-almost_full {
  background: rgba(240, 160, 32, 0.75);
  backdrop-filter: blur(4px);
}

.status-full {
  background: rgba(224, 80, 80, 0.75);
  backdrop-filter: blur(4px);
}

.course-row-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  gap: 6px;
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
  margin-bottom: 8px;
}

.course-row-title-en {
  font-size: 10px;
  color: var(--primary-color);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.3px;
  text-align: left;
}

.comp-list-meta {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.comp-list-meta-item {
  display: flex;
  gap: 4px;
  font-size: 11px;
  line-height: 1.4;
}

.mlabel {
  color: #999;
  flex-shrink: 0;
}

.mvalue {
  color: #555;
  font-weight: 500;
}

.course-time-row {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 6px;
  font-size: 11px;
  color: #999;
  margin-top: 2px;
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

.course-directions {
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-start;
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
