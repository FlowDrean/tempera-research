<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">申请表单</text>
      <view class="nav-action"></view>
    </view>

    <scroll-view enable-flex scroll-y class="page-content" :style="{ height: scrollHeight + 'px' }">
      <!-- 表单头部横幅 -->
      <view class="form-banner-header">
        <text class="form-banner-title">TEMPERA科研项目申请表</text>
        <text class="form-banner-sub">Tempera Research Program Application</text>
      </view>

      <!-- 表体 -->
      <view class="form-body-area">
        <!-- 个人信息 -->
        <view class="form-section-title">
          <text class="zh">个人信息</text><text class="en">Personal Info</text>
        </view>

        <view class="form-group-item">
          <view class="form-label">
            <text class="label-zh">姓名</text>
            <text class="label-en">Name</text>
            <text class="required-star">*</text>
          </view>
          <input class="form-input" v-model="form.name" placeholder="请输入中文姓名" />
        </view>

        <view class="form-group-item">
          <view class="form-label">
            <text class="label-zh">学历阶段</text>
            <text class="label-en">Academic Level</text>
            <text class="required-star">*</text>
          </view>
          <picker :range="educationOptions" @change="onEducationChange">
            <view class="form-select">{{ form.education || '请选择学历阶段' }}</view>
          </picker>
        </view>

        <view class="form-group-item">
          <view class="form-label">
            <text class="label-zh">国际生年级</text>
            <text class="label-en">Grade Level</text>
            <text class="required-star">*</text>
          </view>
          <picker :range="gradeOptions" @change="onGradeChange">
            <view class="form-select">{{ form.grade || '请选择年级（国际生）' }}</view>
          </picker>
        </view>

        <view class="form-group-item">
          <view class="form-label">
            <text class="label-zh">语言考试类型</text>
            <text class="label-en">Language Test Type</text>
            <text class="required-star">*</text>
          </view>
          <picker :range="languageOptions" @change="onLanguageChange">
            <view class="form-select">{{ form.language || '请选择语言成绩' }}</view>
          </picker>
        </view>

        <view class="form-group-item">
          <view class="form-label">
            <text class="label-zh">分数（选填）</text>
            <text class="label-en">Score (Optional)</text>
          </view>
          <input class="form-input" v-model="form.languageScore" placeholder="请输入分数，如 6.5 / 90" />
        </view>

        <view class="form-group-item">
          <view class="form-label">
            <text class="label-zh">手机号码</text>
            <text class="label-en">Phone</text>
            <text class="required-star">*</text>
          </view>
          <input class="form-input" type="number" v-model="form.phone" placeholder="请输入手机号码" />
        </view>

        <view class="form-group-item">
          <view class="form-label">
            <text class="label-zh">微信账号</text>
            <text class="label-en">WeChat ID</text>
            <text class="required-star">*</text>
          </view>
          <input class="form-input" v-model="form.wechat" placeholder="请输入微信账号" />
        </view>

        <!-- 专业意向 -->
        <view class="form-section-title" style="margin-top:48rpx;">
          <text class="zh">专业意向</text>
          <text class="en">Intended Field</text>
          <text class="required-star">*</text>
        </view>

        <view class="form-group-item">
          <view class="field-tags-grid">
            <view class="field-tag" v-for="f in fieldOptions" :key="f"
              :class="{ selected: form.field === f }" @click="form.field = f">{{ f }}</view>
          </view>
        </view>

        <view class="form-group-item">
          <view class="form-label">
            <text class="label-zh">课外活动</text>
            <text class="label-en">Extracurricular Activities</text>
            <text class="required-star">*</text>
          </view>
          <input class="form-input" v-model="form.hobby" placeholder="请输入您的兴趣爱好" />
        </view>

        <view class="form-group-item">
          <view class="form-label">
            <text class="label-zh">参与年限</text>
            <text class="label-en">Years Participated</text>
            <text class="required-star">*</text>
          </view>
          <picker :range="durationOptions" @change="onDurationChange">
            <view class="form-select">{{ form.hobbyDuration || '请选择兴趣爱好时长' }}</view>
          </picker>
        </view>
      </view>

      <view style="height: 120rpx;"></view>
    </scroll-view>

    <!-- 底部按钮 -->
    <view class="full-width-btn-box">
      <view class="btn-block-primary" :class="{ disabled: submitting }" @click="onSubmit">
        {{ submitting ? '提交中...' : '下一步' }}
      </view>
    </view>
  </view>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import SvgIcon from '@/components/SvgIcon.vue'
import { submitApplication } from '@/api/application.js'

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const scrollHeight = windowHeight - statusBarHeight - 88

const applyType = ref('')
const itemId = ref(null)
const itemTitle = ref('')

onLoad((options) => {
  if (options?.type) {
    applyType.value = options.type
  }
  if (options?.itemId) {
    itemId.value = options.itemId
  }
  if (options?.itemTitle) {
    itemTitle.value = decodeURIComponent(options.itemTitle)
  }
})

const goBack = () => {
  uni.navigateBack()
}

