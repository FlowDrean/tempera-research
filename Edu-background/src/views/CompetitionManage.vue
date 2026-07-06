<template>
  <div class="manage-page">
    <div class="card-header">
      <h2 class="section-title">竞赛与写作管理</h2>
      <div class="header-right">
        <span class="count-text">共 {{ total }} 条</span>
        <el-button type="primary" :icon="Plus" @click="openDialog()">新增竞赛</el-button>
      </div>
    </div>

    <!-- Filters -->
    <div class="filter-card glass-card">
      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="竞赛类型">
          <el-select v-model="filters.category" placeholder="全部" clearable style="width:140px" @change="fetchData">
            <el-option label="国内竞赛" value="国内竞赛" />
            <el-option label="国际竞赛" value="国际竞赛" />
            <el-option label="国内写作" value="国内写作" />
            <el-option label="国际写作" value="国际写作" />
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
        <el-table-column prop="titleCn" label="竞赛标题" min-width="180" show-overflow-tooltip />
        <el-table-column label="竞赛类型" width="100" align="center">
          <template #default="{ row }"><el-tag size="small" effect="plain">{{ row.category || '-' }}</el-tag></template>
        </el-table-column>
        <el-table-column label="级别" width="80" align="center">
          <template #default="{ row }"><el-tag size="small" effect="plain" type="warning">{{ row.levelName || '-' }}</el-tag></template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="statusType(row.status)">{{ statusMap[row.status] || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="deadline" label="截止日期" width="110" align="center" />
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
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑竞赛' : '新增竞赛'" width="960px" :close-on-click-modal="false" top="2vh">
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
              <div class="comp-card-info">
                <div class="comp-card-title">{{ form.titleCn || '竞赛标题' }}</div>
                <div class="comp-card-title-en">{{ form.titleEn || 'English Title' }}</div>
                <div class="comp-card-meta">
                  <div class="comp-card-meta-item"><span class="m-label">导师</span><span class="m-val">{{ form.instructorName || '-' }}</span></div>
                  <div class="comp-card-meta-item"><span class="m-label">院校</span><span class="m-val">{{ form.school || '-' }}</span></div>
                  <div class="comp-card-meta-item"><span class="m-label">对象</span><span class="m-val">{{ form.targetAudience || '-' }}</span></div>
                  <div class="comp-card-meta-item"><span class="m-label">截止</span><span class="m-val deadline">{{ form.deadline || '-' }}</span></div>
                </div>
                <div class="comp-card-tags">
                  <span class="comp-card-tag gray">{{ form.category || '竞赛类型' }}</span>
                  <span class="comp-card-tag green">{{ form.levelName || '级别' }}</span>
                  <span class="comp-card-tag" :class="form.participantType === '个人' ? 'orange' : 'green'">{{ form.participantType || '个人/团队' }}</span>
                </div>
              </div>
            </div>
          </div>

          <el-form ref="formRef" :model="form" label-width="100px">
            <el-divider content-position="left">基本信息</el-divider>
            <el-row :gutter="16">
              <el-col :span="12">
                <el-form-item label="竞赛标题" prop="titleCn" :rules="[{ required:true, message:'请输入标题' }]">
                  <el-input v-model="form.titleCn" placeholder="中文标题" />
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
                <el-form-item label="竞赛类型">
                  <el-select v-model="form.category" style="width:100%" clearable>
                    <el-option label="国内竞赛" value="国内竞赛" />
                    <el-option label="国际竞赛" value="国际竞赛" />
                    <el-option label="国内写作" value="国内写作" />
                    <el-option label="国际写作" value="国际写作" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="级别">
                  <el-select v-model="form.levelName" style="width:100%" clearable>
                    <el-option label="国家级" value="国家级" />
                    <el-option label="国际级" value="国际级" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="个人/团体">
                  <el-select v-model="form.participantType" style="width:100%" clearable>
                    <el-option label="个人" value="个人" />
                    <el-option label="团队" value="团队" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="16">
              <el-col :span="8">
                <el-form-item label="导师姓名">
                  <el-input v-model="form.instructorName" placeholder="如：刘教授" />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="院校">
                  <el-input v-model="form.school" placeholder="如：清华大学" />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="招生对象">
                  <el-input v-model="form.targetAudience" placeholder="如：全国高校在校生" />
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="16">
              <el-col :span="8">
                <el-form-item label="状态">
                  <el-select v-model="form.status" style="width:100%">
                    <el-option label="招生中" value="open" />
                    <el-option label="名额紧张" value="almost_full" />
                    <el-option label="已满额" value="full" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="截止日期">
                  <el-date-picker v-model="form.deadline" type="date" placeholder="选择日期" format="YYYY-MM-DD" value-format="YYYY-MM-DD" style="width:100%" />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="主办方">
                  <el-input v-model="form.organizer" placeholder="主办单位" />
                </el-form-item>
              </el-col>
            </el-row>
            <el-form-item label="卡片描述">
              <el-input v-model="form.description" type="textarea" :rows="2" placeholder="竞赛简短描述" />
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
                <el-collapse-item title="项目介绍 / Program Introduction" name="sec1">
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
                <el-collapse-item title="项目信息 / Program Information" name="sec2">
                  <el-form-item label="项目信息">
                    <el-input v-model="form.infoText" type="textarea" :rows="4" placeholder="如：主办单位、参赛对象、竞赛形式等" />
                  </el-form-item>
                </el-collapse-item>
                <el-collapse-item title="竞赛规则 / Competition Rules" name="sec3">
                  <el-form-item label="竞赛规则">
                    <el-input v-model="form.rules" type="textarea" :rows="5" placeholder="竞赛规则详情" />
                  </el-form-item>
                </el-collapse-item>
                <el-collapse-item title="奖项设置 / Awards & Prizes" name="sec4">
                  <el-form-item label="奖项设置">
                    <el-input v-model="form.awards" type="textarea" :rows="4" placeholder="奖项设置详情" />
                  </el-form-item>
                </el-collapse-item>
                <el-collapse-item title="报名时间 / Registration Period" name="sec5">
                  <el-form-item label="报名信息">
                    <el-input v-model="form.deadlineText" type="textarea" :rows="3" placeholder="报名开始/截止时间等" />
                  </el-form-item>
                </el-collapse-item>
                <el-collapse-item title="其他资料 / Materials" name="sec6">
                  <el-form-item label="竞赛成果PDF">
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
                  <div class="mp-detail-hero" :style="{ backgroundImage: (form.detailPoster || form.poster) ? `url(${form.detailPoster || form.poster})` : 'none' }">
                    <div v-if="!form.detailPoster && !form.poster" class="mp-detail-hero-empty">
                      <el-icon :size="24"><Picture /></el-icon>
                      <span>宣传图</span>
                    </div>
                  </div>
                  <!-- 主信息框 -->
                  <div class="mp-detail-sec">
                    <div class="comp-hero-title">{{ form.titleCn || '竞赛标题' }}</div>
                    <div class="comp-hero-title-en">{{ form.titleEn || 'English Title' }}</div>
                    <div class="comp-hero-meta">
                      <div class="comp-hero-meta-item"><span class="m-label">导师</span><span class="m-val">{{ form.instructorName || '-' }}</span></div>
                      <div class="comp-hero-meta-item"><span class="m-label">院校</span><span class="m-val">{{ form.school || '-' }}</span></div>
                      <div class="comp-hero-meta-item"><span class="m-label">对象</span><span class="m-val">{{ form.targetAudience || '-' }}</span></div>
                      <div class="comp-hero-meta-item"><span class="m-label">截止</span><span class="m-val deadline">{{ form.deadline || '-' }}</span></div>
                    </div>
                    <div class="comp-hero-tags">
                      <span class="comp-hero-tag gray">{{ form.category || '竞赛类型' }}</span>
                      <span class="comp-hero-tag green">{{ form.levelName || '级别' }}</span>
                      <span class="comp-hero-tag" :class="form.participantType === '个人' ? 'orange' : 'green'">{{ form.participantType || '个人/团队' }}</span>
                    </div>
                  </div>
                  <!-- 各section -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">项目介绍</span><span class="mp-detail-sec-en">Program Introduction</span></div>
                    <div class="mp-detail-body-text" :class="{ collapsed: !previewExpand.intro }">{{ form.introduction || '项目介绍内容...' }}</div>
                    <div class="mp-detail-expand" v-if="form.introduction && form.introduction.length > 60" @click="previewExpand.intro = !previewExpand.intro">
                      {{ previewExpand.intro ? '收起' : '展开全部' }}
                    </div>
                  </div>
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">项目信息</span><span class="mp-detail-sec-en">Program Information</span></div>
                    <div class="mp-detail-body-text">{{ form.infoText || '项目信息...' }}</div>
                  </div>
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">竞赛规则</span><span class="mp-detail-sec-en">Competition Rules</span></div>
                    <div class="mp-detail-body-text">{{ form.rules || '竞赛规则...' }}</div>
                  </div>
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">奖项设置</span><span class="mp-detail-sec-en">Awards & Prizes</span></div>
                    <div class="mp-detail-body-text">{{ form.awards || '奖项设置...' }}</div>
                  </div>
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">报名时间</span><span class="mp-detail-sec-en">Registration Period</span></div>
                    <div class="mp-detail-body-text">{{ form.deadlineText || '报名时间...' }}</div>
                  </div>
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">其他资料</span><span class="mp-detail-sec-en">Materials</span></div>
                    <div class="mp-pdf-item" v-if="form.achievementPdf">
                      <span class="mp-pdf-icon">📄</span>
                      <span class="mp-pdf-name">竞赛成果 / COMPETITION ACHIEVEMENTS</span>
                    </div>
                    <div class="mp-detail-body-text" v-if="!form.achievementPdf">暂无资料</div>
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
import { getCompetitionList, createCompetition, updateCompetition, deleteCompetition } from '@/api/competition'

