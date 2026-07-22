/**
 * 服务器配置 - 修改此处即可同时更新 HTTP 和 WebSocket 地址
 *
 * 真机调试时，微信小程序要求：
 * 1. 服务器域名必须在微信公众平台后台配置（request 合法域名 + socket 合法域名）
 * 2. 正式环境必须使用 https:// 和 wss:// 协议
 * 3. 开发阶段可在开发者工具中开启「不校验合法域名」
 *
 * 如果你的服务器配置了 nginx 反向代理（如 80/443 端口代理到 8080），
 * 则不需要加端口号；否则需要加上 :8080
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
