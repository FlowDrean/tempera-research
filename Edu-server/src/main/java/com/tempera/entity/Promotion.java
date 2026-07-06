package com.tempera.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("promotion")
public class Promotion {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String imageUrl;
    private String linkType;
    private String linkValue;
    private Integer sortOrder;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
