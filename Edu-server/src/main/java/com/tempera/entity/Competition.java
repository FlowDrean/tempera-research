package com.tempera.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("competition")
public class Competition {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String titleCn;
    private String titleEn;
    private String description;
    private String category;
    @TableField("level")
    private String levelName;
    private String participantType;
    private String instructorName;
    private String school;
    private String targetAudience;
    private String poster;
    private String status;
    private LocalDate deadline;
    private LocalDate startDate;
    private String organizer;
    private String rules;
    private String awards;
    private String achievementPdf;
    private String detailPoster;
    private String introduction;
    private String infoText;
    private String deadlineText;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
