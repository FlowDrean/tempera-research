package com.tempera.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tempera.entity.Video;
import com.tempera.mapper.VideoMapper;
import org.springframework.stereotype.Service;

@Service
public class VideoService extends ServiceImpl<VideoMapper, Video> {

    /**
     * Increment view count by 1
     */
    public void incrementViews(Long id) {
        Video video = getById(id);
        if (video != null) {
            video.setViews((video.getViews() == null ? 0 : video.getViews()) + 1);
            updateById(video);
        }
    }
}
