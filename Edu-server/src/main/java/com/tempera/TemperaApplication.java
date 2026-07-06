package com.tempera;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.tempera.mapper")
public class TemperaApplication {
    public static void main(String[] args) {
        SpringApplication.run(TemperaApplication.class, args);
    }
}
