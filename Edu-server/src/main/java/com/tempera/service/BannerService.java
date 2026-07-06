package com.tempera.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tempera.entity.Banner;
import com.tempera.mapper.BannerMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BannerService extends ServiceImpl<BannerMapper, Banner> {

    /**
     * Get active banners ordered by sort order
     */
    public List<Banner> getActiveBanners() {
        LambdaQueryWrapper<Banner> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Banner::getIsActive, 1)
               .orderByAsc(Banner::getSortOrder);
        return list(wrapper);
    }
}
