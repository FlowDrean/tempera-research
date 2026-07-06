package com.tempera.controller;

import com.tempera.common.Result;
import com.tempera.entity.PromoImage;
import com.tempera.service.PromoImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/promo")
@RequiredArgsConstructor
public class PromoController {

    private final PromoImageService promoImageService;

    /**
     * Get promo image (public)
     */
    @GetMapping("/image")
    public Result<PromoImage> getImage() {
        PromoImage image = promoImageService.getById(1);
        return Result.ok(image);
    }

    /**
     * Update promo image (admin only)
     */
    @PutMapping("/image")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> updateImage(@RequestBody PromoImage promoImage) {
        promoImage.setId(1L);
        promoImageService.updateById(promoImage);
        return Result.ok();
    }
}
