package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 验证规则实体类
 * 用于存储数据验证规则，包括表达式、级别、错误信息等
 */
@Data
public class ValidationRule {
    private Long id;
    private String name;
    private String expression;
    private String level;
    private String message;
    private Boolean enabled;
    private LocalDateTime createdAt;
}
