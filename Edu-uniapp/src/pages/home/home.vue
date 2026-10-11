<template>
  <view class="page-container">
    <!-- 导航标题 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <text class="nav-title">坦培拉科研</text>
    </view>

    <!-- 搜索框 -->
    <view class="search-box-wrap">
      <view class="search-box" @click="goToSearch">
        <SvgIcon name="search" color="#888" />
        <text class="search-placeholder">教授 / 学科 / 学校 / 海外 / 1V1定制</text>
      </view>
    </view>

    <scroll-view enable-flex scroll-y class="page-content" :style="{ height: scrollHeight + 'px' }">
      <!-- Banner 轮播（2.5:1，高度按屏幕宽度自适应） -->
      <view class="home-banner" :style="{ height: bannerHeight }">
        <swiper
          class="banner-swiper"
          :indicator-dots="banners.length > 1"
          indicator-color="rgba(255,255,255,0.4)"
          indicator-active-color="#ffffff"
          autoplay
          interval="3500"
          duration="450"
          circular
          @change="onBannerChange"
        >
          <swiper-item v-for="(item, index) in banners" :key="item.id || index">
            <view class="banner-slide" @click="onBannerTap(item)">
              <image
                v-if="item.imageUrl && !failedBannerImages[index]"
                class="banner-image"
                :src="item.imageUrl"
                mode="aspectFill"
                @error="onBannerImageError(index)"
              />
              <view v-else class="banner-bg" :style="{ background: item.bg }"></view>
              <view v-if="item.title || item.subtitle" class="banner-text-wrap">
                <text v-if="item.title" class="banner-slide-title">{{ item.title }}</text>
                <text v-if="item.subtitle" class="banner-slide-sub">{{ item.subtitle }}</text>
              </view>
            </view>
          </swiper-item>
        </swiper>
      </view>

      <!-- 分类按钮 -->
      <view class="home-categories">
        <view class="cat-btn" v-for="cat in categories" :key="cat.name" @click="onCategoryTap(cat)">
          <view class="cat-btn-icon">
            <image :src="cat.icon" class="cat-icon-img" mode="aspectFit" />
          </view>
          <text class="cat-name">{{ cat.name }}</text>
        </view>
      </view>

      <!-- 学术探索 -->
      <view class="home-section-panel">
        <view class="section-header">
          <text class="section-header-title">学术探索</text>
          <text class="section-header-en">Research Practicum</text>
        </view>
        <view class="featured-courses-row" v-if="largeCard && smallCards.length >= 2">
          <view class="featured-course-card featured-course-large"
            :style="{ backgroundImage: `url(${resolveImageUrl(largeCard.imageUrl)})` }"
            @click="onExploreTap(largeCard)">
            <text class="featured-course-label">{{ largeCard.title }}</text>
            <text class="featured-course-sub">{{ largeCard.subtitle }}</text>
          </view>
          <view class="featured-courses-col">
            <view class="featured-course-card featured-course-small"
              v-for="card in smallCards"
              :key="card.id"
              :style="{ backgroundImage: `url(${resolveImageUrl(card.imageUrl)})` }"
              @click="onExploreTap(card)">
              <text class="featured-course-label">{{ card.title }}</text>
              <text class="featured-course-sub">{{ card.subtitle }}</text>
            </view>
          </view>
        </view>
        <!-- 兜底：无数据时显示默认 -->
        <view class="featured-courses-row" v-else>
          <view class="featured-course-card featured-course-large"
            :style="{ backgroundImage: 'url(https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=600&q=80)' }"
            @click="onFeaturedTap('实践1V1定制')">
            <text class="featured-course-label">实践1V1定制</text>
            <text class="featured-course-sub">1-on-1 Practice</text>
          </view>
          <view class="featured-courses-col">
            <view class="featured-course-card featured-course-small"
              :style="{ backgroundImage: 'url(https://images.unsplash.com/photo-1523050854058-8df90910e683?w=400&q=80)' }"
              @click="onFeaturedTap('海外课题')">
              <text class="featured-course-label">海外课题</text>
              <text class="featured-course-sub">Overseas Research</text>
            </view>
            <view class="featured-course-card featured-course-small"
              :style="{ backgroundImage: 'url(https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=400&q=80)' }"
              @click="onFeaturedTap('研学')">
              <text class="featured-course-label">学术研学</text>
              <text class="featured-course-sub">Academic Tour</text>
            </view>
          </view>
        </view>
      </view>

      <!-- 探索成果 横向滚动 -->
      <view class="home-section-panel">
        <view class="section-header">
          <text class="section-header-title">探索成果</text>
          <text class="section-header-en">Research Outcomes</text>
        </view>
        <scroll-view enable-flex scroll-x class="ad-scroll-track" :show-scrollbar="false">
          <view class="ad-card" v-for="(ad, i) in adList" :key="i">
            <view class="ad-card-img" :style="{ backgroundImage: 'url(' + ad.img + ')' }"></view>
            <text class="ad-card-title">{{ ad.title }}</text>
          </view>
        </scroll-view>
      </view>

      <view style="height: 100rpx;"></view>
    </scroll-view>

    <!-- 悬浮耳机按钮 -->
    <view class="floating-earphone-btn" @click="togglePromo">
      <image class="earphone-icon-img" src="/static/icons/小耳机图标（新）.png" mode="aspectFit" />
    </view>

    <!-- 底部导航栏 -->
    <TabBar :current="0" />
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import TabBar from '@/components/TabBar.vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { getBannerList } from '@/api/banner'
import { getPromotionList } from '@/api/promotion'
import { getExploreList } from '@/api/explore'
import { resolveImageUrl } from '@/api/request'

