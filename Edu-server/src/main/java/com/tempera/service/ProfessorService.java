package com.tempera.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tempera.entity.Professor;
import com.tempera.mapper.ProfessorMapper;
import org.springframework.stereotype.Service;

@Service
public class ProfessorService extends ServiceImpl<ProfessorMapper, Professor> {
}
