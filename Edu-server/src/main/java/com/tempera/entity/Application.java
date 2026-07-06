package com.tempera.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("application")
public class Application {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long projectId;
    private Long competitionId;
    private Long researchTourId;
    private String type;
    private String itemTitle;
    private String name;
    private String education;
    private String grade;
    private String languageTest;
    private String languageScore;
    private String phone;
    private String wechat;
    private String fieldInterest;
    private String hobby;
    private String hobbyDuration;
    private String status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime submitTime;
    private LocalDateTime reviewTime;
    private String reviewComment;
}
