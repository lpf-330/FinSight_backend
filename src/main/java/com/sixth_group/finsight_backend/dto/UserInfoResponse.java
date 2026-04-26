package com.sixth_group.finsight_backend.dto;

import lombok.Data;
import java.util.List;

/**
 * 用户信息响应DTO
 * 用于返回当前登录用户的基本信息
 */
@Data
public class UserInfoResponse {
    private String username;
    private String name;
    private List<String> roles;
    private String department;

    public UserInfoResponse(String username, String name, List<String> roles, String department) {
        this.username = username;
        this.name = name;
        this.roles = roles;
        this.department = department;
    }
}
