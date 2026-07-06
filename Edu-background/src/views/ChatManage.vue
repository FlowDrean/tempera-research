<template>
  <div class="chat-manage">
    <!-- Left Panel: Conversation List -->
    <div class="chat-left glass-card">
      <div class="panel-header">
        <h3 class="panel-title">用户咨询列表</h3>
        <el-button text :icon="Refresh" @click="loadConversations" :loading="convLoading" />
      </div>
      <div class="conv-list">
        <div v-if="conversations.length === 0 && !convLoading" class="empty-state">
          <el-empty description="暂无用户咨询" :image-size="80" />
        </div>
        <div
          v-for="conv in conversations"
          :key="conv.userId"
          class="conv-item"
          :class="{ active: selectedUser && selectedUser.userId === conv.userId }"
          @click="selectConversation(conv)"
        >
          <div class="conv-avatar">
            <el-avatar :size="40" :icon="UserFilled" />
          </div>
          <div class="conv-info">
            <div class="conv-top">
              <span class="conv-name">{{ conv.username }}</span>
              <span class="conv-time">{{ formatConvTime(conv.lastTime) }}</span>
            </div>
            <div class="conv-bottom">
              <span class="conv-last">{{ conv.lastContent }}</span>
              <el-badge v-if="conv.unreadCount > 0" :value="conv.unreadCount" :max="99" class="conv-badge" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Right Panel: Chat Area -->
    <div class="chat-right glass-card">
      <!-- No user selected -->
      <div v-if="!selectedUser" class="chat-empty">
        <el-empty description="请选择左侧一位用户开始回复" :image-size="120" />
      </div>

      <!-- Chat with selected user -->
      <template v-else>
        <!-- Chat header -->
        <div class="chat-header">
          <span class="chat-title">{{ selectedUser.username }}</span>
        </div>

        <!-- Messages -->
        <div class="msg-list" ref="msgListRef">
          <div v-if="loading" class="msg-loading">
            <el-icon class="is-loading" :size="24"><Loading /></el-icon>
          </div>
          <div v-else-if="messages.length === 0" class="msg-empty">
            <span>暂无消息，发送一条消息开始回复</span>
          </div>

          <template v-for="(msg, idx) in messages" :key="'m-' + idx">
            <!-- Time divider -->
            <div v-if="showTime(idx)" class="time-divider">
              <span>{{ formatTime(msg.createTime) }}</span>
            </div>

            <!-- Received (user -> admin) -->
            <div v-if="msg.senderId !== 1" class="msg-row msg-row-left">
              <el-avatar :size="34" :icon="UserFilled" class="msg-avatar" />
              <div class="msg-bubble bubble-recv">
                <el-image
                  v-if="msg.msgType === 'image'"
                  :src="msg.content"
                  :preview-src-list="[msg.content]"
                  fit="contain"
                  class="msg-img"
                />
                <span v-else>{{ msg.content }}</span>
              </div>
            </div>

            <!-- Sent (admin -> user) -->
            <div v-else class="msg-row msg-row-right">
              <div class="msg-bubble bubble-sent">
                <el-image
                  v-if="msg.msgType === 'image'"
                  :src="msg.content"
                  :preview-src-list="[msg.content]"
                  fit="contain"
                  class="msg-img"
                />
                <span v-else>{{ msg.content }}</span>
              </div>
              <el-avatar :size="34" :icon="UserFilled" class="msg-avatar msg-avatar-sent" />
            </div>
          </template>
          <div ref="msgBottomRef" style="height: 1px"></div>
        </div>

        <!-- Input area -->
        <div class="input-area">
          <el-input
            v-model="inputText"
            placeholder="输入回复内容，按 Enter 发送"
            :maxlength="500"
            show-word-limit
            @keyup.enter="sendMessage"
          >
            <template #append>
              <el-button type="primary" :icon="Promotion" @click="sendMessage" :loading="sending">
                发送
              </el-button>
            </template>
          </el-input>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted, onUnmounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { UserFilled, Refresh, Loading, Promotion } from '@element-plus/icons-vue'
import { getConversations, getAdminChatHistory } from '@/api/chat'
import { connect, send, onMessage, close } from '@/utils/websocket'

// --- State ---
const conversations = ref([])
const selectedUser = ref(null)
const messages = ref([])
const loading = ref(false)
const convLoading = ref(false)
const sending = ref(false)
const inputText = ref('')
const msgListRef = ref(null)
const msgBottomRef = ref(null)
let unsubMessage = null

// --- Time helpers ---
function showTime(idx) {
  if (idx === 0) return true
  const curr = messages.value[idx]?.createTime
  const prev = messages.value[idx - 1]?.createTime
  if (!curr || !prev) return false
  return new Date(curr).getTime() - new Date(prev).getTime() > 5 * 60 * 1000
}

function formatTime(time) {
  if (!time) return ''
  const d = new Date(time)
  const now = new Date()
  const pad = (n) => String(n).padStart(2, '0')
  const hm = pad(d.getHours()) + ':' + pad(d.getMinutes())
  if (d.toDateString() === now.toDateString()) return hm
  return (d.getMonth() + 1) + '/' + d.getDate() + ' ' + hm
}

