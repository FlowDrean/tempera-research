package com.tempera.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.Video;
import com.tempera.service.VideoService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/video")
@RequiredArgsConstructor
public class VideoController {

    private final VideoService videoService;

    @GetMapping("/list")
    public Result<PageResult<Video>> list(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        LambdaQueryWrapper<Video> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(category)) {
            wrapper.eq(Video::getCategory, category);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                .like(Video::getTitle, keyword)
                .or()
                .like(Video::getTitleEn, keyword)
                .or()
                .like(Video::getDescription, keyword));
        }
        wrapper.orderByAsc(Video::getSortOrder)
               .orderByDesc(Video::getCreateTime);
        IPage<Video> result = videoService.page(new Page<>(page, size), wrapper);
        return Result.ok(PageResult.of(result));
    }

    @GetMapping("/detail/{id}")
    public Result<Video> detail(@PathVariable Long id) {
        videoService.incrementViews(id);
        Video video = videoService.getById(id);
        if (video == null) {
            return Result.notFound("视频不存在");
        }
        return Result.ok(video);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody Video video) {
        videoService.save(video);
        return Result.ok();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody Video video) {
        video.setId(id);
        videoService.updateById(video);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        videoService.removeById(id);
        return Result.ok();
    }
}
