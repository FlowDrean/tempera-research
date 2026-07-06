package com.tempera.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("banner")
public class Banner {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String subtitle;
    private String imageUrl;
    private String bgColor;
    private String linkType;
    private String linkValue;
    private Integer sortOrder;
    private Integer isActive;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