function formatConvTime(time) {
  if (!time) return ''
  const d = new Date(time)
  const now = new Date()
  const pad = (n) => String(n).padStart(2, '0')
  if (d.toDateString() === now.toDateString()) {
    return pad(d.getHours()) + ':' + pad(d.getMinutes())
  }
  return (d.getMonth() + 1) + '/' + d.getDate()
}

// --- Load conversations ---
async function loadConversations() {
  convLoading.value = true
  try {
    conversations.value = await getConversations() || []
  } catch {
    conversations.value = []
  } finally {
    convLoading.value = false
  }
}

// --- Select conversation ---
async function selectConversation(conv) {
  selectedUser.value = conv
  loading.value = true
  messages.value = []
  try {
    const res = await getAdminChatHistory(conv.userId, 1, 100)
    if (res && res.records) {
      messages.value = res.records
    }
  } catch {
    messages.value = []
  } finally {
    loading.value = false
    scrollToBottom()
  }
}

// --- Send message ---
function sendMessage() {
  const text = inputText.value.trim()
  if (!text || !selectedUser.value) return

  send({
    content: text,
    targetUserId: selectedUser.value.userId
  })
  inputText.value = ''
  sending.value = false
}

// --- Scroll ---
function scrollToBottom() {
  nextTick(() => {
    msgBottomRef.value?.scrollIntoView({ behavior: 'smooth' })
  })
}

// --- WebSocket message handler ---
function handleWsMessage(data) {
  if (data.type !== 'message') return

  // Determine the other party
  const otherId = data.senderId === 1 ? data.receiverId : data.senderId

  // If viewing this conversation, append to messages
  if (selectedUser.value && selectedUser.value.userId === otherId) {
    messages.value.push(data)
    scrollToBottom()
  }

  // Refresh conversation list to update last message / unread
  loadConversations()
}

// --- Lifecycle ---
onMounted(() => {
  connect()
  unsubMessage = onMessage(handleWsMessage)
  loadConversations()
})

onUnmounted(() => {
  if (unsubMessage) unsubMessage()
  close()
})
</script>

<style lang="scss" scoped>
.chat-manage {
  display: flex;
  gap: 16px;
  height: calc(100vh - 140px);
  min-height: 500px;
}

/* ========== Left Panel ========== */
.chat-left {
  width: 320px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  border-radius: 12px;
  overflow: hidden;
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;

  .panel-title {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin: 0;
  }
}

.conv-list {
  flex: 1;
  overflow-y: auto;
}

.conv-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 20px;
  cursor: pointer;
  transition: background 0.15s;
  border-bottom: 1px solid #f5f5f5;

  &:hover {
    background: rgba(91, 108, 255, 0.04);
  }

  &.active {
    background: rgba(91, 108, 255, 0.08);
    border-left: 3px solid #5B6CFF;
    padding-left: 17px;
  }
}

.conv-avatar {
  flex-shrink: 0;
}

.conv-info {
  flex: 1;
  min-width: 0;
}

.conv-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.conv-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

.conv-time {
  font-size: 12px;
  color: #999;
  flex-shrink: 0;
}

.conv-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 4px;
}

.conv-last {
  font-size: 13px;
  color: #999;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
  margin-right: 8px;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
}

/* ========== Right Panel ========== */
.chat-right {
  flex: 1;
  display: flex;
  flex-direction: column;
  border-radius: 12px;
  overflow: hidden;
}

.chat-empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* --- Chat header --- */
.chat-header {
  padding: 14px 20px;
  border-bottom: 1px solid #f0f0f0;
  flex-shrink: 0;

  .chat-title {
    font-size: 16px;
    font-weight: 600;
    color: #333;
  }
}

/* --- Messages --- */
.msg-list {
  flex: 1;
  overflow-y: auto;
  padding: 16px 20px;
  background: #fafafa;
}

.msg-loading, .msg-empty {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  color: #999;
  font-size: 13px;
}

/* Time divider */
.time-divider {
  text-align: center;
  margin: 12px 0;

  span {
    font-size: 12px;
    color: #b2b2b2;
    background: #efefef;
    border-radius: 4px;
    padding: 3px 10px;
  }
}

/* Message row */
.msg-row {
  display: flex;
  align-items: flex-start;
  margin-bottom: 14px;
}

.msg-row-left {
  justify-content: flex-start;
}

.msg-row-right {
  justify-content: flex-end;
}

.msg-avatar {
  flex-shrink: 0;
}

.msg-avatar-sent {
  background: #5B6CFF;
}

/* Bubbles */
.msg-bubble {
  max-width: 65%;
  padding: 10px 14px;
  border-radius: 10px;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-word;
}

.bubble-recv {
  background: #fff;
  color: #333;
  margin-left: 10px;
  border: 1px solid #e8e8e8;
}

.bubble-sent {
  background: #5B6CFF;
  color: #fff;
  margin-right: 10px;
}

.msg-img {
  max-width: 200px;
  border-radius: 6px;
  cursor: pointer;
}

/* --- Input area --- */
.input-area {
  padding: 12px 20px;
  border-top: 1px solid #f0f0f0;
  flex-shrink: 0;
  background: #fff;
}
</style>
