/*
Navicat MySQL Data Transfer

Source Server         : keshe
Source Server Version : 80041
Source Host           : localhost:3306
Source Database       : tempera_research

Target Server Type    : MYSQL
Target Server Version : 80041
File Encoding         : 65001

Date: 2026-07-08 17:28:27
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `application`
-- ----------------------------
DROP TABLE IF EXISTS `application`;
CREATE TABLE `application` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `project_id` bigint DEFAULT NULL,
  `competition_id` bigint DEFAULT NULL,
  `research_tour_id` bigint DEFAULT NULL,
  `type` varchar(20) NOT NULL,
  `item_title` varchar(500) DEFAULT '' COMMENT '申请的项目/竞赛/研学标题',
  `name` varchar(50) DEFAULT NULL,
  `education` varchar(20) DEFAULT NULL,
  `grade` varchar(20) DEFAULT NULL,
  `language_test` varchar(30) DEFAULT NULL,
  `language_score` varchar(20) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `wechat` varchar(50) DEFAULT NULL,
  `field_interest` varchar(30) DEFAULT NULL,
  `hobby` varchar(100) DEFAULT NULL,
  `hobby_duration` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `submit_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `review_time` datetime DEFAULT NULL,
  `review_comment` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of application
-- ----------------------------
INSERT INTO `application` VALUES ('1', '1', '1', null, null, 'project', '', '李传博', '博士', '12年级', '雅思 IELTS', '90', '18195876953', '18195876953', '人文', '去', '3年以上', 'APPROVED', '2026-07-05 00:55:30', '2026-07-06 19:55:15', '');
INSERT INTO `application` VALUES ('2', '1', null, null, null, 'project', '', '企鹅舞', '初中', '8年级', '雅思 IELTS', '恶趣味', '18195876953', '请问', '人文', '21', '3年以上', 'APPROVED', '2026-07-05 00:56:29', '2026-07-06 19:55:13', '');
INSERT INTO `application` VALUES ('3', '1', null, '1', null, 'competition', '', '打赏', '初中', '8年级', '雅思 IELTS', '阿斯顿', '17333603952', '请问', '理科', '我去饿', '3年以上', 'APPROVED', '2026-07-05 00:57:15', '2026-07-06 19:55:09', '');
INSERT INTO `application` VALUES ('4', '19', '1', null, null, 'project', '', '请问', '初中', '8年级', '雅思 IELTS', '10', '18195876953', '请问', '人文', '请问', '3年以上', 'APPROVED', '2026-07-06 19:05:32', '2026-07-06 19:55:07', '');
INSERT INTO `application` VALUES ('5', '19', null, null, '1', 'research', '', '请问', '硕士', '10年级', '雅思 IELTS', '6', '18195876953', '企鹅舞', '人文', '雷', '3年以上', 'APPROVED', '2026-07-06 19:23:17', '2026-07-06 19:54:55', '');
INSERT INTO `application` VALUES ('6', '77', null, null, null, 'project', '', '李传播', '博士', '10年级', '托福 TOEFL', '90', '18195876953', '18195876953', '艺术', '跑步', '3年以上', 'APPROVED', '2026-07-06 21:51:32', '2026-07-06 21:51:59', '');
INSERT INTO `application` VALUES ('7', '77', null, null, null, 'project', '', '李传博', '博士', '10年级', '托福 TOEFL', '90', '18195876953', '213213', '艺术', '跑步', '3年以上', 'PENDING', '2026-07-07 12:15:41', null, null);

-- ----------------------------
-- Table structure for `banner`
-- ----------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) DEFAULT NULL,
  `subtitle` varchar(200) DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `bg_color` varchar(255) DEFAULT '',
  `link_type` varchar(30) DEFAULT NULL,
  `link_value` varchar(200) DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `is_active` tinyint DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of banner
-- ----------------------------
INSERT INTO `banner` VALUES ('1', 'Test', 'Test', '/uploads/20260705/7fed2a8ecd2a494687c45fdaf8342e6d.jpg', '', 'video', '33', '1', '1', '2026-07-04 19:10:46');
INSERT INTO `banner` VALUES ('2', 'TEST', 'TEST', '', 'linear-gradient(135deg, #2d6a4f, #52b788)', '', '', '1', '1', '2026-07-04 19:10:46');
INSERT INTO `banner` VALUES ('3', '定制科研项目', '打造你的专属学术背景', '', '', 'course', '', '3', '1', '2026-07-04 19:10:46');
INSERT INTO `banner` VALUES ('4', '竞赛与写作辅导', '国内外顶级赛事全程助力', '', '', 'competition', '', '4', '1', '2026-07-04 19:10:46');
INSERT INTO `banner` VALUES ('5', '全球学术研学', '沉浸式名校科研体验', '', '', 'research', '', '5', '1', '2026-07-04 19:10:46');

-- ----------------------------
-- Table structure for `chat_message`
-- ----------------------------
DROP TABLE IF EXISTS `chat_message`;
CREATE TABLE `chat_message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sender_id` bigint NOT NULL,
  `receiver_id` bigint NOT NULL,
  `content` text NOT NULL,
  `msg_type` varchar(32) DEFAULT 'text' COMMENT 'text / image',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sender_receiver` (`sender_id`,`receiver_id`),
  KEY `idx_receiver_read` (`receiver_id`,`is_read`,`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of chat_message
-- ----------------------------
INSERT INTO `chat_message` VALUES ('1', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('2', '19', '1', 'test', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('3', '19', '1', 'http://localhost:8080/uploads/20260705/34e8fb46126e46469b5c569aaa5f6c40.jpg', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('4', '19', '1', 'http://localhost:8080/uploads/20260705/b18e4b3057a344aca8ae6cc6d3f0f580.jpg', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('5', '19', '1', 'http://localhost:8080/uploads/20260705/d79013f49afc4e34a11fe859713e24d0.jpg', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('6', '19', '1', 'http://localhost:8080/uploads/20260705/d3a5855ed34a456aabb2a4cca8c381fe.jpg', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('7', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('8', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('9', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('10', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('11', '19', '1', 'http://localhost:8080/uploads/20260705/9933a5f5eca049d88bdaa3bb81c0dae6.jpg', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('12', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('13', '19', '1', 'http://localhost:8080/uploads/20260705/37112d99aa0e49db9d9524d036a4be91.jpg', 'image', '1', null);
INSERT INTO `chat_message` VALUES ('14', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('15', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('16', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('17', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('18', '19', '1', '213', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('19', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('20', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('21', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('22', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('23', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('24', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('25', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('26', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('27', '19', '1', '132', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('28', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('29', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('30', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('31', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('32', '19', '1', '12', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('33', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('34', '19', '1', 'http://localhost:8080/uploads/20260706/67dba01a264c4b6097f4604e6ac9c697.png', 'image', '1', null);
INSERT INTO `chat_message` VALUES ('35', '19', '1', 'http://localhost:8080/uploads/20260706/b6a70cc6de484681b2fe0811d834929e.png', 'image', '1', null);
INSERT INTO `chat_message` VALUES ('36', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('37', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('38', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('39', '19', '1', '我去饿', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('40', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('41', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('42', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('43', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('44', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('45', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('46', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('47', '19', '1', '我去饿', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('48', '19', '1', '请问', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('49', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('50', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('51', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('52', '19', '1', '213', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('53', '19', '1', '123', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('54', '1', '19', '12', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('55', '19', '1', '12', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('56', '19', '1', '你好', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('57', '19', '1', 'http://localhost:8080/uploads/20260706/1412ee1e1fbb437f9940e0801b371669.jpg', 'image', '1', null);
INSERT INTO `chat_message` VALUES ('58', '1', '19', '你好呀', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('59', '77', '1', 'hello', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('60', '1', '77', 'hello', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('61', '19', '1', 'hello', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('62', '1', '19', '1234', 'text', '1', null);
INSERT INTO `chat_message` VALUES ('63', '19', '1', '1321', 'text', '1', null);

-- ----------------------------
-- Table structure for `competition`
-- ----------------------------
DROP TABLE IF EXISTS `competition`;
CREATE TABLE `competition` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title_cn` varchar(200) NOT NULL,
  `title_en` varchar(300) DEFAULT NULL,
  `description` text,
  `category` varchar(50) DEFAULT NULL,
  `level` varchar(30) DEFAULT NULL,
  `participant_type` varchar(20) DEFAULT NULL,
  `instructor_name` varchar(50) DEFAULT NULL,
  `school` varchar(100) DEFAULT NULL,
  `target_audience` varchar(200) DEFAULT NULL,
  `poster` varchar(500) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'open',
  `deadline` date DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `organizer` varchar(200) DEFAULT NULL,
  `rules` text,
  `awards` text,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `achievement_pdf` varchar(512) DEFAULT '' COMMENT '竞赛成果PDF',
  `detail_poster` varchar(512) DEFAULT '' COMMENT '详情宣传图',
  `introduction` text COMMENT '介绍内容',
  `info_text` text COMMENT '项目信息',
  `deadline_text` text COMMENT '报名信息',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of competition
-- ----------------------------
INSERT INTO `competition` VALUES ('1', '全国大学生数学建模竞赛123', 'National Math Modeling Contest', '中国规模最大的数学建模赛事之一，培养大学生运用数学方法和计算机工具解决实际问题的能力。', '国内竞赛', '国家级', '团队', '刘教授', '凡尔赛美术学院', '全国高校在校本科生1', 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&q=80', 'open', '2026-09-15', null, '中国工业与应用数学学会', '1. 每组最多3人，需在规定时间内完成题目并提交论文。\n2. 竞赛期间可使用各类图书资料、计算机和软件。\n3. 不得与组外人员讨论，不得抄袭他人成果。\n4. 论文需符合格式要求，按时通过官方系统提交。123', '一等奖：前1%，获奖证书 + 奖金5000元\n二等奖：前5%，获奖证书 + 奖金2000元\n三等奖：前15%，获奖证书\n优秀奖：若干，获奖证书123', '2026-07-06 17:46:03', '2026-07-06 17:46:03', '/uploads/20260706/807f616b2849482bb4f603208bb54229.pdf', '', null, null, null);
INSERT INTO `competition` VALUES ('2', '全国英语写作大赛', 'National English Writing Contest', '全国性英语写作赛事，提升学术英语写作能力，培养批判性思维与表达能力。', '国内写作', '国家级', '个人', '陈教授', '北京外国语大学', '全国高校在校生', 'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&q=80', 'open', '2026-10-01', null, '北京外国语大学', '1. 参赛作品须为原创，不得抄袭。\n2. 文章字数在1500-3000词之间。\n3. 主题自选，需符合学术规范。\n4. 提交截止日期前通过官网系统上传。', '一等奖：1名，奖金3000元 + 证书\n二等奖：3名，奖金1000元 + 证书\n三等奖：10名，证书\n优秀奖：若干，证书', '2026-07-06 17:46:03', '2026-07-06 17:46:03', '', '', null, null, null);
INSERT INTO `competition` VALUES ('3', '国际生物奥林匹克竞赛', 'International Biology Olympiad', '全球顶级生物学赛事，选拔和培养生物学科顶尖人才，与各国优秀学生同台竞技。', '国际竞赛', '国际级', '团队', '周教授', '北京大学', '全国中学生', 'https://images.unsplash.com/photo-1530210124550-912a7fe4def1?w=400&q=80', 'open', '2026-11-30', null, '国际生物奥林匹克组委会', '1. 参赛者须为中学生，年龄不超过19岁。\n2. 比赛分为理论和实验两部分。\n3. 各国限派4名代表参赛。\n4. 比赛语言为英语。', '金牌：前10%\n银牌：前25%\n铜牌：前50%\n参赛证书：所有参赛者', '2026-07-06 17:46:03', '2026-07-06 17:46:03', '', '', null, null, null);
INSERT INTO `competition` VALUES ('4', 'ACM程序设计大赛', 'ACM Programming Contest', '全球最具影响力的大学生程序设计竞赛，培养算法设计、编程实现与团队协作能力。', '国际竞赛', '国际级', '团队', '王教授', '清华大学', '全国高校在校本科生', 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=400&q=80', 'open', '2026-08-20', null, 'ACM国际计算机协会', '1. 每队3人，使用1台电脑。\n2. 比赛时长5小时，共8-12道题。\n3. 编程语言限C/C++/Java/Python。\n4. 按解题数量和罚时排名。', '冠军：奖杯 + 奖金10000元\n亚军：奖金5000元\n季军：奖金3000元\n优胜奖：前20名队伍，证书', '2026-07-06 17:46:03', '2026-07-06 17:46:03', '', '', null, null, null);
INSERT INTO `competition` VALUES ('33', '1', '1', '11', '国内竞赛', '国家级', '个人', '11', '11', '111', '/uploads/20260708/699a4e897eb249cc801be295b2111b72.jpg', 'open', '2026-06-30', null, '11', '11', '11', null, null, '/uploads/20260708/a5e09ac91459400bab85079d0dc98f8b.pdf', '/uploads/20260708/c55d94ac1d7d441db6adda1a9abee97a.jpg', '111', '111', '111');

-- ----------------------------
-- Table structure for `explore_module`
-- ----------------------------
DROP TABLE IF EXISTS `explore_module`;
CREATE TABLE `explore_module` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL COMMENT '中文标题',
  `subtitle` varchar(255) DEFAULT '' COMMENT '英文副标题',
  `image_url` varchar(512) DEFAULT '' COMMENT '背景图片',
  `card_type` varchar(16) DEFAULT 'small' COMMENT '卡片类型 large/small',
  `link_type` varchar(32) DEFAULT '' COMMENT '跳转类型',
  `link_value` varchar(512) DEFAULT '' COMMENT '跳转值',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of explore_module
-- ----------------------------
INSERT INTO `explore_module` VALUES ('1', '实践1V1定制1', '1-on-1 Practice', 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=600&q=80', 'large', 'course_mode', '', '1', '2026-07-07 15:39:16');
INSERT INTO `explore_module` VALUES ('2', '海外课题', 'Overseas Research', 'https://images.unsplash.com/photo-1523050854058-8df90910e683?w=400&q=80', 'small', 'course_field', '', '2', '2026-07-07 15:39:16');
INSERT INTO `explore_module` VALUES ('3', '学术研学', 'Academic Tour', 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=400&q=80', 'small', 'research_list', '0', '3', '2026-07-07 15:39:16');

-- ----------------------------
-- Table structure for `favorite`
-- ----------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `item_type` varchar(32) NOT NULL COMMENT 'competition/research',
  `item_id` bigint NOT NULL,
  `item_title` varchar(255) DEFAULT '',
  `item_title_en` varchar(255) DEFAULT '',
  `item_poster` varchar(512) DEFAULT '',
  `item_category` varchar(64) DEFAULT '',
  `item_level` varchar(64) DEFAULT '',
  `item_instructor` varchar(64) DEFAULT '',
  `item_deadline` varchar(64) DEFAULT '',
  `item_region` varchar(64) DEFAULT '',
  `item_location` varchar(255) DEFAULT '',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_fav_user_item` (`user_id`,`item_type`,`item_id`),
  KEY `idx_fav_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of favorite
-- ----------------------------
INSERT INTO `favorite` VALUES ('6', '19', 'research', '33', '海外名校研学 · 剑桥大学', 'Cambridge Study Tour', 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=600&q=80', '', '', '李教授', '', '英国', '剑桥大学校内', null);

-- ----------------------------
-- Table structure for `material`
-- ----------------------------
DROP TABLE IF EXISTS `material`;
CREATE TABLE `material` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `name_en` varchar(300) DEFAULT NULL,
  `file_url` varchar(500) DEFAULT NULL,
  `project_id` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of material
-- ----------------------------

-- ----------------------------
-- Table structure for `professor`
-- ----------------------------
DROP TABLE IF EXISTS `professor`;
CREATE TABLE `professor` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `name_en` varchar(100) DEFAULT NULL,
  `school` varchar(200) DEFAULT NULL,
  `school_en` varchar(200) DEFAULT NULL,
  `research_field` varchar(500) DEFAULT NULL,
  `research_field_en` varchar(300) DEFAULT NULL,
  `bio` text,
  `bio_en` text,
  `avatar` varchar(500) DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=313 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of professor
-- ----------------------------
INSERT INTO `professor` VALUES ('1', '张教授', 'Prof. Zhang', '清华大学社会科学学院', 'School of Social Sciences, Tsinghua University', '城市社会学、人口流动', 'Urban Sociology, Population Mobility', '清华大学社会科学学院教授，研究方向为城市社会学、人口流动，课题代表负责人，发表多篇核心文章。', 'Professor at Tsinghua University, specializing in urban sociology and population mobility.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', '教授/博导', '2026-07-04 19:10:46');
INSERT INTO `professor` VALUES ('2', '李教授', 'Prof. Li', '北京大学社会学系', 'Department of Sociology, Peking University', '社会结构、社区治理', 'Social Structure, Community Governance', '北京大学社会学系教授，长期从事社会分层与社区治理研究。', 'Professor at Peking University, long-term research in social stratification and community governance.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80', '教授', '2026-07-04 19:10:46');
INSERT INTO `professor` VALUES ('3', '王教授', 'Prof. Wang', '斯坦福大学计算机科学系', 'Computer Science Department, Stanford University', '机器学习、深度学习', 'Machine Learning, Deep Learning', '斯坦福大学计算机科学系教授，AI领域知名学者。', 'Professor at Stanford University, renowned scholar in AI.', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80', '教授/博导', '2026-07-04 19:10:46');
INSERT INTO `professor` VALUES ('4', '陈教授', 'Prof. Chen', '麻省理工学院AI实验室', 'MIT AI Lab', 'NLP、计算机视觉', 'NLP, Computer Vision', '麻省理工学院AI实验室教授，专注自然语言处理研究。', 'Professor at MIT AI Lab, focusing on natural language processing.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', '教授', '2026-07-04 19:10:46');
INSERT INTO `professor` VALUES ('5', '刘教授', 'Prof. Liu', '伦敦艺术大学中央圣马丁学院', 'Central Saint Martins, UAL', '交互设计、数字媒体', 'Interaction Design, Digital Media', '伦敦艺术大学教授，交互设计与数字媒体艺术家。', 'Professor at UAL, interaction designer and digital media artist.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80', '教授', '2026-07-04 19:10:46');
INSERT INTO `professor` VALUES ('6', '赵教授', 'Prof. Zhao', '中央美术学院设计学院', 'School of Design, CAFA', '视觉传达、用户体验', 'Visual Communication, UX', '中央美术学院设计学院教授，视觉传达与用户体验专家。', 'Professor at CAFA, expert in visual communication and UX.', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80', '教授', '2026-07-04 19:10:46');
INSERT INTO `professor` VALUES ('7', '周教授', 'Prof. Zhou', '哈佛大学环境科学与政策', 'Harvard University', '气候科学、环境政策', 'Climate Science, Environmental Policy', '哈佛大学环境科学与政策教授，气候研究领域权威。', 'Professor at Harvard, authority in climate research.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', '教授/博导', '2026-07-04 19:10:46');
INSERT INTO `professor` VALUES ('8', '吴教授', 'Prof. Wu', '剑桥大学物理与化学学院', 'University of Cambridge', '可持续发展、碳中和', 'Sustainable Development, Carbon Neutrality', '剑桥大学物理与化学学院正教授，可持续能源研究专家。', 'Professor at Cambridge, expert in sustainable energy research.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80', '教授', '2026-07-04 19:10:46');

-- ----------------------------
-- Table structure for `project`
-- ----------------------------
DROP TABLE IF EXISTS `project`;
CREATE TABLE `project` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title_cn` varchar(200) NOT NULL,
  `title_en` varchar(300) DEFAULT NULL,
  `description` text,
  `description_en` text,
  `category` varchar(50) DEFAULT NULL,
  `mode` varchar(30) DEFAULT NULL,
  `region` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'open',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `difficulty` varchar(10) DEFAULT NULL,
  `hours_info` varchar(200) DEFAULT NULL,
  `outcome` text,
  `outcome_format` text COMMENT '成果形式',
  `target_students` varchar(200) DEFAULT NULL,
  `outline` text,
  `schedule` text,
  `process_info` text,
  `match_schools` text,
  `workflow` text,
  `poster` varchar(500) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `enrollment_status` varchar(20) DEFAULT 'open' COMMENT '招生状态',
  `professor1_name` varchar(100) DEFAULT NULL COMMENT '教授1名称',
  `professor1_info` text COMMENT '教授1信息',
  `professor2_name` varchar(100) DEFAULT NULL COMMENT '教授2名称',
  `professor2_info` text COMMENT '教授2信息',
  `professor3_name` varchar(100) DEFAULT NULL COMMENT '教授3名称',
  `professor3_info` text COMMENT '教授3信息',
  `tags` varchar(500) DEFAULT NULL COMMENT '自定义标签',
  `detail_poster` varchar(500) DEFAULT NULL COMMENT '详情页宣传图',
  `academic_bg_label` varchar(100) DEFAULT NULL COMMENT '学术背景标签',
  `academic_bg_title_cn` varchar(200) DEFAULT NULL COMMENT '学术背景中文标题',
  `academic_bg_title_en` varchar(300) DEFAULT NULL COMMENT '学术背景英文标题',
  `academic_bg_content` text COMMENT '学术背景内容',
  `research_directions` text COMMENT '研究方向',
  `professor_intro` text COMMENT '教授介绍',
  `topic_intro` text COMMENT '专题介绍',
  `course_outline_pdf` varchar(500) DEFAULT NULL COMMENT '课程大纲PDF',
  `service_flow_pdf` varchar(500) DEFAULT NULL COMMENT '服务流程PDF',
  `paper_display_pdf` varchar(500) DEFAULT NULL COMMENT '论文展示PDF',
  `practice_research_pdf` varchar(500) DEFAULT NULL COMMENT '实践调研PDF',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of project
-- ----------------------------
INSERT INTO `project` VALUES ('25', 'TEST1', 'TEST', '本课题通过社会学视角，深入探讨城市化进程中的社会结构变迁、人口流动及其对城市发展', '', '人文社科', '线上', '', 'open', '2026-07-13', '2026-10-15', '', '3周线上课 + 6周论文指导 + 6次产学研导师课', '10封教授网申推荐信 + 1篇英文会议论文辅导 + 研学方案', '213213123', '高中生/本科生', '第一章：城市社会学概论\n第二章：人口流动理论\n第三章：社会结构分析\n第四章：社区治理模式\n第五章：城镇化进程研究\n第六章：公共政策分析\n第七章：质性研究方法\n第八章：定量研究方法\n第九章：论文写作指导\n第十章：研究成果展示', '第一周：开题 + 文献综述\n第二周：理论框架搭建\n第三周：研究方法与数据收集\n第四-六周：论文写作\n第七-九周：修改完善123', '[{\"stage\":\"1\",\"link\":\"1\",\"form\":\"1\",\"hours\":\"1\",\"summary\":\"1\"}]', '哈佛大学、耶鲁大学、哥伦比亚123123大学、芝加哥大学', '[{\"title\":\"123\",\"desc\":\"132\"}]', '/uploads/20260707/e927ae35c9284260bd5a0eb0a55f62be.png', '2026-07-06 21:18:46', '2026-07-06 21:18:46', 'open', '张教授', '北京大学教授', '李教授', '清华大学教授', '', '', '科普,科普,科普,科普,科普,科普,科普,科普,科普,科普,', '', '', '', '', '', '123', '[{\"name\":\"张教授\",\"nameEn\":\"123\",\"avatar\":\"\",\"bio\":\"北京大学教授\"},{\"name\":\"李教授\",\"nameEn\":\"312\",\"avatar\":\"/uploads/20260706/9fc519872a2444cc9ab972c061b9905c.jpg\",\"bio\":\"清华大学教授\"}]', 'QWEEWQEWQ', '/uploads/20260706/038768a5e4de47108ff313fba259f5a4.pdf', '/uploads/20260706/0c539204d9e94832bb8760d0f777f14d.pdf', '/uploads/20260706/165a82c2038047f3ab6c8edf902909a6.pdf', '/uploads/20260706/774b681cdfc1440283d949d9eca0163f.pdf');
INSERT INTO `project` VALUES ('26', '机器学习算法与深度学习应用实践研究', 'Machine Learning Algorithms & Applications', '深入探索机器学习与深度学习前沿算法，结合实际应用场景进行项目实践。', '', '理科', '线上', '', 'almost_full', '2026-08-01', '2026-11-01', '', '4周线上课 + 8周论文指导 + 8次产学研导师课', '教授推荐信 + 1篇国际会议论文 + 项目源码', '', '本科生/研究生', '第一章：机器学习基础\n第二章：监督学习算法\n第三章：无监督学习\n第四章：深度学习基础\n第五章：CNN与图像处理\n第六章：RNN与NLP\n第七章：强化学习\n第八章：模型部署', '第一周：ML基础回顾\n第二周：深度学习框架\n第三周：项目选题\n第四-八周：实验与论文', '', '斯坦福大学、MIT、CMU、UC Berkeley', '', '/uploads/20260707/8fd44d2b76114824a850f022964edc17.png', '2026-07-06 21:18:46', '2026-07-06 21:18:46', 'open', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '');
INSERT INTO `project` VALUES ('27', '数字艺术与交互媒体设计创新研究', 'Digital Art & Interactive Design', '探索数字技术与艺术创作的融合边界，研究交互设计在当代媒体中的应用。', null, '艺术科技', '混合', null, 'open', '2026-07-20', '2026-10-20', '3', '3周线下工作坊 + 5周线上指导 + 4次作品集评审', '作品集 + 展览机会 + 教授推荐信', null, '高中生/本科生', '第一章：交互设计概论\n第二章：用户体验研究\n第三章：视觉传达原理\n第四章：动态图形设计\n第五章：品牌设计策略\n第六章：信息可视化', '第一周：设计思维训练\n第二周：UX研究方法\n第三周：原型设计\n第四-六周：项目开发\n第七-八周：作品集完善', '阶段一：设计思维\n阶段二：用户研究\n阶段三：原型制作\n阶段四：迭代优化\n阶段五：成果展示', '中央圣马丁、RISD、Parsons、Pratt', '1.提交作品集\n2.面试评估\n3.导师匹配\n4.项目启动\n5.设计迭代\n6.最终展示\n7.展览呈现', 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&q=80', '2026-07-06 21:18:46', '2026-07-06 21:18:46', 'open', null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
INSERT INTO `project` VALUES ('28', '气候变化与可持续发展政策评估研究', 'Climate Change & Sustainable Development', '研究全球气候变化对可持续发展的影响，评估各国环境政策的实施效果。', null, '理科', '线上', null, 'full', '2026-09-01', '2026-12-01', '4', '4周线上课 + 8周论文指导 + 6次专家研讨', '教授推荐信 + 1篇SSCI论文辅导 + 政策评估报告', null, '本科生/研究生', '第一章：气候科学基础\n第二章：环境政策分析\n第三章：可持续发展理论\n第四章：碳中和路径\n第五章：碳排放交易\n第六章：清洁能源\n第七章：气候金融\n第八章：生态修复', '第一周：气候科学概述\n第二周：政策框架\n第三周：案例研究\n第四-八周：论文', '阶段一：基础理论学习\n阶段二：案例研究\n阶段三：数据分析\n阶段四：政策评估\n阶段五：报告撰写', '哈佛大学、剑桥大学、牛津大学、ETH Zurich', '1.申请材料提交\n2.导师面试\n3.确定研究方向\n4.文献综述\n5.数据分析\n6.论文撰写\n7.答辩评估', 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&q=80', '2026-07-06 21:18:46', '2026-07-06 21:18:46', 'open', null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
INSERT INTO `project` VALUES ('34', '123', '213', '123123', '', '人文社科', '线上', '', '', '2026-07-07', null, '★★★★★', '1', '1', '1', '1', '1', '1', '[{\"stage\":\"1\",\"link\":\"1\",\"form\":\"1\",\"hours\":\"1\",\"summary\":\"1\"}]', '1', '[{\"title\":\"1\",\"desc\":\"1\"}]', '/uploads/20260708/c5edd8df542d4f649ba2bf1cc0112bed.jpg', null, null, 'open', '张教授', '北京大学教授', '李教授', '北京大学教授', '', '', '后端,确定', '/uploads/20260708/955133ea76bb43e0ac3d91d0ce5c23e5.jpg', '', '', '', '', '1', '[{\"name\":\"张教授\",\"nameEn\":\"1\",\"avatar\":\"/uploads/20260708/be9cc09e4b8840e190366fdf32356eae.jpg\",\"bio\":\"北京大学教授\"},{\"name\":\"李教授\",\"nameEn\":\"1\",\"avatar\":\"/uploads/20260708/1fa66236fc554554bf2ff3402c2c6668.jpg\",\"bio\":\"北京大学教授\"}]', '1', '', '', '', '');

-- ----------------------------
-- Table structure for `project_professor`
-- ----------------------------
DROP TABLE IF EXISTS `project_professor`;
CREATE TABLE `project_professor` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` bigint NOT NULL,
  `professor_id` bigint NOT NULL,
  `sort_order` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=313 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of project_professor
-- ----------------------------

-- ----------------------------
-- Table structure for `promotion`
-- ----------------------------
DROP TABLE IF EXISTS `promotion`;
CREATE TABLE `promotion` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `link_type` varchar(30) DEFAULT NULL,
  `link_value` varchar(200) DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `is_active` tinyint DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of promotion
-- ----------------------------
INSERT INTO `promotion` VALUES ('1', '荒野大镖客2去问问强强我请问请问请问请问', '/uploads/20260705/0c70cd452c0b43a7a520a0ad79f71706.jpg', '', '', '1', '1', '2026-07-05 20:26:40');
INSERT INTO `promotion` VALUES ('2', '123123213', 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&q=80', '', '', '2', '1', '2026-07-05 20:26:40');
INSERT INTO `promotion` VALUES ('3', '学术论文发表', 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&q=80', '', '', '3', '1', '2026-07-05 20:26:40');
INSERT INTO `promotion` VALUES ('4', '海外研学体验', 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=400&q=80', '', '', '4', '1', '2026-07-05 20:26:40');
INSERT INTO `promotion` VALUES ('5', '1V1定制课题', 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=400&q=80', '', '', '5', '1', '2026-07-05 20:26:40');

-- ----------------------------
-- Table structure for `promo_image`
-- ----------------------------
DROP TABLE IF EXISTS `promo_image`;
CREATE TABLE `promo_image` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT '',
  `image_url` varchar(512) DEFAULT '',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of promo_image
-- ----------------------------
INSERT INTO `promo_image` VALUES ('1', '宣传', '/uploads/20260706/57f733ea2b4445e29a885821e7a39a13.jpg', '2026-07-06 18:59:58', null);

-- ----------------------------
-- Table structure for `research_tag`
-- ----------------------------
DROP TABLE IF EXISTS `research_tag`;
CREATE TABLE `research_tag` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `project_id` bigint DEFAULT NULL,
  `competition_id` bigint DEFAULT NULL,
  `research_tour_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1249 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of research_tag
-- ----------------------------

-- ----------------------------
-- Table structure for `research_tour`
-- ----------------------------
DROP TABLE IF EXISTS `research_tour`;
CREATE TABLE `research_tour` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title_cn` varchar(200) NOT NULL,
  `title_en` varchar(300) DEFAULT NULL,
  `description` text,
  `country` varchar(50) DEFAULT NULL,
  `season` varchar(20) DEFAULT NULL,
  `instructor_name` varchar(50) DEFAULT NULL,
  `instructor_title` varchar(200) DEFAULT NULL,
  `school` varchar(100) DEFAULT NULL,
  `target_audience` varchar(200) DEFAULT NULL,
  `poster` varchar(500) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'open',
  `location` varchar(200) DEFAULT NULL,
  `duration` varchar(50) DEFAULT NULL,
  `max_enrollment` int DEFAULT NULL,
  `schedule` text,
  `notice` text,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `syllabus_pdf` varchar(512) DEFAULT '' COMMENT '学术研学大纲PDF',
  `achievement_pdf` varchar(512) DEFAULT '' COMMENT '学术研学成果PDF',
  `detail_poster` varchar(512) DEFAULT '' COMMENT '详情宣传图',
  `introduction` text COMMENT '介绍内容',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of research_tour
-- ----------------------------
INSERT INTO `research_tour` VALUES ('25', '暑期科研集训营 · 清华大学', 'Summer Research Camp', '暑期科研集训营是由清华大学主办的沉浸式科研体验项目，旨在为全国优秀大学生提供近距离接触前沿科研的机会。', '中国', '暑假', '张教授', '清华大学暑期科研项目主任', '清华大学', '高中生 / 本科生', 'https://images.unsplash.com/photo-1562774053-701939374585?w=600&q=80', 'almost_full', '清华大学校内', '2周', '30', '第一周：开营仪式 + 实验室参观 + 导师讲座\n第二周：分组研究 + 成果汇报 + 结营仪式\n每日安排：上午课程 + 下午实践 + 晚间研讨', '报名时间：2026年6月1日 — 2026年7月10日\n申请材料：个人简历 + 成绩单 + 推荐信（可选）\n名额有限，报满即止', '2026-07-06 21:18:46', '2026-07-06 21:18:46', '', '', '', null);
INSERT INTO `research_tour` VALUES ('33', '海外名校研学 · 剑桥大学123', 'Cambridge Study Tour123', '剑桥大学研学项目为学生提供在世界顶级学府进行科研体验的机会。', '英国', '暑假', '李教授3213', '剑桥大学物理与化学学院123213正教授', '剑桥大学123', '本科生 / 研究生213', 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=600&q=80', 'open', '剑桥大学校内123', '2周', '29', '第一周：剑桥文化体验 + 学术讲座\n第二周：实验室研究 + 导师一对一指导\n第三周：成果展示 + 结业典礼123', '报名时间：2026年5月1日 — 2026年7月15日\n申请材料：个人陈述 + 成绩单 + 推荐信132', '2026-07-06 21:26:31', '2026-07-06 21:26:31', '/uploads/20260706/9649fdb2f53f4045a7c7e0d762baf87c.pdf', '/uploads/20260706/797ad904bfb7403dada507af6659d2b1.pdf', '', null);
INSERT INTO `research_tour` VALUES ('34', '学术写作工作坊 · 北京大学', 'Academic Writing Workshop', '由北京大学学术写作与修辞学教授亲自指导，帮助学生掌握英文学术论文写作的核心技巧与方法。', '中国', '秋季', '王教授', '北京大学学术写作与修辞学教授', '北京大学', '本科生', 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=600&q=80', 'almost_full', '北京大学校内', '1周', '40', 'Day1：学术写作基础\nDay2：文献综述方法\nDay3：论证与结构\nDay4：语言与风格\nDay5：修改与润色\nDay6：投稿策略\nDay7：成果展示', '报名时间：2026年8月1日 — 2026年9月15日\n申请材料：写作样本 + 个人简历', '2026-07-06 21:26:31', '2026-07-06 21:26:31', '', '', '', null);
INSERT INTO `research_tour` VALUES ('35', '人工智能研学营 · 斯坦福大学', 'AI Research Camp', '深入斯坦福大学AI实验室，在顶尖教授的指导下进行人工智能前沿课题的研究与探索。', '美国', '暑假', '陈教授', '斯坦福大学人工智能实验室教授', '斯坦福大学', '本科生 / 研究生', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&q=80', 'full', '斯坦福大学校内', '2周', '20', '第一周：AI基础课程 + 实验室参观\n第二周：项目实践 + 成果汇报\n每日安排：上午Lecture + 下午Lab + 晚间Seminar', '报名时间：2026年4月1日 — 2026年6月1日\n申请材料：编程作品或GitHub链接 + 成绩单\n名额已满，请关注下一期', '2026-07-06 21:26:31', '2026-07-06 21:26:31', '', '', '', null);
INSERT INTO `research_tour` VALUES ('36', '1', '1', '1', '中国', '春假', '1', '1', '1', '1', '/uploads/20260708/148402d0e57c4eb0bc572b5e17dceaf3.jpg', 'full', '1', '1', '30', '1', '1', null, null, '/uploads/20260708/6d64eebed78446cba6005a962fa4c163.pdf', '/uploads/20260708/aa98e2d73f834b0392273c13d1b708e8.pdf', '/uploads/20260708/9ec86b90b210408cb65db01f698878b4.jpg', '111');

-- ----------------------------
-- Table structure for `user`
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `wechat` varchar(50) DEFAULT NULL,
  `avatar` varchar(500) DEFAULT NULL,
  `role` varchar(20) DEFAULT 'user',
  `education` varchar(20) DEFAULT NULL,
  `grade` varchar(20) DEFAULT NULL,
  `school` varchar(100) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('1', 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'admin@tempera.com', null, null, null, 'admin', null, null, null, '2026-07-04 19:10:45', '2026-07-04 19:10:45');
INSERT INTO `user` VALUES ('2', 'editor', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'editor@tempera.com', null, null, null, 'editor', null, null, null, '2026-07-04 19:10:45', '2026-07-04 19:10:45');
INSERT INTO `user` VALUES ('19', '流梦', '$2a$10$e1BGerOXIEl7JXLD5IRoq.RTqX7dd9JWZrPiR4izMuOatlNsQ7z7m', '', '18195876953', '', null, 'USER', '', '', '', null, null);
INSERT INTO `user` VALUES ('77', 'lichuanbo', '$2a$10$QYQSeKFeYZmAzFTVmvjq.ObgtekSQpDTCa3LdF3cKDnkzZccUx3Mq', '', '17333603952', '', null, 'admin', '', '', '', null, null);
INSERT INTO `user` VALUES ('78', '123', '$2a$10$uQzfic8KPT.N2QNveesFO.wGq9AOGaQFGmd01eyXLvp770q8.pCdG', null, '18195855898', null, null, 'USER', null, null, null, null, null);

-- ----------------------------
-- Table structure for `video`
-- ----------------------------
DROP TABLE IF EXISTS `video`;
CREATE TABLE `video` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `title_en` varchar(300) DEFAULT NULL,
  `url` varchar(500) DEFAULT NULL,
  `cover` varchar(500) DEFAULT NULL,
  `duration` varchar(20) DEFAULT NULL,
  `professor_name` varchar(50) DEFAULT NULL,
  `professor_school` varchar(100) DEFAULT NULL,
  `description` text,
  `professor_bio` text,
  `professor_avatar` varchar(500) DEFAULT NULL,
  `views` int DEFAULT '0',
  `category` varchar(50) DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of video
-- ----------------------------
INSERT INTO `video` VALUES ('25', '人工智能未来发展的思考访谈', 'AI Future Development Interview', '', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&q=80', '12:46', '张教授', '清华大学', '本次访谈深入探讨了科研创新的未来发展趋势、技术突破与实践场景，以及其对现代社会发展和高等教育的深远影响。', '海内外顶尖知名院校资深博导，拥有极其丰富的学术项目指导经验和前沿学科工程落地研究成果。', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', '1235', 'AI', '0', '2026-07-06 21:18:46');
INSERT INTO `video` VALUES ('33', '气候变化与全球治理专访123', 'TEST', '/uploads/20260706/85ed73d3a84446e08f1d0a32d58f6c63.mp4', 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=400&q=80', '1:00', '李教', '哈佛大', '探讨气候变化对全球治理体系的挑战与机遇，分析各国在应对气候危机中的合作与博弈', '哈佛大学环境科学与政策教授，IPCC报告主要作者之', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80', '998', '环境', '0', '2026-07-06 21:26:36');
INSERT INTO `video` VALUES ('34', '艺术与科技融合创新专访', 'Art & Technology Fusion', '', 'https://images.unsplash.com/photo-1547891654-e66ed7edd96c?w=400&q=80', '10:30', '王教授', '伦敦艺术大学', '深入探讨艺术与科技交叉领域的最新发展，展示数字艺术、交互装置等创新实践案例。', '伦敦艺术大学中央圣马丁学院教授，国际知名数字艺术家与策展人。', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80', '769', '艺术', '0', '2026-07-06 21:26:36');
INSERT INTO `video` VALUES ('35', '社会学研究方法论专访', 'Sociology Research Methods', '', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80', '11:16', '陈教授', '北京大学', '分享社会学研究的方法论体系，从质性与定量两条路径出发，探讨当代社会科学研究的创新方法。', '北京大学社会学系教授，中国社会学会常务理事。', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', '655', '社科', '0', '2026-07-06 21:26:36');
INSERT INTO `video` VALUES ('36', '1', '1', '/uploads/20260708/d96a2199994f45769cac21cd44b30a7a.mp4', '/uploads/20260708/b214f5dd29e84f86bf638d92ee8527d9.png', '1', '1', '1', '1', '1', '/uploads/20260708/44cf1a343134406b8032c2665ffb537a.jpg', '1', '教授专访', '0', null);
