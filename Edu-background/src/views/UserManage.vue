<template>
  <div class="user-manage">
    <div class="card-header">
      <h2 class="section-title">用户管理</h2>
      <el-button type="primary" :icon="Plus" @click="openDialog()">
        新增用户
      </el-button>
    </div>

    <!-- Search -->
    <div class="search-bar">
      <el-input
        v-model="keyword"
        placeholder="搜索用户名、邮箱或学校"
        :prefix-icon="Search"
        clearable
        style="width: 320px"
        @keyup.enter="handleSearch"
        @clear="handleSearch"
      />
      <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
    </div>

    <!-- Table -->
    <div class="table-card glass-card">
      <el-table
        :data="tableData"
        v-loading="loading"
        stripe
        :header-cell-style="{ background: '#f5f7fa', color: '#333', fontWeight: 600 }"
      >
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column prop="username" label="用户名" min-width="120" />
        <el-table-column prop="phone" label="手机号" min-width="130">
          <template #default="{ row }">{{ row.phone || '-' }}</template>
        </el-table-column>
        <el-table-column prop="email" label="邮箱" min-width="180">
          <template #default="{ row }">{{ row.email || '-' }}</template>
        </el-table-column>
        <el-table-column prop="school" label="学校" min-width="150">
          <template #default="{ row }">{{ row.school || '-' }}</template>
        </el-table-column>
        <el-table-column prop="education" label="学历" width="100" align="center">
          <template #default="{ row }">{{ row.education || '-' }}</template>
        </el-table-column>
        <el-table-column prop="role" label="角色" width="120" align="center">
          <template #default="{ row }">
            <el-tag
              :type="row.role === 'admin' ? 'danger' : row.role === 'editor' ? 'warning' : 'info'"
              size="small"
            >
              {{ roleMap[row.role] || row.role }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="注册时间" min-width="170" />
        <el-table-column label="操作" width="200" align="center" fixed="right">
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

    <!-- Create/Edit User Dialog -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑用户' : '新增用户'"
      width="520px"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" :prop="isEdit ? '' : 'password'">
          <el-input
            v-model="form.password"
            type="password"
            show-password
            :placeholder="isEdit ? '留空则不修改密码' : '请输入密码'"
          />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="form.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="微信" prop="wechat">
          <el-input v-model="form.wechat" placeholder="请输入微信号" />
        </el-form-item>
        <el-form-item label="学校" prop="school">
          <el-input v-model="form.school" placeholder="请输入学校名称" />
        </el-form-item>
        <el-form-item label="学历" prop="education">
          <el-select v-model="form.education" placeholder="请选择学历" style="width: 100%">
            <el-option label="初中" value="初中" />
            <el-option label="高中" value="高中" />
            <el-option label="本科" value="本科" />
            <el-option label="硕士" value="硕士" />
            <el-option label="博士" value="博士" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="年级" prop="grade">
          <el-input v-model="form.grade" placeholder="请输入年级" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="form.role" placeholder="请选择角色" style="width: 100%">
            <el-option label="普通用户" value="USER" />
            <el-option label="编辑" value="editor" />
            <el-option label="管理员" value="admin" />
          </el-select>
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
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Plus, Edit, Delete } from '@element-plus/icons-vue'
import { getUserList, createUser, updateUser, deleteUser } from '@/api/user'

const roleMap = { USER: '普通用户', editor: '编辑', admin: '管理员' }

const keyword = ref('')
const tableData = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// User CRUD dialog
const dialogVisible = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const submitting = ref(false)
const formRef = ref(null)

const defaultForm = {
  username: '',
  password: '',
  phone: '',
  email: '',
  wechat: '',
  school: '',
  education: '',
  grade: '',
  role: 'USER'
}

const form = ref({ ...defaultForm })

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur', min: 6 }]
}

onMounted(() => fetchData())

async function fetchData() {
  loading.value = true
  try {
    const res = await getUserList({ page: currentPage.value, size: pageSize.value, keyword: keyword.value || undefined })
    tableData.value = res.records
    total.value = res.total
  } catch { /* handled by interceptor */ } finally { loading.value = false }
}

function handleSearch() {
  currentPage.value = 1
  fetchData()
}

// ---- User CRUD ----
function openDialog(row) {
  if (row) {
    isEdit.value = true
    editId.value = row.id
    form.value = {
      username: row.username,
      password: '',
      phone: row.phone || '',
      email: row.email || '',
      wechat: row.wechat || '',
      school: row.school || '',
      education: row.education || '',
      grade: row.grade || '',
      role: row.role || 'USER'
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
    const data = { ...form.value }
    // If editing and password is empty, remove it
    if (isEdit.value && !data.password) {
      delete data.password
    }
    if (isEdit.value) {
      await updateUser(editId.value, data)
      ElMessage.success('用户信息更新成功')
    } else {
      await createUser(data)
      ElMessage.success('用户创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } catch { /* handled by interceptor */ } finally { submitting.value = false }
}

async function handleDelete(row) {
  if (row.id === 1) {
    ElMessage.warning('不能删除超级管理员账号')
    return
  }
  await ElMessageBox.confirm(
    `确定要删除用户「${row.username}」吗？此操作不可撤销。`,
    '删除确认',
    { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'warning' }
  )
  try {
    await deleteUser(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch { /* user cancelled or error */ }
}
</script>

<style lang="scss" scoped>
.user-manage .card-header { margin-bottom: 16px; }
.table-card { padding: 20px; }
.pagination-wrap { display: flex; justify-content: flex-end; margin-top: 16px; }
</style>
