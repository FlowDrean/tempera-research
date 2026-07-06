package com.tempera.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tempera.entity.Professor;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ProfessorMapper extends BaseMapper<Professor> {
}
