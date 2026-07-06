<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">课题详情</text>
      <view class="nav-action" @click="showNavPanel = true">
        <SvgIcon name="menu" color="#333" />
      </view>
    </view>

    <!-- 加载中 -->
    <view v-if="loading" class="loading-wrap">
      <text class="loading-text">加载中...</text>
    </view>

    <scroll-view v-if="!loading" enable-flex scroll-y class="page-content" :style="{ height: scrollHeight + 'px' }" :scroll-into-view="scrollIntoView" scroll-with-animation>
      <!-- 顶图 -->
      <view class="detail-hero" :style="{ backgroundImage: 'url(' + course.heroImg + ')' }"
        @click="previewImage(course.heroImg)"></view>

      <!-- 学术背景 -->
      <view class="detail-section-block" id="sec-overview">
        <view class="detail-section-title">
          <text class="zh">学术背景</text><text class="en">Academic Context</text>
        </view>
        <view class="tags-row">
          <text class="ui-tag gray">{{ course.field }}</text>
          <text class="ui-tag green">{{ course.mode }}</text>
        </view>
        <text class="detail-title">{{ course.title }}</text>
        <text class="detail-title-en">{{ course.titleEn }}</text>
        <view class="detail-content-collapsed" :class="{ expanded: descExpanded }">
          <text class="detail-section-content" style="margin-top: 24rpx;">{{ course.description }}</text>
        </view>
        <view class="detail-expand-btn" @click="descExpanded = !descExpanded" v-if="course.description && course.description.length > 60">
          {{ descExpanded ? '收起' : '展开全部' }}
          <SvgIcon :name="descExpanded ? 'arrow-up' : 'arrow-down'" color="#5B6CFF" />
        </view>
      </view>

      <!-- 课程信息 -->
      <view class="detail-section-block" id="sec-meta">
        <view class="detail-section-title">
          <text class="zh">专题信息</text><text class="en">Module Details</text>
        </view>
        <view class="detail-info-list">
          <view class="detail-info-row">
            <SvgIcon name="clock" color="#5B6CFF" />
            <text class="info-label">开课时间</text>
            <text class="info-value">{{ course.startDate }}</text>
          </view>
          <view class="detail-info-row">
            <SvgIcon name="book" color="#5B6CFF" />
            <text class="info-label">课时</text>
            <text class="info-value">{{ course.hours }}</text>
          </view>
          <view class="detail-info-row">
            <SvgIcon name="star" color="#5B6CFF" />
            <text class="info-label">难度</text>
            <text class="info-value" style="color: #f0a020;">{{ course.difficulty }}</text>
          </view>
          <view class="detail-info-row">
            <SvgIcon name="trophy" color="#5B6CFF" />
            <text class="info-label">学术成果</text>
            <text class="info-value">{{ course.outcome }}</text>
          </view>
        </view>
      </view>

      <!-- 研究方向 -->
      <view class="detail-section-block" id="sec-direction" v-if="course.researchDirection">
        <view class="detail-section-title">
          <text class="zh">研究方向</text><text class="en">Research Areas</text>
        </view>
        <text class="detail-section-content">{{ course.researchDirection }}</text>
      </view>

      <!-- 教授介绍 -->
      <view class="detail-section-block" id="sec-instructor" v-if="course.professors.length">
        <view class="detail-section-title">
          <text class="zh">教授介绍</text><text class="en">Professor Profiles</text>
        </view>
        <view class="instructor-profile-card" v-for="prof in course.professors" :key="prof.name">
          <view class="instructor-avatar" :style="{ backgroundImage: 'url(' + prof.avatar + ')' }"></view>
          <view class="instructor-detail-info">
            <text class="instructor-name">{{ prof.name }} / {{ prof.nameEn }}</text>
            <text class="instructor-bio">{{ prof.bio }}</text>
          </view>
        </view>
      </view>

      <!-- 专题介绍 -->
      <view class="detail-section-block" id="sec-intro" v-if="course.topicIntro">
        <view class="detail-section-title">
          <text class="zh">专题介绍</text><text class="en">Module Descriptions</text>
        </view>
        <view class="detail-content-collapsed" :class="{ expanded: introExpanded }">
          <text class="detail-section-content">{{ course.topicIntro }}</text>
        </view>
        <view class="detail-expand-btn" @click="introExpanded = !introExpanded" v-if="course.topicIntro && course.topicIntro.length > 60">
          {{ introExpanded ? '收起' : '展开全部' }}
          <SvgIcon :name="introExpanded ? 'arrow-up' : 'arrow-down'" color="#5B6CFF" />
        </view>
      </view>

      <!-- 适合学生 -->
      <view class="detail-section-block" id="sec-suitable" v-if="course.suitableStudents.length">
        <view class="detail-section-title">
          <text class="zh">适合学生</text><text class="en">Target Participants</text>
        </view>
        <view class="detail-section-content">
          <view class="suitable-item" v-for="(item, i) in course.suitableStudents" :key="i"
            :class="i % 2 === 0 ? 'suitable-even' : 'suitable-odd'">
            <view class="suitable-bullet"></view>
            <text class="suitable-text">{{ item }}</text>
          </view>
        </view>
      </view>

      <!-- 课题大纲 -->
      <view class="detail-section-block" id="sec-outline" v-if="course.outline.length">
        <view class="detail-section-title">
          <text class="zh">课题大纲</text><text class="en">Curriculum Outline</text>
        </view>
        <view class="detail-section-content">
          <view class="outline-item" v-for="(item, i) in course.outline" :key="i">
            <text>{{ item }}</text>
          </view>
        </view>
      </view>

      <!-- 课程安排 -->
      <view class="detail-section-block" id="sec-plan" v-if="course.schedule">
        <view class="detail-section-title">
          <text class="zh">课题安排</text><text class="en">Program Schedule</text>
        </view>
        <text class="detail-section-content">{{ course.schedule }}</text>
      </view>

      <!-- 完整科研流程 -->
      <view class="detail-section-block" id="sec-process" v-if="course.processTable.length">
        <view class="detail-section-title">
          <text class="zh">科研流程</text><text class="en">Research Process</text>
        </view>
        <view class="process-table">
          <view class="process-table-header">
            <text class="th" style="width:14%;">阶段</text>
            <text class="th" style="width:20%;">环节</text>
            <text class="th" style="width:14%;">形式</text>
            <text class="th" style="width:12%;">课时</text>
            <text class="th" style="flex:1;">内容概要</text>
          </view>
          <view class="process-table-row" v-for="(row, i) in course.processTable" :key="i">
            <text class="td" style="width:14%;">{{ row.stage }}</text>
            <text class="td" style="width:20%;">{{ row.link }}</text>
            <text class="td" style="width:14%;">{{ row.form }}</text>
            <text class="td" style="width:12%;">{{ row.hours }}</text>
            <text class="td" style="flex:1; text-align: left;">{{ row.summary }}</text>
          </view>
        </view>
      </view>

      <!-- 成果形式 -->
      <view class="detail-section-block" id="sec-outcome" v-if="course.outcomeFormat">
        <view class="detail-section-title">
          <text class="zh">成果形式</text><text class="en">Expected Research Outputs</text>
        </view>
        <view class="detail-section-content">
          <text>{{ course.outcomeFormat }}</text>
        </view>
      </view>

      <!-- 专题匹配院校 -->
      <view class="detail-section-block" id="sec-match" v-if="course.matchingSchools">
        <view class="detail-section-title">
          <text class="zh">匹配院校</text><text class="en">Target Universities</text>
        </view>
        <text class="detail-section-content">{{ course.matchingSchools }}</text>
      </view>

      <!-- 项目流程 -->
      <view class="detail-section-block" id="sec-workflow" v-if="course.workflow.length">
        <view class="detail-section-title">
          <text class="zh">项目流程</text><text class="en">Program Roadmap</text>
        </view>
        <view class="process-steps">
          <view class="process-step" v-for="(step, i) in course.workflow" :key="i">
            <view class="process-step-num">{{ i + 1 }}</view>
            <view class="process-step-text">
              <text class="process-step-title">{{ step.title }}</text>
              <text class="process-step-desc">{{ step.desc }}</text>
            </view>
          </view>
        </view>
      </view>

      <!-- PDF 材料 -->
      <view class="detail-section-block" id="sec-materials" v-if="course.pdfMaterials.length">
        <view class="detail-section-title">
          <text class="zh">其他资料</text><text class="en">Materials</text>
        </view>
        <view class="pdf-material-list">
          <view class="pdf-material-item" v-for="pdf in course.pdfMaterials" :key="pdf.name"
            @click="onPdfTap(pdf)">
            <SvgIcon name="file" color="#e05050" />
            <text class="pdf-name">{{ pdf.name }}</text>
            <SvgIcon name="arrow-right" color="#ccc" />
          </view>
        </view>
      </view>

      <view style="height: 120rpx;"></view>
    </scroll-view>

    <!-- 底部操作栏 -->
    <view class="detail-fixed-bottom">
      <view class="btn-outline-primary" @click="onConsult">咨询客服</view>
      <view class="btn-solid-primary" @click="onApply">立即申请</view>
    </view>

    <!-- 快速导航浮动按钮 -->
    <view class="quick-nav-trigger" @click="showNavPanel = true">
      <SvgIcon name="menu" color="#5B6CFF" />
    </view>

    <!-- 快速导航遮罩 -->
    <view v-if="showNavPanel" class="quick-nav-overlay" @click="showNavPanel = false"></view>

    <!-- 快速导航面板 -->
    <view class="quick-nav-panel" :class="{ show: showNavPanel }">
      <view class="quick-nav-panel-header" :style="{ paddingTop: (statusBarHeight + 12) + 'px' }">
        <text class="nav-panel-title">快速导航</text>
      </view>
      <scroll-view enable-flex scroll-y class="quick-nav-list">
        <view class="quick-nav-item" v-for="(item, i) in quickNavItems" :key="i"
          :class="{ active: activeNav === i }" @click="onNavItem(item, i)">
          <SvgIcon :name="item.icon" color="#5B6CFF" />
          <view class="quick-nav-text">
            <text class="qn-en">{{ item.en }}</text>
            <text class="qn-zh">{{ item.zh }}</text>
          </view>
        </view>
      </scroll-view>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed, onMounted, getCurrentInstance } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import SvgIcon from '@/components/SvgIcon.vue'
