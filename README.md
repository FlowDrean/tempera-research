# 坦培拉科研 (Tempera Research)

坦培拉科研是一个面向中学生的科研教育平台，提供研究课题发现、竞赛报名、学术研学、教授专访视频等功能。学生可以通过微信小程序浏览和申请各类学术项目，管理员可通过后台管理系统进行内容管理和申请审核。

## ✨ 核心功能

- **课题发现** — 按分类（人文社科/理科/艺术科技/海外）、教学模式（线上/线下/1v1/混合）、招生状态等筛选研究课题，查看教授简介、学术背景、研究方向、课题介绍及 PDF 参考资料
- **竞赛与写作** — 浏览各类学科竞赛与写作比赛，按分类、级别、参与类型筛选，查看比赛详情、规则、奖项并在线报名
- **学术研学** — 浏览国内外学术研学项目，按国家和季节筛选，查看行程安排、导师信息、注意事项等
- **教授专访视频** — 观看教授科研访谈视频，支持播放量统计
- **用户系统** — JWT 鉴权的注册/登录，支持个人信息管理（学历、年级、学校、联系方式等）
- **报名申请** — 对课题、竞赛、研学项目提交报名申请，支持审核状态跟踪（待审核/已通过/已拒绝）
- **收藏功能** — 收藏感兴趣的竞赛或研学项目
- **实时聊天** — 学生与管理员通过 WebSocket 实时沟通，支持消息持久化、未读消息提醒、已读回执
- **后台管理** — 全功能管理后台，支持用户、轮播图、推广卡片、课题、竞赛、研学、视频、宣传图、报名申请等内容的 CRUD 操作

## 🏗️ 技术栈

### 后端 ([Edu-server](Edu-server/))

| 技术 | 说明 |
|------|------|
| Java 17 | 运行环境 |
| Spring Boot 3.2.0 | 核心框架 |
| Spring MVC | REST API |
| Spring Security | 认证与授权（JWT + BCrypt） |
| Spring WebSocket | 实时通信 |
| MyBatis Plus 3.5.5 | ORM 框架 |
| MySQL 8 | 关系型数据库 |
| jjwt 0.12.3 | JWT 令牌管理 |
| Hutool 5.8.24 | Java 工具库 |
| Lombok | 代码简化 |
| Maven | 构建工具 |

### 管理后台 ([Edu-background](Edu-background/))

| 技术 | 说明 |
|------|------|
| Vue 3.4 | 前端框架（Composition API） |
| Vite 5.4 | 构建工具 |
| Element Plus 2.7 | UI 组件库 |
| Pinia 2.1 | 状态管理 |
| Vue Router 4.3 | 路由管理 |
| Axios 1.7 | HTTP 客户端 |
| ECharts 6.1 | 数据图表 |
| SCSS | 样式预处理器 |

### 微信小程序 ([Edu-uniapp](Edu-uniapp/))

| 技术 | 说明 |
|------|------|
| UniApp (DCloudio) | 跨平台框架 |
| Vue 3.5 | 前端框架 |
| Vite 5.2 | 构建工具 |
| Pinia 2.1 | 状态管理 |
| SCSS | 样式预处理器 |
| 微信小程序 (mp-weixin) | 目标平台 |

## 📂 项目结构

```
Edu-Sys/
├── Edu-server/              # Spring Boot 后端服务
│   ├── src/main/java/com/tempera/
│   │   ├── TemperaApplication.java    # 启动类
│   │   ├── common/                    # 通用工具类（Result、异常处理）
│   │   ├── config/                    # 配置类（Security、CORS、WebSocket）
│   │   ├── controller/                # REST 控制器
│   │   ├── entity/                    # MyBatis Plus 实体类
│   │   ├── mapper/                    # MyBatis Plus Mapper 接口
│   │   ├── security/                  # JWT 认证过滤器
│   │   ├── service/                   # 业务逻辑层
│   │   └── websocket/                 # WebSocket 聊天处理器
│   ├── src/main/resources/
│   │   ├── application.yml            # 应用配置
│   │   ├── schema.sql                 # 数据库建表脚本
│   │   └── data.sql                   # 初始数据
│   └── pom.xml                        # Maven 配置
├── Edu-background/          # Vue 3 管理后台
│   ├── src/
│   │   ├── api/                       # API 封装
│   │   ├── components/                # 公共组件
│   │   ├── layout/                    # 布局组件
│   │   ├── router/                    # 路由配置
│   │   ├── stores/                    # Pinia 状态
│   │   ├── views/                     # 页面组件
│   │   └── utils/                     # 工具函数
│   └── vite.config.js                 # Vite 配置
├── Edu-uniapp/              # 微信小程序（UniApp）
│   ├── src/
│   │   ├── api/                       # API 封装
│   │   ├── components/                # 公共组件
│   │   ├── custom-tab-bar/            # 自定义底部导航
│   │   ├── pages/                     # 页面
│   │   ├── stores/                    # Pinia 状态
│   │   └── utils/                     # 工具函数（WebSocket 等）
│   ├── pages.json                     # 页面路由配置
│   └── manifest.json                  # 应用配置
├── 原型图/                  # 小程序原型设计（HTML）
├── 图标/                    # UI 设计图标资源
└── 需求/                    # 需求原型截图
```

