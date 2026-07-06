package com.tempera.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.Competition;
import com.tempera.service.CompetitionService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/competition")
@RequiredArgsConstructor
public class CompetitionController {

    private final CompetitionService competitionService;

    @GetMapping("/list")
    public Result<PageResult<Competition>> list(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String level,
            @RequestParam(required = false) String participantType,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        LambdaQueryWrapper<Competition> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(category)) {
            wrapper.eq(Competition::getCategory, category);
        }
        if (StringUtils.hasText(status)) {
            wrapper.eq(Competition::getStatus, status);
        }
        if (StringUtils.hasText(level)) {
            wrapper.eq(Competition::getLevelName, level);
        }
        if (StringUtils.hasText(participantType)) {
            wrapper.eq(Competition::getParticipantType, participantType);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                .like(Competition::getTitleCn, keyword)
                .or()
                .like(Competition::getTitleEn, keyword)
                .or()
                .like(Competition::getDescription, keyword));
        }
        wrapper.orderByDesc(Competition::getCreateTime);
        IPage<Competition> result = competitionService.page(new Page<>(page, size), wrapper);
        return Result.ok(PageResult.of(result));
    }

    @GetMapping("/detail/{id}")
    public Result<Competition> detail(@PathVariable Long id) {
        Competition competition = competitionService.getById(id);
        if (competition == null) {
            return Result.notFound("竞赛不存在");
        }
        return Result.ok(competition);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody Competition competition) {
        competitionService.save(competition);
        return Result.ok();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody Competition competition) {
        competition.setId(id);
        competitionService.updateById(competition);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        competitionService.removeById(id);
        return Result.ok();
    }
}
