package com.tempera.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.Promotion;
import com.tempera.service.PromotionService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/promotion")
@RequiredArgsConstructor
public class PromotionController {

    private final PromotionService promotionService;

    /**
     * Public: get all promotions ordered by sort_order
     */
    @GetMapping("/list")
    public Result<List<Promotion>> list() {
        LambdaQueryWrapper<Promotion> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(Promotion::getSortOrder);
        return Result.ok(promotionService.list(wrapper));
    }

    /**
     * Admin: paginated list
     */
    @GetMapping("/admin/list")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<PageResult<Promotion>> adminList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        LambdaQueryWrapper<Promotion> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(Promotion::getSortOrder);
        IPage<Promotion> result = promotionService.page(new Page<>(page, size), wrapper);
        return Result.ok(PageResult.of(result));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody Promotion promotion) {
        promotionService.save(promotion);
        return Result.ok();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody Promotion promotion) {
        promotion.setId(id);
        promotionService.updateById(promotion);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        promotionService.removeById(id);
        return Result.ok();
    }

    @GetMapping("/detail/{id}")
    public Result<Promotion> detail(@PathVariable Long id) {
        Promotion promotion = promotionService.getById(id);
        if (promotion == null) {
            return Result.notFound("推广卡片不存在");
        }
        return Result.ok(promotion);
    }
}
