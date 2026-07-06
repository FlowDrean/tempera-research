package com.tempera.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.Application;
import com.tempera.service.ApplicationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/application")
@RequiredArgsConstructor
public class ApplicationController {

    private final ApplicationService applicationService;

    @PostMapping("/submit")
    public Result<?> submit(@RequestBody Application application) {
        Long userId = getCurrentUserId();
        application.setUserId(userId);
        application.setStatus("PENDING");
        application.setSubmitTime(LocalDateTime.now());
        applicationService.save(application);
        return Result.ok(Map.of("id", application.getId()));
    }

    @GetMapping("/my")
    public Result<PageResult<Application>> myApplications(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        Long userId = getCurrentUserId();
        LambdaQueryWrapper<Application> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Application::getUserId, userId)
               .orderByDesc(Application::getSubmitTime);
        IPage<Application> result = applicationService.page(new Page<>(page, size), wrapper);
        return Result.ok(PageResult.of(result));
    }

    @GetMapping("/list")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<PageResult<Application>> list(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String type,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        LambdaQueryWrapper<Application> wrapper = new LambdaQueryWrapper<>();
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Application::getStatus, status);
        }
        if (type != null && !type.isEmpty()) {
            wrapper.eq(Application::getType, type);
        }
        wrapper.orderByDesc(Application::getSubmitTime);
        IPage<Application> result = applicationService.page(new Page<>(page, size), wrapper);
        return Result.ok(PageResult.of(result));
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Application application = applicationService.getById(id);
        if (application == null) {
            return Result.notFound("申请不存在");
        }
        application.setStatus(body.get("status"));
        application.setReviewTime(LocalDateTime.now());
        if (body.containsKey("reviewComment")) {
            application.setReviewComment(body.get("reviewComment"));
        }
        applicationService.updateById(application);
        return Result.ok();
    }

    /**
     * Get current user ID from JWT SecurityContext
     */
    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Long) {
            return (Long) authentication.getPrincipal();
        }
        throw new RuntimeException("未登录或登录已过期");
    }
}