import { useUserStore } from '@/stores/user'
import { getProjectDetail } from '@/api/project'
import { resolveImageUrl } from '@/api/request'

const userStore = useUserStore()

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const scrollHeight = ref(windowHeight - statusBarHeight - 88)

const descExpanded = ref(false)
const introExpanded = ref(false)
const showNavPanel = ref(false)
const activeNav = ref(0)
const scrollIntoView = ref('')
const loading = ref(true)

// Default empty course structure
const course = reactive({
  id: null,
  title: '',
  titleEn: '',
  heroImg: '',
  field: '',
  mode: '',
  description: '',
  startDate: '',
  hours: '',
  difficulty: '',
  outcome: '',
  researchDirection: '',
  professors: [],
  topicIntro: '',
  suitableStudents: [],
  outline: [],
  schedule: '',
  processTable: [],
  outcomeFormat: '',
  matchingSchools: '',
  workflow: [],
  pdfMaterials: []
})

// Helper: safe JSON parse (returns array or fallback)
function safeJsonParse(str, fallback) {
  if (!str) return fallback
  try {
    const parsed = JSON.parse(str)
    return Array.isArray(parsed) ? parsed : fallback
  } catch { return fallback }
}

// Helper: parse newline-separated string to array
function parseNewlineArray(str) {
  if (!str) return []
  return str.split('\n').map(s => s.trim()).filter(Boolean)
}

