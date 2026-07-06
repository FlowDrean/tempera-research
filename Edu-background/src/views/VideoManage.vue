<template>
  <div class="manage-page">
    <div class="card-header">
      <h2 class="section-title">专访视频管理</h2>
      <div class="header-right">
        <span class="count-text">共 {{ total }} 条</span>
        <el-button type="primary" :icon="Plus" @click="openDialog()">新增视频</el-button>
      </div>
    </div>

    <!-- Filters -->
    <div class="filter-card glass-card">
      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="分类">
          <el-select v-model="filters.category" placeholder="全部" clearable style="width:140px" @change="fetchData">
            <el-option label="教授专访" value="教授专访" />
            <el-option label="学员分享" value="学员分享" />
            <el-option label="科研纪实" value="科研纪实" />
            <el-option label="学术讲座" value="学术讲座" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="filters.keyword" placeholder="搜索标题" clearable style="width:200px" @clear="fetchData" @keyup.enter="fetchData" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">搜索</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- Table -->
    <div class="table-card glass-card">
      <el-table :data="tableData" v-loading="loading" stripe :header-cell-style="{ background:'#f5f7fa',color:'#333',fontWeight:600 }">
        <el-table-column label="封面" width="100">
          <template #default="{ row }">
            <el-image v-if="row.cover" :src="row.cover" fit="cover" style="width:70px;height:46px;border-radius:6px" :preview-src-list="[row.cover]" :preview-teleported="true" />
            <span v-else class="text-hint">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="id" label="ID" width="60" align="center" />
        <el-table-column prop="title" label="视频标题" min-width="180" show-overflow-tooltip />
        <el-table-column label="教授" width="100" align="center">
          <template #default="{ row }">
            <span>{{ row.professorName || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="院校" width="120" align="center" show-overflow-tooltip>
          <template #default="{ row }">
            <span>{{ row.professorSchool || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="时长" width="80" align="center">
          <template #default="{ row }">{{ row.duration || '-' }}</template>
        </el-table-column>
        <el-table-column label="分类" width="100" align="center">
          <template #default="{ row }"><el-tag size="small" effect="plain">{{ row.category || '-' }}</el-tag></template>
        </el-table-column>
        <el-table-column label="播放量" width="80" align="center">
          <template #default="{ row }">{{ row.views || 0 }}</template>
        </el-table-column>
        <el-table-column label="排序" width="60" align="center">
          <template #default="{ row }">{{ row.sortOrder ?? '-' }}</template>
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
          v-model:current-page="currentPage" v-model:page-size="pageSize"
          :page-sizes="[10,20,50]" :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="fetchData" @current-change="fetchData"
        />
      </div>
    </div>

    <!-- Dialog -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑视频' : '新增视频'" width="900px" :close-on-click-modal="false" top="2vh">
      <div class="video-dialog-content">
        <!-- 小程序卡片预览 -->
        <div class="mp-preview-bar">
          <div class="mp-preview-label">
            <el-icon><View /></el-icon> 小程序卡片预览
          </div>
          <div class="mp-video-card">
            <div class="mp-video-thumb" :style="{ backgroundImage: form.cover ? `url(${form.cover})` : 'none' }">
              <div v-if="!form.cover" class="mp-thumb-empty"><el-icon :size="22"><Picture /></el-icon></div>
              <div class="mp-video-duration" v-if="form.duration">{{ form.duration }}</div>
            </div>
            <div class="mp-video-info">
              <div class="mp-video-title">{{ form.title || '视频标题' }}</div>
              <div class="mp-video-meta">
                <span>{{ form.professorName || '教授' }} · {{ form.professorSchool || '院校' }}</span>
              </div>
              <div class="mp-video-meta">
                <span class="mp-video-views">{{ form.views || 0 }}次播放</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 小程序详情页预览 -->
        <div class="mp-preview-bar">
          <div class="mp-preview-label">
            <el-icon><View /></el-icon> 小程序详情页预览
          </div>
          <div class="mp-detail-preview">
            <!-- 视频播放区 -->
            <div class="mp-detail-video" :style="{ backgroundImage: form.cover ? `url(${form.cover})` : 'none' }">
              <div v-if="!form.cover" class="mp-detail-video-empty"><el-icon :size="28"><VideoCamera /></el-icon></div>
              <div class="mp-detail-video-controls">
                <span class="mp-detail-time">00:00 / {{ form.duration || '--:--' }}</span>
              </div>
            </div>
            <!-- 视频信息 -->
            <div class="mp-detail-info">
              <div class="mp-detail-title">{{ form.title || '视频标题' }}</div>
              <div class="mp-detail-title-en">{{ form.titleEn || 'English Title' }}</div>
              <div class="mp-detail-author">{{ form.professorName || '教授' }} · {{ form.professorSchool || '院校' }}</div>
              <div class="mp-detail-views">播放量 {{ form.views || 0 }}</div>
            </div>
            <!-- 切换Tab -->
            <div class="mp-detail-tabs">
              <div class="mp-detail-tab" :class="{ active: previewTab === 'intro' }" @click="previewTab = 'intro'">专访简介</div>
              <div class="mp-detail-tab" :class="{ active: previewTab === 'professor' }" @click="previewTab = 'professor'">教授介绍</div>
            </div>
            <!-- Tab内容 -->
            <div class="mp-detail-section" v-show="previewTab === 'intro'">
              <div class="mp-detail-section-title"><span class="zh">专访简介</span><span class="en">Interview Profile</span></div>
              <div class="mp-detail-section-content">{{ form.description || '暂无简介内容' }}</div>
            </div>
            <div class="mp-detail-section" v-show="previewTab === 'professor'">
              <div class="mp-detail-section-title"><span class="zh">教授介绍</span><span class="en">Faculty Profile</span></div>
              <div class="mp-detail-professor">
                <div class="mp-detail-prof-avatar" :style="{ backgroundImage: form.professorAvatar ? `url(${form.professorAvatar})` : 'none' }">
                  <el-icon :size="20" v-if="!form.professorAvatar"><User /></el-icon>
                </div>
                <div class="mp-detail-prof-info">
                  <div class="mp-detail-prof-name">{{ form.professorName || '教授姓名' }}</div>
                  <div class="mp-detail-prof-bio">{{ form.professorBio || '暂无教授简介' }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <el-form ref="formRef" :model="form" label-width="100px">
          <el-divider content-position="left">基本信息</el-divider>
          <el-row :gutter="16">
            <el-col :span="14">
              <el-form-item label="视频标题" prop="title" :rules="[{ required:true, message:'请输入标题' }]">
                <el-input v-model="form.title" placeholder="中文标题" />
              </el-form-item>
            </el-col>
            <el-col :span="10">
              <el-form-item label="英文标题">
                <el-input v-model="form.titleEn" placeholder="English Title" />
              </el-form-item>
            </el-col>
          </el-row>

          <el-form-item label="视频URL" prop="url" :rules="[{ required:true, message:'请输入视频地址' }]">
            <el-input v-model="form.url" placeholder="视频播放地址（支持 .mp4 / 腾讯视频 / B站嵌入链接等）">
              <template #append>
                <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :before-upload="beforeVideoUpload" :on-progress="() => uploadingVideo = true" :on-success="(r) => handleVideoUpload(r, 'url')" :on-error="handleVideoUploadError" accept="video/mp4">
                  <el-button :icon="Upload" :loading="uploadingVideo">上传视频</el-button>
                </el-upload>
              </template>
            </el-input>
            <div class="upload-hint">支持 .mp4 格式，单文件最大 100MB，建议压缩后再上传</div>
          </el-form-item>

          <el-row :gutter="16">
            <el-col :span="12">
              <el-form-item label="封面图">
                <el-input v-model="form.cover" placeholder="视频封面图片URL">
                  <template #append>
                    <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'cover')" :on-error="handleUploadError" accept="image/*">
                      <el-button :icon="Upload">上传</el-button>
                    </el-upload>
                  </template>
                </el-input>
                <div class="upload-hint">建议尺寸 750×420px</div>
              </el-form-item>
            </el-col>
            <el-col :span="6">
              <el-form-item label="时长">
                <el-input v-model="form.duration" placeholder="如：12:30" />
              </el-form-item>
            </el-col>
            <el-col :span="6">
              <el-form-item label="分类">
                <el-select v-model="form.category" style="width:100%" clearable placeholder="选择分类">
                  <el-option label="教授专访" value="教授专访" />
                  <el-option label="学员分享" value="学员分享" />
                  <el-option label="科研纪实" value="科研纪实" />
                  <el-option label="学术讲座" value="学术讲座" />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>

          <el-divider content-position="left">教授信息</el-divider>
          <el-row :gutter="16">
            <el-col :span="8">
              <el-form-item label="教授姓名">
                <el-input v-model="form.professorName" placeholder="如：张教授" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="所在院校">
                <el-input v-model="form.professorSchool" placeholder="如：清华大学" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="教授头像">
                <el-input v-model="form.professorAvatar" placeholder="头像URL">
                  <template #append>
                    <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'professorAvatar')" :on-error="handleUploadError" accept="image/*">
                      <el-button :icon="Upload">上传</el-button>
                    </el-upload>
                  </template>
                </el-input>
              </el-form-item>
            </el-col>
          </el-row>

          <el-row :gutter="16">
            <el-col :span="12">
              <el-form-item label="视频描述">
                <el-input v-model="form.description" type="textarea" :rows="3" placeholder="视频内容简介" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="教授简介">
                <el-input v-model="form.professorBio" type="textarea" :rows="3" placeholder="教授个人简介" />
              </el-form-item>
            </el-col>
          </el-row>

          <el-divider content-position="left">其他设置</el-divider>
          <el-row :gutter="16">
            <el-col :span="8">
              <el-form-item label="排序序号">
                <el-input-number v-model="form.sortOrder" :min="0" :max="9999" style="width:100%" placeholder="越小越靠前" />
              </el-form-item>
            </el-col>
          </el-row>
        </el-form>
      </div>

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
import { Plus, Edit, Delete, Upload, View, Picture, VideoCamera, User } from '@element-plus/icons-vue'
import { getVideoList, createVideo, updateVideo, deleteVideo } from '@/api/video'

const uploadUrl = '/api/file/upload'
const uploadHeaders = computed(() => {
  const token = localStorage.getItem('admin_token')
  return token ? { Authorization: `Bearer ${token}` } : {}
})

// Filters
const filters = ref({ category: '', keyword: '' })

// Table
const tableData = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// Dialog
const dialogVisible = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const submitting = ref(false)
const uploadingVideo = ref(false)
const previewTab = ref('intro')

const formRef = ref(null)

const defaultForm = {
  title: '', titleEn: '', url: '', cover: '', duration: '',
  professorName: '', professorSchool: '', description: '', professorBio: '', professorAvatar: '',
  category: '', sortOrder: 0, views: 0
}

const form = ref({ ...defaultForm })

onMounted(() => fetchData())

async function fetchData() {
  loading.value = true
  try {
    const params = { page: currentPage.value, size: pageSize.value }
    if (filters.value.category) params.category = filters.value.category
    if (filters.value.keyword) params.keyword = filters.value.keyword
    const res = await getVideoList(params)
    tableData.value = res.records
    total.value = res.total
  } catch { /* handled by interceptor */ } finally { loading.value = false }
}

function openDialog(row) {
  previewTab.value = 'intro'
  if (row) {
    isEdit.value = true
    editId.value = row.id
    form.value = { ...defaultForm, ...Object.fromEntries(Object.entries(row).filter(([_, v]) => v !== null && v !== undefined)) }
  } else {
    isEdit.value = false
    editId.value = null
    form.value = { ...defaultForm }
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (valid === false) return

  submitting.value = true
  try {
    if (isEdit.value) {
      await updateVideo(editId.value, form.value)
      ElMessage.success('视频更新成功')
    } else {
      await createVideo(form.value)
      ElMessage.success('视频创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } catch { /* handled by interceptor */ } finally { submitting.value = false }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定要删除视频「${row.title}」吗？`, '删除确认', { type: 'warning' })
  try {
    await deleteVideo(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch { /* cancelled */ }
}

function handleImgUpload(response, field) {
  if (response.code === 200 && response.data?.url) {
    form.value[field] = response.data.url
    ElMessage.success('上传成功')
  } else {
    ElMessage.error(response.message || '上传失败')
  }
}

function beforeVideoUpload(file) {
  const maxSize = 100 * 1024 * 1024 // 100MB
  if (file.size > maxSize) {
    ElMessage.error(`视频文件过大，单文件最大 ${Math.round(maxSize / 1024 / 1024)}MB，请压缩后重试`)
    return false
  }
  const isMp4 = file.type === 'video/mp4' || file.name.toLowerCase().endsWith('.mp4')
  if (!isMp4) {
    ElMessage.error('仅支持 MP4 格式视频（微信小程序兼容性要求）')
    return false
  }
  return true
}

function handleVideoUpload(response, field) {
  uploadingVideo.value = false
  if (response.code === 200 && response.data?.url) {
    form.value[field] = response.data.url
    ElMessage.success('视频上传成功')
  } else {
    ElMessage.error(response.message || '视频上传失败')
  }
}

function handleVideoUploadError(err) {
  uploadingVideo.value = false
  console.error('Video upload error:', err)
  // 尝试解析错误信息
  let msg = '视频上传失败'
  if (err?.message) {
    msg += '：' + err.message
  } else if (err?.status) {
    msg += '（HTTP ' + err.status + '）'
  }
  if (err?.status === 413 || err?.message?.includes('size')) {
    msg = '视频文件过大，请压缩后重试（最大支持 500MB）'
  }
  ElMessage.error(msg)
}
</script>

<style lang="scss" scoped>
.manage-page {
  .card-header {
    display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;
    .header-right { display: flex; align-items: center; gap: 16px; }
    .count-text { font-size: 13px; color: #999; }
  }
}
.filter-card { padding: 16px 20px 0; margin-bottom: 16px; }
.filter-form { :deep(.el-form-item) { margin-bottom: 16px; } }
.table-card { padding: 20px; }
.text-hint { color: #999; }
.upload-hint { font-size: 12px; color: #999; margin-top: 6px; }
.pagination-wrap { display: flex; justify-content: flex-end; margin-top: 16px; }
.video-dialog-content { :deep(.el-divider__text) { font-weight: 600; color: #555; } }

/* ======== Card Preview ======== */
.mp-preview-bar {
  background: #f0f2f5; border-radius: 10px; padding: 12px 14px; margin-bottom: 16px;
  .mp-preview-label { font-size: 13px; color: #666; display: flex; align-items: center; gap: 4px; margin-bottom: 10px; }
}
.mp-video-card {
  display: flex; gap: 12px;
  background: rgba(255,255,255,0.5); backdrop-filter: blur(12px);
  border-radius: 12px; padding: 10px;
  border: 1px solid rgba(255,255,255,0.6);
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  max-width: 380px; margin: 0 auto; align-items: center;
}
.mp-video-thumb {
  width: 120px; height: 72px; border-radius: 8px; background-color: #eee;
  background-size: cover; background-position: center; flex-shrink: 0; position: relative;
  display: flex; align-items: center; justify-content: center;
}
.mp-thumb-empty { color: #ccc; }
.mp-video-duration {
  position: absolute; bottom: 4px; right: 4px;
  background: rgba(0,0,0,0.7); color: #fff; font-size: 10px;
  padding: 1px 6px; border-radius: 4px;
}
.mp-video-info {
  flex: 1; display: flex; flex-direction: column; gap: 4px; min-width: 0;
}
.mp-video-title {
  font-size: 14px; font-weight: 700; color: #333; line-height: 1.4;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.mp-video-meta { font-size: 11px; color: #888; }
.mp-video-views { color: #5B6CFF; font-weight: 500; }

/* ======== Detail Page Preview ======== */
.mp-detail-preview {
  max-width: 375px; margin: 0 auto; background: #eef1f5; border-radius: 12px; overflow: hidden;
}
.mp-detail-video {
  width: 100%; height: 160px; background-color: #222; background-size: cover; background-position: center;
  position: relative; display: flex; align-items: center; justify-content: center;
}
.mp-detail-video-empty { color: #888; }
.mp-detail-video-controls {
  position: absolute; bottom: 0; left: 0; right: 0; height: 28px;
  background: linear-gradient(transparent, rgba(0,0,0,0.7));
  display: flex; align-items: center; justify-content: flex-end; padding: 0 10px;
}
.mp-detail-time { color: #fff; font-size: 9px; }
.mp-detail-info {
  background: rgba(255,255,255,0.5); backdrop-filter: blur(12px); padding: 12px 14px; margin: 8px 8px 0;
  border-radius: 10px; border: 1px solid rgba(255,255,255,0.6);
}
.mp-detail-title { font-size: 14px; font-weight: 700; color: #333; line-height: 1.4; }
.mp-detail-title-en { font-size: 10px; color: #5B6CFF; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 3px; }
.mp-detail-author { font-size: 11px; color: #666; margin-top: 6px; }
.mp-detail-views { font-size: 10px; color: #999; margin-top: 2px; }
.mp-detail-tabs {
  display: flex; height: 34px; align-items: center;
  background: rgba(255,255,255,0.5); backdrop-filter: blur(12px); margin: 6px 8px 0;
  border-radius: 10px; border: 1px solid rgba(255,255,255,0.6);
}
.mp-detail-tab {
  flex: 1; text-align: center; font-size: 11px; color: #555; cursor: pointer; transition: all 0.2s;
  &:hover { color: #5B6CFF; }
  &.active { color: #5B6CFF; font-weight: 600; }
}
.mp-detail-section {
  background: rgba(255,255,255,0.5); backdrop-filter: blur(12px); padding: 12px 14px; margin: 6px 8px 10px;
  border-radius: 10px; border: 1px solid rgba(255,255,255,0.6);
}
.mp-detail-section-title {
  font-size: 12px; font-weight: 700; color: #333; margin-bottom: 10px; padding-left: 8px;
  position: relative; display: flex; align-items: baseline; gap: 8px; padding-bottom: 8px;
  border-bottom: 1px solid #e8e8e8;
  &::before { content: ''; position: absolute; left: 0; top: 2px; width: 3px; height: 14px; background: #5B6CFF; border-radius: 2px; }
  .zh { font-weight: 700; }
  .en { font-size: 9px; color: #5B6CFF; font-weight: 600; }
}
.mp-detail-section-content { font-size: 11px; color: #555; line-height: 1.6; white-space: pre-line; }
.mp-detail-professor { display: flex; gap: 10px; align-items: flex-start; }
.mp-detail-prof-avatar {
  width: 40px; height: 40px; border-radius: 50%; background-color: #ddd; flex-shrink: 0;
  background-size: cover; background-position: center; display: flex; align-items: center; justify-content: center; color: #aaa;
}
.mp-detail-prof-info { flex: 1; }
.mp-detail-prof-name { font-size: 11px; font-weight: 700; color: #333; }
.mp-detail-prof-bio { font-size: 10px; color: #666; margin-top: 4px; line-height: 1.5; }
</style>
