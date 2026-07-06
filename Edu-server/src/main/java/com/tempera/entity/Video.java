package com.tempera.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("video")
public class Video {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String titleEn;
    private String url;
    private String cover;
    private String duration;
    private String professorName;
    private String professorSchool;
    private String description;
    private String professorBio;
    private String professorAvatar;
    private Integer views;
    private String category;
    private Integer sortOrder;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
