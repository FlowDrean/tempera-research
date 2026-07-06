<script setup>
import { onLaunch, onShow, onHide } from '@dcloudio/uni-app'
import { useUserStore } from '@/stores/user'

onLaunch(() => {
  // 应用启动时从 storage 恢复登录态
  const userStore = useUserStore()
  userStore.init()
})
</script>

<style lang="scss">
@import '@/uni.scss';

/* ========== 原型图设计系统 ========== */
:root {
  --primary-color: #5B6CFF;
  --primary-light: #B1F0FF;
  --bg-color: #B1F0FF;
  --text-main: #333333;
  --text-sub: #999999;
  --text-light: #c0c4cc;
  --border-color: #eeeeee;
  --card-bg: #ffffff;
}

page {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  font-size: 14px;
  color: var(--text-main);
  background: #eef1f5;
  -webkit-tap-highlight-color: transparent;
}

/* ========== 通用页面容器 ========== */
.page-container {
  width: 100%;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  position: relative;
  background-color: #eef1f5;
}

/* ========== 毛玻璃卡片 ========== */
.glass-card {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

/* ========== 毛玻璃面板 ========== */
.glass-panel {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 14px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  overflow: hidden;
}

/* ========== 详情区块 ========== */
.detail-section {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  padding: 16px;
  margin: 0 12px 10px;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

/* ========== 区块标题（左侧蓝色竖条） ========== */
.section-title {
  font-size: 15px;
  font-weight: bold;
  color: var(--text-main);
  margin-bottom: 12px;
  position: relative;
  padding-left: 10px;
  display: flex;
  align-items: baseline;
  gap: 8px;
  padding-bottom: 10px;
  border-bottom: 1px solid #e8e8e8;

  &::before {
    content: '';
    position: absolute;
    left: 0;
    top: 4px;
    width: 3px;
    height: 14px;
    background: var(--primary-color);
    border-radius: 2px;
  }

  .zh { font-weight: 700; }
  .en {
    font-size: 10px;
    color: var(--primary-color);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.4px;
  }
}

/* ========== 标签系统 ========== */
.ui-tag {
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: 500;
}
.ui-tag-gray { background: #f0f2f5; color: #666666; }
.ui-tag-green { background: #e6f4f2; color: var(--primary-color); }
.ui-tag-orange { background: #fff3e0; color: #ff9800; }

/* ========== 状态标签 ========== */
.status-badge {
  position: absolute;
  top: 0;
  left: 0;
  font-size: 10px;
  padding: 3px 8px;
  border-radius: 0 0 6px 0;
  font-weight: 600;
  color: #fff;
  white-space: nowrap;
}
.status-open {
  background: rgba(91, 108, 255, 0.75);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
}
.status-almost {
  background: rgba(240, 160, 32, 0.75);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
}
.status-full {
  background: rgba(224, 80, 80, 0.75);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
}

/* ========== 按钮系统 ========== */
.btn-primary {
  background: var(--primary-color);
  color: #ffffff;
  border: none;
  border-radius: 14px;
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  height: 44px;
}
.btn-outline {
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 14px;
  color: var(--primary-color);
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 44px;
}

.btn-block-primary {
  width: 100%;
  height: 44px;
  background: var(--primary-color);
  border-radius: 22px;
  color: #ffffff;
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
}

/* ========== 搜索框 ========== */
.search-box {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 18px;
  height: 36px;
  display: flex;
  align-items: center;
  padding: 0 14px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  gap: 6px;

  input {
    border: none;
    background: transparent;
    outline: none;
    width: 100%;
    font-size: 13px;
    color: var(--text-main);
  }
}

/* ========== 弹性布局工具 ========== */
.flex-center { display: flex; align-items: center; justify-content: center; }
.flex-between { display: flex; align-items: center; justify-content: space-between; }
.flex-col { display: flex; flex-direction: column; }

/* ========== 动画 ========== */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
@keyframes scaleUp {
  from { transform: scale(0.85); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}
</style>
