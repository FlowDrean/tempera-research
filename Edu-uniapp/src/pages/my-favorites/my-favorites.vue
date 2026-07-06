<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">我的收藏</text>
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

    <!-- 收藏列表 -->
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
        <SvgIcon name="star" color="#c0c4cc" />
        <text class="empty-text">暂无收藏</text>
        <text class="empty-hint">在详情页点击收藏按钮即可添加</text>
      </view>

      <!-- 竞赛与写作卡片 -->
      <view v-else-if="activeTab === 'competition'" class="card-list">
        <view class="card-item" v-for="item in filteredList" :key="item.id"
          @click="goCompetitionDetail(item.itemId)">
          <view class="card-thumb" :style="{ backgroundImage: 'url(' + item.itemPoster + ')' }"></view>
          <view class="card-info">
            <text class="card-title">{{ item.itemTitle }}</text>
            <view class="card-tags">
              <text class="card-tag gray">{{ item.itemCategory }}</text>
              <text class="card-tag green">{{ item.itemLevel }}</text>
            </view>
            <view class="card-meta">
              <text class="meta-text">导师：{{ item.itemInstructor }}</text>
              <text class="meta-text">截止：{{ item.itemDeadline }}</text>
            </view>
          </view>
          <view class="card-unfav" @click.stop="onRemove(item)">
            <SvgIcon name="close" color="#c0c4cc" size="14px" />
          </view>
        </view>
      </view>

      <!-- 学术研学卡片 -->
      <view v-else class="card-list">
        <view class="card-item" v-for="item in filteredList" :key="item.id"
          @click="goResearchDetail(item.itemId)">
          <view class="card-thumb" :style="{ backgroundImage: 'url(' + item.itemPoster + ')' }"></view>
          <view class="card-info">
            <text class="card-title">{{ item.itemTitle }}</text>
            <text class="card-title-en">{{ item.itemTitleEn }}</text>
            <view class="card-meta">
              <text class="meta-text">导师：{{ item.itemInstructor }}</text>
              <text class="meta-text">地点：{{ item.itemLocation || item.itemRegion }}</text>
            </view>
          </view>
          <view class="card-unfav" @click.stop="onRemove(item)">
            <SvgIcon name="close" color="#c0c4cc" size="14px" />
          </view>
        </view>
      </view>

      <view style="height: 40rpx;"></view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import SvgIcon from '@/components/SvgIcon.vue'
import { getMyFavorites, removeFavorite } from '@/api/favorite.js'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const scrollHeight = computed(() => windowHeight - statusBarHeight - 88 - 44)

const refreshing = ref(false)
const loading = ref(true)
const activeTab = ref('competition')
const favorites = ref([])

const tabs = [
  { label: '竞赛与写作', value: 'competition' },
  { label: '学术研学', value: 'research' }
]

const filteredList = computed(() => {
  return favorites.value.filter(item => item.itemType === activeTab.value)
})

const goBack = () => {
  uni.navigateBack()
}

const onTabChange = (value) => {
  activeTab.value = value
}

const loadFavorites = async () => {
  if (!userStore.isLoggedIn) {
    favorites.value = []
    loading.value = false
    return
  }
  try {
    const res = await getMyFavorites()
    favorites.value = res || []
  } catch {
    favorites.value = []
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

const onRefresh = () => {
  refreshing.value = true
  loadFavorites()
}

const onRemove = async (item) => {
  try {
    await removeFavorite(item.itemType, item.itemId)
    favorites.value = favorites.value.filter(
      f => !(f.itemType === item.itemType && f.itemId === item.itemId)
    )
    uni.showToast({ title: '已取消收藏', icon: 'none' })
  } catch { /* ignore */ }
}

const goCompetitionDetail = (id) => {
  uni.navigateTo({ url: '/pages/competition-detail/competition-detail?id=' + id })
}

const goResearchDetail = (id) => {
  uni.navigateTo({ url: '/pages/research-detail/research-detail?id=' + id })
}

// 每次页面显示时重新加载（登录/退出后回到此页可刷新）
onShow(() => {
  if (!userStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages/login/login' })
    return
  }
  loadFavorites()
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
.card-list {
  padding: 20rpx 24rpx;
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.card-item {
  display: flex;
  gap: 20rpx;
  align-items: center;
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 20rpx;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.04);
  padding: 20rpx 24rpx;
}

.card-thumb {
  width: 120rpx;
  height: 120rpx;
  border-radius: 16rpx;
  background-color: #eee;
  background-size: cover;
  background-position: center;
  flex-shrink: 0;
}

.card-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  min-width: 0;
}

.card-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #333;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  line-height: 1.4;
}

.card-title-en {
  font-size: 20rpx;
  color: #5B6CFF;
  font-weight: 500;
  text-transform: uppercase;
}

.card-tags {
  display: flex;
  gap: 12rpx;
  flex-wrap: wrap;
}

.card-tag {
  font-size: 20rpx;
  padding: 2rpx 12rpx;
  border-radius: 8rpx;
}

.card-tag.gray { background: #f0f2f5; color: #666; }
.card-tag.green { background: #e6f4f2; color: #5B6CFF; }

.card-meta {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.meta-text {
  font-size: 22rpx;
  color: #999;
}

.card-unfav {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
</style>
