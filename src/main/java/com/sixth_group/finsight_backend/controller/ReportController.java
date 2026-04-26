package com.sixth_group.finsight_backend.controller;

import com.sixth_group.finsight_backend.entity.PdfReport;
import com.sixth_group.finsight_backend.service.ReportService;
import com.sixth_group.finsight_backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 报告控制器
 * 处理仪表盘数据、图表数据、PDF报告生成、对标数据等报告相关HTTP请求
 */
@RestController
@RequestMapping("/api/report")
public class ReportController {

    @Autowired
    private ReportService reportService;

    @GetMapping("/dashboard")
    public Result<Map<String, Object>> getDashboard() {
        Map<String, Object> data = reportService.getDashboardData();
        return Result.success(data);
    }

    @GetMapping("/charts")
    public Result<Map<String, Object>> getCharts(
            @RequestParam(required = false) String period,
            @RequestParam(required = false) String chartType) {
        Map<String, Object> data = reportService.getChartsData(period, chartType);
        return Result.success(data);
    }

    @PostMapping("/pdf/generate")
    public Result<Map<String, Object>> generatePdf(@RequestBody Map<String, Object> request) {
        String name = (String) request.get("name");
        String type = (String) request.get("type");
        String period = (String) request.get("period");
        Boolean includeWarning = (Boolean) request.get("includeWarning");
        Boolean includeRatio = (Boolean) request.get("includeRatio");
        Boolean includeTrend = (Boolean) request.get("includeTrend");
        Boolean includeInvestment = (Boolean) request.get("includeInvestment");

        Map<String, Object> result = reportService.generatePdfReport(name, type, period, includeWarning, includeRatio, includeTrend, includeInvestment);
        return Result.success(result);
    }

    @GetMapping("/pdf/history")
    public Result<List<PdfReport>> getPdfHistory() {
        List<PdfReport> list = reportService.getPdfReportHistory();
        return Result.success(list);
    }

    @GetMapping("/benchmark/data")
    public Result<List<Map<String, Object>>> getBenchmarkData(
            @RequestParam(required = false) String period,
            @RequestParam(required = false) String industry) {
        List<Map<String, Object>> data = reportService.getBenchmarkData(period, industry);
        return Result.success(data);
    }
}
