package com.sixth_group.finsight_backend.dto;

import lombok.Data;

/**
 * 登录请求DTO
 * 用于接收用户登录时提交的用户名和密码
 */
@Data
public class LoginRequest {
    private String username;
    private String password;
}
