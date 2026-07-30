package com.tempera.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.ChatMessage;
import com.tempera.entity.User;
import com.tempera.service.ChatMessageService;
import com.tempera.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatMessageService chatMessageService;
    private final UserService userService;
    private static final Long ADMIN_ID = 1L;

    /**
     * 获取当前用户与 admin 的聊天记录
     */
    @GetMapping("/history")
    public Result<PageResult<ChatMessage>> history(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size) {
        Long userId = getCurrentUserId();

        LambdaQueryWrapper<ChatMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .eq(ChatMessage::getSenderId, userId).eq(ChatMessage::getReceiverId, ADMIN_ID)
                .or()
                .eq(ChatMessage::getSenderId, ADMIN_ID).eq(ChatMessage::getReceiverId, userId)
        );
        wrapper.orderByAsc(ChatMessage::getCreateTime);

        Page<ChatMessage> pageResult = chatMessageService.page(new Page<>(page, size), wrapper);

        // mark messages sent to current user as read
        List<ChatMessage> records = pageResult.getRecords();
        List<ChatMessage> toUpdate = records.stream()
                .filter(m -> m.getReceiverId().equals(userId) && m.getIsRead() == 0)
                .peek(m -> m.setIsRead(1))
                .collect(Collectors.toList());
        if (!toUpdate.isEmpty()) {
            chatMessageService.updateBatchById(toUpdate);
        }

        return Result.ok(PageResult.of(pageResult));
    }

    /**
     * admin 查看与指定用户的聊天记录
     */
    @GetMapping("/admin/history/{targetUserId}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<PageResult<ChatMessage>> adminHistory(
            @PathVariable Long targetUserId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size) {

        LambdaQueryWrapper<ChatMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .eq(ChatMessage::getSenderId, ADMIN_ID).eq(ChatMessage::getReceiverId, targetUserId)
                .or()
                .eq(ChatMessage::getSenderId, targetUserId).eq(ChatMessage::getReceiverId, ADMIN_ID)
        );
        wrapper.orderByAsc(ChatMessage::getCreateTime);

        Page<ChatMessage> pageResult = chatMessageService.page(new Page<>(page, size), wrapper);

        // mark messages sent to admin as read
        List<ChatMessage> records = pageResult.getRecords();
        List<ChatMessage> toUpdate = records.stream()
                .filter(m -> m.getReceiverId().equals(ADMIN_ID) && m.getIsRead() == 0)
                .peek(m -> m.setIsRead(1))
                .collect(Collectors.toList());
        if (!toUpdate.isEmpty()) {
            chatMessageService.updateBatchById(toUpdate);
        }

        return Result.ok(PageResult.of(pageResult));
    }

    /**
     * admin 获取所有有过聊天的用户列表
     */
    @GetMapping("/conversations")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<List<Map<String, Object>>> conversations() {
        // get all messages, group by the other party
        LambdaQueryWrapper<ChatMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ChatMessage::getSenderId, ADMIN_ID)
               .or()
               .eq(ChatMessage::getReceiverId, ADMIN_ID);
        wrapper.orderByDesc(ChatMessage::getCreateTime);
        List<ChatMessage> all = chatMessageService.list(wrapper);

        // group by the non-admin userId
        Map<Long, List<ChatMessage>> grouped = all.stream()
                .collect(Collectors.groupingBy(m ->
                        m.getSenderId().equals(ADMIN_ID) ? m.getReceiverId() : m.getSenderId()));

        // batch fetch user info for display names
        List<Long> userIds = new ArrayList<>(grouped.keySet());
        Map<Long, User> userMap = Collections.emptyMap();
        if (!userIds.isEmpty()) {
            userMap = userService.listByIds(userIds).stream()
                    .collect(Collectors.toMap(User::getId, u -> u));
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<Long, List<ChatMessage>> entry : grouped.entrySet()) {
            ChatMessage latest = entry.getValue().get(0);
            long unreadCount = entry.getValue().stream()
                    .filter(m -> m.getReceiverId().equals(ADMIN_ID) && m.getIsRead() == 0)
                    .count();
            User u = userMap.get(entry.getKey());
            String username = u != null ? u.getUsername() : ("用户" + entry.getKey());
            Map<String, Object> conv = new LinkedHashMap<>();
            conv.put("userId", entry.getKey());
            conv.put("username", username);
            conv.put("lastContent", latest.getContent());
            conv.put("lastTime", latest.getCreateTime());
            conv.put("unreadCount", unreadCount);
            result.add(conv);
        }
        return Result.ok(result);
    }

    /**
     * 发送消息（HTTP 备用通道，用于 WebSocket 不可用时，如真机调试域名未配置）
     */
    @PostMapping("/send")
    public Result<Map<String, Object>> send(@RequestBody Map<String, Object> payload) {
        Long senderId = getCurrentUserId();
        String content = (String) payload.get("content");
        if (content == null || content.trim().isEmpty()) {
            return Result.fail("消息内容不能为空");
        }
        content = content.trim();

        // determine receiver: admin → targetUser, user → admin
        Long receiverId;
        if (ADMIN_ID.equals(senderId)) {
            Object target = payload.get("targetUserId");
            if (target == null) return Result.fail("缺少目标用户");
            receiverId = ((Number) target).longValue();
        } else {
            receiverId = ADMIN_ID;
        }

        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setSenderId(senderId);
        chatMessage.setReceiverId(receiverId);
        chatMessage.setContent(content);
        String msgType = (String) payload.get("msgType");
        if (msgType != null) {
            chatMessage.setMsgType(msgType);
        }
        chatMessage.setIsRead(0);
        chatMessageService.save(chatMessage);

        // build response
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("type", "message");
        out.put("id", chatMessage.getId());
        out.put("senderId", senderId);
        out.put("receiverId", receiverId);
        out.put("content", chatMessage.getContent());
        if (msgType != null) {
            out.put("msgType", msgType);
        }
        out.put("createTime", chatMessage.getCreateTime() != null
                ? chatMessage.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                : LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

        return Result.ok(out);
    }

    /**
     * 轮询新消息（HTTP 备用通道，用于 WebSocket 不可用时）
     * 返回当前用户上次拉取之后的新消息（也包括自己刚通过 POST /send 发出的回显）
     */
    @GetMapping("/poll")
    public Result<List<Map<String, Object>>> poll(
            @RequestParam(required = false) String since) {
        Long userId = getCurrentUserId();
        Long peerId = ADMIN_ID.equals(userId) ? null : ADMIN_ID;

        LambdaQueryWrapper<ChatMessage> wrapper = new LambdaQueryWrapper<>();
        if (peerId != null) {
            wrapper.and(w -> w
                    .eq(ChatMessage::getSenderId, userId).eq(ChatMessage::getReceiverId, peerId)
                    .or()
                    .eq(ChatMessage::getSenderId, peerId).eq(ChatMessage::getReceiverId, userId));
        } else {
            // admin polls all messages directed to them
            wrapper.eq(ChatMessage::getReceiverId, ADMIN_ID);
        }
        if (since != null && !since.isEmpty()) {
            try {
                LocalDateTime sinceTime = LocalDateTime.parse(since, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                wrapper.gt(ChatMessage::getCreateTime, sinceTime);
            } catch (Exception ignored) {}
        }
        wrapper.orderByAsc(ChatMessage::getCreateTime);

        List<ChatMessage> list = chatMessageService.list(wrapper);

        // mark as read
        List<ChatMessage> toUpdate = list.stream()
                .filter(m -> m.getReceiverId().equals(userId) && m.getIsRead() == 0)
                .peek(m -> m.setIsRead(1))
                .collect(Collectors.toList());
        if (!toUpdate.isEmpty()) {
            chatMessageService.updateBatchById(toUpdate);
        }

        List<Map<String, Object>> result = list.stream().map(msg -> {
            Map<String, Object> map = new LinkedHashMap<>();
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
            return map;
        }).collect(Collectors.toList());

        return Result.ok(result);
    }

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Long) {
            return (Long) authentication.getPrincipal();
        }
        throw new RuntimeException("未登录或登录已过期");
    }
}
