<template>
  <div class="manage-page">
    <div class="card-header">
      <h2 class="section-title">学术研学管理</h2>
      <div class="header-right">
        <span class="count-text">共 {{ total }} 条</span>
        <el-button type="primary" :icon="Plus" @click="openDialog()">新增研学</el-button>
      </div>
    </div>

    <!-- Filters -->
    <div class="filter-card glass-card">
      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="国家">
          <el-select v-model="filters.country" placeholder="全部" clearable style="width:120px" @change="fetchData">
            <el-option label="中国" value="中国" />
            <el-option label="美国" value="美国" />
            <el-option label="欧洲" value="欧洲" />
            <el-option label="英国" value="英国" />
            <el-option label="东南亚" value="东南亚" />
          </el-select>
        </el-form-item>
        <el-form-item label="时间">
          <el-select v-model="filters.season" placeholder="全部" clearable style="width:100px" @change="fetchData">
            <el-option label="春假" value="春假" />
            <el-option label="暑假" value="暑假" />
            <el-option label="秋季" value="秋季" />
            <el-option label="寒假" value="寒假" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filters.status" placeholder="全部" clearable style="width:120px" @change="fetchData">
            <el-option label="招生中" value="open" />
            <el-option label="名额紧张" value="almost_full" />
            <el-option label="已满额" value="full" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="filters.keyword" placeholder="搜索标题" clearable style="width:180px" @clear="fetchData" @keyup.enter="fetchData" />
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
            <el-image v-if="row.poster" :src="row.poster" fit="cover" style="width:70px;height:46px;border-radius:6px" :preview-src-list="[row.poster]" :preview-teleported="true" />
            <span v-else class="text-hint">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column prop="titleCn" label="研学标题" min-width="180" show-overflow-tooltip />
        <el-table-column label="国家" width="80" align="center">
          <template #default="{ row }"><el-tag size="small" effect="plain">{{ row.country || '-' }}</el-tag></template>
        </el-table-column>
        <el-table-column label="时间" width="70" align="center">
          <template #default="{ row }"><el-tag size="small" effect="plain" type="success">{{ row.season || '-' }}</el-tag></template>
        </el-table-column>
        <el-table-column label="地点" width="120" show-overflow-tooltip>
          <template #default="{ row }"><span class="text-hint">{{ row.location || '-' }}</span></template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="statusType(row.status)">{{ statusMap[row.status] || '-' }}</el-tag>
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
          v-model:current-page="currentPage" v-model:page-size="pageSize"
          :page-sizes="[10,20,50]" :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="fetchData" @current-change="fetchData"
        />
      </div>
    </div>

    <!-- Dialog -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑研学' : '新增研学'" width="960px" :close-on-click-modal="false" top="2vh">
      <el-tabs v-model="activeTab" type="border-card">
        <!-- ==================== Tab 1: 卡片信息 ==================== -->
        <el-tab-pane label="卡片信息" name="card">
          <!-- 小程序卡片预览 -->
          <div class="mp-preview-bar">
            <div class="mp-preview-label">
              <el-icon><View /></el-icon> 小程序卡片预览
            </div>
            <div class="mp-card">
              <div class="mp-card-thumb" :style="{ backgroundImage: form.poster ? `url(${form.poster})` : 'none' }">
                <div v-if="!form.poster" class="mp-thumb-empty"><el-icon :size="22"><Picture /></el-icon></div>
                <div class="mp-status" :class="statusClass(form.status)">{{ statusMap[form.status] || '招生中' }}</div>
              </div>
              <div class="research-card-info">
                <div class="research-card-title">{{ form.titleCn || '研学标题' }}</div>
                <div class="research-card-title-en">{{ form.titleEn || 'English Title' }}</div>
                <div class="research-card-meta">
                  <div class="research-card-meta-item"><span class="m-label">带队导师：</span><span class="m-val">{{ form.instructorName || '-' }}</span></div>
                </div>
                <div class="research-card-row">
                  <span class="m-label">导师院校：</span><span class="m-val">{{ form.instructorTitle || '-' }}</span>
                </div>
                <div class="research-card-row">
                  <span class="m-label">招生对象：</span><span class="m-val">{{ form.targetAudience || '-' }}</span>
                  <span class="research-mode-tag">研学</span>
                </div>
                <div class="research-card-tags">
                  <span class="research-card-tag" v-for="t in researchTags" :key="t">{{ t }}</span>
                </div>
              </div>
            </div>
          </div>

          <el-form ref="formRef" :model="form" label-width="100px">
            <el-divider content-position="left">基本信息</el-divider>
            <el-row :gutter="16">
              <el-col :span="12">
                <el-form-item label="研学标题" prop="titleCn" :rules="[{ required:true, message:'请输入标题' }]">
                  <el-input v-model="form.titleCn" placeholder="如：暑期科研集训营 · 清华大学" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="英文标题">
                  <el-input v-model="form.titleEn" placeholder="English Title" />
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="16">
              <el-col :span="8">
                <el-form-item label="国家/地区">
                  <el-select v-model="form.country" style="width:100%" clearable>
                    <el-option label="中国" value="中国" />
                    <el-option label="美国" value="美国" />
                    <el-option label="欧洲" value="欧洲" />
                    <el-option label="英国" value="英国" />
                    <el-option label="东南亚" value="东南亚" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="时间/季节">
                  <el-select v-model="form.season" style="width:100%" clearable>
                    <el-option label="春假" value="春假" />
                    <el-option label="暑假" value="暑假" />
                    <el-option label="秋季" value="秋季" />
                    <el-option label="寒假" value="寒假" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="状态">
                  <el-select v-model="form.status" style="width:100%">
                    <el-option label="招生中" value="open" />
                    <el-option label="名额紧张" value="almost_full" />
                    <el-option label="已满额" value="full" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="16">
              <el-col :span="8">
                <el-form-item label="带队导师">
                  <el-input v-model="form.instructorName" placeholder="如：张教授" />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="导师院校">
                  <el-input v-model="form.instructorTitle" placeholder="如：清华大学" />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="院校">
                  <el-input v-model="form.school" placeholder="院校名称" />
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="16">
              <el-col :span="8">
                <el-form-item label="项目地点">
                  <el-input v-model="form.location" placeholder="如：清华大学校内" />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="项目时长">
                  <el-input v-model="form.duration" placeholder="如：2周" />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="招生对象">
                  <el-input v-model="form.targetAudience" placeholder="如：高中生 / 本科生" />
                </el-form-item>
              </el-col>
            </el-row>
            <el-form-item label="卡片描述">
              <el-input v-model="form.description" type="textarea" :rows="2" placeholder="研学简短描述" />
            </el-form-item>
            <el-form-item label="封面图">
              <el-input v-model="form.poster" placeholder="封面图片URL">
                <template #append>
                  <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'poster')" :on-error="handleUploadError" accept="image/*">
                    <el-button :icon="Upload">上传</el-button>
                  </el-upload>
                </template>
              </el-input>
              <div class="upload-hint">建议尺寸 750×420px</div>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- ==================== Tab 2: 详情页信息 ==================== -->
        <el-tab-pane label="详情页信息" name="detail">
          <div class="detail-editor-layout">
            <div class="detail-editor-form">
              <el-collapse v-model="activeSections">
                <el-collapse-item title="项目介绍 / Program Overview" name="sec1">
                  <el-form-item label="详情宣传图">
                    <el-input v-model="form.detailPoster" placeholder="详情页顶部大图URL（留空则使用封面图）">
                      <template #append>
                        <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'detailPoster')" :on-error="handleUploadError" accept="image/*">
                          <el-button :icon="Upload">上传</el-button>
                        </el-upload>
                      </template>
                    </el-input>
                  </el-form-item>
                  <el-form-item label="介绍内容">
                    <el-input v-model="form.introduction" type="textarea" :rows="4" placeholder="项目介绍详情" />
                  </el-form-item>
                </el-collapse-item>
                <el-collapse-item title="项目信息 / Program Details" name="sec2">
                  <el-row :gutter="16">
                    <el-col :span="12">
                      <el-form-item label="招生人数">
                        <el-input-number v-model="form.maxEnrollment" :min="1" :max="999" placeholder="限额" style="width:100%" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="项目时长">
                        <el-input v-model="form.duration" placeholder="如：2周" />
                      </el-form-item>
                    </el-col>
                  </el-row>
                </el-collapse-item>
                <el-collapse-item title="日程安排 / Schedule" name="sec3">
                  <el-form-item label="日程安排">
                    <el-input v-model="form.schedule" type="textarea" :rows="5" placeholder="日程安排详情" />
                  </el-form-item>
                </el-collapse-item>
                <el-collapse-item title="项目须知 / Program Guidelines" name="sec4">
                  <el-form-item label="报名须知">
                    <el-input v-model="form.notice" type="textarea" :rows="4" placeholder="报名时间、申请材料、注意事项等" />
                  </el-form-item>
                </el-collapse-item>
                <el-collapse-item title="其他资料 / Materials" name="sec5">
                  <el-form-item label="学术研学大纲PDF">
                    <el-input v-model="form.syllabusPdf" placeholder="PDF地址">
                      <template #append>
                        <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'syllabusPdf')" :on-error="handleUploadError" accept=".pdf">
                          <el-button :icon="Upload">上传</el-button>
                        </el-upload>
                      </template>
                    </el-input>
                  </el-form-item>
                  <el-form-item label="学术研学成果PDF">
                    <el-input v-model="form.achievementPdf" placeholder="PDF地址">
                      <template #append>
                        <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'achievementPdf')" :on-error="handleUploadError" accept=".pdf">
                          <el-button :icon="Upload">上传</el-button>
                        </el-upload>
                      </template>
                    </el-input>
                  </el-form-item>
                </el-collapse-item>
              </el-collapse>
            </div>

            <!-- 小程序详情页预览 -->
            <div class="detail-preview-panel">
              <div class="mp-detail-preview">
                <div class="mp-detail-label">
                  <el-icon><View /></el-icon> 小程序详情页预览
                </div>
                <div class="mp-detail-phone">
                  <!-- Hero -->
                  <div class="mp-detail-hero-wide" :style="{ backgroundImage: (form.detailPoster || form.poster) ? `url(${form.detailPoster || form.poster})` : 'none' }">
                    <div v-if="!form.detailPoster && !form.poster" class="mp-detail-hero-empty">
                      <el-icon :size="24"><Picture /></el-icon>
                      <span>宣传图</span>
                    </div>
                  </div>
                  <!-- 主信息框 -->
                  <div class="mp-detail-sec">
                    <div class="research-hero-title">{{ form.titleCn || '研学标题' }}</div>
                    <div class="research-hero-title-en">{{ form.titleEn || 'English Title' }}</div>
                    <div class="research-hero-tags">
                      <span class="research-hero-tag gray">研学项目</span>
                      <span class="research-hero-tag green">{{ form.country || '国家' }}</span>
                      <span class="research-hero-tag orange">定制</span>
                    </div>
                  </div>
                  <!-- 各section -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">项目介绍</span><span class="mp-detail-sec-en">Program Overview</span></div>
                    <div class="mp-detail-body-text" :class="{ collapsed: !previewExpand.intro }">{{ form.introduction || '项目介绍内容...' }}</div>
                    <div class="mp-detail-expand" v-if="form.introduction && form.introduction.length > 60" @click="previewExpand.intro = !previewExpand.intro">
                      {{ previewExpand.intro ? '收起' : '展开全部' }}
                    </div>
                  </div>
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">项目信息</span><span class="mp-detail-sec-en">Program Details</span></div>
                    <div class="research-info-list">
                      <div class="research-info-row"><span class="ri-label">带队导师</span><span class="ri-val">{{ form.instructorName || '-' }}</span></div>
                      <div class="research-info-row"><span class="ri-label">导师院校</span><span class="ri-val">{{ form.instructorTitle || '-' }}</span></div>
                      <div class="research-info-row"><span class="ri-label">报名对象</span><span class="ri-val">{{ form.targetAudience || '-' }}</span></div>
                      <div class="research-info-row"><span class="ri-label">项目地点</span><span class="ri-val">{{ form.location || '-' }}</span></div>
                      <div class="research-info-row"><span class="ri-label">项目时长</span><span class="ri-val">{{ form.duration || '-' }}</span></div>
                      <div class="research-info-row"><span class="ri-label">招生人数</span><span class="ri-val">{{ form.maxEnrollment ? '限' + form.maxEnrollment + '人' : '-' }}</span></div>
                    </div>
                  </div>
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">日程安排</span><span class="mp-detail-sec-en">Schedule</span></div>
                    <div class="mp-detail-body-text">{{ form.schedule || '日程安排...' }}</div>
                  </div>
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">项目须知</span><span class="mp-detail-sec-en">Program Guidelines</span></div>
                    <div class="mp-detail-body-text">{{ form.notice || '项目须知...' }}</div>
                  </div>
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">其他资料</span><span class="mp-detail-sec-en">Materials</span></div>
                    <div class="mp-pdf-item" v-if="form.syllabusPdf">
                      <span class="mp-pdf-icon">📄</span>
                      <span class="mp-pdf-name">学术研学大纲 / ACADEMIC FIELD SYLLABUS</span>
                    </div>
                    <div class="mp-pdf-item" v-if="form.achievementPdf">
                      <span class="mp-pdf-icon">📄</span>
                      <span class="mp-pdf-name">学术研学成果 / ACADEMIC FIELD OUTPUTS</span>
                    </div>
                    <div class="mp-detail-body-text" v-if="!form.syllabusPdf && !form.achievementPdf">暂无资料</div>
                  </div>
                  <div style="height:30px;"></div>
                </div>
              </div>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Edit, Delete, Upload, View, Picture } from '@element-plus/icons-vue'
import { getResearchList, createResearch, updateResearch, deleteResearch } from '@/api/research'

const statusMap = { open: '招生中', almost_full: '名额紧张', full: '已满额' }
const statusType = (s) => ({ open: 'success', almost_full: 'warning', full: 'danger' }[s] || 'info')
const statusClass = (s) => ({ open: 'open', almost_full: 'almost', full: 'full' }[s] || 'open')

const uploadUrl = '/api/file/upload'
const uploadHeaders = computed(() => {
  const token = localStorage.getItem('admin_token')
  return token ? { Authorization: `Bearer ${token}` } : {}
})

// Filters
const filters = ref({ country: '', season: '', status: '', keyword: '' })

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
const activeTab = ref('card')
const activeSections = ref(['sec1', 'sec2', 'sec3', 'sec4', 'sec5'])
const previewExpand = reactive({ intro: false })

const formRef = ref(null)

// Research tags derived from form fields
const researchTags = computed(() => {
  const tags = []
  if (form.value.country) tags.push(form.value.country)
  if (form.value.season) tags.push(form.value.season)
  tags.push('定制')
  return tags
})

const defaultForm = {
  titleCn: '', titleEn: '', description: '',
  country: '', season: '', instructorName: '', instructorTitle: '', school: '',
  targetAudience: '', poster: '', status: 'open',
  location: '', duration: '', maxEnrollment: 30,
  schedule: '', notice: '', syllabusPdf: '', achievementPdf: '',
  detailPoster: '', introduction: ''
}

const form = ref({ ...defaultForm })

onMounted(() => fetchData())

async function fetchData() {
  loading.value = true
  try {
    const params = { page: currentPage.value, size: pageSize.value }
    if (filters.value.country) params.country = filters.value.country
    if (filters.value.season) params.season = filters.value.season
    if (filters.value.status) params.status = filters.value.status
    if (filters.value.keyword) params.keyword = filters.value.keyword
    const res = await getResearchList(params)
    tableData.value = res.records
    total.value = res.total
  } catch { /* handled by interceptor */ } finally { loading.value = false }
}