const form = reactive({
  name: '',
  education: '',
  grade: '',
  language: '',
  languageScore: '',
  phone: '',
  wechat: '',
  field: '人文',
  hobby: '',
  hobbyDuration: ''
})

const educationOptions = ['初中', '高中', '本科', '硕士', '博士']
const gradeOptions = ['8年级', '9年级', '10年级', '11年级', '12年级']
const languageOptions = ['雅思 IELTS', '托福 TOEFL']
const durationOptions = ['1年', '2年', '3年以上']
const fieldOptions = ['人文', '艺术科技', '理科']

const onEducationChange = (e) => { form.education = educationOptions[e.detail.value] }
const onGradeChange = (e) => { form.grade = gradeOptions[e.detail.value] }
const onLanguageChange = (e) => { form.language = languageOptions[e.detail.value] }
const onDurationChange = (e) => { form.hobbyDuration = durationOptions[e.detail.value] }

const phoneReg = /^1[3-9]\d{9}$/

const submitting = ref(false)

const onSubmit = async () => {
  if (!form.name || !form.education || !form.phone) {
    uni.showToast({ title: '请完整填写所有必填项(*)', icon: 'none' })
    return
  }
  if (!phoneReg.test(form.phone)) {
    uni.showToast({ title: '请输入正确的手机号码', icon: 'none' })
    return
  }

  submitting.value = true
  try {
    const data = {
      type: applyType.value || 'project',
      itemTitle: itemTitle.value || '',
      name: form.name,
      education: form.education,
      grade: form.grade,
      languageTest: form.language,
      languageScore: form.languageScore,
      phone: form.phone,
      wechat: form.wechat,
      fieldInterest: form.field,
      hobby: form.hobby,
      hobbyDuration: form.hobbyDuration
    }
    // 根据类型设置对应ID
    if (itemId.value) {
      if (applyType.value === 'competition') {
        data.competitionId = itemId.value
      } else if (applyType.value === 'research') {
        data.researchTourId = itemId.value
      } else {
        data.projectId = itemId.value
      }
    }
    await submitApplication(data)
    uni.navigateTo({ url: '/pages/apply-success/apply-success' })
  } catch (e) {
    // request 拦截器已处理 toast
  } finally {
    submitting.value = false
  }
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

.page-content {
  flex: 1;
  padding-bottom: 80rpx;
}

.form-banner-header {
  background: linear-gradient(135deg, #B1F0FF 0%, #ffffff 100%);
  padding: 56rpx 40rpx;
  text-align: center;
  color: #333;
}

.form-banner-title {
  font-size: 34rpx;
  font-weight: 700;
  letter-spacing: 1rpx;
}

.form-banner-sub {
  display: block;
  font-size: 24rpx;
  opacity: 0.85;
  margin-top: 12rpx;
  font-weight: 300;
}

.form-body-area {
  padding: 40rpx 32rpx;
  margin: 24rpx 28rpx 0;
  border-radius: 24rpx;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4rpx 24rpx rgba(0,0,0,0.06);
}

.form-section-title {
  font-size: 28rpx;
  font-weight: 700;
  color: #333;
  margin-bottom: 28rpx;
  padding-left: 20rpx;
  position: relative;
  display: flex;
  align-items: baseline;
  gap: 16rpx;

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

.form-section-title .zh { font-weight: 700; }
.form-section-title .en { font-size: 20rpx; color: #5B6CFF; font-weight: 500; text-transform: uppercase; }

.required-star { color: #f56c6c; margin-left: -8rpx; font-size: 26rpx; }

.form-group-item {
  margin-bottom: 40rpx;
}

.form-group-item:last-child { margin-bottom: 12rpx; }

.form-label {
  display: flex;
  align-items: baseline;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.label-zh {
  font-size: 28rpx;
  font-weight: 600;
  color: #333;
}

.label-en {
  font-size: 22rpx;
  color: #5B6CFF;
  font-weight: 500;
  text-transform: uppercase;
}

.form-input {
  width: 100%;
  height: 92rpx;
  border: 1px solid #e8ecf1;
  border-radius: 20rpx;
  padding: 0 28rpx;
  font-size: 28rpx;
  color: #333;
  background: #fafbfc;
  box-sizing: border-box;
}

.form-input::placeholder { color: #c0c8d0; }

.form-select {
  width: 100%;
  height: 92rpx;
  border: 1px solid #e8ecf1;
  border-radius: 20rpx;
  padding: 0 28rpx;
  font-size: 28rpx;
  color: #606266;
  background: #fafbfc;
  display: flex;
  align-items: center;
  box-sizing: border-box;
}

.field-tags-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20rpx;
}

.field-tag {
  padding: 16rpx 0;
  border-radius: 32rpx;
  font-size: 24rpx;
  color: #555;
  background: #f2f3f5;
  text-align: center;
}

.field-tag.selected {
  background: #5B6CFF;
  color: #fff;
  font-weight: 600;
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

.btn-block-primary.disabled {
  opacity: 0.5;
}
</style>
