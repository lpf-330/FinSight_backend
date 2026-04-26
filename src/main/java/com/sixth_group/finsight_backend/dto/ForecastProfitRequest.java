package com.sixth_group.finsight_backend.dto;

import lombok.Data;

/**
 * 利润预测请求DTO
 * 用于提交利润预测所需的各项财务参数
 */
@Data
public class ForecastProfitRequest {
    private Double baseRevenue;
    private Double revenueGrowthRate;
    private Double costRate;
    private Double expenseRate;
    private Double taxRate;
    private Integer periods;
}
