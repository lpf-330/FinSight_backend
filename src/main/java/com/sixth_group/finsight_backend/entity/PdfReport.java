package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * PDF报告实体类
 * 用于存储生成的PDF财务分析报告的基本信息
 */
@Data
public class PdfReport {
    private Long id;
    private String name;
    private String type;
    private String period;
    private String status;
    private LocalDateTime createTime;
    private String fileSize;
    private String creatorName;
}
