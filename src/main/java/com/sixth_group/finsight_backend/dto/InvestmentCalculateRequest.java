package com.sixth_group.finsight_backend.dto;

import lombok.Data;
import java.util.List;

/**
 * 投资计算请求DTO
 * 用于提交投资方案的基本信息和现金流数据
 */
@Data
public class InvestmentCalculateRequest {
    private String projectName;
    private Double initialInvestment;
    private Double discountRate;
    private List<CashFlow> cashFlows;

    @Data
    public static class CashFlow {
        private Integer year;
        private Double amount;
    }
}
