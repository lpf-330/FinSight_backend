package com.sixth_group.finsight_backend.service;

import com.sixth_group.finsight_backend.dto.*;

/**
 * 认证服务接口
 * 定义用户登录、用户信息获取、密码修改等认证相关业务方法
 */
public interface AuthService {
    LoginResponse login(LoginRequest request);

    UserInfoResponse getUserInfo(Long userId);

    boolean changePassword(Long userId, String oldPassword, String newPassword);
}
