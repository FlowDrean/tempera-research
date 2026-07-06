package com.tempera.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.ResearchTour;
import com.tempera.service.ResearchTourService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/research-tour")
@RequiredArgsConstructor
public class ResearchTourController {

    private final ResearchTourService researchTourService;

    @GetMapping("/list")
    public Result<PageResult<ResearchTour>> list(
            @RequestParam(required = false) String country,
            @RequestParam(required = false) String season,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        LambdaQueryWrapper<ResearchTour> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(country)) {
            wrapper.eq(ResearchTour::getCountry, country);
        }
        if (StringUtils.hasText(season)) {
            wrapper.eq(ResearchTour::getSeason, season);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                .like(ResearchTour::getTitleCn, keyword)
                .or()
                .like(ResearchTour::getTitleEn, keyword)
                .or()
                .like(ResearchTour::getDescription, keyword));
        }
        wrapper.orderByDesc(ResearchTour::getCreateTime);
        IPage<ResearchTour> result = researchTourService.page(new Page<>(page, size), wrapper);
        return Result.ok(PageResult.of(result));
    }

    @GetMapping("/detail/{id}")
    public Result<ResearchTour> detail(@PathVariable Long id) {
        ResearchTour tour = researchTourService.getById(id);
        if (tour == null) {
            return Result.notFound("研学项目不存在");
        }
        return Result.ok(tour);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody ResearchTour tour) {
        researchTourService.save(tour);
        return Result.ok();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody ResearchTour tour) {
        tour.setId(id);
        researchTourService.updateById(tour);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        researchTourService.removeById(id);
        return Result.ok();
    }
}
