<template>
  <view class="page-container">
    <!-- 导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-action" @click="goBack">
        <SvgIcon name="arrow-left" color="#333" />
      </view>
      <text class="nav-title">搜索</text>
      <view class="nav-action"></view>
    </view>

    <!-- 搜索框 -->
    <view class="search-box-wrap">
      <view class="search-box">
        <SvgIcon name="search" color="#888" />
        <input class="search-input" v-model="keyword" placeholder="教授 / 学科 / 学校 / 海外 / 1V1定制"
          focus @confirm="onSearch" />
        <view v-if="keyword" class="search-clear" @click="keyword = ''; onSearch()">
          <SvgIcon name="close" color="#ccc" />
        </view>
      </view>
    </view>

    <!-- 分类标签 -->
    <view class="search-tabs" v-if="keyword">
      <view class="search-tab" v-for="tab in tabs" :key="tab.value"
        :class="{ active: activeTab === tab.value }" @click="activeTab = tab.value">
        {{ tab.label }}
      </view>
    </view>

    <!-- 搜索结果 -->
    <scroll-view enable-flex scroll-y class="page-content" :style="{ height: scrollHeight + 'px' }">
      <!-- 加载中 -->
      <view v-if="searching" class="loading-wrap">
        <text class="loading-text">搜索中...</text>
      </view>

      <view class="course-list-padding" v-if="!searching">
        <!-- 课题结果 -->
        <template v-if="activeTab === 'course'">
          <view class="course-row-card" v-for="course in courses" :key="'c' + course.id"
            @click="goToProject(course)">
            <view class="course-row-thumb" :style="{ backgroundImage: 'url(' + course.thumb + ')' }">
              <view class="course-status-badge" :class="course.statusClass">{{ course.statusText }}</view>
            </view>
            <view class="course-row-info">
              <text class="course-row-title">{{ course.title }}</text>
              <view class="course-professors">
                <view class="course-prof-item" v-for="prof in course.professors" :key="prof.name">
                  <text class="prof-name">{{ prof.name }}</text>
                  <text class="prof-school">{{ prof.school }}</text>
                </view>
              </view>
              <view class="course-directions">
                <text class="course-dir-tag" v-for="tag in course.tags" :key="tag">{{ tag }}</text>
              </view>
            </view>
          </view>
        </template>

        <!-- 竞赛与写作结果 -->
        <template v-if="activeTab === 'competition'">
          <view class="comp-list-card" v-for="comp in competitions" :key="'cp' + comp.id"
            @click="goToCompetition(comp)">
            <view class="comp-list-poster" :style="{ backgroundImage: 'url(' + comp.poster + ')' }">
              <view class="course-status-badge" :class="comp.statusClass">{{ comp.statusText }}</view>
            </view>
            <view class="comp-list-info">
              <text class="comp-list-title-zh">{{ comp.title }}</text>
              <text class="comp-list-title-en">{{ comp.titleEn }}</text>
              <view class="comp-list-meta">
                <view class="comp-list-meta-item">
                  <text class="mlabel">导师</text>
                  <text class="mvalue">{{ comp.instructor }}</text>
                </view>
                <view class="comp-list-meta-item">
                  <text class="mlabel">院校</text>
                  <text class="mvalue">{{ comp.school }}</text>
                </view>
                <view class="comp-list-meta-item">
                  <text class="mlabel">对象</text>
                  <text class="mvalue">{{ comp.participants }}</text>
                </view>
              </view>
              <view class="course-time-row">
                <text class="time-label">截止：{{ comp.deadline }}</text>
                <text class="course-mode-tag online">{{ comp.level }}</text>
                <text class="course-mode-tag one2one">{{ comp.groupType }}</text>
              </view>
            </view>
          </view>
        </template>

        <!-- 学术研学结果 -->
        <template v-if="activeTab === 'research'">
          <view class="course-row-card" v-for="r in researches" :key="'r' + r.id"
            @click="goToResearch(r)">
            <view class="course-row-thumb" :style="{ backgroundImage: 'url(' + r.poster + ')' }">
              <view class="course-status-badge" :class="r.status === 'full' ? 'full' : r.status === 'almost_full' ? 'almost' : 'open'">{{ r.statusText }}</view>
            </view>
            <view class="course-row-info">
              <text class="course-row-title">{{ r.titleCn }}</text>
              <text class="course-row-title-en">{{ r.titleEn }}</text>
              <view class="comp-list-meta">
                <view class="comp-list-meta-item">
                  <text class="mlabel">带队老师：</text>
                  <text class="mvalue">{{ r.instructorName }}</text>
                </view>
                <view class="comp-list-meta-item">
                  <text class="mlabel">教授职称：</text>
                  <text class="mvalue">{{ r.instructorTitle }}</text>
                </view>
              </view>
              <view class="course-time-row">
                <text class="time-label">适用学生：</text>
                <text class="time-value">{{ r.targetAudience }}</text>
                <text class="course-mode-tag online">研学</text>
              </view>
              <view class="course-directions">
                <text class="course-dir-tag" v-for="t in r.tags" :key="t">{{ t }}</text>
              </view>
            </view>
          </view>
        </template>

        <!-- 无结果 -->
        <view v-if="keyword && !currentResults.length" class="empty-result">
          <text>未找到相关结果</text>
        </view>

        <!-- 未输入关键词 -->
        <view v-if="!keyword && !searching" class="empty-result">
          <text>请输入关键词搜索</text>
        </view>

        <view style="height: 60rpx;"></view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import SvgIcon from '@/components/SvgIcon.vue'
