package com.tempera.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * SPA fallback: forward unmatched non-API GET requests to index.html
 * so Vue Router can handle client-side routes like /dashboard, /users, etc.
 */
@Controller
public class SpaController {

    @RequestMapping({
        "/",
        "/login",
        "/dashboard",
        "/users",
        "/banners",
        "/projects",
        "/competitions",
        "/researches",
        "/videos",
        "/promo",
        "/promotions",
        "/applications",
        "/chat"
    })
    public String spa() {
        return "forward:/index.html";
    }
}
