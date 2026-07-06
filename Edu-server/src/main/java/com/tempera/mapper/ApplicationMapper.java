package com.tempera.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tempera.entity.Application;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ApplicationMapper extends BaseMapper<Application> {
}