// Build professor list from entity flat fields
function buildProfessors(p) {
  const profs = []
  if (p.professor1Name) {
    profs.push({ name: p.professor1Name, nameEn: '', avatar: '', bio: p.professor1Info || '' })
  }
  if (p.professor2Name) {
    profs.push({ name: p.professor2Name, nameEn: '', avatar: '', bio: p.professor2Info || '' })
  }
  if (p.professor3Name) {
    profs.push({ name: p.professor3Name, nameEn: '', avatar: '', bio: p.professor3Info || '' })
  }
  return profs
}

// Build PDF materials list from entity PDF fields
function buildPdfMaterials(p) {
  const list = []
  if (p.courseOutlinePdf) list.push({ name: '课题大纲 / Curriculum Outline', url: p.courseOutlinePdf })
  if (p.serviceFlowPdf) list.push({ name: '服务流程 / SERVICE PROCESS', url: p.serviceFlowPdf })
  if (p.paperDisplayPdf) list.push({ name: '论文与学术作品展示 / PAPERS & ACADEMIC OUTPUTS', url: p.paperDisplayPdf })
  if (p.practiceResearchPdf) list.push({ name: '实践调研 / FIELD RESEARCH', url: p.practiceResearchPdf })
  return list
}

// Map API project object to detail display format
function mapProjectToDetail(p) {
  const professors = (safeJsonParse(p.professorIntro, null) || buildProfessors(p)).map(prof => ({
    ...prof,
    avatar: resolveImageUrl(prof.avatar || '')
  }))

  Object.assign(course, {
    id: p.id,
    title: p.titleCn || '',
    titleEn: p.titleEn || '',
    heroImg: resolveImageUrl(p.detailPoster || p.poster),
    field: p.category || '',
    mode: p.mode || '',
    description: p.description || '',
    startDate: p.startDate || '',
    hours: p.hoursInfo || '',
    difficulty: p.difficulty || '',
    outcome: p.outcome || '',
    researchDirection: p.researchDirections || '',
    professors: professors,
    topicIntro: p.topicIntro || '',
    suitableStudents: parseNewlineArray(p.targetStudents),
    outline: parseNewlineArray(p.outlineInfo),
    schedule: p.schedule || '',
    processTable: safeJsonParse(p.processInfo, []),
    outcomeFormat: p.outcomeFormat || '',
    matchingSchools: p.matchSchools || '',
    workflow: safeJsonParse(p.workflow, []),
    pdfMaterials: buildPdfMaterials(p)
  })
}

