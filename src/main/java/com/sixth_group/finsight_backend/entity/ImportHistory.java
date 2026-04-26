package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 导入历史实体类
 * 用于记录Excel数据导入操作的详细信息
 */
@Data
public class ImportHistory {
    private Long id;
    private String fileName;
    private String type;
    private String mode;
    private Integer records;
    private String status;
    private String operatorName;
    private LocalDateTime createdAt;
}
