<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">竞赛详情</text>
      <view class="nav-action" @click="showNavPanel = true">
        <SvgIcon name="menu" color="#333" />
      </view>
    </view>

    <!-- 加载中 -->
    <view v-if="loading" class="loading-wrap">
      <text class="loading-text">加载中...</text>
    </view>

    <scroll-view v-else enable-flex scroll-y class="page-content" :style="{ height: scrollHeight + 'px' }" :scroll-into-view="scrollIntoView" scroll-with-animation>
      <!-- 竞赛顶部大图 -->
      <view class="detail-hero" :style="{ backgroundImage: 'url(' + comp.poster + ')' }"
        @click="previewImage(comp.poster)"></view>

      <!-- 主信息框 -->
      <view class="detail-main-box">
        <text class="comp-hero-title-zh">{{ comp.title }}</text>
        <text class="comp-hero-title-en">{{ comp.titleEn }}</text>
        <view class="comp-hero-meta">
          <view class="comp-hero-meta-item">
            <text class="meta-label">导师</text>
            <text class="meta-value">{{ comp.instructor }}</text>
          </view>
          <view class="comp-hero-meta-item">
            <text class="meta-label">院校</text>
            <text class="meta-value">{{ comp.school }}</text>
          </view>
          <view class="comp-hero-meta-item">
            <text class="meta-label">对象</text>
            <text class="meta-value">{{ comp.participants }}</text>
          </view>
          <view class="comp-hero-meta-item">
            <text class="meta-label">截止</text>
            <text class="meta-value deadline">{{ comp.deadline }}</text>
          </view>
        </view>
        <view class="tags-row">
          <text class="ui-tag gray">{{ comp.category }}</text>
          <text class="ui-tag green">{{ comp.level }}</text>
          <text class="ui-tag" :class="comp.groupTagClass">{{ comp.groupType }}</text>
        </view>
      </view>

      <!-- 项目介绍 -->
      <view class="detail-section-block" id="sec-intro">
        <view class="detail-section-title">
          <text class="zh">项目介绍</text><text class="en">Program Introduction</text>
        </view>
        <text class="detail-section-content">{{ comp.introduction }}</text>
      </view>

      <!-- 项目信息 -->
      <view class="detail-section-block" id="sec-info">
        <view class="detail-section-title">
          <text class="zh">项目信息</text><text class="en">Program Information</text>
        </view>
        <view class="detail-section-content">
          <text>{{ comp.infoText }}</text>
        </view>
      </view>

      <!-- 竞赛规则 -->
      <view class="detail-section-block" id="sec-rules">
        <view class="detail-section-title">
          <text class="zh">竞赛规则</text><text class="en">Competition Rules</text>
        </view>
        <view class="detail-section-content">
          <text>{{ comp.rulesText }}</text>
        </view>
      </view>

      <!-- 奖项设置 -->
      <view class="detail-section-block" id="sec-awards">
        <view class="detail-section-title">
          <text class="zh">奖项设置</text><text class="en">Awards & Prizes</text>
        </view>
        <view class="detail-section-content">
          <text>{{ comp.awardsText }}</text>
        </view>
      </view>

      <!-- 报名时间 -->
      <view class="detail-section-block" id="sec-deadline">
        <view class="detail-section-title">
          <text class="zh">报名时间</text><text class="en">Registration Period</text>
        </view>
        <view class="detail-section-content">
          <text>{{ comp.deadlineText }}</text>
        </view>
      </view>

      <!-- 其他资料 -->
      <view class="detail-section-block" id="sec-materials">
        <view class="detail-section-title">
          <text class="zh">其他资料</text><text class="en">Materials</text>
        </view>
        <view class="pdf-material-list">
          <view class="pdf-material-item" v-for="pdf in comp.pdfMaterials" :key="pdf.name"
            @click="onPdfTap(pdf)">
            <SvgIcon name="file" color="#e05050" />
            <text class="pdf-name">{{ pdf.name }}</text>
            <SvgIcon name="arrow-right" color="#ccc" />
          </view>
          <view v-if="comp.pdfMaterials.length === 0" class="detail-section-content">
            <text>暂无资料</text>
          </view>
        </view>
      </view>

      <view style="height: 140rpx;"></view>
    </scroll-view>

    <!-- 底部操作栏 -->
    <view class="competition-bottom-bar">
      <view class="competition-icon-btn" @click="onConsult">
        <SvgIcon name="message" color="#555" />
        <text>TR咨询</text>
      </view>
      <view class="competition-icon-btn" @click="onShare">
        <SvgIcon name="link" color="#555" />
        <text>分享</text>
      </view>
      <view class="competition-icon-btn" @click="toggleFavorite">
        <SvgIcon name="star" :color="isFav ? '#f5a623' : '#555'" :fill="isFav ? '#f5a623' : 'none'" />
        <text :style="{ color: isFav ? '#f5a623' : '#555' }">{{ isFav ? '已收藏' : '收藏' }}</text>
      </view>
      <view class="competition-apply-btn" @click="onApply">立即申请</view>
    </view>

    <!-- 快速导航按钮 -->
    <view class="quick-nav-trigger" @click="showNavPanel = true">
      <SvgIcon name="menu" color="#5B6CFF" />
    </view>

    <!-- 快导面板 -->
    <view v-if="showNavPanel" class="quick-nav-overlay" @click="showNavPanel = false"></view>
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
import { ref, reactive, onMounted } from 'vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { useUserStore } from '@/stores/user'
import { getCompetitionDetail } from '@/api/competition'
import { resolveImageUrl } from '@/api/request'
import { addFavorite, removeFavorite, checkFavorite } from '@/api/favorite.js'

