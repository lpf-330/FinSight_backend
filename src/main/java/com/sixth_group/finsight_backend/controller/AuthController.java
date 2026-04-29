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
    public Result<UserInfoResponse> getUserInfo(@RequestHeader(value = "Authorization", required = false) String token) {
        if (token == null || token.isEmpty()) {
            return Result.error(401, "未提供认证Token");
        }
        
        // 将token转换为用户id
        String realToken = token.replace("Bearer ", "");
        Object userIdObj = null;
        Long userId = null;
        
        try {
            userIdObj = JwtUtils.parseToken(realToken).get("userId");
        } catch (Exception e) {
            return Result.error(401, "无效的Token");
        }
        
        // 处理JWT中Long类型被序列化为Integer的情况
        if (userIdObj instanceof Integer) {
            userId = ((Integer) userIdObj).longValue();
        } else if (userIdObj instanceof Long) {
            userId = (Long) userIdObj;
        } else {
            return Result.error(401, "无效的Token");
        }

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
            @RequestHeader(value = "Authorization", required = false) String token) {
        if (token == null || token.isEmpty()) {
            return Result.error(401, "未提供认证Token");
        }
        
        // 将token转换为用户id
        String realToken = token.replace("Bearer ", "");
        Object userIdObj = null;
        Long userId = null;
        
        try {
            userIdObj = JwtUtils.parseToken(realToken).get("userId");
        } catch (Exception e) {
            return Result.error(401, "无效的Token");
        }
        
        // 处理JWT中Long类型被序列化为Integer的情况
        if (userIdObj instanceof Integer) {
            userId = ((Integer) userIdObj).longValue();
        } else if (userIdObj instanceof Long) {
            userId = (Long) userIdObj;
        } else {
            return Result.error(401, "无效的Token");
        }

        try {
            authService.changePassword(userId, changeRequest.getOldPassword(), changeRequest.getNewPassword());
            return Result.success();
        } catch (Exception e) {
            return Result.badRequest(e.getMessage());
        }
    }

    /**
     * 用户退出登录
     * 
     * @param token 认证令牌
     * @return 退出结果
     */
    @PostMapping("/logout")
    public Result<Void> logout(@RequestHeader(value = "Authorization", required = false) String token) {
        if (token == null || token.isEmpty()) {
            return Result.error(401, "未提供认证Token");
        }
        
        String realToken = token.replace("Bearer ", "");
        try {
            JwtUtils.parseToken(realToken);
        } catch (Exception e) {
            return Result.error(401, "无效的Token");
        }
        
        return Result.success();
    }
}
