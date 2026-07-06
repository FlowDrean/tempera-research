package com.tempera.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tempera.entity.Favorite;
import com.tempera.mapper.FavoriteMapper;
import org.springframework.stereotype.Service;

@Service
public class FavoriteService extends ServiceImpl<FavoriteMapper, Favorite> {
}
