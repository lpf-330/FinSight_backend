package com.sixth_group.finsight_backend.controller;

import com.sixth_group.finsight_backend.entity.PdfReport;
import com.sixth_group.finsight_backend.service.ReportService;
import com.sixth_group.finsight_backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Map;

/**
 * 报告控制器
 * 处理仪表盘数据、图表数据、PDF报告生成、对标数据等报告相关HTTP请求
 */
@RestController
@RequestMapping("/report")
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
        try {
            String name = (String) request.get("name");
            String type = (String) request.get("type");
            String period = (String) request.get("period");
            Boolean includeWarning = (Boolean) request.get("includeWarning");
            Boolean includeRatio = (Boolean) request.get("includeRatio");
            Boolean includeTrend = (Boolean) request.get("includeTrend");
            Boolean includeInvestment = (Boolean) request.get("includeInvestment");

            Map<String, Object> result = reportService.generatePdfReport(name, type, period, includeWarning,
                    includeRatio, includeTrend, includeInvestment);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("PDF报告生成失败：" + e.getMessage());
        }
    }

    @GetMapping("/pdf/history")
    public Result<List<PdfReport>> getPdfHistory() {
        try {
            List<PdfReport> list = reportService.getPdfReportHistory();
            return Result.success(list);
        } catch (Exception e) {
            return Result.error("获取PDF报告历史失败：" + e.getMessage());
        }
    }

    @GetMapping("/benchmark/data")
    public Result<List<Map<String, Object>>> getBenchmarkData(
            @RequestParam(required = false) String period,
            @RequestParam(required = false) String industry) {
        List<Map<String, Object>> data = reportService.getBenchmarkData(period, industry);
        return Result.success(data);
    }

    @PostMapping("/benchmark/upload")
    public Result<Map<String, Object>> uploadBenchmarkData(@RequestParam("file") MultipartFile file) {
        if (file == null) {
            return Result.badRequest("上传文件不能为空");
        }
        if (file.isEmpty()) {
            return Result.badRequest("上传文件内容不能为空");
        }
        String filename = file.getOriginalFilename();
        if (filename == null || filename.isEmpty()) {
            return Result.badRequest("文件名不能为空");
        }
        String extension = "";
        int dotIndex = filename.lastIndexOf('.');
        if (dotIndex > 0) {
            extension = filename.substring(dotIndex + 1).toLowerCase();
        }
        if (!extension.equals("xlsx") && !extension.equals("xls")) {
            return Result.badRequest("只支持 .xlsx 或 .xls 格式的Excel文件");
        }
        Map<String, Object> result = reportService.uploadBenchmarkData(file);
        return Result.success(result);
    }

    @GetMapping("/benchmark/template")
    public void downloadBenchmarkTemplate(HttpServletResponse response) {
        reportService.downloadBenchmarkTemplate(response);
    }
}
