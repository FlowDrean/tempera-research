package com.tempera.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tempera.entity.Competition;
import com.tempera.mapper.CompetitionMapper;
import org.springframework.stereotype.Service;

@Service
public class CompetitionService extends ServiceImpl<CompetitionMapper, Competition> {
}
