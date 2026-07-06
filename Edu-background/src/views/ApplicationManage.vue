<template>
  <div class="manage-page">
    <div class="card-header">
      <h2 class="section-title">申请表单管理</h2>
      <span class="count-text">共 {{ total }} 条</span>
    </div>

    <!-- Filters -->
    <div class="filter-card glass-card">
      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="申请类型">
          <el-select v-model="filters.type" placeholder="全部" clearable style="width:140px" @change="fetchData">
            <el-option label="课题" value="project" />
            <el-option label="竞赛与写作" value="competition" />
            <el-option label="学术研学" value="research" />
          </el-select>
        </el-form-item>
        <el-form-item label="审核状态">
          <el-select v-model="filters.status" placeholder="全部" clearable style="width:120px" @change="fetchData">
            <el-option label="待审核" value="PENDING" />
            <el-option label="已通过" value="APPROVED" />
            <el-option label="已拒绝" value="REJECTED" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">搜索</el-button>
          <el-button @click="resetFilters">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- Table -->
    <div class="table-card glass-card">
      <el-table :data="tableData" v-loading="loading" stripe :header-cell-style="{ background:'#f5f7fa',color:'#333',fontWeight:600 }">
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column label="申请类型" width="110" align="center">
          <template #default="{ row }">
            <el-tag size="small" :style="typeStyle(row.type)">{{ typeMap[row.type] || row.type || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="itemTitle" label="申请项目" min-width="160" show-overflow-tooltip />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="education" label="学历" width="70" align="center" />
        <el-table-column prop="grade" label="年级" width="80" align="center" />
        <el-table-column prop="phone" label="手机号" width="120" align="center" />
        <el-table-column label="意向专业" width="80" align="center">
          <template #default="{ row }">
            <el-tag size="small" effect="plain" type="info">{{ row.fieldInterest || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="审核状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="statusType(row.status)">{{ statusMap[row.status] || row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="submitTime" label="提交时间" width="160" align="center">
          <template #default="{ row }">{{ formatTime(row.submitTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="150" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link :icon="View" @click="openDetail(row)">详情</el-button>
            <el-button v-if="row.status === 'PENDING'" type="success" link :icon="Select" @click="approve(row)">通过</el-button>
            <el-button v-if="row.status === 'PENDING'" type="danger" link :icon="CloseBold" @click="reject(row)">拒绝</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="currentPage" v-model:page-size="pageSize"
          :page-sizes="[10,20,50]" :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="fetchData" @current-change="fetchData"
        />
      </div>
    </div>

    <!-- Detail Dialog -->
    <el-dialog v-model="detailVisible" title="申请详情" width="680px" :close-on-click-modal="false">
      <div class="detail-content" v-if="detailRow">
        <!-- 基本信息 -->
        <div class="detail-section">
          <div class="detail-section-title">
            <span class="zh">基本信息</span>
            <span class="en">Basic Information</span>
          </div>
          <el-descriptions :column="2" border size="small">
            <el-descriptions-item label="申请类型">
              <el-tag size="small" :style="typeStyle(detailRow.type)">{{ typeMap[detailRow.type] || detailRow.type }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="审核状态">
              <el-tag size="small" :type="statusType(detailRow.status)">{{ statusMap[detailRow.status] || detailRow.status }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="姓名">{{ detailRow.name || '-' }}</el-descriptions-item>
            <el-descriptions-item label="手机号">{{ detailRow.phone || '-' }}</el-descriptions-item>
            <el-descriptions-item label="微信">{{ detailRow.wechat || '-' }}</el-descriptions-item>
            <el-descriptions-item label="学历阶段">{{ detailRow.education || '-' }}</el-descriptions-item>
            <el-descriptions-item label="年级">{{ detailRow.grade || '-' }}</el-descriptions-item>
            <el-descriptions-item label="语言考试">{{ detailRow.languageTest || '-' }}</el-descriptions-item>
            <el-descriptions-item label="语言分数">{{ detailRow.languageScore || '-' }}</el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 意向信息 -->
        <div class="detail-section">
          <div class="detail-section-title">
            <span class="zh">专业意向</span>
            <span class="en">Intended Field & Interests</span>
          </div>
          <el-descriptions :column="2" border size="small">
            <el-descriptions-item label="意向专业">
              <el-tag size="small" effect="plain" type="info">{{ detailRow.fieldInterest || '-' }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="申请项目" :span="1">{{ detailRow.itemTitle || '-' }}</el-descriptions-item>
            <el-descriptions-item label="课外活动" :span="2">{{ detailRow.hobby || '-' }}</el-descriptions-item>
            <el-descriptions-item label="参与年限">{{ detailRow.hobbyDuration || '-' }}</el-descriptions-item>
            <el-descriptions-item label="提交时间">{{ formatTime(detailRow.submitTime) }}</el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 审核信息 -->
        <div class="detail-section" v-if="detailRow.status !== 'PENDING'">
          <div class="detail-section-title">
            <span class="zh">审核信息</span>
            <span class="en">Review Information</span>
          </div>
          <el-descriptions :column="2" border size="small">
            <el-descriptions-item label="审核时间">{{ formatTime(detailRow.reviewTime) }}</el-descriptions-item>
            <el-descriptions-item label="审核备注" :span="2">{{ detailRow.reviewComment || '-' }}</el-descriptions-item>
          </el-descriptions>
        </div>
      </div>

      <template #footer>
        <div style="display:flex;justify-content:space-between;align-items:center;">
          <div v-if="detailRow?.status === 'PENDING'" style="display:flex;gap:8px;">
            <el-button type="success" @click="approveFromDetail">审核通过</el-button>
            <el-button type="danger" @click="rejectFromDetail">审核拒绝</el-button>
          </div>
          <div v-else></div>
          <el-button @click="detailVisible = false">关闭</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- Review Comment Dialog -->
    <el-dialog v-model="reviewDialog.visible" :title="reviewDialog.title" width="460px" :close-on-click-modal="false">
      <el-form :model="reviewDialog">
        <el-form-item label="审核备注">
          <el-input
            v-model="reviewDialog.comment"
            type="textarea"
            :rows="3"
            :placeholder="reviewDialog.status === 'APPROVED' ? '如：您的申请已通过，请留意后续通知...' : '请填写拒绝原因...'"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="reviewDialog.visible = false">取消</el-button>
        <el-button :type="reviewDialog.status === 'APPROVED' ? 'success' : 'danger'" :loading="reviewDialog.loading" @click="confirmReview">
          {{ reviewDialog.status === 'APPROVED' ? '确认通过' : '确认拒绝' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { View, Select, CloseBold } from '@element-plus/icons-vue'
import { getApplicationList, updateApplicationStatus } from '@/api/application'

const typeMap = { project: '课题', competition: '竞赛与写作', research: '学术研学' }
const statusMap = { PENDING: '待审核', APPROVED: '已通过', REJECTED: '已拒绝' }
const statusType = (s) => ({ PENDING: 'warning', APPROVED: 'success', REJECTED: 'danger' }[s] || 'info')
const typeStyle = (t) => {
  const m = { project: { background: '#e6f4f2', color: '#5B6CFF', borderColor: '#b3ddd6' }, competition: { background: '#fff3e0', color: '#ff9800', borderColor: '#ffcc80' }, research: { background: '#f3e8ff', color: '#9333ea', borderColor: '#d8b4fe' } }
  return m[t] || {}
}

// Filters
const filters = ref({ type: '', status: '' })

// Table
const tableData = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// Detail
const detailVisible = ref(false)
const detailRow = ref(null)

// Review
const reviewDialog = ref({
  visible: false,
  title: '',
  status: '',
  comment: '',
  loading: false,
  row: null
})

onMounted(() => fetchData())

async function fetchData() {
  loading.value = true
  try {
    const params = { page: currentPage.value, size: pageSize.value }
    if (filters.value.status) params.status = filters.value.status
    if (filters.value.type) params.type = filters.value.type
    const res = await getApplicationList(params)
    tableData.value = res.records
    total.value = res.total
  } catch { /* handled by interceptor */ } finally { loading.value = false }
}

function resetFilters() {
  filters.value = { type: '', status: '' }
  fetchData()
}

function openDetail(row) {
  detailRow.value = { ...row }
  detailVisible.value = true
}

function formatTime(time) {
  if (!time) return '-'
  return time.replace('T', ' ').substring(0, 19)
}

function approve(row) {
  reviewDialog.value = {
    visible: true,
    title: `审核通过 - ${row.name} (${row.itemTitle || typeMap[row.type] || ''})`,
    status: 'APPROVED',
    comment: '',
    loading: false,
    row
  }
}

function reject(row) {
  reviewDialog.value = {
    visible: true,
    title: `审核拒绝 - ${row.name} (${row.itemTitle || typeMap[row.type] || ''})`,
    status: 'REJECTED',
    comment: '',
    loading: false,
    row
  }
}

function approveFromDetail() {
  detailVisible.value = false
  approve(detailRow.value)
}

function rejectFromDetail() {
  detailVisible.value = false
  reject(detailRow.value)
}

async function confirmReview() {
  reviewDialog.value.loading = true
  try {
    await updateApplicationStatus(reviewDialog.value.row.id, {
      status: reviewDialog.value.status,
      reviewComment: reviewDialog.value.comment
    })
    ElMessage.success(reviewDialog.value.status === 'APPROVED' ? '已通过该申请' : '已拒绝该申请')
    reviewDialog.value.visible = false
    fetchData()
  } catch { /* handled by interceptor */ } finally {
    reviewDialog.value.loading = false
  }
}
</script>

<style lang="scss" scoped>
.manage-page {
  .card-header {
    display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;
    .count-text { font-size: 13px; color: #999; }
  }
}
.filter-card { padding: 16px 20px 0; margin-bottom: 16px; }
.filter-form { :deep(.el-form-item) { margin-bottom: 16px; } }
.table-card { padding: 20px; }
.pagination-wrap { display: flex; justify-content: flex-end; margin-top: 16px; }

/* ======== Detail Dialog ======== */
.detail-content {
  max-height: 60vh; overflow-y: auto;
  &::-webkit-scrollbar { width: 4px; }
  &::-webkit-scrollbar-thumb { background: #ddd; border-radius: 2px; }
}
.detail-section {
  margin-bottom: 20px;
}
.detail-section-title {
  display: flex; align-items: baseline; gap: 10px; margin-bottom: 10px;
  padding-left: 10px; border-left: 3px solid #5B6CFF;
  .zh { font-size: 14px; font-weight: 700; color: #333; }
  .en { font-size: 11px; color: #5B6CFF; font-weight: 500; text-transform: uppercase; }
}
</style>
