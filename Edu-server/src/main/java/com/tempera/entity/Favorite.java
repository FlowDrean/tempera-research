package com.tempera.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("favorite")
public class Favorite {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String itemType;
    private Long itemId;
    private String itemTitle;
    private String itemTitleEn;
    private String itemPoster;
    private String itemCategory;
    private String itemLevel;
    private String itemInstructor;
    private String itemDeadline;
    private String itemRegion;
    private String itemLocation;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
