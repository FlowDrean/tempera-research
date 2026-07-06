<template>
  <view class="banner-container" v-if="items && items.length > 0">
    <swiper
      class="banner-swiper"
      :indicator-dots="false"
      :autoplay="true"
      :interval="3500"
      :duration="450"
      :circular="true"
      @change="onChange"
    >
      <swiper-item v-for="(item, index) in items" :key="index">
        <view class="banner-slide" :style="{ background: item.bg || gradients[index % gradients.length] }">
          <text class="banner-title">{{ item.title || '坦培拉科研' }}</text>
          <text class="banner-sub">{{ item.subtitle || '' }}</text>
        </view>
      </swiper-item>
    </swiper>
    <view class="dots" v-if="items.length > 1">
      <view
        v-for="(_, index) in items"
        :key="index"
        class="dot"
        :class="{ active: current === index }"
        @click="goTo(index)"
      ></view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'

defineProps({
  items: { type: Array, default: () => [] }
})

const current = ref(0)

const gradients = [
  'linear-gradient(135deg, #1d3557, #457b9d)',
  'linear-gradient(135deg, #2d6a4f, #52b788)',
  'linear-gradient(135deg, #6a1b9a, #ab47bc)',
  'linear-gradient(135deg, #c0392b, #e74c3c)',
  'linear-gradient(135deg, #e67e22, #f39c12)'
]

function onChange(e) {
  current.value = e.detail.current
}

function goTo(index) {
  current.value = index
}
</script>

<style lang="scss" scoped>
.banner-container {
  margin: 12px 14px;
  height: 150px;
  border-radius: 12px;
  position: relative;
  overflow: hidden;
}

.banner-swiper {
  height: 100%;
  border-radius: 12px;
}

.banner-slide {
  height: 100%;
  padding: 24px;
  color: #ffffff;
  display: flex;
  flex-direction: column;
  justify-content: center;
  border-radius: 12px;
}

.banner-title {
  font-size: 20px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.banner-sub {
  font-size: 13px;
  opacity: 0.8;
  margin-top: 4px;
}

.dots {
  position: absolute;
  bottom: 12px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 6px;
}

.dot {
  width: 6px;
  height: 6px;
  background: rgba(255, 255, 255, 0.4);
  border-radius: 50%;
  transition: all 0.3s;

  &.active {
    width: 14px;
    height: 6px;
    background: #ffffff;
    border-radius: 3px;
  }
}
</style>
