<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">竞赛与写作</text>
    </view>

    <!-- 搜索框 -->
    <view class="search-box-wrap">
      <view class="search-box">
        <SvgIcon name="search" color="#888" />
        <input class="search-input" v-model="searchKeyword" placeholder="搜索竞赛或写作项目" @confirm="onSearch" />
      </view>
    </view>

    <!-- 筛选标签栏 -->
    <view class="filter-tabs-bar">
      <view class="filter-tab" :class="{ active: activePanel === 'type' }" @click="togglePanel('type')">
        <text>竞赛类型</text>
        <SvgIcon name="arrow-down" :color="activePanel === 'type' ? '#5B6CFF' : '#999'" />
      </view>
      <view class="filter-tab" :class="{ active: activePanel === 'level' }" @click="togglePanel('level')">
        <text>级别</text>
        <SvgIcon name="arrow-down" :color="activePanel === 'level' ? '#5B6CFF' : '#999'" />
      </view>
      <view class="filter-tab" :class="{ active: activePanel === 'group' }" @click="togglePanel('group')">
        <text>个人/团体</text>
        <SvgIcon name="arrow-down" :color="activePanel === 'group' ? '#5B6CFF' : '#999'" />
      </view>

      <!-- 竞赛类型面板 -->
      <view v-show="activePanel === 'type'" class="filter-panel">
        <view class="filter-options-grid">
          <view class="filter-option-tag" v-for="opt in typeOptions" :key="opt.value"
            :class="{ selected: selectedType === opt.value }" @click="selectedType = opt.value">{{ opt.label }}</view>
        </view>
        <view class="filter-panel-btns">
          <view class="btn-reset" @click="selectedType = 'all'">重置</view>
          <view class="btn-confirm" @click="confirmPanel('type')">确定</view>
        </view>
      </view>

      <!-- 级别面板 -->
      <view v-show="activePanel === 'level'" class="filter-panel">
        <view class="filter-options-grid">
          <view class="filter-option-tag" v-for="opt in levelOptions" :key="opt.value"
            :class="{ selected: selectedLevel === opt.value }" @click="selectedLevel = opt.value">{{ opt.label }}</view>
        </view>
        <view class="filter-panel-btns">
          <view class="btn-reset" @click="selectedLevel = 'all'">重置</view>
          <view class="btn-confirm" @click="confirmPanel('level')">确定</view>
        </view>
      </view>

      <!-- 个人/团体面板 -->
      <view v-show="activePanel === 'group'" class="filter-panel">
        <view class="filter-options-grid">
          <view class="filter-option-tag" v-for="opt in groupOptions" :key="opt.value"
            :class="{ selected: selectedGroup === opt.value }" @click="selectedGroup = opt.value">{{ opt.label }}</view>
        </view>
        <view class="filter-panel-btns">
          <view class="btn-reset" @click="selectedGroup = 'all'">重置</view>
          <view class="btn-confirm" @click="confirmPanel('group')">确定</view>
        </view>
      </view>
    </view>

    <!-- 遮罩 -->
    <view v-if="activePanel" class="filter-backdrop" @click="activePanel = ''"></view>

    <!-- 竞赛列表 -->
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
      <view v-if="!loading && competitions.length === 0" class="empty-wrap">
        <text class="empty-text">暂无竞赛</text>
      </view>

      <view class="course-list-padding">
        <view class="comp-list-card" v-for="comp in competitions" :key="comp.id" @click="goToDetail(comp)">
          <view class="comp-list-poster"
            :style="{ backgroundImage: 'url(' + comp.poster + ')' }"
            @click.stop="previewPoster(comp.poster)">
            <view class="course-status-badge" :class="comp.statusClass">{{ comp.statusText }}</view>
          </view>
          <view class="comp-list-info">
            <text class="comp-list-title-zh">{{ comp.title }}</text>
            <text class="comp-list-title-en">{{ comp.titleEn }}</text>
            <view class="comp-list-meta">
              <view class="comp-list-meta-item">
                <text class="mlabel">导师</text>
                <text class="mvalue">{{ comp.instructor }}</text>
              </view>
              <view class="comp-list-meta-item">
                <text class="mlabel">院校</text>
                <text class="mvalue">{{ comp.school }}</text>
              </view>
              <view class="comp-list-meta-item">
                <text class="mlabel">对象</text>
                <text class="mvalue">{{ comp.participants }}</text>
              </view>
              <view class="comp-list-meta-item">
                <text class="mlabel">截止</text>
                <text class="mvalue deadline">{{ comp.deadline }}</text>
              </view>
            </view>
            <view class="comp-list-bottom">
              <text class="ui-tag ui-tag-gray">{{ comp.category }}</text>
              <text class="ui-tag" :class="comp.levelTagClass">{{ comp.level }}</text>
              <text class="ui-tag" :class="comp.groupTagClass">{{ comp.groupType }}</text>
            </view>
          </view>
        </view>
      </view>
      <view style="height: 100rpx;"></view>
    </scroll-view>

  </view>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { getCompetitionList } from '@/api/competition'
import { resolveImageUrl } from '@/api/request'

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const FIXED_HEADER_HEIGHT = 140
const scrollHeight = computed(() => windowHeight - statusBarHeight - FIXED_HEADER_HEIGHT)

const searchKeyword = ref('')
const refreshing = ref(false)
const loading = ref(false)
const competitions = ref([])