function openDialog(row) {
  activeTab.value = 'card'
  activeSections.value = ['sec1', 'sec2', 'sec3', 'sec4', 'sec5']
  previewExpand.intro = false

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
      await updateResearch(editId.value, form.value)
      ElMessage.success('研学更新成功')
    } else {
      await createResearch(form.value)
      ElMessage.success('研学创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } catch { /* handled by interceptor */ } finally { submitting.value = false }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定要删除「${row.titleCn}」吗？`, '删除确认', { type: 'warning' })
  try {
    await deleteResearch(row.id)
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

function handleUploadError(err) {
  console.error('Upload error:', err)
  ElMessage.error('上传失败，请确保后端服务已启动')
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
:deep(.el-tabs__content) { padding: 12px 16px; max-height: 62vh; overflow-y: auto; }

/* ======== Card Preview (matching mini-program research.vue) ======== */
.mp-preview-bar {
  background: #f0f2f5; border-radius: 10px; padding: 12px 14px; margin-bottom: 16px;
  .mp-preview-label { font-size: 13px; color: #666; display: flex; align-items: center; gap: 4px; margin-bottom: 10px; }
}
.mp-card {
  display: flex; gap: 10px;
  background: rgba(255,255,255,0.5); backdrop-filter: blur(12px);
  border-radius: 12px; padding: 6px 10px 2px 8px;
  border: 1px solid rgba(255,255,255,0.6);
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  height: 190px; overflow: hidden; align-items: flex-start;
  max-width: 350px; margin: 0 auto;
}
.mp-card-thumb {
  width: 110px; height: 172px; border-radius: 12px; background-color: #eee;
  background-size: cover; background-position: center; flex-shrink: 0; position: relative;
  display: flex; align-items: center; justify-content: center;
}
.mp-thumb-empty { color: #ccc; }
.mp-status {
  position: absolute; top: 0; left: 0; padding: 3px 8px;
  border-radius: 0 0 6px 0; font-size: 10px; font-weight: 600; color: #fff; white-space: nowrap;
  &.open { background: rgba(91,108,255,0.75); backdrop-filter: blur(4px); }
  &.almost { background: rgba(240,160,32,0.75); backdrop-filter: blur(4px); }
  &.full { background: rgba(224,80,80,0.75); backdrop-filter: blur(4px); }
}

/* Research card info (matching mini-program research.vue card) */
.research-card-info {
  flex: 1; display: flex; flex-direction: column; gap: 6px; min-width: 0; padding-left: 8px;
}
.research-card-title {
  font-size: 13px; font-weight: 700; color: #333; line-height: 1.5;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
  overflow: hidden; text-align: left; margin-bottom: 8px;
}
.research-card-title-en {
  font-size: 10px; color: #5B6CFF; font-weight: 600; text-transform: uppercase;
  letter-spacing: 0.3px; text-align: left;
}
.research-card-meta { display: flex; flex-direction: column; gap: 0; }
.research-card-meta-item { display: flex; gap: 4px; font-size: 11px; line-height: 1.4;
  .m-label { color: #999; }
  .m-val { color: #555; font-weight: 500; }
}
.research-card-row { display: flex; align-items: center; gap: 6px; font-size: 11px; color: #999; margin-top: 2px;
  .m-label { color: #999; flex-shrink: 0; }
  .m-val { color: #555; font-weight: 500; }
}
.research-mode-tag {
  font-size: 10px; padding: 2px 8px; border-radius: 10px; font-weight: 500;
  background: #e6f4f2; color: #5B6CFF; flex-shrink: 0; margin-left: auto;
}
.research-card-tags {
  display: flex; flex-wrap: wrap; gap: 4px; max-height: 44px; overflow: hidden;
}
.research-card-tag {
  font-size: 10px; padding: 3px 8px; border-radius: 3px;
  background: #f0f6f5; color: #5B6CFF; white-space: nowrap;
}

/* ======== Detail Editor Layout ======== */
.detail-editor-layout {
  display: flex; gap: 16px; height: 58vh;
  .detail-editor-form {
    flex: 1; overflow-y: auto; padding-right: 4px;
    &::-webkit-scrollbar { width: 4px; }
    &::-webkit-scrollbar-thumb { background: #ddd; border-radius: 2px; }
    :deep(.el-collapse-item__header) { font-weight: 600; font-size: 14px; color: #333; }
    :deep(.el-collapse-item__content) { padding-bottom: 8px; }
    :deep(.el-form-item) { margin-bottom: 10px; }
    :deep(.el-form-item__label) { font-weight: 500; }
  }
  .detail-preview-panel { width: 340px; flex-shrink: 0; }
}

/* ======== Detail Page Preview ======== */
.mp-detail-preview {
  background: #eef1f5; border-radius: 10px; padding: 8px;
  .mp-detail-label { font-size: 12px; color: #888; display: flex; align-items: center; gap: 4px; margin-bottom: 8px; padding: 0 4px; }
}
.mp-detail-phone {
  background: #fff; border-radius: 8px; max-height: 52vh; overflow-y: auto; box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  &::-webkit-scrollbar { width: 3px; }
  &::-webkit-scrollbar-thumb { background: #ddd; border-radius: 2px; }
}
.mp-detail-hero-wide {
  width: 100%; height: 84px; background-size: cover; background-position: center; background-color: #e0e0e0;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 8px 8px 0 0;
}
.mp-detail-hero-empty { display: flex; flex-direction: column; align-items: center; gap: 2px; color: #ccc; font-size: 11px; }

.mp-detail-sec {
  padding: 10px 12px; border-bottom: 1px solid #f0f0f0;
  &:last-child { border-bottom: none; }
}
.mp-detail-sec-title {
  display: flex; align-items: baseline; gap: 6px; margin-bottom: 6px;
  padding-left: 8px; border-left: 3px solid #5B6CFF;
  .mp-detail-sec-zh { font-size: 13px; font-weight: 700; color: #333; }
  .mp-detail-sec-en { font-size: 10px; color: #5B6CFF; font-weight: 600; text-transform: uppercase; }
}
.mp-detail-body-text { font-size: 11px; color: #666; line-height: 1.6; white-space: pre-line;
  &.collapsed { max-height: 44px; overflow: hidden; }
}
.mp-detail-expand { font-size: 11px; color: #5B6CFF; text-align: center; margin-top: 4px; cursor: pointer; }

/* Research hero main box styles */
.research-hero-title { font-size: 14px; font-weight: 700; color: #333; line-height: 1.4; }
.research-hero-title-en { font-size: 10px; color: #5B6CFF; font-weight: 600; text-transform: uppercase; margin-top: 6px; display: block; }
.research-hero-tags { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 8px; }
.research-hero-tag {
  font-size: 10px; padding: 2px 6px; border-radius: 4px;
  &.gray { background: #f0f2f5; color: #666; }
  &.green { background: #e6f4f2; color: #5B6CFF; }
  &.orange { background: #fff3e0; color: #ff9800; }
}

/* Info list in detail preview */
.research-info-list { display: flex; flex-direction: column; gap: 10px; }
.research-info-row { display: flex; gap: 8px; font-size: 11px; color: #555; line-height: 1.6;
  .ri-label { color: #777; flex-shrink: 0; min-width: 60px; font-weight: 500; }
  .ri-val { color: #555; flex: 1; font-weight: 500; }
}

.mp-pdf-item { display: flex; align-items: center; gap: 8px; padding: 6px 10px; background: #fafbfc; border-radius: 8px; font-size: 11px; color: #444; margin-top: 4px; }
.mp-pdf-icon { flex-shrink: 0; font-size: 13px; }
.mp-pdf-name { flex: 1; }
</style>
