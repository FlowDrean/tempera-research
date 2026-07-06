package com.tempera.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tempera.common.PageResult;
import com.tempera.common.Result;
import com.tempera.entity.Professor;
import com.tempera.service.ProfessorService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/professor")
@RequiredArgsConstructor
public class ProfessorController {

    private final ProfessorService professorService;

    @GetMapping("/list")
    public Result<PageResult<Professor>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        IPage<Professor> result = professorService.page(new Page<>(page, size));
        return Result.ok(PageResult.of(result));
    }

    @GetMapping("/{id}")
    public Result<Professor> detail(@PathVariable Long id) {
        Professor professor = professorService.getById(id);
        if (professor == null) {
            return Result.notFound("教授不存在");
        }
        return Result.ok(professor);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody Professor professor) {
        professorService.save(professor);
        return Result.ok();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody Professor professor) {
        professor.setId(id);
        professorService.updateById(professor);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        professorService.removeById(id);
        return Result.ok();
    }
}
