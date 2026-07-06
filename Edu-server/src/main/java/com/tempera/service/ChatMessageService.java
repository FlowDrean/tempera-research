package com.tempera.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tempera.entity.ChatMessage;
import com.tempera.mapper.ChatMessageMapper;
import org.springframework.stereotype.Service;

@Service
public class ChatMessageService extends ServiceImpl<ChatMessageMapper, ChatMessage> {
}
