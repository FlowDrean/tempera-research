package com.tempera.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("professor")
public class Professor {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String nameEn;
    private String school;
    private String schoolEn;
    private String researchField;
    private String researchFieldEn;
    private String bio;
    private String bioEn;
    private String avatar;
    private String title;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