const statusMap = { open: '招生中', almost_full: '名额紧张', full: '已满额' }
const statusType = (s) => ({ open: 'success', almost_full: 'warning', full: 'danger' }[s] || 'info')
const statusClass = (s) => ({ open: 'open', almost_full: 'almost', full: 'full' }[s] || 'open')

const uploadUrl = '/api/file/upload'
const uploadHeaders = computed(() => {
  const token = localStorage.getItem('admin_token')
  return token ? { Authorization: `Bearer ${token}` } : {}
})

// Filters
const filters = ref({ category: '', status: '', keyword: '' })

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
const activeSections = ref(['sec1', 'sec2', 'sec3', 'sec4', 'sec5', 'sec6'])
const previewExpand = reactive({ intro: false })

const formRef = ref(null)

const defaultForm = {
  titleCn: '', titleEn: '', description: '',
  category: '', levelName: '', participantType: '',
  instructorName: '', school: '', targetAudience: '',
  poster: '', status: 'open', deadline: '', startDate: '', organizer: '',
  rules: '', awards: '', achievementPdf: '',
  detailPoster: '', introduction: '', infoText: '', deadlineText: ''
}

const form = ref({ ...defaultForm })

onMounted(() => fetchData())

async function fetchData() {
  loading.value = true
  try {
    const params = { page: currentPage.value, size: pageSize.value }
    if (filters.value.category) params.category = filters.value.category
    if (filters.value.status) params.status = filters.value.status
    if (filters.value.keyword) params.keyword = filters.value.keyword
    const res = await getCompetitionList(params)
    tableData.value = res.records
    total.value = res.total
  } catch { /* handled by interceptor */ } finally { loading.value = false }
}