const activePanel = ref('')
const selectedType = ref('all')
const selectedLevel = ref('all')
const selectedGroup = ref('all')
const filterLabel = ref('')

const statusMap = { open: '招生中', full: '已满额', almost_full: '名额紧张' }
const levelTagClassMap = { '国家级': 'ui-tag-green', '国际级': 'ui-tag-orange' }
const groupTagClassMap = { '个人': 'ui-tag-orange', '团队': 'ui-tag-green' }

const typeOptions = [
  { label: '全部', value: 'all' },
  { label: '国内竞赛', value: '国内竞赛' },
  { label: '国际竞赛', value: '国际竞赛' },
  { label: '国内写作', value: '国内写作' },
  { label: '国际写作', value: '国际写作' }
]

const levelOptions = [
  { label: '全部', value: 'all' },
  { label: '国家级', value: '国家级' },
  { label: '国际级', value: '国际级' }
]

const groupOptions = [
  { label: '全部', value: 'all' },
  { label: '个人', value: '个人' },
  { label: '团队', value: '团队' }
]

// Map API entity to card display format
function mapCompetitionToCard(c) {
  const status = c.status || 'open'
  return {
    id: c.id,
    title: c.titleCn || '',
    titleEn: c.titleEn || '',
    poster: resolveImageUrl(c.poster),
    statusText: statusMap[status] || '招生中',
    statusClass: status === 'full' ? 'full' : (status === 'almost_full') ? 'almost' : 'open',
    instructor: c.instructorName || '',
    school: c.school || '',
    participants: c.targetAudience || '',
    deadline: c.deadline || '',
    category: c.category || '',
    level: c.levelName || '',
    groupType: c.participantType || '',
    levelTagClass: levelTagClassMap[c.levelName] || 'ui-tag-green',
    groupTagClass: groupTagClassMap[c.participantType] || 'ui-tag-green',
    type: c.category || ''  // maps to type for filter
  }
}

// Fetch competitions from API
async function fetchCompetitions() {
  loading.value = true
  try {
    const params = { page: 1, size: 50 }
    if (selectedType.value !== 'all') params.category = selectedType.value
    if (selectedLevel.value !== 'all') params.level = selectedLevel.value
    if (selectedGroup.value !== 'all') params.participantType = selectedGroup.value
    if (searchKeyword.value.trim()) params.keyword = searchKeyword.value.trim()

    const res = await getCompetitionList(params)
    competitions.value = (res.records || []).map(mapCompetitionToCard)
  } catch (e) {
    console.error('Fetch competitions failed:', e)
  } finally {
    loading.value = false
  }
}

const togglePanel = (key) => {
  activePanel.value = activePanel.value === key ? '' : key
}

const confirmPanel = (type) => {
  const parts = []
  if (selectedType.value !== 'all') parts.push('竞赛类型：' + selectedType.value)
  if (selectedLevel.value !== 'all') parts.push('级别：' + selectedLevel.value)
  if (selectedGroup.value !== 'all') parts.push('形式：' + selectedGroup.value)
  filterLabel.value = parts.join(' | ')
  activePanel.value = ''
  fetchCompetitions()
}

const clearFilter = () => {
  selectedType.value = 'all'
  selectedLevel.value = 'all'
  selectedGroup.value = 'all'
  filterLabel.value = ''
  fetchCompetitions()
}

const onSearch = () => {
  fetchCompetitions()
}

const goBack = () => {
  uni.navigateBack()
}

const goToDetail = (comp) => {
  uni.navigateTo({ url: `/pages/competition-detail/competition-detail?id=${comp.id}` })
}

const previewPoster = (url) => {
  uni.previewImage({ urls: [url] })
}

const onRefresh = () => {
  refreshing.value = true
  fetchCompetitions().finally(() => {
    refreshing.value = false
  })
}

onMounted(() => {
  fetchCompetitions()
})

// 监听来自首页的筛选事件
onMounted(() => {
  uni.$on('filterCompetitionType', (type) => {
    selectedType.value = type
    filterLabel.value = '竞赛类型：' + type
    fetchCompetitions()
  })
  uni.$on('filterCompetitionLevel', (level) => {
    selectedLevel.value = level
    filterLabel.value = '级别：' + level
    fetchCompetitions()
  })
})

onUnmounted(() => {
  uni.$off('filterCompetitionType')
  uni.$off('filterCompetitionLevel')
})
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

/* ========== 筛选遮罩 ========== */
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

/* ========== 竞赛卡片 ========== */
.comp-list-card {
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
  align-items: stretch;
  height: 180px;
  overflow: hidden;
}

.comp-list-poster {
  width: 110px;
  height: 172px;
  border-radius: 12px;
  background-size: cover;
  background-position: center;
  flex-shrink: 0;
  position: relative;
  background-color: #eee;
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

.comp-list-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  gap: 6px;
  min-width: 0;
  padding-left: 8px;
}

.comp-list-title-zh {
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

.comp-list-title-en {
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
  gap: 3px;
  margin-top: 2px;
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

.mvalue.deadline {
  color: #e05050;
  font-weight: 600;
}

.comp-list-bottom {
  display: flex;
  gap: 6px;
  align-items: center;
  margin-top: 6px;
  flex-wrap: wrap;
}

.ui-tag {
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: 500;
}

.ui-tag-gray { background: #f0f2f5; color: #666666; }
.ui-tag-green { background: #e6f4f2; color: var(--primary-color); }
.ui-tag-orange { background: #fff3e0; color: #ff9800; }
</style>
