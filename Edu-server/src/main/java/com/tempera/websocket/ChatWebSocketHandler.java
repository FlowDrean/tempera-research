package com.tempera.websocket;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tempera.entity.ChatMessage;
import com.tempera.service.ChatMessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Component
@RequiredArgsConstructor
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private static final ConcurrentHashMap<Long, WebSocketSession> SESSION_MAP = new ConcurrentHashMap<>();
    private static final Long ADMIN_ID = 1L;
    private final ChatMessageService chatMessageService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId == null) {
            session.close(CloseStatus.NOT_ACCEPTABLE);
            return;
        }

        // close old session if exists
        WebSocketSession old = SESSION_MAP.remove(userId);
        if (old != null && old.isOpen()) {
            try { old.close(CloseStatus.NORMAL); } catch (Exception ignored) {}
        }
        SESSION_MAP.put(userId, session);

        // deliver unread messages
        LambdaQueryWrapper<ChatMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ChatMessage::getReceiverId, userId)
               .eq(ChatMessage::getIsRead, 0)
               .orderByAsc(ChatMessage::getCreateTime);
        List<ChatMessage> unread = chatMessageService.list(wrapper);
        for (ChatMessage msg : unread) {
            session.sendMessage(new TextMessage(toJson(msg)));
            msg.setIsRead(1);
        }
        if (!unread.isEmpty()) {
            chatMessageService.updateBatchById(unread);
        }

        log.info("WebSocket connected: userId={}, unread delivered={}", userId, unread.size());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        Long senderId = (Long) session.getAttributes().get("userId");
        String senderName = (String) session.getAttributes().get("username");
        if (senderId == null) return;

        Map<String, Object> payload = objectMapper.readValue(message.getPayload(), Map.class);
        String content = (String) payload.get("content");
        if (content == null || content.trim().isEmpty()) return;

        // determine receiver
        Long receiverId;
        if (ADMIN_ID.equals(senderId)) {
            Object target = payload.get("targetUserId");
            if (target == null) return;
            receiverId = ((Number) target).longValue();
        } else {
            receiverId = ADMIN_ID;
        }

        // persist
        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setSenderId(senderId);
        chatMessage.setReceiverId(receiverId);
        chatMessage.setContent(content.trim());
        String msgType = (String) payload.get("msgType");
        if (msgType != null) {
            chatMessage.setMsgType(msgType);
        }
        chatMessage.setIsRead(0);
        chatMessageService.save(chatMessage);

        // build response JSON
        Map<String, Object> out = new java.util.LinkedHashMap<>();
        out.put("type", "message");
        out.put("id", chatMessage.getId());
        out.put("senderId", senderId);
        out.put("senderName", senderName);
        out.put("receiverId", receiverId);
        out.put("content", chatMessage.getContent());
        if (msgType != null) {
            out.put("msgType", msgType);
        }
        out.put("createTime", chatMessage.getCreateTime() != null
                ? chatMessage.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                : LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

        String json = objectMapper.writeValueAsString(out);

        // send to receiver
        WebSocketSession receiverSession = SESSION_MAP.get(receiverId);
        if (receiverSession != null && receiverSession.isOpen()) {
            receiverSession.sendMessage(new TextMessage(json));
            // mark as read immediately since receiver is online
            chatMessage.setIsRead(1);
            chatMessageService.updateById(chatMessage);
        }

        // echo back to sender
        session.sendMessage(new TextMessage(json));
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId != null) {
            SESSION_MAP.remove(userId);
            log.info("WebSocket disconnected: userId={}", userId);
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId != null) {
            SESSION_MAP.remove(userId);
        }
        log.error("WebSocket transport error: userId={}", userId, exception);
        try { session.close(CloseStatus.SERVER_ERROR); } catch (IOException ignored) {}
    }

    private String toJson(ChatMessage msg) {
        try {
            Map<String, Object> map = new java.util.LinkedHashMap<>();
            map.put("type", "message");
            map.put("id", msg.getId());
            map.put("senderId", msg.getSenderId());
            map.put("receiverId", msg.getReceiverId());
            map.put("content", msg.getContent());
            if (msg.getMsgType() != null) {
                map.put("msgType", msg.getMsgType());
            }
            map.put("createTime", msg.getCreateTime() != null
                    ? msg.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                    : "");
            return objectMapper.writeValueAsString(map);
        } catch (Exception e) {
            return "{}";
        }
    }
}