const userStore = useUserStore()

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const scrollHeight = ref(windowHeight - statusBarHeight - 88)

const showNavPanel = ref(false)
const activeNav = ref(0)
const scrollIntoView = ref('')
const isFav = ref(false)
const loading = ref(true)
const itemId = ref(0)

const comp = reactive({
  id: 0,
  title: '',
  titleEn: '',
  poster: '',
  instructor: '',
  school: '',
  participants: '',
  deadline: '',
  category: '',
  level: '',
  groupType: '',
  groupTagClass: 'green',
  introduction: '',
  infoText: '',
  rulesText: '',
  awardsText: '',
  deadlineText: '',
  pdfMaterials: []
})

const quickNavItems = [
  { en: 'Program Introduction', zh: '项目介绍', icon: 'info', anchor: 'sec-intro' },
  { en: 'Program Information', zh: '项目信息', icon: 'info', anchor: 'sec-info' },
  { en: 'Competition Rules', zh: '竞赛规则', icon: 'menu', anchor: 'sec-rules' },
  { en: 'Awards & Prizes', zh: '奖项设置', icon: 'trophy', anchor: 'sec-awards' },
  { en: 'Registration Period', zh: '报名时间', icon: 'clock', anchor: 'sec-deadline' },
  { en: 'Materials', zh: '其他资料', icon: 'file', anchor: 'sec-materials' }
]

const levelTagClassMap = { '国家级': 'green', '国际级': 'orange' }
const groupTagClassMap = { '个人': 'orange', '团队': 'green' }

function mapDetailToDisplay(data) {
  const posters = resolveImageUrl(data.poster)
  const pdfMaterials = []
  if (data.achievementPdf) {
    pdfMaterials.push({ name: '竞赛成果 / COMPETITION ACHIEVEMENTS', url: data.achievementPdf })
  }

  const infoLines = []
  if (data.organizer) infoLines.push('主办单位：' + data.organizer)
  if (data.targetAudience) infoLines.push('参赛对象：' + data.targetAudience)
  if (data.participantType) infoLines.push('竞赛形式：' + data.participantType)
  if (data.levelName) infoLines.push('竞赛级别：' + data.levelName)

  const deadlineTextParts = []
  if (data.startDate) deadlineTextParts.push('报名开始：' + data.startDate)
  if (data.deadline) deadlineTextParts.push('报名截止：' + data.deadline)

  return {
    id: data.id,
    title: data.titleCn || '',
    titleEn: data.titleEn || '',
    poster: posters,
    instructor: data.instructorName || '',
    school: data.school || '',
    participants: data.targetAudience || '',
    deadline: data.deadline || '',
    category: data.category || '',
    level: data.levelName || '',
    groupType: data.participantType || '',
    groupTagClass: groupTagClassMap[data.participantType] || 'green',
    introduction: data.description || '',
    infoText: infoLines.join('\n'),
    rulesText: data.rules || '',
    awardsText: data.awards || '',
    deadlineText: deadlineTextParts.join('\n'),
    pdfMaterials: pdfMaterials
  }
}

