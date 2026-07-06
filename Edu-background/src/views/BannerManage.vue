<template>
  <div class="banner-manage">
    <div class="card-header">
      <h2 class="section-title">首页轮播图管理</h2>
      <div class="header-right">
        <span class="banner-count">共 {{ tableData.length }} 张（首页展示前5张启用的轮播图）</span>
        <el-button type="primary" :icon="Plus" @click="openDialog()">新增轮播图</el-button>
      </div>
    </div>

    <!-- Carousel Preview -->
    <div class="carousel-preview glass-card">
      <h3 class="preview-title">
        <el-icon><View /></el-icon>
        小程序首页预览效果
      </h3>
      <div class="preview-phone">
        <div class="phone-screen">
          <div v-if="activeBanners.length > 0" class="preview-carousel">
            <div
              class="preview-slide"
              :style="getSlideStyle(activeBanners[currentSlide])"
            >
              <div class="slide-text">
                <div class="slide-title">{{ activeBanners[currentSlide].title }}</div>
                <div class="slide-sub">{{ activeBanners[currentSlide].subtitle }}</div>
              </div>
            </div>
            <!-- Dot indicators -->
            <div class="slide-dots">
              <span
                v-for="(item, i) in activeBanners"
                :key="i"
                class="dot"
                :class="{ active: i === currentSlide }"
                @click="currentSlide = i"
              ></span>
            </div>
            <!-- Arrows -->
            <button class="slide-arrow left" @click="prevSlide">&lt;</button>
            <button class="slide-arrow right" @click="nextSlide">&gt;</button>
          </div>
          <div v-else class="preview-empty">
            <el-icon :size="40"><Picture /></el-icon>
            <span>暂无启用的轮播图</span>
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
        <el-table-column label="预览" width="260">
          <template #default="{ row }">
            <div
              class="row-preview"
              :style="getSlideStyle(row)"
            >
              <div class="row-preview-text">
                <span class="row-preview-title">{{ row.title }}</span>
                <span class="row-preview-sub">{{ row.subtitle || '&nbsp;' }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="标题" min-width="130" />
        <el-table-column prop="subtitle" label="副标题" min-width="140">
          <template #default="{ row }">{{ row.subtitle || '-' }}</template>
        </el-table-column>
        <el-table-column prop="linkType" label="跳转类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.linkType" size="small">{{ linkTypeMap[row.linkType] || row.linkType }}</el-tag>
            <span v-else class="text-hint">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="isActive" label="启用" width="70" align="center">
          <template #default="{ row }">
            <el-switch
              :model-value="row.isActive === 1"
              @change="(val) => handleToggleActive(row, val)"
              active-color="#5B6CFF"
              size="small"
            />
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
          :page-sizes="[10, 20, 50]"
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
      :title="isEdit ? '编辑轮播图' : '新增轮播图'"
      width="580px"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <!-- Title & Subtitle -->
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="标题" prop="title">
              <el-input v-model="form.title" placeholder="如：顶尖导师团队" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="副标题" prop="subtitle">
              <el-input v-model="form.subtitle" placeholder="如：全球名校教授一对一指导" />
            </el-form-item>
          </el-col>
        </el-row>

        <!-- Background: Image URL or Gradient -->
        <el-divider content-position="left">背景设置（图片与渐变色二选一）</el-divider>

        <el-form-item label="图片地址">
          <el-input v-model="form.imageUrl" placeholder="背景图片URL（与渐变色二选一）">
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
            建议尺寸 750×300px，支持 jpg / png / gif，大小不超过 2MB
          </div>
        </el-form-item>

        <el-form-item label="渐变色背景">
          <div class="gradient-row">
            <el-input
              v-model="form.bgColor"
              placeholder="如：linear-gradient(135deg, #1d3557, #457b9d)"
              style="flex:1"
            />
            <el-color-picker
              v-model="gradientColor1"
              show-alpha
              @change="applySimpleGradient"
            />
            <el-color-picker
              v-model="gradientColor2"
              @change="applySimpleGradient"
            />
          </div>
          <div class="gradient-presets">
            <span class="preset-label">快捷渐变：</span>
            <span
              v-for="(preset, i) in gradientPresets"
              :key="i"
              class="preset-dot"
              :style="{ background: preset.value }"
              :title="preset.label"
              @click="form.bgColor = preset.value"
            ></span>
          </div>
        </el-form-item>

        <!-- Live Preview -->
        <el-form-item label="实时预览">
          <div
            class="dialog-preview"
            :style="getSlideStyle(form)"
          >
            <div class="dialog-preview-text">
              <span class="dialog-preview-title">{{ form.title || '标题预览' }}</span>
              <span class="dialog-preview-sub">{{ form.subtitle || '副标题预览' }}</span>
            </div>
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
              <el-input v-model="form.linkValue" placeholder="链接或ID" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="排序" prop="sortOrder">
              <el-input-number v-model="form.sortOrder" :min="0" :max="99" controls-position="right" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="启用">
              <el-switch
                v-model="form.isActive"
                :active-value="1"
                :inactive-value="0"
                active-color="#5B6CFF"
              />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Edit, Delete, Upload, View, Picture, InfoFilled } from '@element-plus/icons-vue'
