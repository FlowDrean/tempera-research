<template>
  <div class="explore-manage">
    <div class="card-header">
      <h2 class="section-title">学术探索模块管理</h2>
      <div class="header-right">
        <span class="card-count">共 {{ total }} 个卡片（首页展示：1 张大图 + 2 张小图）</span>
        <el-button type="primary" :icon="Plus" @click="openDialog()">新增卡片</el-button>
      </div>
    </div>

    <!-- Mini-Program Layout Preview -->
    <div class="module-preview glass-card">
      <h3 class="preview-title">
        <el-icon><View /></el-icon>
        小程序首页预览效果 —「学术探索」
      </h3>
      <div class="preview-phone-wrap">
        <div class="preview-panel">
          <!-- Section Header -->
          <div class="preview-section-header">
            <span class="preview-header-cn">学术探索</span>
            <span class="preview-header-en">Research Practicum</span>
          </div>
          <!-- Featured Cards -->
          <div v-if="largeCard && smallCards.length >= 2" class="preview-featured-row">
            <!-- Large Card -->
            <div
              class="preview-card preview-card-large"
              :style="{ backgroundImage: `linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.5)), url(${largeCard.imageUrl || defaultImg})` }"
            >
              <span class="preview-card-label">{{ largeCard.title }}</span>
              <span class="preview-card-sub">{{ largeCard.subtitle }}</span>
            </div>
            <!-- Small Cards Column -->
            <div class="preview-small-col">
              <div
                v-for="card in smallCards"
                :key="card.id"
                class="preview-card preview-card-small"
                :style="{ backgroundImage: `linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.5)), url(${card.imageUrl || defaultImg})` }"
              >
                <span class="preview-card-label">{{ card.title }}</span>
                <span class="preview-card-sub">{{ card.subtitle }}</span>
              </div>
            </div>
          </div>
          <div v-else class="preview-empty">
            <el-icon :size="36"><Picture /></el-icon>
            <span>请配置 1 张大图卡片 + 2 张小图卡片</span>
            <span class="preview-empty-hint">大图卡片 card_type=large，小图卡片 card_type=small</span>
          </div>
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
        <el-table-column label="卡片预览" width="180">
          <template #default="{ row }">
            <div
              class="row-card-preview"
              :class="{ 'row-card-large': row.cardType === 'large', 'row-card-small': row.cardType === 'small' }"
              :style="{ backgroundImage: `linear-gradient(rgba(0,0,0,0.35), rgba(0,0,0,0.55)), url(${row.imageUrl || defaultImg})` }"
            >
              <span class="row-card-label">{{ row.title }}</span>
              <span class="row-card-sub-text">{{ row.subtitle || '&nbsp;' }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="中文标题" min-width="120">
          <template #default="{ row }">
            <span class="table-title-text">{{ row.title }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="subtitle" label="英文副标题" min-width="130">
          <template #default="{ row }">
            <span class="text-hint">{{ row.subtitle || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="cardType" label="卡片类型" width="90" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.cardType === 'large'" size="small" type="primary" effect="dark">大图</el-tag>
            <el-tag v-else-if="row.cardType === 'small'" size="small" type="success" effect="dark">小图</el-tag>
            <el-tag v-else size="small" type="info">-</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="linkType" label="跳转类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.linkType" size="small" effect="plain">
              {{ linkTypeMap[row.linkType] || row.linkType }}
            </el-tag>
            <span v-else class="text-hint">无跳转</span>
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
      :title="isEdit ? '编辑学术探索卡片' : '新增学术探索卡片'"
      width="640px"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="85px">
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="中文标题" prop="title">
              <el-input v-model="form.title" placeholder="如：实践1V1定制" maxlength="10" show-word-limit />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="英文副标题" prop="subtitle">
              <el-input v-model="form.subtitle" placeholder="如：1-on-1 Practice" maxlength="30" show-word-limit />
            </el-form-item>
          </el-col>
        </el-row>

        <!-- Card Type -->
        <el-form-item label="卡片类型" prop="cardType">
          <el-radio-group v-model="form.cardType">
            <el-radio value="large">
              <span class="card-type-label">大图卡片</span>
              <span class="card-type-hint">— 左侧大尺寸，首页展示 1 张</span>
            </el-radio>
            <el-radio value="small">
              <span class="card-type-label">小图卡片</span>
              <span class="card-type-hint">— 右侧小尺寸，首页展示 2 张</span>
            </el-radio>
          </el-radio-group>
        </el-form-item>

        <!-- Background Image -->
        <el-form-item label="背景图片" prop="imageUrl">
          <el-input v-model="form.imageUrl" placeholder="背景图片URL地址">
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
            大图建议 600×400px，小图建议 400×200px。支持 jpg / png，大小不超过 2MB
          </div>
        </el-form-item>

        <!-- Live Card Preview -->
        <el-form-item label="卡片预览">
          <div class="live-card-wrapper">
            <div
              class="live-card-preview"
              :class="{ 'live-card-lg': form.cardType === 'large', 'live-card-sm': form.cardType === 'small' }"
              :style="{ backgroundImage: form.imageUrl ? `linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.5)), url(${form.imageUrl})` : 'none' }"
            >
              <div v-if="!form.imageUrl" class="live-card-placeholder">
                <el-icon :size="28"><Picture /></el-icon>
                <span>请上传背景图片</span>
              </div>
              <template v-else>
                <span class="live-card-label">{{ form.title || '中文标题' }}</span>
                <span class="live-card-sub">{{ form.subtitle || 'English Subtitle' }}</span>
              </template>
            </div>
            <div class="live-card-note">
              <el-icon><InfoFilled /></el-icon>
              <span>文字显示在卡片底部，半透明遮罩上方</span>
            </div>
          </div>
        </el-form-item>

        <el-divider content-position="left">跳转与排序</el-divider>

        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="跳转类型">
              <el-select v-model="form.linkType" placeholder="无跳转" style="width: 100%" clearable>
                <el-option label="无跳转" value="" />
                <el-option label="课题详情" value="course" />
                <el-option label="课题列表" value="course_list" />
                <el-option label="课题列表 - 实践1V1定制" value="course_mode" />
                <el-option label="课题列表 - 海外课题" value="course_field" />
                <el-option label="竞赛详情" value="competition" />
                <el-option label="竞赛与写作列表" value="competition_list" />
                <el-option label="研学详情" value="research" />
                <el-option label="学术研学列表" value="research_list" />
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
          <span class="sort-hint">数字越小越靠前，建议大图卡片排序最前</span>
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
import { getExploreList, createExplore, updateExplore, deleteExplore } from '@/api/explore'

const linkTypeMap = {
  course: '课题详情', course_list: '课题列表', course_mode: '课题-1V1定制', course_field: '课题-海外课题',
  competition: '竞赛详情', competition_list: '竞赛列表',
  research: '研学详情', research_list: '研学列表',
  video: '视频', external: '外部链接'
}

const defaultImg = 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=600&q=80'

const uploadUrl = '/api/file/upload'
const uploadHeaders = computed(() => {
  const token = localStorage.getItem('admin_token')
  return token ? { Authorization: `Bearer ${token}` } : {}
})

// Table data
const tableData = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// Preview: separate by card type
const sortedByType = computed(() =>
  [...tableData.value].sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0))
)

const largeCard = computed(() =>
  sortedByType.value.find(c => c.cardType === 'large') || null
)

const smallCards = computed(() =>
  sortedByType.value.filter(c => c.cardType === 'small').slice(0, 2)
)

// Dialog
const dialogVisible = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const submitting = ref(false)
const formRef = ref(null)

const defaultForm = {
  title: '',
  subtitle: '',
  imageUrl: '',
  cardType: 'small',
  linkType: '',
  linkValue: '',
  sortOrder: 0
}

const form = ref({ ...defaultForm })

const rules = {
  title: [{ required: true, message: '请输入中文标题', trigger: 'blur' }],
  subtitle: [{ required: true, message: '请输入英文副标题', trigger: 'blur' }],
  imageUrl: [{ required: true, message: '请上传背景图片', trigger: 'blur' }],
  cardType: [{ required: true, message: '请选择卡片类型', trigger: 'change' }]
}

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const res = await getExploreList({ page: currentPage.value, size: pageSize.value })
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
      subtitle: row.subtitle || '',
      imageUrl: row.imageUrl || '',
      cardType: row.cardType || 'small',
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
      await updateExplore(editId.value, form.value)
      ElMessage.success('卡片更新成功')
    } else {
      await createExplore(form.value)
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
    await deleteExplore(row.id)
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
.explore-manage {
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

/* ======== Module Preview (matches mini-program) ======== */
.module-preview {
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

  .preview-phone-wrap {
    display: flex;
    justify-content: center;
  }

  .preview-panel {
    width: 100%;
    max-width: 520px;
    background: rgba(255, 255, 255, 0.5);
    backdrop-filter: blur(12px);
    border-radius: 14px;
    padding: 12px 14px 14px;
    border: 1px solid rgba(255, 255, 255, 0.6);
    box-shadow: 0 2px 12px rgba(0,0,0,0.06);
  }

  .preview-section-header {
    display: flex;
    justify-content: space-between;
    align-items: baseline;
    padding: 4px 0 12px 4px;
    gap: 10px;

    .preview-header-cn {
      font-size: 15px;
      font-weight: 700;
      color: #333;
    }

    .preview-header-en {
      font-size: 10px;
      color: #5B6CFF;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
  }

  .preview-featured-row {
    display: flex;
    gap: 10px;
  }

  .preview-card {
    border-radius: 14px;
    background-size: cover;
    background-position: center;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    padding: 14px;
    color: #fff;
    overflow: hidden;
    box-shadow: 0 4px 16px rgba(0,0,0,0.25);
  }

  .preview-card-large {
    flex: 1.35;
    min-height: 180px;
  }

  .preview-small-col {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .preview-card-small {
    flex: 1;
    min-height: 85px;
    padding: 12px;
  }

  .preview-card-label {
    font-size: 17px;
    font-weight: 800;
    letter-spacing: 2px;
    text-shadow: 0 2px 8px rgba(0,0,0,0.5);
  }

  .preview-card-small .preview-card-label {
    font-size: 15px;
  }

  .preview-card-sub {
    font-size: 11px;
    opacity: 0.85;
    margin-top: 3px;
    letter-spacing: 1px;
    text-shadow: 0 1px 4px rgba(0,0,0,0.4);
  }

  .preview-empty {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 6px;
    height: 140px;
    color: #999;
    font-size: 14px;
    background: #f5f7fa;
    border-radius: 10px;

    .preview-empty-hint {
      font-size: 12px;
      color: #bbb;
    }
  }
}

/* ======== Table ======== */
.table-card {
  padding: 20px;
}

.row-card-preview {
  width: 150px;
  border-radius: 8px;
  background-size: cover;
  background-position: center;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 10px;
  color: #fff;
  overflow: hidden;

  &.row-card-large {
    height: 100px;
  }

  &.row-card-small {
    height: 60px;
  }

  .row-card-label {
    font-size: 12px;
    font-weight: 700;
    text-shadow: 0 1px 4px rgba(0,0,0,0.5);
  }

  .row-card-sub-text {
    font-size: 9px;
    opacity: 0.8;
    text-shadow: 0 1px 3px rgba(0,0,0,0.4);
  }
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

.card-type-label {
  font-weight: 500;
}

.card-type-hint {
  font-size: 12px;
  color: #999;
  margin-left: 2px;
}

.live-card-wrapper {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.live-card-preview {
  border-radius: 12px;
  background-size: cover;
  background-position: center;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 14px;
  color: #fff;
  overflow: hidden;
  flex-shrink: 0;

  &.live-card-lg {
    width: 200px;
    height: 150px;
  }

  &.live-card-sm {
    width: 160px;
    height: 80px;
    padding: 10px;
  }
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
  background: #e0e0e0;
  border-radius: 8px;
}

.live-card-label {
  font-size: 16px;
  font-weight: 800;
  letter-spacing: 1px;
  text-shadow: 0 2px 8px rgba(0,0,0,0.5);
}

.live-card-sm .live-card-label {
  font-size: 14px;
}

.live-card-sub {
  font-size: 11px;
  opacity: 0.85;
  margin-top: 2px;
  letter-spacing: 0.5px;
  text-shadow: 0 1px 4px rgba(0,0,0,0.4);
}

.live-card-note {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #999;
  padding-top: 30px;
  white-space: nowrap;
}

.sort-hint {
  margin-left: 10px;
  font-size: 12px;
  color: #999;
}
</style>