// Quick nav items - dynamically filtered based on available content
const quickNavItems = computed(() => {
  const items = [
    { en: 'Academic Context', zh: '学术背景', icon: 'info', anchor: 'sec-overview' },
    { en: 'Module Details', zh: '专题信息', icon: 'clock', anchor: 'sec-meta' }
  ]
  if (course.researchDirection) items.push({ en: 'Research Areas', zh: '研究方向', icon: 'globe', anchor: 'sec-direction' })
  if (course.professors.length) items.push({ en: 'Professor Profiles', zh: '教授介绍', icon: 'user', anchor: 'sec-instructor' })
  if (course.topicIntro) items.push({ en: 'Module Descriptions', zh: '专题介绍', icon: 'info', anchor: 'sec-intro' })
  if (course.suitableStudents.length) items.push({ en: 'Target Participants', zh: '适合学生', icon: 'check', anchor: 'sec-suitable' })
  if (course.outline.length) items.push({ en: 'Curriculum Outline', zh: '课题大纲', icon: 'menu', anchor: 'sec-outline' })
  if (course.schedule) items.push({ en: 'Program Schedule', zh: '课题安排', icon: 'gear', anchor: 'sec-plan' })
  if (course.processTable.length) items.push({ en: 'Research Process', zh: '科研流程', icon: 'microscope', anchor: 'sec-process' })
  if (course.outcomeFormat) items.push({ en: 'Expected Research Outputs', zh: '成果形式', icon: 'file', anchor: 'sec-outcome' })
  if (course.matchingSchools) items.push({ en: 'Target Universities', zh: '匹配院校', icon: 'graduation', anchor: 'sec-match' })
  if (course.workflow.length) items.push({ en: 'Program Roadmap', zh: '项目流程', icon: 'lightbulb', anchor: 'sec-workflow' })
  if (course.pdfMaterials.length) items.push({ en: 'Materials', zh: '其他资料', icon: 'file', anchor: 'sec-materials' })
  return items
})

