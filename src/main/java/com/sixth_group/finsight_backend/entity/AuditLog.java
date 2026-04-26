package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 审计日志实体类
 * 用于记录系统用户的操作日志，便于安全审计和追溯
 */
@Data
public class AuditLog {
    private Long id;
    private Long userId;
    private String username;
    private String operation;
    private String module;
    private String detail;
    private String ip;
    private LocalDateTime createdAt;
}
