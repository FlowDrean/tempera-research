<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-back" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">{{ isAdmin && selectedUser ? ('用户' + selectedUser.userId) : '客服中心' }}</text>
      <view class="nav-back"></view>
    </view>

    <!-- Admin: 会话列表 -->
    <view v-if="isAdmin && !selectedUser" class="conv-list">
      <view v-if="conversations.length === 0" class="empty-state">
        <text class="empty-text">暂无用户咨询</text>
      </view>
      <view
        v-for="conv in conversations"
        :key="conv.userId"
        class="conv-item"
        @click="selectConversation(conv)"
      >
        <view class="conv-avatar">
          <SvgIcon name="user" color="#999" size="22px" />
        </view>
        <view class="conv-info">
          <text class="conv-name">用户{{ conv.userId }}</text>
          <text class="conv-last">{{ conv.lastContent }}</text>
        </view>
        <view v-if="conv.unreadCount > 0" class="conv-badge">{{ conv.unreadCount }}</view>
      </view>
    </view>

    <!-- 聊天区域 -->
    <view v-else class="chat-area">
      <!-- 消息列表 -->
      <scroll-view
        scroll-y
        class="msg-list"
        :scroll-with-animation="true"
        :scroll-into-view="scrollToId"
        :style="{ height: listHeight + 'px' }"
      >
        <view v-if="loading" class="loading-hint">
          <text>加载中...</text>
        </view>
        <view v-else-if="messages.length === 0" class="empty-hint-wrap">
          <text class="empty-hint-text">暂无消息，发送消息开始咨询</text>
        </view>

        <block v-for="(msg, idx) in messages" :key="'m-' + idx">
          <view v-if="showTime(idx)" class="time-divider">
            <text class="time-text">{{ formatTime(msg.createTime) }}</text>
          </view>

          <!-- 自己发的 -->
          <view v-if="isMine(msg)" class="msg-row msg-row-right">
            <view class="msg-bubble bubble-sent">
              <image
                v-if="msg.msgType === 'image'"
                class="msg-img"
                :src="msg.content"
                mode="widthFix"
                @click="previewImage(msg.content)"
              />
              <text v-else class="bubble-text">{{ msg.content }}</text>
            </view>
            <view class="msg-avatar msg-avatar-sent">
              <SvgIcon name="user" color="#fff" size="14px" />
            </view>
          </view>

          <!-- 对方发的 -->
          <view v-else class="msg-row msg-row-left">
            <view class="msg-avatar msg-avatar-recv">
              <SvgIcon name="headphones" color="#5B6CFF" size="14px" />
            </view>
            <view class="msg-bubble bubble-recv">
              <image
                v-if="msg.msgType === 'image'"
                class="msg-img"
                :src="msg.content"
                mode="widthFix"
                @click="previewImage(msg.content)"
              />
              <text v-else class="bubble-text">{{ msg.content }}</text>
            </view>
          </view>
        </block>

        <view :id="'msg-bottom-' + bottomTick" :style="{ height: msgBottomPad + 'px' }"></view>
      </scroll-view>

      <!-- 底部区域（面板 + 输入栏，面板绝对定位不挤压输入栏） -->
      <view class="bottom-area">
        <!-- 更多面板（加号展开，绝对定位在输入栏上方） -->
        <view v-if="showPanel" class="plus-panel">
          <view class="plus-item" @click="pickImage(); showPanel = false">
            <view class="plus-icon-wrap"><SvgIcon name="file" color="#fff" size="20px" /></view>
            <text class="plus-label">相册</text>
          </view>
        </view>

        <!-- 输入栏 -->
        <view class="input-bar" :style="{ paddingBottom: safeBottom + 'px' }">
          <view class="input-row">
            <!-- 输入框 -->
            <input
              class="input-box"
              v-model="inputText"
              placeholder=""
              confirm-type="send"
              :maxlength="500"
              @confirm="sendMessage"
              @focus="showPanel = false"
            />

            <!-- 加号（输入为空时，右侧） -->
            <view v-if="!hasInput" class="btn-plus" @click="showPanel = !showPanel">
              <text class="plus-sign">+</text>
            </view>

            <!-- 发送按钮（有输入时，右侧替换加号） -->
            <view v-if="hasInput" class="btn-send" @click="sendMessage">
              <text>发送</text>
            </view>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, nextTick, watch, onUnmounted } from 'vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { useUserStore } from '@/stores/user'