import { getProjectList } from '@/api/project'
import { getCompetitionList } from '@/api/competition'
import { getResearchTourList } from '@/api/research'
import { resolveImageUrl } from '@/api/request'

const { windowHeight, statusBarHeight } = uni.getWindowInfo()
const scrollHeight = ref(windowHeight - statusBarHeight - 160)

const keyword = ref('')
const searching = ref(false)
const activeTab = ref('course')
const tabs = [
  { label: '课题', value: 'course' },
  { label: '竞赛与写作', value: 'competition' },
  { label: '学术研学', value: 'research' }
]

const statusMap = { open: '招生中', almost_full: '名额紧张', full: '已满额' }
const modeClassMap = { '线上': 'online', '线下': 'offline', '实践1V1定制': 'one2one', '混合': 'offline' }

const courses = ref([])
const competitions = ref([])
const researches = ref([])

// Build professor list from entity (卡片只展示前2位教授)
function buildProfessors(p) {
  const profs = []
  if (p.professor1Name) profs.push({ name: p.professor1Name, school: p.professor1Info || '' })
  if (p.professor2Name) profs.push({ name: p.professor2Name, school: p.professor2Info || '' })
  return profs
}

// Map project to card format
function mapProjectToCard(p) {
  const status = p.enrollmentStatus || p.status || 'open'
  return {
    id: p.id,
    title: p.titleCn || '',
    thumb: resolveImageUrl(p.poster),
    statusText: statusMap[status] || '招生中',
    statusClass: status === 'full' ? 'full' : (status === 'soon' || status === 'almost_full') ? 'almost' : 'open',
    field: p.category || '',
    mode: p.mode || '',
    date: p.startDate || '',
    modeClass: modeClassMap[p.mode] || 'online',
    professors: buildProfessors(p),
    tags: (p.tags || '').split(',').filter(Boolean).map(t => t.trim())
  }
}

