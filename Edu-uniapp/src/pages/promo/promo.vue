<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">{{ title }}</text>
      <view class="nav-action"></view>
    </view>

    <!-- 加载中 -->
    <view v-if="loading" class="loading-wrap">
      <text class="loading-text">加载中...</text>
    </view>

    <!-- 宣传图 -->
    <view v-else-if="imageUrl" class="promo-content">
      <image :src="imageUrl" mode="widthFix" class="promo-image" @click="previewImage" />
    </view>

    <!-- 无图片 -->
    <view v-else class="loading-wrap">
      <text class="loading-text">暂无内容</text>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { getPromoImage } from '@/api/promo'
import { resolveImageUrl } from '@/api/request'

const { statusBarHeight } = uni.getWindowInfo()

const loading = ref(true)
const title = ref('宣传图')
const imageUrl = ref('')

const goBack = () => uni.navigateBack()

const previewImage = () => {
  if (imageUrl.value) {
    uni.previewImage({
      urls: [imageUrl.value],
      current: imageUrl.value
    })
  }
}

onMounted(async () => {
  try {
    const data = await getPromoImage()
    if (data) {
      title.value = data.title || '宣传图'
      imageUrl.value = resolveImageUrl(data.imageUrl)
    }
  } catch {
    // ignore
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
  background-color: #111;
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
  width: 44px;
  display: flex;
  align-items: center;
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
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #111;
}

.loading-text {
  font-size: 14px;
  color: #999;
}

.promo-content {
  flex: 1;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  overflow-y: auto;
}

.promo-image {
  width: 100%;
}
</style>