// Fetch project detail from API
async function fetchDetail(id) {
  loading.value = true
  try {
    const data = await getProjectDetail(id)
    if (data) {
      mapProjectToDetail(data)
    } else {
      uni.showToast({ title: '课题不存在', icon: 'none' })
    }
  } catch (e) {
    console.error('Fetch detail failed:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

let detailLoaded = false

// Try to load detail with given id
function tryLoadDetail(routeId) {
  if (detailLoaded || !routeId) return false
  detailLoaded = true
  fetchDetail(Number(routeId))
  return true
}

// Approach 1: onLoad lifecycle (standard uni-app way)
onLoad((options) => {
  console.log('[project-detail] onLoad options:', JSON.stringify(options))
  if (options?.id) {
    tryLoadDetail(options.id)
  }
})

// Approach 2: fallback via getCurrentPages (runs after mount)
onMounted(() => {
  if (detailLoaded) return
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage?.options || currentPage?.$page?.options || {}
  console.log('[project-detail] getCurrentPages options:', JSON.stringify(options))
  if (options.id) {
    tryLoadDetail(options.id)
  } else {
    loading.value = false
    uni.showToast({ title: '缺少课题ID', icon: 'none' })
  }
})

const goBack = () => {
  uni.navigateBack()
}

const previewImage = (url) => {
  if (!url) return
  uni.previewImage({ urls: [url] })
}

const onNavItem = (item, index) => {
  activeNav.value = index
  scrollIntoView.value = ''
  setTimeout(() => {
    scrollIntoView.value = item.anchor
  }, 50)
}

const onConsult = () => {
  if (!userStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages/login/login' })
    return
  }
  uni.navigateTo({ url: '/pages/chat/chat' })
}

const onApply = () => {
  if (!userStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages/login/login' })
    return
  }
  uni.navigateTo({ url: `/pages/apply/apply?type=project&itemId=${course.id}&itemTitle=${encodeURIComponent(course.title)}` })
}

const onPdfTap = (pdf) => {
  if (!pdf.url) {
    uni.showToast({ title: '暂无文件', icon: 'none' })
    return
  }
  const url = resolveImageUrl(pdf.url)
  uni.showLoading({ title: '加载中...' })
  uni.downloadFile({
    url: url,
    success: (res) => {
      uni.hideLoading()
      if (res.statusCode === 200) {
        uni.openDocument({
          filePath: res.tempFilePath,
          showMenu: true,
          fileType: 'pdf',
          success: () => {},
          fail: (err) => {
            console.error('openDocument fail:', err)
            uni.showToast({ title: '预览失败', icon: 'none' })
          }
        })
      } else {
        uni.showToast({ title: '下载失败', icon: 'none' })
      }
    },
    fail: (err) => {
      uni.hideLoading()
      console.error('downloadFile fail:', err)
      uni.showToast({ title: '下载失败', icon: 'none' })
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
  position: relative;
}

.loading-wrap {
  flex: 1; display: flex; align-items: center; justify-content: center;
}
.loading-text { font-size: 14px; color: #999; }

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
  padding-bottom: 140rpx;
}

.detail-hero {
  width: calc(100% - 48rpx);
  height: 360rpx;
  margin: 0 24rpx 24rpx;
  border-radius: 24rpx;
  background-color: #ccc;
  background-size: cover;
  background-position: center;
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

.detail-section-title .zh {
  font-weight: 700;
}

.detail-section-title .en {
  font-size: 20rpx;
  color: #5B6CFF;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.8rpx;
}

.detail-section-content {
  font-size: 26rpx;
  color: #555;
  line-height: 1.7;
  white-space: pre-line;
}

.tags-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  margin-bottom: 20rpx;
}

.ui-tag {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 8rpx;
}

.ui-tag.gray { background: #f0f2f5; color: #666; }
.ui-tag.green { background: #e6f4f2; color: #5B6CFF; }

.detail-title {
  font-size: 34rpx;
  font-weight: bold;
  color: #333;
  line-height: 1.4;
  margin-top: 16rpx;
  display: block;
}

.detail-title-en {
  font-size: 22rpx;
  color: #5B6CFF;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.6rpx;
  margin-top: 8rpx;
  display: block;
}

.detail-content-collapsed {
  max-height: 160rpx;
  overflow: hidden;
}

.detail-content-collapsed.expanded {
  max-height: none;
  overflow: visible;
}

.detail-expand-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  margin-top: 16rpx;
  font-size: 24rpx;
  color: #5B6CFF;
}

.detail-info-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.detail-info-row {
  display: flex;
  align-items: flex-start;
  gap: 16rpx;
  font-size: 26rpx;
  color: #555;
  line-height: 1.6;
}

.info-icon { color: #5B6CFF; flex-shrink: 0; font-size: 28rpx; }
.info-label { color: #777; flex-shrink: 0; min-width: 112rpx; }
.info-value { color: #555; flex: 1; }

.instructor-profile-card {
  display: flex;
  gap: 24rpx;
  align-items: flex-start;
  margin-top: 16rpx;
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
  display: block;
  line-height: 1.5;
}

.suitable-item {
  display: flex;
  gap: 24rpx;
  align-items: center;
  padding: 28rpx 32rpx;
  border-radius: 16rpx;
  transition: background 0.2s;
}

.suitable-even {
  background: #ffffff;
}

.suitable-odd {
  background: #f4f0ff;
}

.suitable-bullet {
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: #7c5cfc;
  flex-shrink: 0;
}

.suitable-text {
  line-height: 1.7;
  font-size: 26rpx;
  color: #444;
  flex: 1;
}

.outline-item {
  font-size: 26rpx;
  color: #555;
  line-height: 2;
}

.process-table {
  font-size: 22rpx;
  color: #555;
}

.process-table-header {
  display: flex;
  background: rgba(91, 108, 255, 0.08);
  color: #5B6CFF;
  font-weight: 600;
  padding: 16rpx 8rpx;
  border-radius: 8rpx 8rpx 0 0;
  font-size: 20rpx;

  .th {
    text-align: center;
  }
}

.process-table-row {
  display: flex;
  padding: 16rpx 8rpx;
  border-bottom: 1px solid rgba(0,0,0,0.06);
  line-height: 1.4;

  .td {
    text-align: center;
    font-size: 20rpx;
  }

  .td:first-child {
    font-weight: 600;
    color: #5B6CFF;
  }
}

.process-steps {
  display: flex;
  flex-direction: column;
}

.process-step {
  display: flex;
  gap: 28rpx;
  padding: 0 0 32rpx 0;
  position: relative;

  &:last-child {
    padding-bottom: 0;
  }

  &::after {
    content: '';
    position: absolute;
    left: 24rpx;
    top: 60rpx;
    width: 2rpx;
    height: calc(100% - 60rpx);
    background: #e0e8e5;
  }

  &:last-child::after {
    display: none;
  }
}

.process-step-num {
  width: 52rpx;
  height: 52rpx;
  border-radius: 50%;
  background: #5B6CFF;
  color: #fff;
  font-size: 24rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  margin-top: 2rpx;
}

.process-step-text {
  font-size: 26rpx;
  color: #555;
  line-height: 1.6;
  padding-top: 6rpx;
}

.process-step-title {
  color: #333;
  font-weight: 600;
  display: block;
  margin-bottom: 4rpx;
}

.process-step-desc {
  display: block;
}

.pdf-material-list {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.pdf-material-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 24rpx 28rpx;
  background: #fafbfc;
  border-radius: 16rpx;
  font-size: 26rpx;
  color: #333;
}

.pdf-icon { color: #e05050; flex-shrink: 0; font-size: 30rpx; }
.pdf-name { flex: 1; }
.pdf-arrow { color: #ccc; font-size: 24rpx; }

.detail-fixed-bottom {
  display: flex;
  padding: 20rpx 28rpx;
  gap: 24rpx;
  align-items: center;
  position: fixed;
  bottom: 20rpx;
  left: 24rpx;
  right: 24rpx;
  z-index: 50;
}

.btn-outline-primary {
  flex: 1;
  height: 88rpx;
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 28rpx;
  color: #5B6CFF;
  font-size: 28rpx;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}

.btn-solid-primary {
  flex: 1.8;
  height: 88rpx;
  border-radius: 28rpx;
  color: #fff;
  font-size: 28rpx;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #5B6CFF;
  border: none;
}

.quick-nav-trigger {
  position: fixed;
  right: 20rpx;
  top: 50%;
  transform: translateY(-50%);
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  color: #5B6CFF;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 70;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  box-shadow: 0 4rpx 24rpx rgba(0,0,0,0.12);
  border: 1px solid rgba(255, 255, 255, 0.6);
  font-size: 32rpx;
}

.quick-nav-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.5);
  z-index: 200;
}

.quick-nav-panel {
  position: fixed;
  top: 0;
  right: 0;
  width: 62%;
  max-width: 520rpx;
  height: 100%;
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  z-index: 201;
  transform: translateX(100%);
  transition: transform 0.35s cubic-bezier(0.32, 0.72, 0, 1);
  display: flex;
  flex-direction: column;
  box-shadow: -16rpx 0 60rpx rgba(0,0,0,0.15);
  border-radius: 32rpx 0 0 32rpx;
  border-left: 1px solid rgba(255, 255, 255, 0.6);
}

.quick-nav-panel.show {
  transform: translateX(0);
}

.quick-nav-panel-header {
  padding: 40rpx 36rpx 32rpx;
  font-size: 32rpx;
  font-weight: 700;
  color: #333;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid rgba(0,0,0,0.06);
}

.close-btn {
  width: 56rpx;
  height: 56rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;
  font-size: 30rpx;
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(8px);
}

.quick-nav-list {
  flex: 1;
  overflow-y: auto;
  padding: 12rpx 0;
}

.quick-nav-item {
  display: flex;
  align-items: center;
  padding: 28rpx 40rpx;
  gap: 28rpx;
  border-bottom: 1px solid rgba(0,0,0,0.05);
}

.quick-nav-item.active {
  background: rgba(91, 108, 255, 0.12);
  border-left: 6rpx solid #5B6CFF;
}

.nav-item-icon {
  font-size: 28rpx;
  color: #5B6CFF;
  flex-shrink: 0;
}

.quick-nav-text {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.qn-en {
  font-size: 20rpx;
  color: #5B6CFF;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.8rpx;
}

.qn-zh {
  font-size: 27rpx;
  color: #333;
  font-weight: 600;
}
</style>
