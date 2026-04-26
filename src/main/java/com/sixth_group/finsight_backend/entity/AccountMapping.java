package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 科目映射实体类
 * 用于存储K8系统科目与目标科目之间的映射关系
 */
@Data
public class AccountMapping {
    private Long id;
    private String k8Code;
    private String k8Name;
    private String targetCode;
    private String targetName;
    private String category;
    private Boolean enabled;
}