import { getChatHistory, getConversations } from '@/api/chat.js'
import { connect, send, onMessage, close } from '@/utils/websocket.js'
import { uploadFile } from '@/api/request.js'

const userStore = useUserStore()
const isAdmin = computed(() => userStore.isAdmin)

const { windowHeight, statusBarHeight, safeAreaInsets } = uni.getWindowInfo()
const safeBottom = computed(() => (safeAreaInsets?.bottom || 16))
const statusHeight = computed(() => statusBarHeight + 44)
// 输入栏高度 ≈ 边框1 + 内边距6*2 + 输入框36 = 49px，留 12px 余量避免最后一条消息被挡住
const inputBarH = 49
const msgBottomPad = computed(() => inputBarH + 12)
const listHeight = computed(() => windowHeight - statusHeight.value - inputBarH - safeBottom.value)

const loading = ref(true)
const inputText = ref('')
const messages = ref([])
const scrollToId = ref('')
const bottomTick = ref(0)
const showPanel = ref(false)
const conversations = ref([])
const selectedUser = ref(null)
let unsubMessage = null

const hasInput = computed(() => inputText.value.trim().length > 0)

// 输入框草稿持久化：离开页面再回来不会丢失已输入的文字
const DRAFT_KEY = 'chat_input_draft'
const restoreDraft = () => {
  try {
    const saved = uni.getStorageSync(DRAFT_KEY)
    if (saved) inputText.value = saved
  } catch { /* ignore */ }
}
watch(inputText, (val) => {
  uni.setStorageSync(DRAFT_KEY, val)
})

const isMine = (msg) => {
  if (isAdmin.value) return msg.senderId === userStore.userId
  return msg.senderId !== 1
}

const showTime = (idx) => {
  if (idx === 0) return true
  const curr = messages.value[idx]?.createTime
  const prev = messages.value[idx - 1]?.createTime
  if (!curr || !prev) return false
  return new Date(curr).getTime() - new Date(prev).getTime() > 5 * 60 * 1000
}

const formatTime = (time) => {
  if (!time) return ''
  const d = new Date(time)
  const now = new Date()
  const pad = (n) => String(n).padStart(2, '0')
  const hm = pad(d.getHours()) + ':' + pad(d.getMinutes())
  if (d.toDateString() === now.toDateString()) return hm
  return (d.getMonth() + 1) + '/' + d.getDate() + ' ' + hm
}

const goBack = () => {
  if (isAdmin.value && selectedUser.value) {
    selectedUser.value = null; return
  }
  uni.navigateBack()
}

const loadHistory = async () => {
  try {
    const res = await getChatHistory(1, 100)
    if (res && res.records) messages.value = res.records
  } catch { messages.value = [] }
  finally { loading.value = false; scrollToBottom() }
}

const loadConversations = async () => {
  try { conversations.value = await getConversations() || [] }
  catch { conversations.value = [] }
}

const selectConversation = (conv) => {
  selectedUser.value = conv
  loading.value = true
  messages.value = []
  loadHistory()
}

const scrollToBottom = () => {
  bottomTick.value++
  nextTick(() => { scrollToId.value = 'msg-bottom-' + bottomTick.value })
}

const sendMessage = () => {
  const text = inputText.value.trim()
  if (!text) return
  const payload = { type: 'message', content: text }
  if (isAdmin.value && selectedUser.value) payload.targetUserId = selectedUser.value.userId
  send(payload)
  inputText.value = ''
  scrollToBottom()
}

