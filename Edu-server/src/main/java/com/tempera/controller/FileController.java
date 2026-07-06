package com.tempera.controller;

import com.tempera.common.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/api/file")
public class FileController {

    @Value("${file.upload.path:./uploads/}")
    private String uploadPath;

    @PostMapping("/upload")
    public Result<?> upload(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return Result.fail("文件不能为空");
        }

        try {
            // resolve upload base path
            Path basePath = Paths.get(uploadPath).toAbsolutePath().normalize();
            log.info("Upload base path: {}", basePath);

            // create date-based subdirectory
            String dateDir = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            Path dir = basePath.resolve(dateDir);
            Files.createDirectories(dir);

            // generate unique filename
            String originalName = file.getOriginalFilename();
            String ext = "";
            if (originalName != null && originalName.contains(".")) {
                ext = originalName.substring(originalName.lastIndexOf("."));
            }
            String fileName = UUID.randomUUID().toString().replace("-", "") + ext;
            String relativePath = dateDir + "/" + fileName;

            // save file
            Path dest = basePath.resolve(relativePath);
            file.transferTo(dest.toFile());

            String url = "/uploads/" + relativePath;
            log.info("File uploaded successfully: {}", url);
            return Result.ok(Map.of("url", url));
        } catch (IOException e) {
            log.error("File upload failed: {}", e.getMessage(), e);
            return Result.fail("文件上传失败: " + e.getMessage());
        }
    }
}
