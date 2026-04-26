package com.sixth_group.finsight_backend.dto;

import lombok.Data;

/**
 * 修改密码请求DTO
 * 用于接收用户修改密码时提交的旧密码和新密码
 */
@Data
public class ChangePasswordRequest {
    private String oldPassword;
    private String newPassword;
}
