<template>
  <div class="promotion-manage">
    <div class="card-header">
      <h2 class="section-title">首页探索成果模块管理</h2>
      <div class="header-right">
        <span class="card-count">共 {{ total }} 张卡片（首页横向滚动展示）</span>
        <el-button type="primary" :icon="Plus" @click="openDialog()">新增卡片</el-button>
      </div>
    </div>

    <!-- Mini-Program Card Preview Ribbon -->
    <div class="card-preview glass-card">
      <h3 class="preview-title">
        <el-icon><View /></el-icon>
        小程序首页预览效果 —「探索成果」
      </h3>
      <div class="preview-ribbon-wrapper">
        <div v-if="sortedCards.length > 0" class="preview-ribbon">
          <div
            class="preview-card"
            v-for="card in sortedCards"
            :key="card.id"
          >
            <div
              class="preview-card-img"
              :style="{ backgroundImage: card.imageUrl ? `url(${card.imageUrl})` : 'none' }"
            ></div>
            <div class="preview-card-title">{{ card.title || '未命名' }}</div>
          </div>
        </div>
        <div v-else class="preview-empty">
          <el-icon :size="36"><Picture /></el-icon>
          <span>暂无卡片，点击「新增卡片」添加</span>
        </div>
      </div>
    </div>

    <!-- Table -->
    <div class="table-card glass-card">
      <el-table
        :data="tableData"
        v-loading="loading"
        stripe
        :header-cell-style="{ background: '#f5f7fa', color: '#333', fontWeight: 600 }"
      >
        <el-table-column prop="sortOrder" label="排序" width="65" align="center" />
        <el-table-column label="卡片预览" width="200">
          <template #default="{ row }">
            <div class="row-card-preview">
              <div
                class="row-card-img"
                :style="{ backgroundImage: row.imageUrl ? `url(${row.imageUrl})` : 'none' }"
              ></div>
              <span class="row-card-title">{{ row.title }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="卡片标题" min-width="140">
          <template #default="{ row }">
            <span class="table-title-text">{{ row.title }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="linkType" label="跳转类型" width="110" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.linkType" size="small" effect="plain">
              {{ linkTypeMap[row.linkType] || row.linkType }}
            </el-tag>
            <span v-else class="text-hint">无跳转</span>
          </template>
        </el-table-column>
        <el-table-column prop="linkValue" label="跳转值" min-width="130">
          <template #default="{ row }">
            <span class="text-hint">{{ row.linkValue || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link :icon="Edit" @click="openDialog(row)">编辑</el-button>
            <el-button type="danger" link :icon="Delete" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[5, 10, 20]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="fetchData"
          @current-change="fetchData"
        />
      </div>
    </div>

    <!-- Create/Edit Dialog -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑探索成果卡片' : '新增探索成果卡片'"
      width="620px"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <!-- Card Title -->
        <el-form-item label="卡片标题" prop="title">
          <el-input v-model="form.title" placeholder="如：名校科研项目（显示在图片下方居中）" maxlength="20" show-word-limit />
        </el-form-item>

        <!-- Image Upload -->
        <el-form-item label="卡片图片" prop="imageUrl">
          <el-input v-model="form.imageUrl" placeholder="图片URL地址">
            <template #append>
              <el-upload
                :action="uploadUrl"
                :headers="uploadHeaders"
                name="file"
                :show-file-list="false"
                :on-success="handleUploadSuccess"
                :on-error="handleUploadError"
                accept="image/*"
              >
                <el-button :icon="Upload">上传</el-button>
              </el-upload>
            </template>
          </el-input>
          <div class="upload-hint">
            <el-icon><InfoFilled /></el-icon>
            建议尺寸 320×212px（16:10），支持 jpg / png / gif，大小不超过 2MB
          </div>
        </el-form-item>

        <!-- Live Card Preview -->
        <el-form-item label="卡片预览">
          <div class="live-card-wrapper">
            <div class="live-card">
              <div
                class="live-card-img"
                :style="{ backgroundImage: form.imageUrl ? `url(${form.imageUrl})` : 'none' }"
              >
                <div v-if="!form.imageUrl" class="live-card-placeholder">
                  <el-icon :size="28"><Picture /></el-icon>
                  <span>请上传图片</span>
                </div>
              </div>
              <div class="live-card-title">{{ form.title || '卡片标题预览' }}</div>
            </div>
            <div class="live-card-hint">← 小程序中实际显示效果</div>
          </div>
        </el-form-item>

        <el-divider content-position="left">跳转与排序</el-divider>

        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="跳转类型">
              <el-select v-model="form.linkType" placeholder="无跳转" style="width: 100%" clearable>
                <el-option label="无跳转" value="" />
                <el-option label="课题" value="course" />
                <el-option label="竞赛" value="competition" />
                <el-option label="研学" value="research" />
                <el-option label="视频" value="video" />
                <el-option label="外部链接" value="external" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="跳转值">
              <el-input v-model="form.linkValue" placeholder="链接地址或内容ID" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="排序" prop="sortOrder">
          <el-input-number v-model="form.sortOrder" :min="0" :max="99" controls-position="right" />
          <span class="sort-hint">数字越小越靠前，首页从左到右依次展示</span>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Edit, Delete, Upload, View, Picture, InfoFilled } from '@element-plus/icons-vue'
import { getPromotionList, createPromotion, updatePromotion, deletePromotion } from '@/api/promotion'

const linkTypeMap = {
  course: '课题', competition: '竞赛', research: '研学', video: '视频', external: '外部链接'
}

const uploadUrl = '/api/file/upload'
const uploadHeaders = computed(() => {
  const token = localStorage.getItem('admin_token')
  return token ? { Authorization: `Bearer ${token}` } : {}
})

// Table data
const tableData = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(5)
const total = ref(0)

// Sorted cards for preview ribbon (all cards, not just current page)
const sortedCards = computed(() =>
  [...tableData.value].sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0))
)

// Dialog
const dialogVisible = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const submitting = ref(false)
const formRef = ref(null)

const defaultForm = {
  title: '',
  imageUrl: '',
  linkType: '',
  linkValue: '',
  sortOrder: 0
}

const form = ref({ ...defaultForm })

const rules = {
  title: [{ required: true, message: '请输入卡片标题', trigger: 'blur' }],
  imageUrl: [{ required: true, message: '请上传卡片图片', trigger: 'blur' }]
}

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const res = await getPromotionList({ page: currentPage.value, size: pageSize.value })
    tableData.value = res.records
    total.value = res.total
  } catch { /* handled by interceptor */ } finally { loading.value = false }
}

