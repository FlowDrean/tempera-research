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

    <!-- 宣传图：用 background 显示，避免真机 <image> 网络图片校验 -->
    <view v-else-if="imageUrl" class="promo-content">
      <view class="promo-bg" :style="promoStyle" @click="previewImage"></view>
    </view>

    <!-- 无图片 -->
    <view v-else class="loading-wrap">
      <text class="loading-text">暂无内容</text>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { getPromoImage } from '@/api/promo'
import { resolveImageUrl } from '@/api/request'

const { statusBarHeight, windowWidth } = uni.getWindowInfo()

const loading = ref(true)
const title = ref('宣传图')
const imageUrl = ref('')
const promoHeight = ref(0)

// 后台建议尺寸 750x1334，获取真实尺寸失败时按此比例兜底
const DEFAULT_RATIO = 1334 / 750

const promoStyle = computed(() => {
  if (!imageUrl.value) return {}
  return {
    backgroundImage: `url(${imageUrl.value})`,
    backgroundSize: '100% auto',
    backgroundPosition: 'top center',
    backgroundRepeat: 'no-repeat',
    width: '100%',
    height: promoHeight.value + 'px'
  }
})

const goBack = () => uni.navigateBack()

// 解析 jpg/png/gif 头部，获取图片宽高，用于按原比例撑开背景容器
function parseImageSize(buffer) {
  const bytes = new Uint8Array(buffer)

  // PNG：宽高在 IHDR 中
  if (bytes.length > 24 && bytes[0] === 0x89 && bytes[1] === 0x50 && bytes[2] === 0x4e && bytes[3] === 0x47) {
    return {
      width: (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19],
      height: (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23]
    }
  }

  // GIF：宽高在第 6-9 字节，小端
  if (bytes.length > 10 && bytes[0] === 0x47 && bytes[1] === 0x49 && bytes[2] === 0x46) {
    return {
      width: bytes[6] | (bytes[7] << 8),
      height: bytes[8] | (bytes[9] << 8)
    }
  }

  // JPEG：扫描 SOF 段
  if (bytes.length > 4 && bytes[0] === 0xff && bytes[1] === 0xd8) {
    let offset = 2
    while (offset + 8 < bytes.length) {
      if (bytes[offset] !== 0xff) {
        offset++
        continue
      }
      const marker = bytes[offset + 1]
      const isSOF = (marker >= 0xc0 && marker <= 0xc3) ||
                    (marker >= 0xc5 && marker <= 0xc7) ||
                    (marker >= 0xc9 && marker <= 0xcb) ||
                    (marker >= 0xcd && marker <= 0xcf)
      if (isSOF) {
        return {
          height: (bytes[offset + 5] << 8) | bytes[offset + 6],
          width: (bytes[offset + 7] << 8) | bytes[offset + 8]
        }
      }
      if (marker === 0xd8 || marker === 0x01 || (marker >= 0xd0 && marker <= 0xd7)) {
        offset += 2
        continue
      }
      if (offset + 4 > bytes.length) break
      const segmentLength = (bytes[offset + 2] << 8) | bytes[offset + 3]
      offset += 2 + segmentLength
    }
  }

  return null
}

// 通过 uni.request 拉取图片二进制解析尺寸（走 request 通道，避开 image 的 downloadFile 校验）
function getImageSizeByRequest(url) {
  return new Promise((resolve, reject) => {
    uni.request({
      url,
      method: 'GET',
      responseType: 'arraybuffer',
      header: { Range: 'bytes=0-262143' },
      success: (res) => {
        if ((res.statusCode === 200 || res.statusCode === 206) && res.data) {
          const size = parseImageSize(res.data)
          if (size && size.width && size.height) {
            resolve(size)
          } else {
            reject(new Error('无法解析图片尺寸'))
          }
        } else {
          reject(new Error('图片请求失败'))
        }
      },
      fail: reject
    })
  })
}

async function loadPromoSize(url) {
  try {
    const size = await getImageSizeByRequest(url)
    promoHeight.value = windowWidth * (size.height / size.width)
  } catch (e) {
    console.warn('获取宣传图尺寸失败，按默认比例显示', e)
  }
}

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
    if (data && data.imageUrl) {
      title.value = data.title || '宣传图'
      imageUrl.value = resolveImageUrl(data.imageUrl)
      promoHeight.value = windowWidth * DEFAULT_RATIO
      // 不阻塞页面展示，异步获取真实尺寸后修正高度
      loadPromoSize(imageUrl.value)
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
  overflow-y: auto;
  background: #111;
}

/* 宣传图背景容器，高度由 JS 按图片实际宽高比计算 */
.promo-bg {
  width: 100%;
}
</style>
