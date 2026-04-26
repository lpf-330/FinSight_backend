package com.sixth_group.finsight_backend.controller;

import com.sixth_group.finsight_backend.dto.*;
import com.sixth_group.finsight_backend.service.AuthService;
import com.sixth_group.finsight_backend.utils.JwtUtils;
import com.sixth_group.finsight_backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 认证控制器
 * 处理用户登录、获取用户信息、修改密码等认证相关HTTP请求
 */
@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    public Result<LoginResponse> login(@RequestBody LoginRequest request) {
        try {
            LoginResponse response = authService.login(request);
            return Result.success(response);
        } catch (Exception e) {
            return Result.badRequest(e.getMessage());
        }
    }

    @GetMapping("/user-info")
    public Result<UserInfoResponse> getUserInfo(@RequestHeader("Authorization") String token) {
        // 将token转换为用户id
        String realToken = token.replace("Bearer ", "");
        Long userId = (Long) JwtUtils.parseToken(realToken).get("userId");

        // 从数据库中查询用户信息
        try {
            UserInfoResponse response = authService.getUserInfo(userId);
            return Result.success(response);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PutMapping("/change-password")
    public Result<Void> changePassword(@RequestBody ChangePasswordRequest changeRequest,
            @RequestHeader("Authorization") String token) {
        // 将token转换为用户id
        String realToken = token.replace("Bearer ", "");
        Long userId = (Long) JwtUtils.parseToken(realToken).get("userId");

        try {
            authService.changePassword(userId, changeRequest.getOldPassword(), changeRequest.getNewPassword());
            return Result.success();
        } catch (Exception e) {
            return Result.badRequest(e.getMessage());
        }
    }
}
