import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: () => import('@/views/Layout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue'),
        meta: { title: '仪表盘', icon: 'Odometer' }
      },
      {
        path: 'users',
        name: 'UserManage',
        component: () => import('@/views/UserManage.vue'),
        meta: { title: '用户管理', icon: 'User' }
      },
      {
        path: 'banners',
        name: 'BannerManage',
        component: () => import('@/views/BannerManage.vue'),
        meta: { title: '首页轮播图', icon: 'Picture' }
      },
      {
        path: 'promotions',
        name: 'PromotionManage',
        component: () => import('@/views/PromotionManage.vue'),
        meta: { title: '探索成果模块', icon: 'Collection' }
      },
      {
        path: 'projects',
        name: 'ProjectManage',
        component: () => import('@/views/ProjectManage.vue'),
        meta: { title: '课题管理', icon: 'Notebook' }
      },
      {
        path: 'competitions',
        name: 'CompetitionManage',
        component: () => import('@/views/CompetitionManage.vue'),
        meta: { title: '竞赛与写作管理', icon: 'Trophy' }
      },
      {
        path: 'researches',
        name: 'ResearchManage',
        component: () => import('@/views/ResearchManage.vue'),
        meta: { title: '学术研学管理', icon: 'Promotion' }
      },
      {
        path: 'videos',
        name: 'VideoManage',
        component: () => import('@/views/VideoManage.vue'),
        meta: { title: '专访视频管理', icon: 'VideoCamera' }
      },
      {
        path: 'promo',
        name: 'PromoManage',
        component: () => import('@/views/PromoManage.vue'),
        meta: { title: '宣传图管理', icon: 'Headset' }
      },
      {
        path: 'chat',
        name: 'ChatManage',
        component: () => import('@/views/ChatManage.vue'),
        meta: { title: '用户消息回复', icon: 'ChatDotRound' }
      },
      {
        path: 'applications',
        name: 'ApplicationManage',
        component: () => import('@/views/ApplicationManage.vue'),
        meta: { title: '申请表单管理', icon: 'DocumentChecked' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guard
router.beforeEach((to, from, next) => {
  document.title = to.meta.title ? `${to.meta.title} - 坦培拉后台` : '坦培拉科研后台管理系统'

  const userStore = useUserStore()
  if (to.path !== '/login' && !userStore.token) {
    next('/login')
  } else if (to.path === '/login' && userStore.token) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router
