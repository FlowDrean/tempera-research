package com.tempera.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);

        registry.addMapping("/ws/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // uploaded files
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:./uploads/");

        // static assets - Spring strips the matched prefix, so
        // /assets/** -> classpath:/static/assets/  and  /*.html -> classpath:/static/
        registry.addResourceHandler("/assets/**")
                .addResourceLocations("classpath:/static/assets/");
        registry.addResourceHandler("/*.html", "/vite.svg")
                .addResourceLocations("classpath:/static/");
    }
}
