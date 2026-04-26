package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 模型版本实体类
 * 用于存储预测模型的版本信息
 */
@Data
public class ModelVersion {
    private Long id;
    private String modelType;
    private String version;
    private String description;
    private String creator;
    private Boolean isActive;
    private LocalDateTime createdAt;
}
