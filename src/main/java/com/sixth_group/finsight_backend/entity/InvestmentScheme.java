package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 投资方案实体类
 * 用于存储投资方案的基本信息及财务分析结果，如NPV、IRR等指标
 */
@Data
public class InvestmentScheme {
    private Long id;
    private String projectName;
    private Double initialInvestment;
    private Double discountRate;
    private String cashFlows;
    private Double npv;
    private Double irr;
    private Double staticPayback;
    private Double dynamicPayback;
    private LocalDateTime createdAt;
}
