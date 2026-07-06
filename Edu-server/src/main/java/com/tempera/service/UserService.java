package com.tempera.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tempera.common.BusinessException;
import com.tempera.entity.User;
import com.tempera.mapper.UserMapper;
import com.tempera.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class UserService extends ServiceImpl<UserMapper, User> {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    /**
     * Login with username and password, returns JWT token and user info
     */
    public Map<String, Object> login(String username, String password) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, username)
               .or()
               .eq(User::getPhone, username);
        User user = userMapper.selectOne(wrapper);

        if (user == null) {
            throw new BusinessException(401, "用户名或密码错误");
        }

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new BusinessException(401, "用户名或密码错误");
        }

        String token = jwtTokenProvider.generateToken(user.getId(), user.getUsername(), user.getRole());

        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("id", user.getId());
        userInfo.put("username", user.getUsername());
        userInfo.put("email", user.getEmail());
        userInfo.put("phone", user.getPhone());
        userInfo.put("avatar", user.getAvatar());
        userInfo.put("role", user.getRole());
        userInfo.put("education", user.getEducation());
        userInfo.put("grade", user.getGrade());
        userInfo.put("school", user.getSchool());

        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("userInfo", userInfo);
        return result;
    }

    /**
     * Register a new user with BCrypt encoded password
     */
    public Long register(User user) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, user.getUsername());
        Long count = userMapper.selectCount(wrapper);
        if (count > 0) {
            throw new BusinessException("用户名已存在");
        }

        user.setPassword(passwordEncoder.encode(user.getPassword()));
        if (user.getRole() == null || user.getRole().isEmpty()) {
            user.setRole("USER");
        }
        save(user);
        return user.getId();
    }
}
