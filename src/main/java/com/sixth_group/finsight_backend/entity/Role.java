package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 角色实体类
 * 用于存储系统角色的信息，包括角色名称、权限等
 */
@Data
public class Role {
    private Long id;
    private String name;
    private String code;
    private String description;
    private Integer userCount;
    private String permissions;
    private LocalDateTime createdAt;
}