## 🗄️ 数据库设计

数据库名为 `tempera_research`，共 15 张表：

| 表名 | 说明 |
|------|------|
| `user` | 用户账户（用户名、密码、角色、学历等） |
| `professor` | 教授信息（姓名、学校、研究方向、简介等） |
| `project` | 研究课题（中英文标题、分类、模式、地区、状态、日期、难度、学术背景、研究方向、课题介绍、PDF 参考资料、海报等） |
| `project_professor` | 课题与教授多对多关联表 |
| `research_tag` | 课题标签 |
| `competition` | 竞赛/写作比赛（中英文标题、分类、级别、参与类型、指导老师、学校、日期、主办方、规则、奖项等） |
| `research_tour` | 学术研学（中英文标题、国家、季节、导师、学校、地点、时长、名额、行程安排等） |
| `video` | 教授专访视频（标题、URL、封面、时长、教授信息、播放量、分类等） |
| `material` | 课题附加资料 |
| `banner` | 首页轮播图 |
| `promotion` | 首页推广/探索卡片 |
| `favorite` | 用户收藏（关联用户、收藏类型和项目） |
| `chat_message` | 聊天消息（发送方、接收方、内容、消息类型、已读状态） |
| `application` | 报名申请（关联用户、目标项目、个人信息、语言成绩、审核状态） |
| `promo_image` | 宣传图片管理（单行表） |

## 🚀 快速开始

### 环境要求

- JDK 17+
- Maven 3.8+
- MySQL 8.0+
- Node.js 18+
- HBuilder X（如需编译微信小程序）

### 1. 数据库初始化

```bash
# 创建数据库
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS tempera_research DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 导入建表脚本与初始数据
mysql -u root -p tempera_research < Edu-server/src/main/resources/schema.sql
mysql -u root -p tempera_research < Edu-server/src/main/resources/data.sql
```

### 2. 启动后端服务

```bash
cd Edu-server
# 修改 src/main/resources/application.yml 中的数据库连接信息
mvn clean package -DskipTests
java -jar target/tempera-*.jar
```

后端服务默认运行在 `http://localhost:8080`。

### 3. 启动管理后台

```bash
cd Edu-background
npm install
npm run dev
```

管理后台开发服务器默认运行在 `http://localhost:3000`，并自动代理 `/api` 和 `/uploads` 请求到后端。

### 4. 编译微信小程序

使用 HBuilder X 打开 `Edu-uniapp/` 目录，配置微信小程序 AppID 后编译运行。

### API 端点概览

| 路径前缀 | 说明 |
|----------|------|
| `/api/user/**` | 用户管理（注册/登录公开，其余需认证） |
| `/api/project/**` | 研究课题（列表/详情公开，管理需管理员权限） |
| `/api/competition/**` | 竞赛管理（列表/详情公开） |
| `/api/research-tour/**` | 学术研学（列表/详情公开） |
| `/api/video/**` | 专访视频（列表/详情公开） |
| `/api/banner/**` | 轮播图管理 |
| `/api/promotion/**` | 推广卡片管理 |
| `/api/promo/**` | 宣传图片管理 |
| `/api/application/**` | 报名申请 |
| `/api/favorite/**` | 收藏管理 |
| `/api/chat/**` | 聊天记录 |
| `/api/file/upload` | 文件上传 |
| `/ws/chat` | WebSocket 实时聊天 |

## 📦 构建部署

### 管理后台构建

```bash
cd Edu-background
npm run build
```

构建产物输出至 `Edu-server/src/main/resources/static/`，由后端 Spring Boot 的 `SpaController` 统一提供前端路由服务。

### 后端打包

```bash
cd Edu-server
mvn clean package -DskipTests
```

生成的 JAR 包包含管理后台静态资源，可直接部署运行。

### 微信小程序发布

使用 HBuilder X 编译为微信小程序后，通过微信开发者工具上传发布。

## 📄 许可证

本项目为内部使用项目。

---

**坦培拉科研** — 连接中学生与学术研究前沿的桥梁。