async function fetchDetail(id) {
  loading.value = true
  try {
    const data = await getCompetitionDetail(id)
    const mapped = mapDetailToDisplay(data)
    Object.assign(comp, mapped)
    itemId.value = mapped.id

    // Check favorite status
    if (userStore.isLoggedIn) {
      try {
        const res = await checkFavorite('competition', mapped.id)
        isFav.value = res?.favorited || false
      } catch { /* ignore */ }
    }
  } catch (e) {
    console.error('Fetch competition detail failed:', e)
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  // Get ID from route query
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const id = currentPage.$page?.options?.id || currentPage.options?.id
  if (id) {
    fetchDetail(id)
  }
})

const goBack = () => {
  uni.navigateBack()
}

const previewImage = (url) => {
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

const onShare = () => {
  uni.showToast({ title: '分享链接已复制到剪贴板', icon: 'none' })
}

const toggleFavorite = async () => {
  if (!userStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages/login/login' })
    return
  }
  isFav.value = !isFav.value
  try {
    if (isFav.value) {
      await addFavorite({
        itemType: 'competition',
        itemId: comp.id,
        itemTitle: comp.title,
        itemPoster: comp.poster,
        itemCategory: comp.category,
        itemLevel: comp.level,
        itemInstructor: comp.instructor,
        itemDeadline: comp.deadline
      })
    } else {
      await removeFavorite('competition', comp.id)
    }
    uni.showToast({ title: isFav.value ? '已收藏' : '已取消收藏', icon: 'none' })
  } catch (e) {
    isFav.value = !isFav.value
  }
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

const onApply = () => {
  if (!userStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages/login/login' })
    return
  }
  uni.navigateTo({ url: `/pages/apply/apply?type=competition&itemId=${comp.id}&itemTitle=${encodeURIComponent(comp.title)}` })
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

.loading-wrap {
  display: flex;
  justify-content: center;
  align-items: center;
  flex: 1;
}
.loading-text { font-size: 14px; color: #999; }

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

.comp-hero-title-zh {
  font-size: 32rpx;
  font-weight: 700;
  color: #333;
  line-height: 1.3;
}

.comp-hero-title-en {
  font-size: 22rpx;
  color: #5B6CFF;
  font-weight: 600;
  line-height: 1.3;
  text-transform: uppercase;
  letter-spacing: 0.6rpx;
  margin-top: 8rpx;
}

.comp-hero-meta {
  display: flex;
  flex-direction: column;
  gap: 10rpx;
  margin-top: 8rpx;
}

.comp-hero-meta-item {
  display: flex;
  gap: 12rpx;
  font-size: 24rpx;
  line-height: 1.4;
}

.meta-label { color: #999; flex-shrink: 0; min-width: 56rpx; }
.meta-value { color: #555; font-weight: 500; }
.meta-value.deadline { color: #e05050; font-weight: 600; }

.tags-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  margin-top: 16rpx;
}

.ui-tag {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 8rpx;
}

.ui-tag.gray { background: #f0f2f5; color: #666; }
.ui-tag.green { background: #e6f4f2; color: #5B6CFF; }
.ui-tag.orange { background: #fff3e0; color: #ff9800; }

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

.competition-bottom-bar {
  display: flex;
  padding: 20rpx 28rpx;
  gap: 20rpx;
  align-items: center;
  position: fixed;
  bottom: 20rpx;
  left: 24rpx;
  right: 24rpx;
  z-index: 50;
}

.competition-icon-btn {
  width: 88rpx;
  height: 88rpx;
  border-radius: 28rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #555;
  font-size: 20rpx;
  gap: 4rpx;
  flex-shrink: 0;
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}

.competition-apply-btn {
  flex: 1;
  height: 88rpx;
  border-radius: 28rpx;
  color: #fff;
  font-size: 28rpx;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #5B6CFF;
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
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.5);
  z-index: 200;
}

.quick-nav-panel {
  position: fixed;
  top: 0; right: 0;
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

.quick-nav-panel.show { transform: translateX(0); }

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

.quick-nav-list { flex: 1; overflow-y: auto; padding: 12rpx 0; }

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

.quick-nav-text { display: flex; flex-direction: column; gap: 4rpx; }

.qn-en { font-size: 20rpx; color: #5B6CFF; font-weight: 600; text-transform: uppercase; }
.qn-zh { font-size: 27rpx; color: #333; font-weight: 600; }

/* ========== PDF 材料 ========== */
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

.pdf-name { flex: 1; }
</style>
