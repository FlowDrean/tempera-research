package com.tempera.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tempera.entity.Promotion;
import com.tempera.mapper.PromotionMapper;
import org.springframework.stereotype.Service;

@Service
public class PromotionService extends ServiceImpl<PromotionMapper, Promotion> {
}
