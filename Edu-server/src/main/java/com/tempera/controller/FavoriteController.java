package com.tempera.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tempera.common.Result;
import com.tempera.entity.Favorite;
import com.tempera.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/favorite")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;

    /**
     * 添加收藏
     */
    @PostMapping("/add")
    public Result<?> add(@RequestBody Favorite favorite) {
        Long userId = getCurrentUserId();
        favorite.setUserId(userId);

        // 检查是否已收藏
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId)
               .eq(Favorite::getItemType, favorite.getItemType())
               .eq(Favorite::getItemId, favorite.getItemId());
        if (favoriteService.count(wrapper) > 0) {
            return Result.ok(Map.of("id", 0, "msg", "already favorited"));
        }

        favoriteService.save(favorite);
        return Result.ok(Map.of("id", favorite.getId()));
    }

    /**
     * 取消收藏
     */
    @DeleteMapping("/remove")
    public Result<?> remove(@RequestParam String itemType, @RequestParam Long itemId) {
        Long userId = getCurrentUserId();

        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId)
               .eq(Favorite::getItemType, itemType)
               .eq(Favorite::getItemId, itemId);
        favoriteService.remove(wrapper);
        return Result.ok();
    }

    /**
     * 获取当前用户的收藏列表
     */
    @GetMapping("/my")
    public Result<List<Favorite>> myFavorites(@RequestParam(required = false) String itemType) {
        Long userId = getCurrentUserId();
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId);
        if (itemType != null && !itemType.isEmpty()) {
            wrapper.eq(Favorite::getItemType, itemType);
        }
        wrapper.orderByDesc(Favorite::getCreateTime);
        return Result.ok(favoriteService.list(wrapper));
    }

    /**
     * 检查是否已收藏
     */
    @GetMapping("/check")
    public Result<Map<String, Boolean>> check(
            @RequestParam String itemType,
            @RequestParam Long itemId) {
        Long userId = getCurrentUserId();
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId)
               .eq(Favorite::getItemType, itemType)
               .eq(Favorite::getItemId, itemId);
        boolean favorited = favoriteService.count(wrapper) > 0;
        return Result.ok(Map.of("favorited", favorited));
    }

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Long) {
            return (Long) authentication.getPrincipal();
        }
        throw new RuntimeException("未登录或登录已过期");
    }
}