import { getBannerList, createBanner, updateBanner, deleteBanner } from '@/api/banner'

const linkTypeMap = {
  course: '课题', competition: '竞赛', research: '研学', video: '视频', external: '外部链接'
}

// Gradient presets matching the mini-program home page
const gradientPresets = [
  { label: '深海蓝', value: 'linear-gradient(135deg, #1d3557, #457b9d)' },
  { label: '森林绿', value: 'linear-gradient(135deg, #2d6a4f, #52b788)' },
  { label: '紫罗兰', value: 'linear-gradient(135deg, #6a1b9a, #ab47bc)' },
  { label: '热情红', value: 'linear-gradient(135deg, #c0392b, #e74c3c)' },
  { label: '暖阳橙', value: 'linear-gradient(135deg, #e67e22, #f39c12)' },
  { label: '皇家蓝', value: 'linear-gradient(135deg, #0f2027, #203a43, #2c5364)' },
  { label: '樱花粉', value: 'linear-gradient(135deg, #ff9a9e, #fecfef)' },
  { label: '夜空紫', value: 'linear-gradient(135deg, #667eea, #764ba2)' }
]

const uploadUrl = '/api/file/upload'
const uploadHeaders = computed(() => {
  const token = localStorage.getItem('admin_token')
  return token ? { Authorization: `Bearer ${token}` } : {}
})
const gradientColor1 = ref('#1d3557')
const gradientColor2 = ref('#457b9d')

// Carousel preview state
const currentSlide = ref(0)
let autoTimer = null

function nextSlide() {
  if (activeBanners.value.length > 0) {
    currentSlide.value = (currentSlide.value + 1) % activeBanners.value.length
  }
}
function prevSlide() {
  if (activeBanners.value.length > 0) {
    currentSlide.value = (currentSlide.value - 1 + activeBanners.value.length) % activeBanners.value.length
  }
}

const tableData = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// Active banners for preview carousel
const activeBanners = computed(() =>
  tableData.value.filter(b => b.isActive === 1).sort((a, b) => a.sortOrder - b.sortOrder)
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
  bgColor: '',
  linkType: '',
  linkValue: '',
  sortOrder: 0,
  isActive: 1
}

const form = ref({ ...defaultForm })

const rules = {
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }]
}

onMounted(() => {
  fetchData()
  autoTimer = setInterval(() => nextSlide(), 3000)
})

onUnmounted(() => {
  if (autoTimer) clearInterval(autoTimer)
})

function getSlideStyle(item) {
  if (item.bgColor) return { background: item.bgColor }
  if (item.imageUrl) return { backgroundImage: `url(${item.imageUrl})`, backgroundSize: 'cover', backgroundPosition: 'center' }
  return { background: 'linear-gradient(135deg, #5B6CFF, #B1F0FF)' }
}

function applySimpleGradient() {
  if (gradientColor1.value && gradientColor2.value) {
    form.value.bgColor = `linear-gradient(135deg, ${gradientColor1.value}, ${gradientColor2.value})`
  }
}

