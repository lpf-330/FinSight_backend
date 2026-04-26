package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户实体类
 * 用于存储系统用户的基本信息
 */
@Data
public class User {
    private Long id;
    private String username;
    private String password;
    private String name;
    private String department;
    private Long roleId;
    private String status;
    private LocalDateTime lastLogin;
    private LocalDateTime createdAt;
}