// Fetch search results
async function doSearch() {
  const kw = keyword.value.trim()
  if (!kw) {
    courses.value = []
    competitions.value = []
    researches.value = []
    return
  }

  searching.value = true
  try {
    const params = { keyword: kw, size: 20 }

    // Fetch based on active tab
    if (activeTab.value === 'course') {
      const res = await getProjectList(params)
      courses.value = (res.records || []).map(mapProjectToCard)
    } else if (activeTab.value === 'competition') {
      const res = await getCompetitionList(params)
      competitions.value = (res.records || []).map(c => ({
        id: c.id,
        title: c.titleCn || '',
        titleEn: c.titleEn || '',
        poster: resolveImageUrl(c.poster),
        statusText: statusMap[c.status] || '招生中',
        statusClass: c.status === 'full' ? 'full' : (c.status === 'almost_full') ? 'almost' : 'open',
        instructor: c.instructorName || '',
        school: c.school || '',
        participants: c.targetAudience || '',
        deadline: c.deadline || '',
        level: c.levelName || '',
        groupType: c.participantType || ''
      }))
    } else if (activeTab.value === 'research') {
      const res = await getResearchTourList(params)
      researches.value = (res.records || []).map(r => ({
        id: r.id,
        titleCn: r.titleCn || '',
        titleEn: r.titleEn || '',
        instructorName: r.instructorName || '',
        instructorTitle: r.instructorTitle || '',
        targetAudience: r.targetAudience || '',
        poster: resolveImageUrl(r.poster),
        status: r.status || 'open',
        statusText: statusMap[r.status] || '招生中',
        tags: [r.country, r.season, '定制'].filter(Boolean)
      }))
    }
  } catch (e) {
    console.error('Search failed:', e)
  } finally {
    searching.value = false
  }
}

const onSearch = () => { doSearch() }

// Re-search when tab changes
watch(activeTab, () => {
  if (keyword.value.trim()) doSearch()
})

const currentResults = computed(() => {
  switch (activeTab.value) {
    case 'course': return courses.value
    case 'competition': return competitions.value
    case 'research': return researches.value
    default: return []
  }
})

const goBack = () => uni.navigateBack()

const goToProject = (course) => {
  uni.navigateTo({ url: `/pages/project-detail/project-detail?id=${course.id}` })
}

const goToCompetition = (comp) => {
  uni.navigateTo({ url: `/pages/competition-detail/competition-detail?id=${comp.id}` })
}

const goToResearch = (item) => {
  uni.navigateTo({ url: `/pages/research-detail/research-detail?id=${item.id}` })
}
</script>

<style lang="scss" scoped>
.page-container {
  height: 100vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background-color: #eef1f5;
  position: relative;
}

.nav-bar {
  height: 44px;
  background: transparent;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  position: relative;
  z-index: 61;
  flex-shrink: 0;
}
.nav-action {
  display: flex;
  align-items: center;
  color: #333;
}
.nav-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
}

.search-box-wrap {
  padding: 10px 14px;
  display: flex;
  align-items: center;
  flex-shrink: 0;
}
.search-box {
  flex: 1;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  border-radius: 18px;
  height: 36px;
  display: flex;
  align-items: center;
  padding: 0 14px;
  gap: 6px;
  border: 1px solid rgba(255, 255, 255, 0.5);
}
.search-input {
  flex: 1; border: none; background: transparent; outline: none; font-size: 13px; color: #333;
}
.search-clear { padding: 4px; }

