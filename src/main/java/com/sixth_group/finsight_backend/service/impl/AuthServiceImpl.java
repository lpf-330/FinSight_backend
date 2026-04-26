package com.sixth_group.finsight_backend.service.impl;

import com.sixth_group.finsight_backend.dto.*;
import com.sixth_group.finsight_backend.entity.Role;
import com.sixth_group.finsight_backend.entity.User;
import com.sixth_group.finsight_backend.mapper.RoleMapper;
import com.sixth_group.finsight_backend.mapper.UserMapper;
import com.sixth_group.finsight_backend.service.AuthService;
import com.sixth_group.finsight_backend.utils.JwtUtils;
import com.sixth_group.finsight_backend.utils.PasswordUtil;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 认证服务实现类
 * 实现用户登录、用户信息获取、密码修改等认证相关业务逻辑
 */
@Service
public class AuthServiceImpl implements AuthService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private RoleMapper roleMapper;

    @Override
    public LoginResponse login(LoginRequest request) {
        User user = userMapper.selectByUsername(request.getUsername());
        if (user == null || !PasswordUtil.verifyPassword(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }

        if (!"active".equals(user.getStatus())) {
            throw new RuntimeException("用户已被禁用");
        }

        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", user.getId());
        claims.put("username", user.getUsername());

        String token = JwtUtils.generateToken(claims);

        user.setLastLogin(LocalDateTime.now());
        userMapper.update(user);

        return new LoginResponse(token, 86400L);
    }

    @Override
    public UserInfoResponse getUserInfo(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        List<String> roles = new ArrayList<>();
        if (user.getRoleId() != null) {
            Role role = roleMapper.selectById(user.getRoleId());
            if (role != null) {
                roles.add(role.getCode());
            }
        }

        return new UserInfoResponse(user.getUsername(), user.getName(), roles, user.getDepartment());
    }

    @Override
    public boolean changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (!PasswordUtil.verifyPassword(oldPassword, user.getPassword())) {
            throw new RuntimeException("原密码错误");
        }

        String hashedPassword = PasswordUtil.hashPassword(newPassword);
        int rows = userMapper.updatePassword(userId, hashedPassword);
        if (rows == 0) {
            throw new RuntimeException("密码更新失败");
        }
        return true;
    }
}
