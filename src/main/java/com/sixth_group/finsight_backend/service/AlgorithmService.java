package com.sixth_group.finsight_backend.service;

import com.sixth_group.finsight_backend.dto.*;
import com.sixth_group.finsight_backend.entity.InvestmentScheme;
import com.sixth_group.finsight_backend.entity.WarningRecord;

import java.util.List;
import java.util.Map;

/**
 * 算法服务接口
 * 定义财务比率计算、预警管理、投资分析、利润预测、趋势分析等算法相关业务方法
 */
public interface AlgorithmService {
    Map<String, Object> getRatioResults(String period, String category);
    void calculateRatios(String period);
    List<String> getRatioCategories();
    List<WarningRecord> getWarningRecords(String level, String status);
    void ignoreWarning(Long id);
    Map<String, Integer> getWarningSummary();
    Map<String, Object> calculateInvestment(InvestmentCalculateRequest request);
    InvestmentScheme saveInvestmentScheme(InvestmentCalculateRequest request, Map<String, Object> result);
    List<InvestmentScheme> getInvestmentSchemes();
    List<Map<String, Object>> forecastProfit(ForecastProfitRequest request);
    List<Map<String, Object>> getTrendData(String indicator, Integer months);
    Map<String, Object> getDupontData(String period);
}
