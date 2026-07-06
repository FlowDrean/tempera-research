package com.tempera.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("chat_message")
public class ChatMessage {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long senderId;
    private Long receiverId;
    private String content;
    private String msgType;
    private Integer isRead;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
