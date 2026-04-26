package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 阈值实体类
 * 用于存储财务指标的预警阈值配置，包括黄、橙、红三个等级
 */
@Data
public class Threshold {
    private Long id;
    private String indicator;
    private String indicatorCode;
    private String direction;
    private String yellowValue;
    private String orangeValue;
    private String redValue;
    private Boolean dynamicBase;
    private LocalDateTime updateTime;
}
