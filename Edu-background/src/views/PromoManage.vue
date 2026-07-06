<template>
  <div class="manage-page">
    <div class="card-header">
      <h2 class="section-title">宣传图管理</h2>
      <span class="count-text">点击首页悬浮耳机图标或个人中心「关于我们」展示此图片</span>
    </div>

    <div class="form-card glass-card">
      <el-form :model="form" label-width="100px">
        <el-form-item label="标题">
          <el-input v-model="form.title" placeholder="宣传图标题" style="max-width:400px" />
        </el-form-item>
        <el-form-item label="宣传图">
          <el-input v-model="form.imageUrl" placeholder="图片URL">
            <template #append>
              <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="handleUpload" :on-error="handleUploadError" accept="image/*">
                <el-button :icon="Upload">上传图片</el-button>
              </el-upload>
            </template>
          </el-input>
          <div class="upload-hint">建议尺寸 750×1334px，支持 jpg/png</div>
        </el-form-item>

        <!-- 预览 -->
        <el-form-item label="手机预览" v-if="form.imageUrl">
          <div class="phone-preview-wrap">
            <div class="phone-frame">
              <div class="phone-status-bar">
                <span class="phone-time">9:41</span>
              </div>
              <div class="phone-nav">
                <span class="phone-back">←</span>
                <span class="phone-nav-title">{{ form.title || '宣传图' }}</span>
                <span style="width:32px"></span>
              </div>
              <div class="phone-body">
                <img v-if="form.imageUrl" :src="form.imageUrl" class="phone-preview-img" />
                <span v-else class="phone-empty">暂无图片</span>
              </div>
            </div>
          </div>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" :loading="saving" @click="handleSave">保存</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Upload } from '@element-plus/icons-vue'
import { getPromoImage, updatePromoImage } from '@/api/promo'

const uploadUrl = '/api/file/upload'
const uploadHeaders = computed(() => {
  const token = localStorage.getItem('admin_token')
  return token ? { Authorization: `Bearer ${token}` } : {}
})

const form = ref({ title: '', imageUrl: '' })
const saving = ref(false)

onMounted(async () => {
  try {
    const data = await getPromoImage()
    if (data) {
      form.value = { title: data.title || '', imageUrl: data.imageUrl || '' }
    }
  } catch { /* ignore */ }
})

function handleUpload(response) {
  if (response.code === 200 && response.data?.url) {
    form.value.imageUrl = response.data.url
    ElMessage.success('上传成功')
  } else {
    ElMessage.error(response.message || '上传失败')
  }
}

function handleUploadError(err) {
  console.error('Upload error:', err)
  ElMessage.error('上传失败，请确保后端服务已启动')
}

async function handleSave() {
  saving.value = true
  try {
    await updatePromoImage(form.value)
    ElMessage.success('宣传图已更新')
  } catch { /* handled by interceptor */ } finally {
    saving.value = false
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
.form-card { padding: 24px; }
.upload-hint { font-size: 12px; color: #999; margin-top: 6px; }

/* Phone Preview */
.phone-preview-wrap { display: flex; justify-content: flex-start; }
.phone-frame {
  width: 280px; background: #111; border-radius: 20px; overflow: hidden;
  box-shadow: 0 8px 32px rgba(0,0,0,0.18);
}
.phone-status-bar {
  height: 24px; display: flex; align-items: center; justify-content: center;
}
.phone-time { color: #fff; font-size: 11px; }
.phone-nav {
  height: 36px; background: #fff; display: flex; align-items: center;
  justify-content: space-between; padding: 0 10px;
}
.phone-nav-title { font-size: 13px; font-weight: 600; color: #333; }
.phone-back { font-size: 14px; color: #333; }
.phone-body { background: #000; min-height: 120px; display: flex; align-items: flex-start; }
.phone-preview-img { width: 100%; display: block; }
.phone-empty { color: #666; font-size: 13px; padding: 40px; margin: auto; }
</style>
