<template>
  <view class="page-container">
    <view class="success-state-container">
      <view class="success-big-icon-wrap">
        <SvgIcon name="check" color="#fff" />
      </view>
      <text class="success-heading">提交成功！</text>
      <text class="success-message">我们已收到您的申请，客服将在1-2个工作日内与您联系</text>
    </view>

    <view class="full-width-btn-box">
      <view class="btn-block-primary" @click="goHome">返回首页</view>
    </view>
  </view>
</template>

<script setup>
import SvgIcon from '@/components/SvgIcon.vue'

const goHome = () => {
  uni.switchTab({ url: '/pages/home/home' })
}
</script>

<style lang="scss" scoped>
.page-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: #fff;
  height: 100vh;
  position: relative;
}

.success-state-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex: 1;
  padding: 120rpx 60rpx;
  text-align: center;
}

.success-big-icon-wrap {
  width: 140rpx;
  height: 140rpx;
  background: #B1F0FF;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #5B6CFF;
  margin-bottom: 40rpx;
}

.success-icon {
  font-size: 72rpx;
  font-weight: bold;
}

.success-heading {
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
}

.success-message {
  font-size: 24rpx;
  color: #999;
  margin-top: 20rpx;
  line-height: 1.6;
  max-width: 480rpx;
}

.full-width-btn-box {
  padding: 40rpx 32rpx;
  position: fixed;
  bottom: 0;
  left: 0;
  width: 100%;
  z-index: 50;
  background: #fff;
  box-sizing: border-box;
}

.btn-block-primary {
  width: 100%;
  height: 88rpx;
  background: #5B6CFF;
  border-radius: 44rpx;
  color: #fff;
  font-size: 28rpx;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
