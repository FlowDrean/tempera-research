package com.tempera.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.Banner;
import com.tempera.service.BannerService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/banner")
@RequiredArgsConstructor
public class BannerController {

    private final BannerService bannerService;

    @GetMapping("/list")
    public Result<List<Banner>> list() {
        List<Banner> banners = bannerService.getActiveBanners();
        return Result.ok(banners);
    }

    @GetMapping("/admin/list")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<PageResult<Banner>> adminList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        IPage<Banner> result = bannerService.page(new Page<>(page, size));
        return Result.ok(PageResult.of(result));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody Banner banner) {
        bannerService.save(banner);
        return Result.ok();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody Banner banner) {
        banner.setId(id);
        bannerService.updateById(banner);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        bannerService.removeById(id);
        return Result.ok();
    }

    @GetMapping("/detail/{id}")
    public Result<Banner> detail(@PathVariable Long id) {
        Banner banner = bannerService.getById(id);
        if (banner == null) {
            return Result.notFound("Banner不存在");
        }
        return Result.ok(banner);
    }
}
