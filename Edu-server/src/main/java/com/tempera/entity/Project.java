package com.tempera.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("project")
public class Project {
    @TableId(type = IdType.AUTO)
    private Long id;

    // === 卡片信息 ===
    private String titleCn;
    private String titleEn;
    private String description;
    private String descriptionEn;
    private String category;              // 学科领域：人文社科/理科/艺术科技/海外课题
    private String mode;                  // 教学形式：线上/线下/实践1v1定制/混合
    private String region;
    private String status;                // 招生状态
    private String enrollmentStatus;
    private LocalDate startDate;          // 开课时间
    private LocalDate endDate;
    private String difficulty;
    private String hoursInfo;
    private String poster;                // 卡片封面图
    private String tags;                  // 自定义标签

    // 教授信息（卡片展示）
    private String professor1Name;
    private String professor1Info;
    private String professor2Name;
    private String professor2Info;
    private String professor3Name;
    private String professor3Info;

    // === 详情页信息 ===
    private String detailPoster;          // 详情页宣传图

    // 学术背景
    private String academicBgLabel;
    private String academicBgTitleCn;
    private String academicBgTitleEn;
    private String academicBgContent;

    // 专题信息（部分复用卡片字段）
    private String outcome;               // 学术成果
    private String outcomeFormat;         // 成果形式
    private String targetStudents;        // 适合学生
    @TableField("outline")
    private String outlineInfo;           // 课题大纲
    private String schedule;              // 课程安排
    @TableField("process_info")
    private String processInfo;           // 科研流程
    private String matchSchools;          // 匹配院校
    private String workflow;              // 项目流程（保留原版）

    // 新增详情字段
    private String researchDirections;    // 研究方向
    private String professorIntro;        // 教授介绍（含3位教授）
    private String topicIntro;            // 专题介绍

    // PDF资料
    private String courseOutlinePdf;
    private String serviceFlowPdf;
    private String paperDisplayPdf;
    private String practiceResearchPdf;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
