<template>
  <div class="project-manage">
    <div class="card-header">
      <h2 class="section-title">课题管理</h2>
      <div class="header-right">
        <span class="count-text">共 {{ total }} 个课题</span>
        <el-button type="primary" :icon="Plus" @click="openDialog()">新增课题</el-button>
      </div>
    </div>

    <!-- Search Filters -->
    <div class="filter-card glass-card">
      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="学科领域">
          <el-select v-model="filters.category" placeholder="全部" clearable style="width:140px" @change="fetchData">
            <el-option label="人文社科" value="人文社科" />
            <el-option label="理科" value="理科" />
            <el-option label="艺术科技" value="艺术科技" />
            <el-option label="海外课题" value="海外课题" />
          </el-select>
        </el-form-item>
        <el-form-item label="教学形式">
          <el-select v-model="filters.mode" placeholder="全部" clearable style="width:140px" @change="fetchData">
            <el-option label="线上" value="线上" />
            <el-option label="线下" value="线下" />
            <el-option label="实践1V1定制" value="实践1V1定制" />
            <el-option label="混合" value="混合" />
          </el-select>
        </el-form-item>
        <el-form-item label="招生状态">
          <el-select v-model="filters.status" placeholder="全部" clearable style="width:120px" @change="fetchData">
            <el-option label="招生中" value="open" />
            <el-option label="已满员" value="full" />
            <el-option label="即将开课" value="soon" />
          </el-select>
        </el-form-item>
        <el-form-item label="开课时间">
          <el-date-picker v-model="filters.startDate" type="month" placeholder="选择月份" format="YYYY-MM" value-format="YYYY-MM" style="width:150px" @change="fetchData" />
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
        <el-table-column prop="id" label="课题ID" width="80" align="center" />
        <el-table-column prop="titleCn" label="课题标题" min-width="180" show-overflow-tooltip />
        <el-table-column label="学科领域" width="100" align="center">
          <template #default="{ row }"><el-tag size="small" effect="plain">{{ row.category || '-' }}</el-tag></template>
        </el-table-column>
        <el-table-column label="教学形式" width="120" align="center">
          <template #default="{ row }"><el-tag size="small" effect="plain" type="info">{{ row.mode || '-' }}</el-tag></template>
        </el-table-column>
        <el-table-column label="招生状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="statusType(row.enrollmentStatus || row.status)">{{ statusMap[row.enrollmentStatus || row.status] || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="startDate" label="开课时间" width="110" align="center" />
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
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑课题' : '新增课题'" width="960px" :close-on-click-modal="false" top="2vh">
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
                <div class="mp-status" :class="statusClass(form.enrollmentStatus || form.status)">{{ statusMap[form.enrollmentStatus || form.status] || '招生中' }}</div>
              </div>
              <div class="mp-card-info">
                <div class="mp-title">{{ form.titleCn || '课题标题' }}</div>
                <div class="mp-profs">
                  <div class="mp-prof" v-if="form.professor1Name">
                    <span class="mp-prof-name">{{ form.professor1Name }}</span>
                    <span class="mp-prof-school">{{ form.professor1Info }}</span>
                  </div>
                  <div class="mp-prof" v-if="form.professor2Name">
                    <span class="mp-prof-name">{{ form.professor2Name }}</span>
                    <span class="mp-prof-school">{{ form.professor2Info }}</span>
                  </div>
                </div>
                <div class="mp-tags" v-if="form.tags">
                  <span class="mp-tag" v-for="t in form.tags.split(',').filter(Boolean).slice(0, 8)" :key="t">{{ t.trim() }}</span>
                </div>
                <div class="mp-bottom">
                  <span class="mp-clock-icon">🕐</span>
                  <span class="mp-date" v-if="form.startDate">{{ form.startDate }}</span>
                  <span class="mp-mode" :class="'mp-mode-' + modeClass(form.mode)">{{ form.mode || '教学形式' }}</span>
                </div>
              </div>
            </div>
          </div>

          <el-form ref="formRef" :model="form" label-width="110px">
            <el-divider content-position="left">基本信息</el-divider>
            <el-row :gutter="16">
              <el-col :span="12">
                <el-form-item label="课题标题" prop="titleCn" :rules="[{ required:true, message:'请输入标题' }]">
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
              <el-col :span="12">
                <el-form-item label="学科领域">
                  <el-select v-model="form.category" style="width:100%" clearable placeholder="请选择">
                    <el-option label="人文社科" value="人文社科" />
                    <el-option label="理科" value="理科" />
                    <el-option label="艺术科技" value="艺术科技" />
                    <el-option label="海外课题" value="海外课题" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="教学形式">
                  <el-select v-model="form.mode" style="width:100%" clearable placeholder="请选择">
                    <el-option label="线上" value="线上" />
                    <el-option label="线下" value="线下" />
                    <el-option label="实践1V1定制" value="实践1V1定制" />
                    <el-option label="混合" value="混合" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="16">
              <el-col :span="12">
                <el-form-item label="招生状态">
                  <el-select v-model="form.enrollmentStatus" style="width:100%">
                    <el-option label="招生中" value="open" />
                    <el-option label="已满员" value="full" />
                    <el-option label="即将开课" value="soon" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="开课时间">
                  <el-date-picker v-model="form.startDate" type="date" placeholder="选择日期" format="YYYY-MM-DD" value-format="YYYY-MM-DD" style="width:100%" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item label="卡片描述">
              <el-input v-model="form.description" type="textarea" :rows="2" placeholder="课题简短描述（用于卡片展示）" />
            </el-form-item>

            <el-form-item label="封面图">
              <el-input v-model="form.poster" placeholder="卡片封面图片URL">
                <template #append>
                  <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'poster')" :on-error="handleUploadError" accept="image/*">
                    <el-button :icon="Upload">上传</el-button>
                  </el-upload>
                </template>
              </el-input>
              <div class="upload-hint">建议尺寸 750×420px</div>
            </el-form-item>

            <el-form-item label="自定义标签">
              <el-input v-model="form.tags" placeholder="多个标签用逗号分隔，如：热门,推荐,新课题" />
            </el-form-item>

            <el-divider content-position="left">教授信息（卡片展示）</el-divider>
            <el-row :gutter="16">
              <el-col :span="12">
                <el-form-item label="教授1名称">
                  <el-input v-model="form.professor1Name" placeholder="教授姓名" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="教授1信息">
                  <el-input v-model="form.professor1Info" placeholder="如：清华大学教授" />
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="16">
              <el-col :span="12">
                <el-form-item label="教授2名称">
                  <el-input v-model="form.professor2Name" placeholder="教授姓名" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="教授2信息">
                  <el-input v-model="form.professor2Info" placeholder="如：北京大学副教授" />
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
        </el-tab-pane>

        <!-- ==================== Tab 2: 详情页信息 ==================== -->
        <el-tab-pane label="详情页信息" name="detail">
          <div class="detail-editor-layout">
            <!-- LEFT: Section Editors -->
            <div class="detail-editor-form">
              <el-collapse v-model="activeSections">
                <!-- 1. 学术背景 -->
                <el-collapse-item title="学术背景 / Academic Context" name="sec1">
                  <el-form-item label="详情宣传图">
                    <el-input v-model="form.detailPoster" placeholder="详情页顶部宣传图URL">
                      <template #append>
                        <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'detailPoster')" :on-error="handleUploadError" accept="image/*">
                          <el-button :icon="Upload">上传</el-button>
                        </el-upload>
                      </template>
                    </el-input>
                  </el-form-item>
                  <el-form-item label="描述内容">
                    <el-input v-model="form.description" type="textarea" :rows="3" placeholder="学术背景内容描述" />
                  </el-form-item>
                </el-collapse-item>

                <!-- 2. 专题信息 -->
                <el-collapse-item title="专题信息 / Module Details" name="sec2">
                  <el-row :gutter="16">
                    <el-col :span="12">
                      <el-form-item label="课时">
                        <el-input v-model="form.hoursInfo" placeholder="如：3周线上课 + 6周论文指导" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="难度">
                        <el-rate v-model="difficultyStars" :max="5" :texts="['简单', '较易', '中等', '较难', '困难']" show-text />
                      </el-form-item>
                    </el-col>
                  </el-row>
                  <el-form-item label="学术成果">
                    <el-input v-model="form.outcome" type="textarea" :rows="2" placeholder="如：10封教授推荐信 + 1篇论文辅导" />
                  </el-form-item>
                </el-collapse-item>

                <!-- 3. 研究方向 -->
                <el-collapse-item title="研究方向 / Research Areas" name="sec3">
                  <el-form-item label="研究方向">
                    <el-input v-model="form.researchDirections" type="textarea" :rows="2" placeholder="研究方向描述" />
                  </el-form-item>
                </el-collapse-item>

                <!-- 4. 教授介绍 -->
                <el-collapse-item title="教授介绍 / Professor Profiles" name="sec4">
                  <div class="prof-editor-list">
                    <div class="prof-editor-card" v-for="(prof, i) in detailProfessors" :key="i">
                      <div class="prof-editor-header">
                        <span>教授 {{ i + 1 }}</span>
                        <el-button type="danger" link :icon="Delete" @click="removeProfessor(i)" :disabled="detailProfessors.length <= 1">删除</el-button>
                      </div>
                      <el-row :gutter="12">
                        <el-col :span="12">
                          <el-input v-model="prof.name" placeholder="中文名" size="small" />
                        </el-col>
                        <el-col :span="12">
                          <el-input v-model="prof.nameEn" placeholder="英文名 (如 Prof. Zhang)" size="small" />
                        </el-col>
                      </el-row>
                      <el-row :gutter="12" style="margin-top:6px">
                        <el-col :span="24">
                          <el-input v-model="prof.avatar" placeholder="头像URL" size="small">
                            <template #append>
                              <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleProfAvatarUpload(r, i)" :on-error="handleUploadError" accept="image/*">
                                <el-button :icon="Upload" size="small">上传</el-button>
                              </el-upload>
                            </template>
                          </el-input>
                        </el-col>
                      </el-row>
                      <el-input v-model="prof.bio" type="textarea" :rows="2" placeholder="教授简介" size="small" style="margin-top:6px" />
                    </div>
                    <el-button type="primary" link :icon="Plus" @click="addProfessor" v-if="detailProfessors.length < 5">添加教授</el-button>
                  </div>
                </el-collapse-item>

                <!-- 5. 专题介绍 -->
                <el-collapse-item title="专题介绍 / Module Descriptions" name="sec5">
                  <el-form-item label="专题介绍">
                    <el-input v-model="form.topicIntro" type="textarea" :rows="4" placeholder="课题/专题的详细介绍" />
                  </el-form-item>
                </el-collapse-item>

                <!-- 6. 适合学生 -->
                <el-collapse-item title="适合学生 / Target Participants" name="sec6">
                  <div class="list-editor">
                    <div class="list-editor-item" v-for="(item, i) in detailSuitableStudents" :key="i">
                      <el-input v-model="detailSuitableStudents[i]" placeholder="适合的学生类型" size="small" />
                      <el-button type="danger" :icon="Delete" circle size="small" @click="detailSuitableStudents.splice(i,1)" :disabled="detailSuitableStudents.length <= 1" />
                    </div>
                    <el-button type="primary" link :icon="Plus" @click="detailSuitableStudents.push('')">添加条目</el-button>
                  </div>
                </el-collapse-item>

                <!-- 7. 课题大纲 -->
                <el-collapse-item title="课题大纲 / Curriculum Outline" name="sec7">
                  <div class="list-editor">
                    <div class="list-editor-item" v-for="(item, i) in detailOutline" :key="i">
                      <el-input v-model="detailOutline[i]" placeholder="如：第一章：城市社会学理论基础" size="small" />
                      <el-button type="danger" :icon="Delete" circle size="small" @click="detailOutline.splice(i,1)" :disabled="detailOutline.length <= 1" />
                    </div>
                    <el-button type="primary" link :icon="Plus" @click="detailOutline.push('')">添加章节</el-button>
                  </div>
                </el-collapse-item>

                <!-- 8. 课题安排 -->
                <el-collapse-item title="课题安排 / Program Schedule" name="sec8">
                  <el-form-item label="课程安排">
                    <el-input v-model="form.schedule" type="textarea" :rows="4" placeholder="课程安排详情" />
                  </el-form-item>
                </el-collapse-item>

                <!-- 9. 科研流程 -->
                <el-collapse-item title="科研流程 / Research Process" name="sec9">
                  <div class="process-table-editor">
                    <div class="process-editor-header">
                      <span class="pe-col" style="width:12%">阶段</span>
                      <span class="pe-col" style="width:16%">环节</span>
                      <span class="pe-col" style="width:14%">形式</span>
                      <span class="pe-col" style="width:10%">课时</span>
                      <span class="pe-col" style="flex:1">内容概要</span>
                      <span class="pe-col" style="width:44px"></span>
                    </div>
                    <div class="process-editor-row" v-for="(row, i) in detailProcessTable" :key="i">
                      <el-input v-model="row.stage" placeholder="阶段" size="small" style="width:12%" />
                      <el-input v-model="row.link" placeholder="环节" size="small" style="width:16%" />
                      <el-input v-model="row.form" placeholder="形式" size="small" style="width:14%" />
                      <el-input v-model="row.hours" placeholder="课时" size="small" style="width:10%" />
                      <el-input v-model="row.summary" placeholder="内容概要" size="small" style="flex:1" />
                      <el-button type="danger" :icon="Delete" circle size="small" @click="detailProcessTable.splice(i,1)" :disabled="detailProcessTable.length <= 1" />
                    </div>
                    <el-button type="primary" link :icon="Plus" @click="detailProcessTable.push({stage:'',link:'',form:'',hours:'',summary:''})">添加阶段</el-button>
                  </div>
                </el-collapse-item>

                <!-- 10. 成果形式 -->
                <el-collapse-item title="成果形式 / Expected Research Outputs" name="sec10">
                  <el-form-item label="成果形式">
                    <el-input v-model="form.outcomeFormat" type="textarea" :rows="3" placeholder="如：学术论文1篇（可投稿核心期刊）&#10;研究报告1份&#10;导师推荐信（优秀学员）" />
                  </el-form-item>
                </el-collapse-item>

                <!-- 11. 匹配院校 -->
                <el-collapse-item title="匹配院校 / Target Universities" name="sec11">
                  <el-form-item label="匹配院校">
                    <el-input v-model="form.matchSchools" type="textarea" :rows="3" placeholder="匹配的留学院校" />
                  </el-form-item>
                </el-collapse-item>

                <!-- 12. 项目流程 -->
                <el-collapse-item title="项目流程 / Program Roadmap" name="sec12">
                  <div class="workflow-editor">
                    <div class="workflow-editor-item" v-for="(step, i) in detailWorkflow" :key="i">
                      <div class="wf-step-num">{{ i + 1 }}</div>
                      <div class="wf-step-fields">
                        <el-input v-model="step.title" placeholder="步骤标题 (如：申请面试 / Apply & Interview)" size="small" />
                        <el-input v-model="step.desc" placeholder="步骤描述" size="small" style="margin-top:4px" />
                      </div>
                      <el-button type="danger" :icon="Delete" circle size="small" @click="detailWorkflow.splice(i,1)" :disabled="detailWorkflow.length <= 1" />
                    </div>
                    <el-button type="primary" link :icon="Plus" @click="detailWorkflow.push({title:'',desc:''})">添加步骤</el-button>
                  </div>
                </el-collapse-item>

                <!-- 13. 其他资料 -->
                <el-collapse-item title="其他资料 / Materials" name="sec13">
                  <el-row :gutter="16">
                    <el-col :span="12">
                      <el-form-item label="课程大纲PDF">
                        <el-input v-model="form.courseOutlinePdf" placeholder="PDF地址">
                          <template #append>
                            <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'courseOutlinePdf')" :on-error="handleUploadError" accept=".pdf">
                              <el-button :icon="Upload">上传</el-button>
                            </el-upload>
                          </template>
                        </el-input>
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="服务流程PDF">
                        <el-input v-model="form.serviceFlowPdf" placeholder="PDF地址">
                          <template #append>
                            <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'serviceFlowPdf')" :on-error="handleUploadError" accept=".pdf">
                              <el-button :icon="Upload">上传</el-button>
                            </el-upload>
                          </template>
                        </el-input>
                      </el-form-item>
                    </el-col>
                  </el-row>
                  <el-row :gutter="16">
                    <el-col :span="12">
                      <el-form-item label="论文展示PDF">
                        <el-input v-model="form.paperDisplayPdf" placeholder="PDF地址">
                          <template #append>
                            <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'paperDisplayPdf')" :on-error="handleUploadError" accept=".pdf">
                              <el-button :icon="Upload">上传</el-button>
                            </el-upload>
                          </template>
                        </el-input>
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="实践调研PDF">
                        <el-input v-model="form.practiceResearchPdf" placeholder="PDF地址">
                          <template #append>
                            <el-upload :action="uploadUrl" :headers="uploadHeaders" name="file" :show-file-list="false" :on-success="(r) => handleImgUpload(r, 'practiceResearchPdf')" :on-error="handleUploadError" accept=".pdf">
                              <el-button :icon="Upload">上传</el-button>
                            </el-upload>
                          </template>
                        </el-input>
                      </el-form-item>
                    </el-col>
                  </el-row>
                </el-collapse-item>
              </el-collapse>
            </div>

            <!-- RIGHT: 小程序详情页预览 -->
            <div class="detail-preview-panel">
              <div class="mp-detail-preview">
                <div class="mp-detail-label">
                  <el-icon><View /></el-icon> 小程序详情页预览
                </div>
                <div class="mp-detail-phone">
                  <!-- Hero -->
                  <div class="mp-detail-hero" :style="{ backgroundImage: form.detailPoster ? `url(${form.detailPoster})` : (form.poster ? `url(${form.poster})` : 'none') }">
                    <div v-if="!form.detailPoster && !form.poster" class="mp-detail-hero-empty">
                      <el-icon :size="24"><Picture /></el-icon>
                      <span>宣传图</span>
                    </div>
                  </div>

                  <!-- 1. 学术背景 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">学术背景</span><span class="mp-detail-sec-en">Academic Context</span></div>
                    <div class="mp-detail-tags">
                      <span class="mp-detail-tag gray">{{ form.category || '学科领域' }}</span>
                      <span class="mp-detail-tag green">{{ form.mode || '教学形式' }}</span>
                    </div>
                    <div class="mp-detail-title-text">{{ form.titleCn || '课题标题' }}</div>
                    <div class="mp-detail-title-en">{{ form.titleEn || 'English Title' }}</div>
                    <div class="mp-detail-body-text" :class="{ collapsed: !previewExpand.desc }">{{ form.description || '描述内容...' }}</div>
                    <div class="mp-detail-expand" v-if="form.description && form.description.length > 60" @click="previewExpand.desc = !previewExpand.desc">
                      {{ previewExpand.desc ? '收起' : '展开全部' }}
                    </div>
                  </div>

                  <!-- 2. 专题信息 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">专题信息</span><span class="mp-detail-sec-en">Module Details</span></div>
                    <div class="mp-detail-info-row"><span class="mp-info-icon">🕐</span><span class="mp-info-label">开课时间</span><span class="mp-info-val">{{ form.startDate || '-' }}</span></div>
                    <div class="mp-detail-info-row"><span class="mp-info-icon">📖</span><span class="mp-info-label">课时</span><span class="mp-info-val">{{ form.hoursInfo || '-' }}</span></div>
                    <div class="mp-detail-info-row"><span class="mp-info-icon">⭐</span><span class="mp-info-label">难度</span><span class="mp-info-val difficulty">{{ difficultyStars > 0 ? '★'.repeat(difficultyStars) + '☆'.repeat(5 - difficultyStars) : '-' }}</span></div>
                    <div class="mp-detail-info-row"><span class="mp-info-icon">🏆</span><span class="mp-info-label">学术成果</span><span class="mp-info-val">{{ form.outcome || '-' }}</span></div>
                  </div>

                  <!-- 3. 研究方向 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">研究方向</span><span class="mp-detail-sec-en">Research Areas</span></div>
                    <div class="mp-detail-body-text">{{ form.researchDirections || '研究方向描述...' }}</div>
                  </div>

                  <!-- 4. 教授介绍 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">教授介绍</span><span class="mp-detail-sec-en">Professor Profiles</span></div>
                    <div class="mp-prof-card" v-for="(prof, i) in detailProfessors" :key="i">
                      <div class="mp-prof-avatar" :style="{ backgroundImage: prof.avatar ? `url(${prof.avatar})` : 'none' }"></div>
                      <div class="mp-prof-detail">
                        <span class="mp-prof-name-text">{{ prof.name || '教授姓名' }} / {{ prof.nameEn || 'Prof.' }}</span>
                        <span class="mp-prof-bio-text">{{ prof.bio || '教授简介...' }}</span>
                      </div>
                    </div>
                    <div class="mp-detail-body-text" v-if="!detailProfessors.length">教授团队介绍...</div>
                  </div>

                  <!-- 5. 专题介绍 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">专题介绍</span><span class="mp-detail-sec-en">Module Descriptions</span></div>
                    <div class="mp-detail-body-text" :class="{ collapsed: !previewExpand.intro }">{{ form.topicIntro || '专题介绍内容...' }}</div>
                    <div class="mp-detail-expand" v-if="form.topicIntro && form.topicIntro.length > 60" @click="previewExpand.intro = !previewExpand.intro">
                      {{ previewExpand.intro ? '收起' : '展开全部' }}
                    </div>
                  </div>

                  <!-- 6. 适合学生 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">适合学生</span><span class="mp-detail-sec-en">Target Participants</span></div>
                    <div class="mp-suitable-item" v-for="(item, i) in detailSuitableStudents" :key="i" :class="i % 2 === 0 ? 'mp-suitable-even' : 'mp-suitable-odd'">
                      <div class="mp-suitable-bullet"></div>
                      <span class="mp-suitable-text">{{ item || '适合的学生类型...' }}</span>
                    </div>
                    <div class="mp-detail-body-text" v-if="!detailSuitableStudents.length">适合学生描述...</div>
                  </div>

                  <!-- 7. 课题大纲 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">课题大纲</span><span class="mp-detail-sec-en">Curriculum Outline</span></div>
                    <div class="mp-outline-item" v-for="(item, i) in detailOutline" :key="i">{{ item || `第${i+1}章` }}</div>
                    <div class="mp-detail-body-text" v-if="!detailOutline.length">课题大纲内容...</div>
                  </div>

                  <!-- 8. 课题安排 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">课题安排</span><span class="mp-detail-sec-en">Program Schedule</span></div>
                    <div class="mp-detail-body-text">{{ form.schedule || '课程安排...' }}</div>
                  </div>

                  <!-- 9. 科研流程 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">科研流程</span><span class="mp-detail-sec-en">Research Process</span></div>
                    <div class="mp-process-table">
                      <div class="mp-process-header">
                        <span class="mp-th" style="width:14%">阶段</span>
                        <span class="mp-th" style="width:16%">环节</span>
                        <span class="mp-th" style="width:14%">形式</span>
                        <span class="mp-th" style="width:10%">课时</span>
                        <span class="mp-th" style="flex:1">内容概要</span>
                      </div>
                      <div class="mp-process-row" v-for="(row, i) in detailProcessTable" :key="i">
                        <span class="mp-td" style="width:14%">{{ row.stage || '-' }}</span>
                        <span class="mp-td" style="width:16%">{{ row.link || '-' }}</span>
                        <span class="mp-td" style="width:14%">{{ row.form || '-' }}</span>
                        <span class="mp-td" style="width:10%">{{ row.hours || '-' }}</span>
                        <span class="mp-td" style="flex:1;text-align:left">{{ row.summary || '-' }}</span>
                      </div>
                    </div>
                    <div class="mp-detail-body-text" v-if="!detailProcessTable.length">科研流程...</div>
                  </div>

                  <!-- 10. 成果形式 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">成果形式</span><span class="mp-detail-sec-en">Expected Research Outputs</span></div>
                    <div class="mp-detail-body-text">{{ form.outcomeFormat || '成果形式...' }}</div>
                  </div>

                  <!-- 11. 匹配院校 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">匹配院校</span><span class="mp-detail-sec-en">Target Universities</span></div>
                    <div class="mp-detail-body-text">{{ form.matchSchools || '匹配院校...' }}</div>
                  </div>

                  <!-- 12. 项目流程 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">项目流程</span><span class="mp-detail-sec-en">Program Roadmap</span></div>
                    <div class="mp-wf-step" v-for="(step, i) in detailWorkflow" :key="i">
                      <div class="mp-wf-num">{{ i + 1 }}</div>
                      <div class="mp-wf-text">
                        <span class="mp-wf-title">{{ step.title || '步骤标题' }}</span>
                        <span class="mp-wf-desc">{{ step.desc || '步骤描述' }}</span>
                      </div>
                    </div>
                    <div class="mp-detail-body-text" v-if="!detailWorkflow.length">项目流程...</div>
                  </div>

                  <!-- 13. 其他资料 -->
                  <div class="mp-detail-sec">
                    <div class="mp-detail-sec-title"><span class="mp-detail-sec-zh">其他资料</span><span class="mp-detail-sec-en">Materials</span></div>
                    <div class="mp-pdf-item" v-if="form.courseOutlinePdf">
                      <span class="mp-pdf-icon">📄</span>
                      <span class="mp-pdf-name">课题大纲 / Curriculum Outline</span>
                    </div>
                    <div class="mp-pdf-item" v-if="form.serviceFlowPdf">
                      <span class="mp-pdf-icon">📄</span>
                      <span class="mp-pdf-name">服务流程 / SERVICE PROCESS</span>
                    </div>
                    <div class="mp-pdf-item" v-if="form.paperDisplayPdf">
                      <span class="mp-pdf-icon">📄</span>
                      <span class="mp-pdf-name">论文与学术作品展示 / PAPERS & ACADEMIC OUTPUTS</span>
                    </div>
                    <div class="mp-pdf-item" v-if="form.practiceResearchPdf">
                      <span class="mp-pdf-icon">📄</span>
                      <span class="mp-pdf-name">实践调研 / FIELD RESEARCH</span>
                    </div>
                    <div class="mp-detail-body-text" v-if="!form.courseOutlinePdf && !form.serviceFlowPdf && !form.paperDisplayPdf && !form.practiceResearchPdf">暂无资料</div>
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
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Edit, Delete, Upload, View, Picture } from '@element-plus/icons-vue'
import { getProjectList, createProject, updateProject, deleteProject } from '@/api/project'

const statusMap = { open: '招生中', full: '已满员', soon: '即将开课' }
const statusType = (s) => ({ open: 'success', full: 'danger', soon: 'warning' }[s] || 'info')
const statusClass = (s) => ({ open: 'open', full: 'full', soon: 'soon' }[s] || 'open')
const modeClass = (m) => {
  if (m === '线上') return 'online'
  if (m === '线下') return 'offline'
  if (m === '实践1V1定制') return 'one2one'
  return 'online'
}

const uploadUrl = '/api/file/upload'
const uploadHeaders = computed(() => {
  const token = localStorage.getItem('admin_token')
  return token ? { Authorization: `Bearer ${token}` } : {}
})

// Filters
const filters = ref({ category: '', mode: '', status: '', startDate: '', keyword: '' })

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
const activeSections = ref(['sec1', 'sec2', 'sec3', 'sec4', 'sec5', 'sec6', 'sec7', 'sec8', 'sec9', 'sec10', 'sec11', 'sec12', 'sec13'])
const previewExpand = reactive({ desc: false, intro: false })

// Difficulty star rating (1-5 number, converted to/from star string for API)
const difficultyStars = ref(0)

// Structured data (reactive arrays for editors)
const detailProfessors = ref([{ name: '', nameEn: '', avatar: '', bio: '' }])
const detailSuitableStudents = ref([''])
const detailOutline = ref([''])
const detailProcessTable = ref([{ stage: '', link: '', form: '', hours: '', summary: '' }])
const detailWorkflow = ref([{ title: '', desc: '' }])

const formRef = ref(null)

const defaultForm = {
  titleCn: '', titleEn: '', description: '', descriptionEn: '',
  category: '', mode: '', region: '', status: '', enrollmentStatus: 'open',
  startDate: '', endDate: '', difficulty: '', hoursInfo: '', poster: '', tags: '',
  professor1Name: '', professor1Info: '', professor2Name: '', professor2Info: '',
  professor3Name: '', professor3Info: '',
  detailPoster: '',
  academicBgLabel: '', academicBgTitleCn: '', academicBgTitleEn: '', academicBgContent: '',
  outcome: '', outcomeFormat: '', targetStudents: '', outlineInfo: '', schedule: '', processInfo: '',
  matchSchools: '', workflow: '', researchDirections: '', professorIntro: '', topicIntro: '',
  courseOutlinePdf: '', serviceFlowPdf: '', paperDisplayPdf: '', practiceResearchPdf: ''
}

const form = ref({ ...defaultForm })

onMounted(() => fetchData())

// ============ Data Transformations ============

function safeJsonParse(str, fallback) {
  if (!str) return fallback
  try {
    const parsed = JSON.parse(str)
    return Array.isArray(parsed) ? parsed : fallback
  } catch { return fallback }
}

function parseNewlineArray(str) {
  if (!str) return ['']
  const arr = str.split('\n').filter(Boolean)
  return arr.length ? arr : ['']
}

// Parse structured data from the flat form when loading from API
function parseDetailData(data) {
  // Professors: try professorIntro JSON first, then fall back to individual fields
  const profsFromJson = safeJsonParse(data.professorIntro, null)
  if (profsFromJson && profsFromJson.length) {
    detailProfessors.value = profsFromJson
  } else {
    // Build from individual professor fields
    const profs = []
    if (data.professor1Name) profs.push({ name: data.professor1Name, nameEn: '', avatar: '', bio: data.professor1Info || '' })
    if (data.professor2Name) profs.push({ name: data.professor2Name, nameEn: '', avatar: '', bio: data.professor2Info || '' })
    if (data.professor3Name) profs.push({ name: data.professor3Name, nameEn: '', avatar: '', bio: data.professor3Info || '' })
    if (profs.length) detailProfessors.value = profs
  }

  detailSuitableStudents.value = parseNewlineArray(data.targetStudents)
  detailOutline.value = parseNewlineArray(data.outlineInfo)
  detailProcessTable.value = safeJsonParse(data.processInfo, [{ stage: '', link: '', form: '', hours: '', summary: '' }])
  detailWorkflow.value = safeJsonParse(data.workflow, [{ title: '', desc: '' }])
}

// Serialize structured data back to flat form fields before saving
function serializeDetailData() {
  // Professors → professorIntro JSON
  const validProfs = detailProfessors.value.filter(p => p.name || p.bio)
  form.value.professorIntro = validProfs.length ? JSON.stringify(validProfs) : ''

  // Also update individual professor fields for backward compatibility
  if (detailProfessors.value[0]) {
    form.value.professor1Name = detailProfessors.value[0].name || ''
    form.value.professor1Info = detailProfessors.value[0].bio || ''
  }
  if (detailProfessors.value[1]) {
    form.value.professor2Name = detailProfessors.value[1].name || ''
    form.value.professor2Info = detailProfessors.value[1].bio || ''
  }
  if (detailProfessors.value[2]) {
    form.value.professor3Name = detailProfessors.value[2].name || ''
    form.value.professor3Info = detailProfessors.value[2].bio || ''
  }

  // Suitable students → targetStudents (newline-separated)
  form.value.targetStudents = detailSuitableStudents.value.filter(Boolean).join('\n')

  // Outline → outlineInfo (newline-separated)
  form.value.outlineInfo = detailOutline.value.filter(Boolean).join('\n')

  // Process table → processInfo JSON
  const validProcess = detailProcessTable.value.filter(r => r.stage || r.link || r.summary)
  form.value.processInfo = validProcess.length ? JSON.stringify(validProcess) : ''

  // Workflow → workflow JSON
  const validWf = detailWorkflow.value.filter(s => s.title || s.desc)
  form.value.workflow = validWf.length ? JSON.stringify(validWf) : ''

  // Difficulty → star string
  form.value.difficulty = formatDifficulty(difficultyStars.value)
}

// ============ API & Data ============

async function fetchData() {
  loading.value = true
  try {
    const params = { page: currentPage.value, size: pageSize.value }
    if (filters.value.category) params.category = filters.value.category
    if (filters.value.mode) params.mode = filters.value.mode
    if (filters.value.status) params.status = filters.value.status
    if (filters.value.startDate) params.startDate = filters.value.startDate
    if (filters.value.keyword) params.keyword = filters.value.keyword
    const res = await getProjectList(params)
    tableData.value = res.records
    total.value = res.total
  } catch { /* handled by interceptor */ } finally { loading.value = false }
}