function openDialog(row) {
  activeTab.value = 'card'
  activeSections.value = ['sec1', 'sec2', 'sec3', 'sec4', 'sec5', 'sec6']
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
      await updateCompetition(editId.value, form.value)
      ElMessage.success('竞赛更新成功')
    } else {
      await createCompetition(form.value)
      ElMessage.success('竞赛创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } catch { /* handled by interceptor */ } finally { submitting.value = false }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定要删除「${row.titleCn}」吗？`, '删除确认', { type: 'warning' })
  try {
    await deleteCompetition(row.id)
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

/* ======== Card Preview (matching mini-program competition.vue) ======== */
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

/* Competition card info (matching mini-program) */
.comp-card-info {
  flex: 1; display: flex; flex-direction: column; gap: 6px; min-width: 0; padding-left: 8px;
}
.comp-card-title {
  font-size: 13px; font-weight: 700; color: #333; line-height: 1.5;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
  overflow: hidden; text-align: left; margin-bottom: 8px;
}
.comp-card-title-en {
  font-size: 10px; color: #5B6CFF; font-weight: 600; text-transform: uppercase;
  letter-spacing: 0.3px; text-align: left;
}
.comp-card-meta { display: flex; flex-direction: column; gap: 3px; margin-top: 2px; }
.comp-card-meta-item { display: flex; gap: 4px; font-size: 11px; line-height: 1.4;
  .m-label { color: #999; flex-shrink: 0; }
  .m-val { color: #555; font-weight: 500; }
  .m-val.deadline { color: #e05050; font-weight: 600; }
}
.comp-card-tags { display: flex; gap: 6px; margin-top: 6px; flex-wrap: wrap; }
.comp-card-tag {
  font-size: 10px; padding: 2px 6px; border-radius: 4px; font-weight: 500;
  &.gray { background: #f0f2f5; color: #666; }
  &.green { background: #e6f4f2; color: #5B6CFF; }
  &.orange { background: #fff3e0; color: #ff9800; }
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
.mp-detail-hero {
  width: 100%; height: 90px; background-size: cover; background-position: center; background-color: #e0e0e0;
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

/* Competition hero main box styles */
.comp-hero-title { font-size: 14px; font-weight: 700; color: #333; line-height: 1.3; }
.comp-hero-title-en { font-size: 10px; color: #5B6CFF; font-weight: 600; text-transform: uppercase; margin-top: 4px; }
.comp-hero-meta { display: flex; flex-direction: column; gap: 4px; margin-top: 6px; }
.comp-hero-meta-item { display: flex; gap: 6px; font-size: 11px; line-height: 1.4;
  .m-label { color: #999; flex-shrink: 0; min-width: 28px; }
  .m-val { color: #555; font-weight: 500; }
  .m-val.deadline { color: #e05050; font-weight: 600; }
}
.comp-hero-tags { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 8px; }
.comp-hero-tag {
  font-size: 10px; padding: 2px 6px; border-radius: 4px;
  &.gray { background: #f0f2f5; color: #666; }
  &.green { background: #e6f4f2; color: #5B6CFF; }
  &.orange { background: #fff3e0; color: #ff9800; }
}

.mp-pdf-item { display: flex; align-items: center; gap: 8px; padding: 6px 10px; background: #fafbfc; border-radius: 8px; font-size: 11px; color: #444; margin-top: 4px; }
.mp-pdf-icon { flex-shrink: 0; font-size: 13px; }
.mp-pdf-name { flex: 1; }
</style>
