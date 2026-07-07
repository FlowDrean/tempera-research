package com.tempera.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.ExploreModule;
import com.tempera.service.ExploreModuleService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/explore")
@RequiredArgsConstructor
public class ExploreModuleController {

    private final ExploreModuleService exploreModuleService;

    /**
     * Public: get all explore modules ordered by sort_order
     */
    @GetMapping("/list")
    public Result<List<ExploreModule>> list() {
        LambdaQueryWrapper<ExploreModule> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(ExploreModule::getSortOrder);
        return Result.ok(exploreModuleService.list(wrapper));
    }

    /**
     * Admin: paginated list
     */
    @GetMapping("/admin/list")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<PageResult<ExploreModule>> adminList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        LambdaQueryWrapper<ExploreModule> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(ExploreModule::getSortOrder);
        IPage<ExploreModule> result = exploreModuleService.page(new Page<>(page, size), wrapper);
        return Result.ok(PageResult.of(result));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody ExploreModule exploreModule) {
        exploreModuleService.save(exploreModule);
        return Result.ok();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody ExploreModule exploreModule) {
        exploreModule.setId(id);
        exploreModuleService.updateById(exploreModule);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        exploreModuleService.removeById(id);
        return Result.ok();
    }

    @GetMapping("/detail/{id}")
    public Result<ExploreModule> detail(@PathVariable Long id) {
        ExploreModule exploreModule = exploreModuleService.getById(id);
        if (exploreModule == null) {
            return Result.notFound("学术探索模块不存在");
        }
        return Result.ok(exploreModule);
    }
}
