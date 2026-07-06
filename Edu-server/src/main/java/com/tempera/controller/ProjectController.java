package com.tempera.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.Project;
import com.tempera.service.ProjectService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/project")
@RequiredArgsConstructor
public class ProjectController {

    private final ProjectService projectService;

    @GetMapping("/list")
    public Result<PageResult<Project>> list(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String mode,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String startDate,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        IPage<Project> result = projectService.getList(category, mode, status, keyword, startDate, page, size);
        return Result.ok(PageResult.of(result));
    }

    @GetMapping("/detail/{id}")
    public Result<Project> detail(@PathVariable Long id) {
        Project project = projectService.getById(id);
        if (project == null) {
            return Result.notFound("项目不存在");
        }
        return Result.ok(project);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody Project project) {
        projectService.save(project);
        return Result.ok();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody Project project) {
        project.setId(id);
        projectService.updateById(project);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        projectService.removeById(id);
        return Result.ok();
    }
}
