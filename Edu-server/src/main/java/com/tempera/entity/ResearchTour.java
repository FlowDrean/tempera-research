package com.tempera.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("research_tour")
public class ResearchTour {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String titleCn;
    private String titleEn;
    private String description;
    private String country;
    private String season;
    private String instructorName;
    private String instructorTitle;
    private String school;
    private String targetAudience;
    private String poster;
    private String status;
    private String location;
    private String duration;
    private Integer maxEnrollment;
    private String schedule;
    private String notice;
    private String syllabusPdf;
    private String achievementPdf;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
