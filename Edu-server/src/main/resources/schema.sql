-- ============================================
-- Tempera Research Platform - Database Schema
-- ============================================

CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(64) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `email` VARCHAR(128) DEFAULT '',
    `phone` VARCHAR(32) DEFAULT '',
    `wechat` VARCHAR(64) DEFAULT '',
    `avatar` VARCHAR(512) DEFAULT '',
    `role` VARCHAR(32) NOT NULL DEFAULT 'USER',
    `education` VARCHAR(64) DEFAULT '',
    `grade` VARCHAR(64) DEFAULT '',
    `school` VARCHAR(128) DEFAULT '',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `professor` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(64) NOT NULL,
    `name_en` VARCHAR(128) DEFAULT '',
    `school` VARCHAR(255) DEFAULT '',
    `school_en` VARCHAR(255) DEFAULT '',
    `research_field` VARCHAR(255) DEFAULT '',
    `research_field_en` VARCHAR(255) DEFAULT '',
    `bio` TEXT,
    `bio_en` TEXT,
    `avatar` VARCHAR(512) DEFAULT '',
    `title` VARCHAR(128) DEFAULT '',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `project` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title_cn` VARCHAR(255) NOT NULL,
    `title_en` VARCHAR(255) DEFAULT '',
    `description` TEXT,
    `description_en` TEXT,
    `category` VARCHAR(64) DEFAULT '',
    `mode` VARCHAR(32) DEFAULT '',
    `region` VARCHAR(64) DEFAULT '',
    `status` VARCHAR(32) DEFAULT 'open',
    `enrollment_status` VARCHAR(32) DEFAULT 'open',
    `start_date` DATE DEFAULT NULL,
    `end_date` DATE DEFAULT NULL,
    `difficulty` VARCHAR(8) DEFAULT '',
    `hours_info` VARCHAR(255) DEFAULT '',
    `outcome` VARCHAR(512) DEFAULT '',
    `outcome_format` TEXT DEFAULT NULL COMMENT '成果形式',
    `target_students` VARCHAR(255) DEFAULT '',
    `outline` TEXT,
    `schedule` TEXT,
    `process_info` TEXT,
    `match_schools` VARCHAR(512) DEFAULT '',
    `workflow` TEXT,
    `poster` VARCHAR(512) DEFAULT '',
    `tags` VARCHAR(500) DEFAULT '',
    `detail_poster` VARCHAR(512) DEFAULT '',
    `professor1_name` VARCHAR(100) DEFAULT '',
    `professor1_info` VARCHAR(255) DEFAULT '',
    `professor2_name` VARCHAR(100) DEFAULT '',
    `professor2_info` VARCHAR(255) DEFAULT '',
    `professor3_name` VARCHAR(100) DEFAULT '',
    `professor3_info` VARCHAR(255) DEFAULT '',
    `academic_bg_label` VARCHAR(100) DEFAULT '',
    `academic_bg_title_cn` VARCHAR(200) DEFAULT '',
    `academic_bg_title_en` VARCHAR(300) DEFAULT '',
    `academic_bg_content` TEXT,
    `research_directions` TEXT,
    `professor_intro` TEXT,
    `topic_intro` TEXT,
    `course_outline_pdf` VARCHAR(512) DEFAULT '',
    `service_flow_pdf` VARCHAR(512) DEFAULT '',
    `paper_display_pdf` VARCHAR(512) DEFAULT '',
    `practice_research_pdf` VARCHAR(512) DEFAULT '',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `project_professor` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `project_id` BIGINT NOT NULL,
    `professor_id` BIGINT NOT NULL,
    `sort_order` INT DEFAULT 0,
    INDEX `idx_pp_project` (`project_id`),
    INDEX `idx_pp_professor` (`professor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `research_tag` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(128) NOT NULL,
    `project_id` BIGINT NOT NULL,
    INDEX `idx_rt_project` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `competition` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title_cn` VARCHAR(255) NOT NULL,
    `title_en` VARCHAR(255) DEFAULT '',
    `description` TEXT,
    `category` VARCHAR(64) DEFAULT '',
    `level` VARCHAR(64) DEFAULT '',
    `participant_type` VARCHAR(32) DEFAULT '',
    `instructor_name` VARCHAR(64) DEFAULT '',
    `school` VARCHAR(255) DEFAULT '',
    `target_audience` VARCHAR(255) DEFAULT '',
    `poster` VARCHAR(512) DEFAULT '',
    `status` VARCHAR(32) DEFAULT 'open',
    `deadline` DATE DEFAULT NULL,
    `start_date` DATE DEFAULT NULL,
    `organizer` VARCHAR(255) DEFAULT '',
    `rules` TEXT,
    `awards` TEXT,
    `achievement_pdf` VARCHAR(512) DEFAULT '',
    `detail_poster` VARCHAR(512) DEFAULT '' COMMENT '详情宣传图',
    `introduction` TEXT COMMENT '介绍内容',
    `info_text` TEXT COMMENT '项目信息',
    `deadline_text` TEXT COMMENT '报名信息',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `research_tour` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title_cn` VARCHAR(255) NOT NULL,
    `title_en` VARCHAR(255) DEFAULT '',
    `description` TEXT,
    `country` VARCHAR(64) DEFAULT '',
    `season` VARCHAR(32) DEFAULT '',
    `instructor_name` VARCHAR(64) DEFAULT '',
    `instructor_title` VARCHAR(128) DEFAULT '',
    `school` VARCHAR(255) DEFAULT '',
    `target_audience` VARCHAR(255) DEFAULT '',
    `poster` VARCHAR(512) DEFAULT '',
    `status` VARCHAR(32) DEFAULT 'open',
    `location` VARCHAR(255) DEFAULT '',
    `duration` VARCHAR(32) DEFAULT '',
    `max_enrollment` INT DEFAULT 0,
    `schedule` TEXT,
    `notice` TEXT,
    `syllabus_pdf` VARCHAR(512) DEFAULT '',
    `achievement_pdf` VARCHAR(512) DEFAULT '',
    `detail_poster` VARCHAR(512) DEFAULT '' COMMENT '详情宣传图',
    `introduction` TEXT COMMENT '介绍内容',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `video` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `title_en` VARCHAR(255) DEFAULT '',
    `url` VARCHAR(512) DEFAULT '',
    `cover` VARCHAR(512) DEFAULT '',
    `duration` VARCHAR(16) DEFAULT '',
    `professor_name` VARCHAR(64) DEFAULT '',
    `professor_school` VARCHAR(255) DEFAULT '',
    `description` TEXT,
    `professor_bio` TEXT,
    `professor_avatar` VARCHAR(512) DEFAULT '',
    `views` INT DEFAULT 0,
    `category` VARCHAR(64) DEFAULT '',
    `sort_order` INT DEFAULT 0,
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `material` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `name_en` VARCHAR(255) DEFAULT '',
    `file_url` VARCHAR(512) DEFAULT '',
    `project_id` BIGINT NOT NULL,
    INDEX `idx_mat_project` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `banner` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `subtitle` VARCHAR(255) DEFAULT '',
    `image_url` VARCHAR(512) DEFAULT '',
    `bg_color` VARCHAR(255) DEFAULT '',
    `link_type` VARCHAR(32) DEFAULT '',
    `link_value` VARCHAR(512) DEFAULT '',
    `sort_order` INT DEFAULT 0,
    `is_active` TINYINT DEFAULT 1,
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `promotion` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `image_url` VARCHAR(512) DEFAULT '',
    `link_type` VARCHAR(32) DEFAULT '',
    `link_value` VARCHAR(512) DEFAULT '',
    `sort_order` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `explore_module` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL COMMENT '中文标题',
    `subtitle` VARCHAR(255) DEFAULT '' COMMENT '英文副标题',
    `image_url` VARCHAR(512) DEFAULT '' COMMENT '背景图片',
    `card_type` VARCHAR(16) DEFAULT 'small' COMMENT '卡片类型 large/small',
    `link_type` VARCHAR(32) DEFAULT '' COMMENT '跳转类型',
    `link_value` VARCHAR(512) DEFAULT '' COMMENT '跳转值',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `favorite` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `item_type` VARCHAR(32) NOT NULL COMMENT 'competition/research',
    `item_id` BIGINT NOT NULL,
    `item_title` VARCHAR(255) DEFAULT '',
    `item_title_en` VARCHAR(255) DEFAULT '',
    `item_poster` VARCHAR(512) DEFAULT '',
    `item_category` VARCHAR(64) DEFAULT '',
    `item_level` VARCHAR(64) DEFAULT '',
    `item_instructor` VARCHAR(64) DEFAULT '',
    `item_deadline` VARCHAR(64) DEFAULT '',
    `item_region` VARCHAR(64) DEFAULT '',
    `item_location` VARCHAR(255) DEFAULT '',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_fav_user` (`user_id`),
    UNIQUE KEY `uk_fav_user_item` (`user_id`, `item_type`, `item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `chat_message` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `sender_id` BIGINT NOT NULL,
    `receiver_id` BIGINT NOT NULL,
    `content` TEXT NOT NULL,
    `msg_type` VARCHAR(32) DEFAULT 'text' COMMENT 'text / image',
    `is_read` TINYINT(1) NOT NULL DEFAULT 0,
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sender_receiver (sender_id, receiver_id),
    INDEX idx_receiver_read (receiver_id, is_read, create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 兼容已有数据库：补充 msg_type 列
SET @stmt = IF(
  (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'tempera_research' AND TABLE_NAME = 'chat_message' AND COLUMN_NAME = 'msg_type') = 0,
  'ALTER TABLE chat_message ADD COLUMN msg_type VARCHAR(32) DEFAULT ''text'' COMMENT ''text / image'' AFTER content',
  'SELECT 1'
);
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS `application` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT DEFAULT NULL,
    `project_id` BIGINT DEFAULT NULL,
    `competition_id` BIGINT DEFAULT NULL,
    `research_tour_id` BIGINT DEFAULT NULL,
    `type` VARCHAR(32) DEFAULT '',
    `item_title` VARCHAR(500) DEFAULT '' COMMENT '申请的项目/竞赛/研学标题',
    `name` VARCHAR(64) DEFAULT '',
    `education` VARCHAR(64) DEFAULT '',
    `grade` VARCHAR(64) DEFAULT '',
    `language_test` VARCHAR(64) DEFAULT '',
    `language_score` VARCHAR(32) DEFAULT '',
    `phone` VARCHAR(32) DEFAULT '',
    `wechat` VARCHAR(64) DEFAULT '',
    `field_interest` VARCHAR(255) DEFAULT '',
    `hobby` VARCHAR(255) DEFAULT '',
    `hobby_duration` VARCHAR(64) DEFAULT '',
    `status` VARCHAR(32) DEFAULT 'pending',
    `submit_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `review_time` DATETIME DEFAULT NULL,
    `review_comment` VARCHAR(512) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
