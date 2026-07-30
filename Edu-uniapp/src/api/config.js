/**
 * 服务器配置 - 修改此处即可同时更新 HTTP 和 WebSocket 地址
 *
 * ⚠️ 真机调试 / 正式发布前必读：
 * 微信小程序要求在「微信公众平台 → 开发管理 → 开发设置」中配置：
 *   1. request 合法域名（HTTP 请求）  → 你的域名
 *   2. socket 合法域名（WebSocket）   → 你的域名
 *   3. uploadFile 合法域名（上传文件） → 你的域名
 *   4. downloadFile 合法域名（下载文件）→ 你的域名
 *
 * 限制：
 *   - 不允许使用 IP 地址（如 192.144.187.103），必须是已备案的域名
 *   - 正式环境必须使用 https:// 和 wss:// 协议（需要 SSL 证书）
 *   - 仅「开发者工具」中可以勾选「不校验合法域名」跳过验证
 *   - 「真机调试」模式下，WebSocket 域名校验不可绕过
 *
 * 建议配置步骤：
 *   1. 购买一个已备案的域名，解析到服务器 IP
 *   2. 配置 nginx 反向代理 + SSL 证书（Let's Encrypt 免费）
 *   3. 将 HTTPS 域名和 WSS 域名填入下方 SERVER_HOST
 *   4. 在微信公众平台后台添加域名到对应合法域名列表
 *
 *   示例：
 *     const SERVER_HOST = 'https://your-domain.com'  // 自动推导 wss://your-domain.com/ws/chat
 *
 * 如果暂时没有域名，本项目已实现 HTTP 轮询兜底方案：
 *   当 WebSocket 连接失败时，聊天页会自动切换为 HTTP 轮询模式
 *   （发送消息用 POST /api/chat/send，接收消息用 GET /api/chat/poll 轮询）
 */
const SERVER_HOST = 'http://192.144.187.103'

// ========== 以下由 SERVER_HOST 自动推导，无需手动修改 ==========

/** HTTP API 基础地址 */
export const BASE_URL = SERVER_HOST + '/api'

/** 静态资源（图片/上传文件）基础地址 */
export const STATIC_BASE = SERVER_HOST

/** WebSocket 地址（自动根据 HTTP/HTTPS 协议切换 ws/wss） */
export const WS_URL = SERVER_HOST
  .replace('http://', 'ws://')
  .replace('https://', 'wss://') + '/ws/chat'

export default SERVER_HOST