function resetDetailData() {
  detailProfessors.value = [{ name: '', nameEn: '', avatar: '', bio: '' }]
  detailSuitableStudents.value = ['']
  detailOutline.value = ['']
  detailProcessTable.value = [{ stage: '', link: '', form: '', hours: '', summary: '' }]
  detailWorkflow.value = [{ title: '', desc: '' }]
  difficultyStars.value = 0
  previewExpand.desc = false
  previewExpand.intro = false
}

// Parse difficulty star string (e.g., "★★★☆☆") to number
function parseDifficulty(str) {
  if (!str) return 0
  // Count filled stars
  const match = str.match(/★/g)
  return match ? match.length : 0
}

// Convert difficulty number (1-5) to star string (e.g., 3 → "★★★☆☆")
function formatDifficulty(num) {
  if (!num || num < 1) return ''
  return '★'.repeat(num) + '☆'.repeat(5 - num)
}

function openDialog(row) {
  activeTab.value = 'card'
  activeSections.value = ['sec1', 'sec2', 'sec3', 'sec4', 'sec5', 'sec6', 'sec7', 'sec8', 'sec9', 'sec10', 'sec11', 'sec12', 'sec13']
  resetDetailData()

  if (row) {
    isEdit.value = true
    editId.value = row.id
    form.value = { ...defaultForm, ...Object.fromEntries(Object.entries(row).filter(([_, v]) => v !== null && v !== undefined)) }
    parseDetailData(row)
    difficultyStars.value = parseDifficulty(form.value.difficulty)
  } else {
    isEdit.value = false
    editId.value = null
    form.value = { ...defaultForm }
    resetDetailData()
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (valid === false) return

  serializeDetailData()
  submitting.value = true
  try {
    if (isEdit.value) {
      await updateProject(editId.value, form.value)
      ElMessage.success('课题更新成功')
    } else {
      await createProject(form.value)
      ElMessage.success('课题创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } catch { /* handled by interceptor */ } finally { submitting.value = false }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定要删除课题「${row.titleCn}」吗？`, '删除确认', { type: 'warning' })
  try {
    await deleteProject(row.id)
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

// Professor list operations
function addProfessor() { detailProfessors.value.push({ name: '', nameEn: '', avatar: '', bio: '' }) }
function removeProfessor(i) { if (detailProfessors.value.length > 1) detailProfessors.value.splice(i, 1) }
function handleProfAvatarUpload(response, index) {
  if (response.code === 200 && response.data?.url) {
    detailProfessors.value[index].avatar = response.data.url
    ElMessage.success('头像上传成功')
  } else {
    ElMessage.error(response.message || '上传失败')
  }
}
</script>

<style lang="scss" scoped>
.project-manage {
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
.upload-hint { display: flex; align-items: center; gap: 4px; font-size: 12px; color: #999; margin-top: 6px; }
.pagination-wrap { display: flex; justify-content: flex-end; margin-top: 16px; }
:deep(.el-tabs__content) { padding: 12px 16px; max-height: 62vh; overflow-y: auto; }

/* ======== Card Preview (matching mini-program project.vue) ======== */
.mp-preview-bar {
  background: #f0f2f5; border-radius: 10px; padding: 12px 14px; margin-bottom: 16px;
  .mp-preview-label {
    font-size: 13px; color: #666; display: flex; align-items: center; gap: 4px; margin-bottom: 10px;
  }
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
  border-radius: 0 0 6px 0; font-size: 10px; font-weight: 600; color: #fff;
  white-space: nowrap;
  &.open { background: rgba(91,108,255,0.75); backdrop-filter: blur(4px); }
  &.full { background: rgba(224,80,80,0.75); backdrop-filter: blur(4px); }
  &.soon { background: rgba(240,160,32,0.75); backdrop-filter: blur(4px); }
}
.mp-card-info {
  flex: 1; display: flex; flex-direction: column; gap: 0; min-width: 0; padding-left: 8px;
}
.mp-title {
  font-size: 13px; font-weight: 700; color: #333; line-height: 1.5;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
  overflow: hidden; text-align: left; min-height: 39px; margin-bottom: 0;
}
.mp-profs {
  display: flex; flex-direction: column; gap: 0; margin-bottom: 0;
}
.mp-prof {
  display: flex; flex-direction: column; align-items: center; gap: 1px;
  padding: 3px 0; border-bottom: 1px solid #aaaaaa;
  &:last-child { border-bottom: none; }
}
.mp-prof-name { font-size: 11px; font-weight: 600; color: #333; white-space: nowrap; }
.mp-prof-school { font-size: 11px; color: #666; font-weight: 500; }
.mp-tags {
  display: flex; flex-wrap: wrap; justify-content: center; gap: 4px;
  max-height: 44px; overflow: hidden;
}
.mp-tag {
  font-size: 10px; padding: 3px 8px; border-radius: 3px;
  background: #f0f6f5; color: #5B6CFF; white-space: nowrap;
}
.mp-bottom {
  display: flex; align-items: center; justify-content: center; gap: 8px;
  margin-top: auto; font-size: 11px; color: #999;
}
.mp-clock-icon { font-size: 11px; flex-shrink: 0; }
.mp-date { color: #555; font-weight: 500; }
.mp-mode {
  font-size: 10px; padding: 2px 8px; border-radius: 10px; font-weight: 500; flex-shrink: 0;
  &.mp-mode-online { background: #e6f4f2; color: #5B6CFF; }
  &.mp-mode-offline { background: #fff3e0; color: #ff9800; }
  &.mp-mode-one2one { background: #f3e8ff; color: #7c3aed; }
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
  .detail-preview-panel {
    width: 340px; flex-shrink: 0;
  }
}

/* ======== Structured Editors ======== */
.prof-editor-list {
  display: flex; flex-direction: column; gap: 10px;
  .prof-editor-card {
    background: #f9fafb; border-radius: 8px; padding: 10px 12px; border: 1px solid #eee;
    .prof-editor-header {
      display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;
      span { font-size: 13px; font-weight: 600; color: #5B6CFF; }
    }
  }
}

.list-editor {
  display: flex; flex-direction: column; gap: 6px;
  .list-editor-item {
    display: flex; gap: 8px; align-items: center;
    .el-input { flex: 1; }
  }
}

.process-table-editor {
  .process-editor-header {
    display: flex; gap: 4px; background: rgba(91,108,255,0.08); padding: 6px 8px; border-radius: 6px 6px 0 0;
    font-size: 12px; font-weight: 600; color: #5B6CFF;
    .pe-col { text-align: center; }
  }
  .process-editor-row {
    display: flex; gap: 4px; align-items: center; padding: 6px 0; border-bottom: 1px solid #f0f0f0;
  }
}

.workflow-editor {
  display: flex; flex-direction: column; gap: 8px;
  .workflow-editor-item {
    display: flex; gap: 10px; align-items: flex-start;
    .wf-step-num {
      width: 24px; height: 24px; border-radius: 50%; background: #5B6CFF; color: #fff;
      font-size: 12px; font-weight: 700; display: flex; align-items: center; justify-content: center;
      flex-shrink: 0; margin-top: 4px;
    }
    .wf-step-fields { flex: 1; }
  }
}

/* ======== Detail Page Preview (matching mini-program) ======== */
.mp-detail-preview {
  background: #eef1f5; border-radius: 10px; padding: 8px;
  .mp-detail-label {
    font-size: 12px; color: #888; display: flex; align-items: center; gap: 4px; margin-bottom: 8px; padding: 0 4px;
  }
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

.mp-detail-tags { display: flex; gap: 5px; margin-bottom: 6px; }
.mp-detail-tag {
  font-size: 10px; padding: 1px 7px; border-radius: 4px;
  &.gray { background: #f0f2f5; color: #666; }
  &.green { background: rgba(91,108,255,0.08); color: #5B6CFF; }
}

.mp-detail-title-text { font-size: 14px; font-weight: 700; color: #333; line-height: 1.4; margin-bottom: 2px; }
.mp-detail-title-en { font-size: 11px; color: #5B6CFF; font-weight: 600; text-transform: uppercase; margin-bottom: 6px; }

.mp-detail-body-text { font-size: 11px; color: #666; line-height: 1.6; white-space: pre-line;
  &.collapsed { max-height: 44px; overflow: hidden; }
}
.mp-detail-expand { font-size: 11px; color: #5B6CFF; text-align: center; margin-top: 4px; cursor: pointer; }

.mp-detail-info-row { display: flex; align-items: flex-start; gap: 6px; padding: 3px 0; font-size: 11px; }
.mp-info-icon { flex-shrink: 0; font-size: 12px; }
.mp-info-label { color: #888; flex-shrink: 0; width: 52px; }
.mp-info-val { color: #444; flex: 1;
  &.difficulty { color: #f0a020; font-weight: 600; }
}

.mp-prof-card { display: flex; gap: 10px; align-items: flex-start; margin-top: 8px; }
.mp-prof-avatar {
  width: 36px; height: 36px; border-radius: 50%; background-color: #e0e0e0; background-size: cover; flex-shrink: 0;
}
.mp-prof-detail { flex: 1; }
.mp-prof-name-text { font-size: 12px; font-weight: 700; color: #333; display: block; }
.mp-prof-bio-text { font-size: 10px; color: #777; line-height: 1.4; display: block; margin-top: 2px; }

.mp-suitable-item {
  display: flex; gap: 10px; align-items: center; padding: 10px 12px; border-radius: 8px;
  &.mp-suitable-even { background: #fff; }
  &.mp-suitable-odd { background: #f4f0ff; }
}
.mp-suitable-bullet { width: 6px; height: 6px; border-radius: 50%; background: #7c5cfc; flex-shrink: 0; }
.mp-suitable-text { font-size: 11px; color: #555; line-height: 1.5; flex: 1; }

.mp-outline-item { font-size: 11px; color: #555; line-height: 1.8; }

.mp-process-table { font-size: 10px; }
.mp-process-header {
  display: flex; background: rgba(91,108,255,0.06); color: #5B6CFF; font-weight: 600;
  padding: 6px 4px; border-radius: 4px 4px 0 0; font-size: 9px;
  .mp-th { text-align: center; }
}
.mp-process-row {
  display: flex; padding: 5px 4px; border-bottom: 1px solid rgba(0,0,0,0.04); line-height: 1.3;
  .mp-td { text-align: center; font-size: 9px; color: #555;
    &:first-child { font-weight: 600; color: #5B6CFF; }
  }
}

.mp-wf-step {
  display: flex; gap: 10px; padding: 0 0 12px 0; position: relative;
  &:last-child { padding-bottom: 0; }
}
.mp-wf-num {
  width: 22px; height: 22px; border-radius: 50%; background: #5B6CFF; color: #fff;
  font-size: 11px; font-weight: 700; display: flex; align-items: center; justify-content: center;
  flex-shrink: 0; margin-top: 2px;
}
.mp-wf-text { font-size: 11px; color: #555; line-height: 1.4; }
.mp-wf-title { color: #333; font-weight: 600; display: block; }
.mp-wf-desc { display: block; font-size: 10px; color: #777; }

.mp-pdf-item { display: flex; align-items: center; gap: 8px; padding: 8px 10px; background: #fafbfc; border-radius: 8px; font-size: 11px; color: #444; margin-top: 4px; }
.mp-pdf-icon { flex-shrink: 0; font-size: 13px; }
.mp-pdf-name { flex: 1; }
</style>
