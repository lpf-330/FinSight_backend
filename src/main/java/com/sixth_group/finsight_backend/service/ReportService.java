package com.sixth_group.finsight_backend.service;

import com.sixth_group.finsight_backend.entity.PdfReport;

import java.util.List;
import java.util.Map;

/**
 * 报告服务接口
 * 定义仪表盘数据、图表数据、PDF报告生成、对标数据等报告相关业务方法
 */
public interface ReportService {
    Map<String, Object> getDashboardData();

    Map<String, Object> getChartsData(String period, String chartType);

    Map<String, Object> generatePdfReport(String name, String type, String period, Boolean includeWarning,
            Boolean includeRatio, Boolean includeTrend, Boolean includeInvestment);

    List<PdfReport> getPdfReportHistory();

    List<Map<String, Object>> getBenchmarkData(String period, String industry);

    Map<String, Object> uploadBenchmarkData(org.springframework.web.multipart.MultipartFile file);

    void downloadBenchmarkTemplate(jakarta.servlet.http.HttpServletResponse response);
}
