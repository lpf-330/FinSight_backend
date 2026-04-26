package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 公式实体类
 * 用于存储财务分析计算公式的定义信息
 */
@Data
public class Formula {
    private Long id;
    private String name;
    private String expression;
    private String category;
    private Boolean enabled;
    private String version;
    private LocalDateTime updateTime;
}