const pickImage = () => {
  uni.chooseImage({
    count: 1, sizeType: ['compressed'], sourceType: ['album'],
    success: (res) => doUpload(res.tempFilePaths[0])
  })
}

const doUpload = (filePath) => {
  uni.showLoading({ title: '发送中...', mask: true })
  uploadFile(filePath).then((data) => {
    uni.hideLoading()
    const url = (typeof data === 'string') ? data : (data && data.url ? data.url : data)
    const fullUrl = url.startsWith('http') ? url : ('http://localhost:8080' + url)
    const payload = { type: 'message', content: fullUrl, msgType: 'image' }
    if (isAdmin.value && selectedUser.value) payload.targetUserId = selectedUser.value.userId
    send(payload)
    scrollToBottom()
  }).catch((err) => {
    uni.hideLoading()
    console.error('Upload error:', err)
    uni.showToast({ title: '上传失败，请确认后端服务已启动', icon: 'none', duration: 2500 })
  })
}

const previewImage = (url) => {
  uni.previewImage({ urls: [url], current: url })
}

onUnmounted(() => {
  if (unsubMessage) unsubMessage()
  close()
})

// init
if (!userStore.isLoggedIn) {
  uni.navigateTo({ url: '/pages/login/login' })
} else {
  restoreDraft()
  connect()
  unsubMessage = onMessage((data) => {
    if (data.type === 'message') {
      if (isAdmin.value && selectedUser.value) {
        const otherId = data.senderId === userStore.userId ? data.receiverId : data.senderId
        if (otherId !== selectedUser.value.userId && data.senderId !== selectedUser.value.userId) return
      }
      messages.value.push(data)
      scrollToBottom()
    }
  })
  if (isAdmin.value) loadConversations()
  else loadHistory()
}
</script>

<style lang="scss" scoped>
/* ========== 整体 ========== */
.page-container {
  height: 100vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background-color: #EDEDED;
}

/* ========== 导航栏 ========== */
.nav-bar {
  height: 44px;
  background: #EDEDED;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 14px;
  position: relative;
  z-index: 61;
  flex-shrink: 0;
  border-bottom: 0.5px solid #d9d9d9;
}
.nav-back {
  width: 36px; display: flex; align-items: center;
}
.nav-title {
  font-size: 17px;
  font-weight: 500;
  color: #191919;
}

