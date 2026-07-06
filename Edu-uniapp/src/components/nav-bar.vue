<template>
  <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
    <view class="nav-inner">
      <view class="nav-left" @click="$emit('back')" v-if="showBack">
        <text class="back-icon">‹</text>
      </view>
      <view class="nav-title" v-if="title && !showBack">{{ title }}</view>
      <view class="nav-title-center" v-if="showBack">{{ title }}</view>
      <view class="nav-right" @click="$emit('rightClick')" v-if="showRight">
        <slot name="right"></slot>
      </view>
      <view class="nav-right" v-else></view>
    </view>
  </view>
</template>

<script setup>
defineProps({
  title: { type: String, default: '' },
  showBack: { type: Boolean, default: false },
  showRight: { type: Boolean, default: false }
})
defineEmits(['back', 'rightClick'])

const { statusBarHeight = 0 } = uni.getWindowInfo()
</script>

<style lang="scss" scoped>
.nav-bar {
  background: transparent;
  flex-shrink: 0;
}

.nav-inner {
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  position: relative;
}

.nav-left {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  z-index: 1;
}

.back-icon {
  font-size: 28px;
  color: #333333;
  font-weight: 500;
  line-height: 1;
}

.nav-title {
  font-size: 16px;
  font-weight: bold;
  color: #333333;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
}

.nav-title-center {
  font-size: 15px;
  font-weight: bold;
  color: #333333;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
}

.nav-right {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  z-index: 1;
}
</style>