async function fetchData() {
  loading.value = true
  try {
    const res = await getBannerList({ page: currentPage.value, size: pageSize.value })
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
      bgColor: row.bgColor || '',
      linkType: row.linkType || '',
      linkValue: row.linkValue || '',
      sortOrder: row.sortOrder ?? 0,
      isActive: row.isActive ?? 1
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
      await updateBanner(editId.value, form.value)
      ElMessage.success('轮播图更新成功')
    } else {
      await createBanner(form.value)
      ElMessage.success('轮播图创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } catch { /* handled by interceptor */ } finally { submitting.value = false }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(
    `确定要删除轮播图「${row.title}」吗？`,
    '删除确认',
    { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'warning' }
  )
  try {
    await deleteBanner(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch { /* user cancelled or error */ }
}

async function handleToggleActive(row, val) {
  try {
    const updated = { ...row, bgColor: row.bgColor || '', isActive: val ? 1 : 0 }
    await updateBanner(row.id, updated)
    row.isActive = val ? 1 : 0
    ElMessage.success(val ? '已启用' : '已禁用')
  } catch { /* handled by interceptor */ }
}

function handleUploadSuccess(response) {
  if (response.code === 200 && response.data?.url) {
    form.value.imageUrl = response.data.url
    form.value.bgColor = ''
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
.banner-manage {
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

    .banner-count {
      font-size: 13px;
      color: #999;
    }
  }
}

/* ---- Carousel Preview (phone mockup) ---- */
.carousel-preview {
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

  .preview-phone {
    display: flex;
    justify-content: center;

    .phone-screen {
      width: 100%;
      max-width: 500px;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 4px 20px rgba(0,0,0,0.15);
      position: relative;
    }

    .preview-carousel {
      position: relative;
    }

    .preview-slide {
      height: 150px;
      display: flex;
      align-items: center;
      padding: 24px 28px;
      color: #fff;
      transition: background 0.5s;
    }

    .slide-text {
      .slide-title {
        font-size: 20px;
        font-weight: 700;
        letter-spacing: 0.5px;
      }
      .slide-sub {
        font-size: 13px;
        opacity: 0.8;
        margin-top: 4px;
        font-weight: 300;
      }
    }

    .slide-dots {
      position: absolute;
      bottom: 10px;
      left: 50%;
      transform: translateX(-50%);
      display: flex;
      gap: 6px;
      z-index: 2;

      .dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: rgba(255,255,255,0.4);
        cursor: pointer;
        transition: all 0.2s;

        &.active {
          background: #fff;
          width: 20px;
          border-radius: 4px;
        }
      }
    }

    .slide-arrow {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      width: 28px;
      height: 28px;
      border-radius: 50%;
      background: rgba(255,255,255,0.3);
      border: none;
      color: #fff;
      font-size: 14px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 2;
      transition: background 0.2s;

      &:hover { background: rgba(255,255,255,0.5); }

      &.left { left: 8px; }
      &.right { right: 8px; }
    }

    .preview-empty {
      height: 150px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 8px;
      background: #f5f7fa;
      color: #999;
      font-size: 14px;
    }
  }
}

/* ---- Table row preview ---- */
.row-preview {
  width: 230px;
  height: 60px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  padding: 0 16px;
  color: #fff;

  .row-preview-text {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .row-preview-title {
    font-size: 14px;
    font-weight: 700;
  }

  .row-preview-sub {
    font-size: 11px;
    opacity: 0.8;
  }
}

.table-card {
  padding: 20px;
}

.text-hint { color: #999; }

.pagination-wrap {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

/* ---- Dialog ---- */
.upload-hint {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #999;
  margin-top: 6px;
}

.gradient-row {
  display: flex;
  gap: 8px;
  align-items: center;
}

.gradient-presets {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-top: 8px;
  flex-wrap: wrap;

  .preset-label {
    font-size: 12px;
    color: #999;
    margin-right: 2px;
  }

  .preset-dot {
    width: 24px;
    height: 24px;
    border-radius: 6px;
    cursor: pointer;
    border: 2px solid transparent;
    transition: all 0.2s;

    &:hover {
      border-color: #5B6CFF;
      transform: scale(1.15);
    }
  }
}

.dialog-preview {
  width: 100%;
  height: 100px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  padding: 0 24px;
  color: #fff;

  .dialog-preview-text {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .dialog-preview-title {
    font-size: 18px;
    font-weight: 700;
    letter-spacing: 0.5px;
  }

  .dialog-preview-sub {
    font-size: 13px;
    opacity: 0.8;
  }
}
</style>
