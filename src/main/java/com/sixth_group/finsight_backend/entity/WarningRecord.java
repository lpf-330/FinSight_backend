package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 预警记录实体类
 * 用于存储财务指标触发预警的详细信息，包括指标值、阈值、趋势等
 */
@Data
public class WarningRecord {
    private Long id;
    private String indicator;
    private String indicatorCode;
    private String level;
    private Double currentValue;
    private String yellowThreshold;
    private String orangeThreshold;
    private String redThreshold;
    private String trend;
    private String suggestion;
    private String status;
    private String period;
    private LocalDateTime triggeredAt;
}
