package com.tempera.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tempera.entity.Project;
import com.tempera.mapper.ProjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class ProjectService extends ServiceImpl<ProjectMapper, Project> {

    /**
     * Get paginated project list with optional filters
     */
    public IPage<Project> getList(String category, String mode, String status, String keyword, String startDate, int page, int size) {
        LambdaQueryWrapper<Project> wrapper = new LambdaQueryWrapper<>();

        if (StringUtils.hasText(category)) {
            wrapper.eq(Project::getCategory, category);
        }
        if (StringUtils.hasText(mode)) {
            wrapper.eq(Project::getMode, mode);
        }
        if (StringUtils.hasText(status)) {
            wrapper.eq(Project::getStatus, status);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                .like(Project::getTitleCn, keyword)
                .or()
                .like(Project::getTitleEn, keyword)
                .or()
                .like(Project::getDescription, keyword));
        }
        if (StringUtils.hasText(startDate)) {
            wrapper.apply("DATE_FORMAT(start_date, '%Y-%m') = {0}", startDate);
        }

        wrapper.orderByDesc(Project::getCreateTime);
        return this.page(new Page<>(page, size), wrapper);
    }
}
