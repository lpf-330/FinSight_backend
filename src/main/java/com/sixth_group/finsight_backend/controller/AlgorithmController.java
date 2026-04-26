package com.sixth_group.finsight_backend.controller;

import com.sixth_group.finsight_backend.dto.ForecastProfitRequest;
import com.sixth_group.finsight_backend.dto.InvestmentCalculateRequest;
import com.sixth_group.finsight_backend.entity.InvestmentScheme;
import com.sixth_group.finsight_backend.entity.WarningRecord;
import com.sixth_group.finsight_backend.service.AlgorithmService;
import com.sixth_group.finsight_backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 算法控制器
 * 处理财务比率计算、预警管理、投资分析、利润预测、趋势分析等算法相关HTTP请求
 */
@RestController
@RequestMapping("/api/algorithm")
public class AlgorithmController {

    @Autowired
    private AlgorithmService algorithmService;

    @GetMapping("/ratio/results")
    public Result<Map<String, Object>> getRatioResults(
            @RequestParam(required = false) String period,
            @RequestParam(required = false) String category) {
        Map<String, Object> results = algorithmService.getRatioResults(period, category);
        return Result.success(results);
    }

    @PostMapping("/ratio/calculate")
    public Result<Void> calculateRatios(@RequestBody Map<String, String> request) {
        String period = request.get("period");
        algorithmService.calculateRatios(period);
        return Result.success();
    }

    @GetMapping("/ratio/categories")
    public Result<List<String>> getRatioCategories() {
        List<String> categories = algorithmService.getRatioCategories();
        return Result.success(categories);
    }

    @GetMapping("/warning/records")
    public Result<List<WarningRecord>> getWarningRecords(
            @RequestParam(required = false) String level,
            @RequestParam(required = false) String status) {
        List<WarningRecord> records = algorithmService.getWarningRecords(level, status);
        return Result.success(records);
    }

    @PutMapping("/warning/records/{id}/ignore")
    public Result<Void> ignoreWarning(@PathVariable Long id) {
        algorithmService.ignoreWarning(id);
        return Result.success();
    }

    @GetMapping("/warning/summary")
    public Result<Map<String, Integer>> getWarningSummary() {
        Map<String, Integer> summary = algorithmService.getWarningSummary();
        return Result.success(summary);
    }

    @PostMapping("/investment/calculate")
    public Result<Map<String, Object>> calculateInvestment(@RequestBody InvestmentCalculateRequest request) {
        Map<String, Object> result = algorithmService.calculateInvestment(request);
        return Result.success(result);
    }

    @PostMapping("/investment/scheme")
    public Result<InvestmentScheme> saveInvestmentScheme(@RequestBody InvestmentCalculateRequest request) {
        Map<String, Object> result = algorithmService.calculateInvestment(request);
        InvestmentScheme scheme = algorithmService.saveInvestmentScheme(request, result);
        return Result.success(scheme);
    }

    @GetMapping("/investment/schemes")
    public Result<List<InvestmentScheme>> getInvestmentSchemes() {
        List<InvestmentScheme> schemes = algorithmService.getInvestmentSchemes();
        return Result.success(schemes);
    }

    @PostMapping("/forecast/profit")
    public Result<List<Map<String, Object>>> forecastProfit(@RequestBody ForecastProfitRequest request) {
        List<Map<String, Object>> results = algorithmService.forecastProfit(request);
        return Result.success(results);
    }

    @GetMapping("/trend/data")
    public Result<List<Map<String, Object>>> getTrendData(
            @RequestParam String indicator,
            @RequestParam(required = false, defaultValue = "12") Integer months) {
        List<Map<String, Object>> data = algorithmService.getTrendData(indicator, months);
        return Result.success(data);
    }

    @GetMapping("/trend/dupont")
    public Result<Map<String, Object>> getDupontData(@RequestParam(required = false) String period) {
        Map<String, Object> data = algorithmService.getDupontData(period);
        return Result.success(data);
    }
}