const { windowHeight, statusBarHeight, windowWidth } = uni.getWindowInfo()
// 固定区域: nav-bar(statusBarHeight+44) + search-box(56) = statusBarHeight + 100
const scrollHeight = computed(() => windowHeight - statusBarHeight - 100)

// Banner 保持 2.5:1 宽高比：容器宽 = 屏幕宽 - 左右 margin 14px
const bannerHeight = `${Math.round((windowWidth - 28) / 2.5)}px`

// 后台图片是 http://IP 地址，真机不允许加载；同图在本地打包一份，按文件名兜底
// （后台切到 HTTPS 域名后会优先使用网络图，本地兜底自动失效）
const localBannerMap = {
  '734c094491604dbf86c9c130a456ab68.jpg': '/static/banner/banner-1.jpg',
  '31f4bd0361a643f4a4c6219a0b4d4100.jpg': '/static/banner/banner-2.jpg',
  '59b1e9c9f7cb4436b186bd54d47eb635.jpg': '/static/banner/banner-3.jpg',
  'e62014a09b4b4121a35b04d37f4d6a79.jpg': '/static/banner/banner-4.jpg',
  'f10be1c1d31e4bba96032356f70a5ea9.jpg': '/static/banner/banner-5.jpg'
}

// 图片加载失败记录（避免轮播出现空白）
const failedBannerImages = ref({})

function onBannerImageError(index) {
  failedBannerImages.value[index] = true
}

// 解析图片地址：HTTPS 网络图直接用；http 图能匹配到本地兜底图则用本地
function getBannerImage(url) {
  const remote = resolveImageUrl(url)
  if (!remote) return ''
  if (remote.startsWith('https://')) return remote
  const fileName = remote.split('?')[0].split('/').pop()
  return localBannerMap[fileName] || remote
}

// 默认兜底数据
const defaultBanners = [
  { title: 'Explore Research', subtitle: 'Unlock Academic Future', bg: 'linear-gradient(135deg, #1d3557, #457b9d)' },
  { title: '顶尖导师团队', subtitle: '全球名校教授一对一指导', bg: 'linear-gradient(135deg, #2d6a4f, #52b788)' },
  { title: '定制科研项目', subtitle: '打造你的专属学术背景', bg: 'linear-gradient(135deg, #6a1b9a, #ab47bc)' },
  { title: '竞赛与写作辅导', subtitle: '国内外顶级赛事全程助力', bg: 'linear-gradient(135deg, #c0392b, #e74c3c)' },
  { title: '全球学术研学', subtitle: '沉浸式名校科研体验', bg: 'linear-gradient(135deg, #e67e22, #f39c12)' }
]

// Banner 数据（从后台管理获取）
const banners = ref([...defaultBanners])
const bannerCurrent = ref(0)

// 学术探索卡片数据
const exploreCards = ref([])
const largeCard = computed(() => exploreCards.value.find(c => c.cardType === 'large') || null)
const smallCards = computed(() => exploreCards.value.filter(c => c.cardType === 'small').slice(0, 2))

onMounted(async () => {
  try {
    const list = await getBannerList()
    if (list && list.length > 0) {
      banners.value = list.map(item => ({
        id: item.id,
        title: item.title,
        subtitle: item.subtitle || '',
        // bgColor 优先级高于 imageUrl，与后台管理系统一致
        imageUrl: item.bgColor ? '' : getBannerImage(item.imageUrl),
        bg: item.bgColor || 'linear-gradient(135deg, #5B6CFF, #B1F0FF)',
        linkType: item.linkType || '',
        linkValue: item.linkValue || ''
      }))
    }
  } catch {
    // 接口失败使用默认数据
    console.log('Banner API 获取失败，使用默认数据')
  }

  try {
    const promoList = await getPromotionList()
    if (promoList && promoList.length > 0) {
      adList.value = promoList.map(item => ({
        title: item.title,
        img: resolveImageUrl(item.imageUrl)
      }))
    }
  } catch {
    // 接口失败使用默认数据
    console.log('Promotion API 获取失败，使用默认数据')
  }

  try {
    const exploreList = await getExploreList()
    if (exploreList && exploreList.length > 0) {
      exploreCards.value = exploreList
    }
  } catch {
    // 接口失败使用默认数据
    console.log('Explore API 获取失败，使用默认数据')
  }
})

