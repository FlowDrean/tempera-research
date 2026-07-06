package com.tempera.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tempera.entity.Application;
import com.tempera.mapper.ApplicationMapper;
import org.springframework.stereotype.Service;

@Service
public class ApplicationService extends ServiceImpl<ApplicationMapper, Application> {
}
