package com.tempera.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tempera.entity.Project;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import java.util.List;

@Mapper
public interface ProjectMapper extends BaseMapper<Project> {

    @Select("SELECT p.* FROM project p " +
            "LEFT JOIN project_professor pp ON p.id = pp.project_id " +
            "WHERE p.status != 'draft' " +
            "AND (#{category} IS NULL OR p.category = #{category}) " +
            "AND (#{mode} IS NULL OR p.mode = #{mode}) " +
            "AND (#{status} IS NULL OR p.status = #{status}) " +
            "AND (#{keyword} IS NULL OR p.title_cn LIKE CONCAT('%',#{keyword},'%') OR p.title_en LIKE CONCAT('%',#{keyword},'%')) " +
            "GROUP BY p.id ORDER BY p.create_time DESC")
    List<Project> findList(@Param("category") String category,
                           @Param("mode") String mode,
                           @Param("status") String status,
                           @Param("keyword") String keyword);
}