function openDialog(row) {
  if (row) {
    isEdit.value = true
    editId.value = row.id
    form.value = {
      title: row.title || '',
      imageUrl: row.imageUrl || '',
      linkType: row.linkType || '',
      linkValue: row.linkValue || '',
      sortOrder: row.sortOrder ?? 0
    }
  } else {
    isEdit.value = false
    editId.value = null
    form.value = { ...defaultForm }
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (isEdit.value) {
      await updatePromotion(editId.value, form.value)
      ElMessage.success('卡片更新成功')
    } else {
      await createPromotion(form.value)
      ElMessage.success('卡片创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } catch { /* handled by interceptor */ } finally { submitting.value = false }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(
    `确定要删除卡片「${row.title}」吗？删除后小程序首页将不再展示此卡片。`,
    '删除确认',
    { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'warning' }
  )
  try {
    await deletePromotion(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch { /* user cancelled or error */ }
}

function handleUploadSuccess(response) {
  if (response.code === 200 && response.data?.url) {
    form.value.imageUrl = response.data.url
    ElMessage.success('上传成功')
  } else {
    ElMessage.error(response.message || '上传失败，请检查后端服务是否启动')
  }
}

function handleUploadError(err) {
  console.error('Upload error:', err)
  ElMessage.error('上传失败，请确保后端服务已启动（端口8080）')
}
</script>

<style lang="scss" scoped>
.promotion-manage {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;

    .header-right {
      display: flex;
      align-items: center;
      gap: 16px;
    }

    .card-count {
      font-size: 13px;
      color: #999;
    }
  }
}

/* ======== Card Preview Ribbon ======== */
.card-preview {
  padding: 20px;
  margin-bottom: 20px;

  .preview-title {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 15px;
    color: #333;
    margin-bottom: 16px;
  }

  .preview-ribbon-wrapper {
    background: #f5f7fa;
    border-radius: 12px;
    padding: 16px;
    min-height: 130px;
  }

  .preview-ribbon {
    display: flex;
    gap: 12px;
    overflow-x: auto;
    padding-bottom: 4px;

    &::-webkit-scrollbar {
      height: 4px;
    }
    &::-webkit-scrollbar-thumb {
      background: #c0c4cc;
      border-radius: 2px;
    }
  }

  .preview-card {
    flex-shrink: 0;
    width: 160px;
  }

  .preview-card-img {
    width: 160px;
    height: 106px;
    border-radius: 10px;
    background-size: cover;
    background-position: center;
    background-color: #e0e0e0;
  }

  .preview-card-title {
    font-size: 13px;
    font-weight: 600;
    color: #333;
    text-align: center;
    margin-top: 8px;
    padding: 0 4px;
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    word-break: break-all;
    min-height: 36px;
  }

  .preview-empty {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    height: 110px;
    color: #999;
    font-size: 14px;
  }
}

/* ======== Table ======== */
.table-card {
  padding: 20px;
}

.row-card-preview {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.row-card-img {
  width: 80px;
  height: 53px;
  border-radius: 6px;
  background-size: cover;
  background-position: center;
  background-color: #e0e0e0;
}

.row-card-title {
  font-size: 12px;
  color: #666;
  text-align: center;
  max-width: 160px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.table-title-text {
  font-weight: 500;
}

.text-hint { color: #999; font-size: 13px; }

.pagination-wrap {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

/* ======== Dialog ======== */
.upload-hint {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #999;
  margin-top: 6px;
}

.live-card-wrapper {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.live-card {
  flex-shrink: 0;
  width: 160px;
}

.live-card-img {
  width: 160px;
  height: 106px;
  border-radius: 10px;
  background-size: cover;
  background-position: center;
  background-color: #e0e0e0;
  overflow: hidden;
}

.live-card-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  color: #bbb;
  font-size: 12px;
}

.live-card-title {
  font-size: 13px;
  font-weight: 600;
  color: #333;
  text-align: center;
  margin-top: 8px;
  padding: 0 4px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  word-break: break-all;
  min-height: 36px;
}

.live-card-hint {
  font-size: 12px;
  color: #999;
  padding-top: 40px;
  white-space: nowrap;
}

.sort-hint {
  margin-left: 10px;
  font-size: 12px;
  color: #999;
}
</style>