/* ========== Admin 会话列表 ========== */
.conv-list { flex: 1; overflow-y: auto; background: #fff; }
.conv-item {
  display: flex; align-items: center; gap: 12px;
  padding: 12px 16px; background: #fff;
}
.conv-item + .conv-item { border-top: 0.5px solid #ededed; }
.conv-avatar {
  width: 44px; height: 44px; border-radius: 6px;
  background: #e0e0e0; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.conv-info { flex: 1; min-width: 0; }
.conv-name { font-size: 16px; color: #191919; display: block; }
.conv-last {
  font-size: 13px; color: #999; display: block;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin-top: 2px;
}
.conv-badge {
  background: #f43530; color: #fff; font-size: 11px;
  min-width: 18px; height: 18px; line-height: 18px; text-align: center;
  border-radius: 9px; padding: 0 5px; flex-shrink: 0;
}

.empty-state {
  display: flex; align-items: center; justify-content: center;
  padding-top: 200rpx;
}
.empty-text { font-size: 28rpx; color: #999; }

/* ========== 聊天区域 ========== */
.chat-area { flex: 1; display: flex; flex-direction: column; overflow: hidden; }

.msg-list { flex: 1; }

.loading-hint {
  text-align: center; padding-top: 60rpx;
  font-size: 24rpx; color: #b2b2b2;
}

.empty-hint-wrap {
  display: flex; justify-content: center; padding-top: 200rpx;
}
.empty-hint-text {
  font-size: 24rpx; color: #b2b2b2;
}

/* ========== 时间分割线 ========== */
.time-divider {
  display: flex; justify-content: center; padding: 16px 0 8px;
}
.time-text {
  font-size: 22rpx; color: #b2b2b2;
  background: #e0e0e0; border-radius: 4px; padding: 4px 10px;
}

/* ========== 消息行 ========== */
.msg-row {
  display: flex; align-items: flex-start;
  padding: 0 14px; margin-bottom: 12px;
}
.msg-row-right { justify-content: flex-end; }
.msg-row-left  { justify-content: flex-start; }

.msg-avatar {
  width: 34px; height: 34px; border-radius: 6px;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.msg-avatar-sent { background: #5B6CFF; }
.msg-avatar-recv { background: #fff; }

/* ========== 气泡 ========== */
.msg-bubble {
  max-width: 70%;
  position: relative;
  padding: 12px 14px;
  font-size: 30rpx;
  line-height: 1.5;
  word-break: break-all;
}

.bubble-sent {
  background: #5B6CFF;
  color: #fff;
  border-radius: 8px;
  margin-right: 10px;
}
/* sent 气泡的小三角 */
.bubble-sent::after {
  content: '';
  position: absolute;
  right: -6px; top: 14px;
  width: 0; height: 0;
  border-left: 6px solid #5B6CFF;
  border-top: 4px solid transparent;
  border-bottom: 4px solid transparent;
}

.bubble-recv {
  background: #fff;
  color: #333;
  border-radius: 8px;
  margin-left: 10px;
}
/* recv 气泡的小三角 */
.bubble-recv::after {
  content: '';
  position: absolute;
  left: -6px; top: 14px;
  width: 0; height: 0;
  border-right: 6px solid #fff;
  border-top: 4px solid transparent;
  border-bottom: 4px solid transparent;
}

.bubble-text { white-space: pre-wrap; }
.bubble-sent .bubble-text { color: #fff; }
.bubble-recv .bubble-text { color: #333; }

.msg-img {
  max-width: 200px;
  border-radius: 4px;
  display: block;
}

/* ========== 底部区域（面板 + 输入栏） ========== */
.bottom-area {
  position: relative;
  flex-shrink: 0;
  z-index: 10;
}

/* ========== 加号面板（绝对定位在输入栏上方，不挤压输入栏） ========== */
.plus-panel {
  position: absolute;
  bottom: 100%;
  left: 0;
  right: 0;
  display: flex; gap: 20px;
  padding: 16px 24px;
  background: #f7f7f7;
  border-top: 0.5px solid #e0e0e0;
}
.plus-item {
  display: flex; flex-direction: column; align-items: center; gap: 6px;
}
.plus-icon-wrap {
  width: 54px; height: 54px; border-radius: 12px;
  background: #5B6CFF;
  display: flex; align-items: center; justify-content: center;
}
.plus-label { font-size: 22rpx; color: #888; }

/* ========== 输入栏 ========== */
.input-bar {
  background: #f7f7f7;
  border-top: 0.5px solid #e0e0e0;
  flex-shrink: 0;
}
.input-row {
  display: flex; align-items: center; gap: 10px;
  padding: 6px 14px;
}

.btn-plus {
  width: 32px; height: 32px;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.plus-sign {
  font-size: 28px; color: #7f7f7f; font-weight: 300;
  line-height: 1; transform: translateY(-1px);
}

.input-box {
  flex: 1; height: 36px; line-height: 36px;
  background: #fff;
  border-radius: 6px;
  padding: 0 12px;
  font-size: 30rpx;
  color: #333;
}

.btn-send {
  flex-shrink: 0;
  background: #5B6CFF;
  color: #fff;
  font-size: 28rpx;
  padding: 6px 14px;
  border-radius: 6px;
  font-weight: 500;
}
</style>
