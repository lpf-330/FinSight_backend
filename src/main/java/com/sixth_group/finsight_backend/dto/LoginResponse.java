package com.sixth_group.finsight_backend.dto;

import lombok.Data;

/**
 * 登录响应DTO
 * 用于返回用户登录成功后的令牌信息
 */
@Data
public class LoginResponse {
    private String token;
    private Long expiresIn;

    public LoginResponse(String token, Long expiresIn) {
        this.token = token;
        this.expiresIn = expiresIn;
    }
}