.search-tabs {
  display: flex; gap: 12px; padding: 6px 14px 10px; flex-shrink: 0;
}
.search-tab {
  font-size: 12px; padding: 4px 14px; border-radius: 14px; background: #f0f2f5; color: #666;
  &.active { background: #5B6CFF; color: #fff; font-weight: 600; }
}

.page-content { flex: 1; }

.loading-wrap {
  display: flex; justify-content: center; padding: 40px 0;
}
.loading-text { font-size: 13px; color: #999; }

.course-list-padding { padding: 0 10px; }

.course-row-card {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  border-radius: 12px;
  padding: 6px 10px 2px 8px;
  display: flex;
  gap: 10px;
  margin-bottom: 12px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  align-items: flex-start;
  height: 180px;
  overflow: hidden;
}

.course-row-thumb {
  width: 110px; height: 172px; border-radius: 12px; background-color: #eee;
  background-size: cover; background-position: center; flex-shrink: 0; position: relative;
}

.course-status-badge {
  position: absolute; top: 0; left: 0; font-size: 10px; padding: 3px 8px;
  border-radius: 0 0 6px 0; font-weight: 600; color: #fff; white-space: nowrap;
}
.course-status-badge.open { background: rgba(91, 108, 255, 0.75); backdrop-filter: blur(4px); }
.course-status-badge.almost { background: rgba(240, 160, 32, 0.75); backdrop-filter: blur(4px); }
.course-status-badge.full { background: rgba(224, 80, 80, 0.75); backdrop-filter: blur(4px); }

.course-row-info {
  flex: 1; display: flex; flex-direction: column; gap: 2px; min-width: 0; padding-left: 8px;
}

.course-row-title {
  font-size: 13px; font-weight: 700; color: #333; line-height: 1.5;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
  overflow: hidden; text-align: left; min-height: 39px;
}
.course-row-title-en { font-size: 11px; color: #5B6CFF; font-weight: 600; margin-bottom: 2px; }

.course-professors {
  display: flex; flex-direction: column; gap: 0; margin-bottom: 0;
}
.course-prof-item {
  font-size: 11px; color: #555; line-height: 1.3; display: flex; flex-direction: column;
  align-items: center; gap: 1px; padding: 3px 0; border-bottom: 1px solid #aaaaaa;
}
.course-prof-item:last-child { border-bottom: none; }
.prof-name { font-weight: 600; color: #333; white-space: nowrap; }
.prof-school { color: #666; font-size: 11px; font-weight: 500; }

.course-directions {
  display: flex; flex-wrap: wrap; justify-content: center; gap: 4px;
  max-height: 44px; overflow: hidden;
}
.course-dir-tag {
  font-size: 10px; padding: 3px 8px; border-radius: 3px;
  background: #f0f6f5; color: #5B6CFF; white-space: nowrap;
}

.course-time-row {
  display: flex; align-items: center; justify-content: center; gap: 8px;
  font-size: 11px; color: #999; margin-top: auto;
}
.time-label { font-size: 11px; color: #999; }
.time-value { color: #555; font-weight: 500; }

.course-mode-tag {
  font-size: 10px; padding: 2px 8px; border-radius: 10px; font-weight: 500; flex-shrink: 0;
}
.course-mode-tag.online { background: #e6f4f2; color: #5B6CFF; }
.course-mode-tag.one2one { background: #f3e8ff; color: #7c3aed; }

/* Competition card styles (kept from original) */
.comp-list-card {
  background: rgba(255, 255, 255, 0.5); backdrop-filter: blur(12px);
  border-radius: 12px; padding: 6px 10px 2px 8px; display: flex;
  gap: 10px; margin-bottom: 12px; border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04); align-items: flex-start;
  height: 180px; overflow: hidden;
}
.comp-list-poster {
  width: 110px; height: 172px; border-radius: 12px; background-color: #eee;
  background-size: cover; background-position: center; flex-shrink: 0; position: relative;
}
.comp-list-info {
  flex: 1; display: flex; flex-direction: column; gap: 2px; min-width: 0; padding-left: 8px;
}
.comp-list-title-zh {
  font-size: 13px; font-weight: 700; color: #333; line-height: 1.5;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
  overflow: hidden; text-align: left;
}
.comp-list-title-en {
  font-size: 11px; color: #5B6CFF; font-weight: 600; margin-bottom: 2px;
}
.comp-list-meta { display: flex; flex-direction: column; gap: 1px; }
.comp-list-meta-item { display: flex; gap: 4px; font-size: 10px; }
.mlabel { color: #999; flex-shrink: 0; }
.mvalue { color: #555; }

.empty-result {
  display: flex; justify-content: center; padding: 60px 0;
  font-size: 14px; color: #999;
}
</style>