// 分类按钮
const categories = ref([
  { name: '人文社科', icon: '/static/icons/人文社科.png' },
  { name: '理科', icon: '/static/icons/理科.png' },
  { name: '艺术科技', icon: '/static/icons/艺术科技.png' },
  { name: '竞赛与写作', icon: '/static/icons/竞赛与写作.png' }
])

// 探索成果广告 - 默认兜底数据
const defaultAds = [
  { title: '名校科研项目', img: 'https://images.unsplash.com/photo-1523050854058-8df90910e683?w=400&q=80' },
  { title: '国际竞赛辅导', img: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&q=80' },
  { title: '学术论文发表', img: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&q=80' },
  { title: '海外研学体验', img: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=400&q=80' },
  { title: '1V1定制课题', img: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=400&q=80' }
]
const adList = ref([...defaultAds])
const adCurrent = ref(0)

const onBannerChange = (e) => {
  bannerCurrent.value = e.detail.current
}

const onBannerTap = (item) => {
  if (!item.linkType || !item.linkValue) return
  switch (item.linkType) {
    case 'course':
      uni.navigateTo({ url: `/pages/project-detail/project-detail?id=${item.linkValue}` })
      break
    case 'competition':
      uni.navigateTo({ url: `/pages/competition-detail/competition-detail?id=${item.linkValue}` })
      break
    case 'research':
      uni.navigateTo({ url: `/pages/research-detail/research-detail?id=${item.linkValue}` })
      break
    case 'video':
      uni.navigateTo({ url: `/pages/video-player/video-player?id=${item.linkValue}` })
      break
    case 'external':
      // 外部链接：复制到剪贴板或使用 webview
      uni.setClipboardData({ data: item.linkValue, success: () => {
        uni.showToast({ title: '链接已复制', icon: 'none' })
      }})
      break
    default:
      break
  }
}

const goToSearch = () => uni.navigateTo({ url: '/pages/search/search' })

const goToProject = () => uni.switchTab({ url: '/pages/project/project' })

const onCategoryTap = (cat) => {
  if (cat.name === '竞赛与写作') {
    uni.navigateTo({ url: '/pages/competition/competition' })
  } else {
    // 通过事件总线传递筛选条件
    uni.$emit('filterField', cat.name)
    uni.switchTab({ url: '/pages/project/project' })
  }
}

const onExploreTap = (card) => {
  // 优先使用后台配置的跳转类型
  if (card && card.linkType) {
    switch (card.linkType) {
      case 'course':
        uni.navigateTo({ url: `/pages/project-detail/project-detail?id=${card.linkValue}` })
        break
      case 'course_list':
        uni.switchTab({ url: '/pages/project/project' })
        break
      case 'course_mode':
        uni.$emit('filterMode', '实践1V1定制')
        uni.switchTab({ url: '/pages/project/project' })
        break
      case 'course_field':
        uni.$emit('filterField', '海外课题')
        uni.switchTab({ url: '/pages/project/project' })
        break
      case 'competition':
        uni.navigateTo({ url: `/pages/competition-detail/competition-detail?id=${card.linkValue}` })
        break
      case 'competition_list':
        uni.navigateTo({ url: '/pages/competition/competition' })
        break
      case 'research':
        uni.navigateTo({ url: `/pages/research-detail/research-detail?id=${card.linkValue}` })
        break
      case 'research_list':
        uni.navigateTo({ url: '/pages/research/research' })
        break
      case 'video':
        uni.navigateTo({ url: `/pages/video-player/video-player?id=${card.linkValue}` })
        break
      case 'external':
        uni.setClipboardData({ data: card.linkValue, success: () => {
          uni.showToast({ title: '链接已复制', icon: 'none' })
        }})
        break
      default:
        break
    }
    return
  }
  // 兜底：按标题关键词跳转
  const title = card?.title || ''
  if (title.includes('研学')) {
    uni.navigateTo({ url: '/pages/research/research' })
  } else if (title.includes('实践') || title.includes('定制')) {
    uni.$emit('filterMode', '实践1V1定制')
    uni.switchTab({ url: '/pages/project/project' })
  } else if (title.includes('海外')) {
    uni.$emit('filterField', '海外课题')
    uni.switchTab({ url: '/pages/project/project' })
  } else {
    uni.switchTab({ url: '/pages/project/project' })
  }
}

const onFeaturedTap = (filter) => {
  if (filter === '研学') {
    uni.navigateTo({ url: '/pages/research/research' })
  } else if (filter === '实践1V1定制') {
    uni.$emit('filterMode', '实践1V1定制')
    uni.switchTab({ url: '/pages/project/project' })
  } else if (filter === '海外课题') {
    uni.$emit('filterField', '海外课题')
    uni.switchTab({ url: '/pages/project/project' })
  } else {
    uni.switchTab({ url: '/pages/project/project' })
  }
}

const onAdTap = () => {
  uni.switchTab({ url: '/pages/project/project' })
}

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
  background-color: var(--bg-color);
  position: relative;
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
  background: transparent;
  display: flex;
  align-items: center;
  position: relative;
  z-index: 61;
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

.search-icon-text {
  font-size: 16px;
  color: #888;
}

.search-placeholder {
  font-size: 13px;
  color: var(--text-sub);
}

/* ========== 页面滚动区 ========== */
.page-content {
  flex: 1;
  padding-bottom: 20px;
}

/* ========== Banner（2.5:1） ========== */
.home-banner {
  margin: 12px 14px;
  height: 150px; /* 兜底值，实际高度由 bannerHeight 按屏幕宽度换算 */
  border-radius: 12px;
  position: relative;
  overflow: hidden;
}

.banner-swiper {
  height: 100%;
  border-radius: 12px;
}

.banner-slide {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
  border-radius: 12px;
}

.banner-image,
.banner-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.banner-text-wrap {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 24px;
  color: #ffffff;
  display: flex;
  flex-direction: column;
  justify-content: center;
  box-sizing: border-box;
}

.banner-slide-title {
  font-size: 20px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.banner-slide-sub {
  font-size: 13px;
  opacity: 0.8;
  margin-top: 4px;
  font-weight: 300;
}

/* ========== 分类按钮 ========== */
.home-categories {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
  padding: 14px 8px;
  margin: 0 12px 10px;
  gap: 8px 0;
}

.cat-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  min-width: 64px;
  flex: 0 0 auto;
}

.cat-btn-icon {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
}

.cat-icon-img {
  width: 100%;
  height: 100%;
}

.cat-name {
  font-size: 11px;
  font-weight: 500;
  color: var(--text-main);
}

/* ========== 区块标题 ========== */
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  padding: 6px 0 14px 4px;
  gap: 10px;
}

.section-header-title {
  font-size: 15px;
  font-weight: bold;
  color: var(--text-main);
}

.section-header-en {
  font-size: 10px;
  color: #5B6CFF;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* ========== 毛玻璃面板 ========== */
.home-section-panel {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  margin: 0 12px 10px;
  border-radius: 14px;
  padding: 10px 14px 12px;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

/* ========== 特色课题卡片 ========== */
.featured-courses-row {
  display: flex;
  gap: 10px;
  padding: 0 0 10px;
}

.featured-courses-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.featured-course-card {
  border-radius: 14px;
  background-size: cover;
  background-position: center;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 14px;
  color: #ffffff;
  position: relative;
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.25);
}

.featured-course-large {
  flex: 1.35;
  height: auto;
}

.featured-course-small {
  flex: 1;
  height: auto;
  padding: 18px;
}

.featured-course-label {
  font-size: 19px;
  font-weight: 800;
  letter-spacing: 2px;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.5);
}

.featured-course-small .featured-course-label {
  font-size: 17px;
}

.featured-course-sub {
  font-size: 11px;
  opacity: 0.85;
  margin-top: 4px;
  letter-spacing: 1px;
  text-shadow: 0 1px 4px rgba(0, 0, 0, 0.4);
}

/* ========== 探索成果 横向滚动 ========== */
.ad-scroll-track {
  display: flex;
  white-space: nowrap;
  padding: 0 0 10px;
}

.ad-card {
  display: inline-block;
  min-width: 160px;
  width: 160px;
  flex-shrink: 0;
  margin-right: 12px;
}

.ad-card-img {
  width: 160px;
  height: 106px;
  border-radius: 10px;
  background-size: cover;
  background-position: center;
  background-color: #eee;
}

.ad-card-title {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-main);
  margin-top: 10px;
  padding: 0 6px 6px;
  text-align: center;
  line-height: 1.5;
  min-height: 39px;
  white-space: normal;
  word-break: break-all;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
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

.earphone-icon-text {
  font-size: 24px;
}

.earphone-icon-img {
  width: 28px;
  height: 28px;
}
</style>
