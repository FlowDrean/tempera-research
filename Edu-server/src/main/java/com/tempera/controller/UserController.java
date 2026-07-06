package com.tempera.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.User;
import com.tempera.security.JwtTokenProvider;
import com.tempera.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/login")
    public Result<?> login(@RequestBody Map<String, String> loginData) {
        String username = loginData.get("username");
        String password = loginData.get("password");
        Map<String, Object> result = userService.login(username, password);
        return Result.ok(result);
    }

    @PostMapping("/register")
    public Result<?> register(@RequestBody User user) {
        Long id = userService.register(user);
        return Result.ok(Map.of("id", id));
    }

    @GetMapping("/info")
    public Result<User> getInfo() {
        Long userId = getCurrentUserId();
        User user = userService.getById(userId);
        if (user != null) {
            user.setPassword(null);
        }
        return Result.ok(user);
    }

    @PutMapping("/info")
    public Result<?> updateInfo(@RequestBody User user) {
        Long userId = getCurrentUserId();
        user.setId(userId);
        user.setPassword(null);
        user.setRole(null);
        userService.updateById(user);
        return Result.ok();
    }

    @GetMapping("/list")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<PageResult<User>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like(User::getUsername, keyword)
                   .or()
                   .like(User::getEmail, keyword)
                   .or()
                   .like(User::getSchool, keyword);
        }
        wrapper.orderByDesc(User::getCreateTime);
        IPage<User> result = userService.page(new Page<>(page, size), wrapper);
        result.getRecords().forEach(u -> u.setPassword(null));
        return Result.ok(PageResult.of(result));
    }

    @PutMapping("/{id}/role")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> updateRole(@PathVariable Long id, @RequestBody Map<String, String> body) {
        User user = userService.getById(id);
        if (user == null) {
            return Result.notFound("用户不存在");
        }
        user.setRole(body.get("role"));
        userService.updateById(user);
        return Result.ok();
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody User user) {
        userService.register(user);
        return Result.ok(Map.of("id", user.getId()));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody User user) {
        User existing = userService.getById(id);
        if (existing == null) {
            return Result.notFound("用户不存在");
        }
        user.setId(id);
        // If password is provided, encode it
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        } else {
            user.setPassword(existing.getPassword());
        }
        // Keep role if not explicitly set
        if (user.getRole() == null || user.getRole().isEmpty()) {
            user.setRole(existing.getRole());
        }
        userService.updateById(user);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        User user = userService.getById(id);
        if (user == null) {
            return Result.notFound("用户不存在");
        }
        // Prevent deleting the admin account (id=1)
        if (id == 1L) {
            return Result.fail("不能删除超级管理员账号");
        }
        userService.removeById(id);
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
