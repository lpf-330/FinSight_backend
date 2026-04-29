package com.sixth_group.finsight_backend.service.impl;

import com.sixth_group.finsight_backend.entity.PdfReport;
import com.sixth_group.finsight_backend.mapper.PdfReportMapper;
import com.sixth_group.finsight_backend.service.ReportService;

import jakarta.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 报告服务实现类
 * 实现仪表盘数据、图表数据、PDF报告生成、对标数据等报告相关业务逻辑
 */
@Service
public class ReportServiceImpl implements ReportService {

    @Autowired
    private PdfReportMapper pdfReportMapper;

    @Override
    public Map<String, Object> getDashboardData() {
        Map<String, Object> data = new HashMap<>();

        List<Map<String, Object>> indicatorCards = new ArrayList<>();
        Map<String, Object> card1 = new HashMap<>();
        card1.put("label", "营业收入");
        card1.put("value", "2,458.6");
        card1.put("unit", "万元");
        card1.put("change_pct", 12.5);
        card1.put("icon", "TrendCharts");
        card1.put("color", "#409eff");
        card1.put("bgColor", "#ecf5ff");
        indicatorCards.add(card1);

        Map<String, Object> card2 = new HashMap<>();
        card2.put("label", "净利润");
        card2.put("value", "386.5");
        card2.put("unit", "万元");
        card2.put("change_pct", 8.3);
        card2.put("icon", "Money");
        card2.put("color", "#67c23a");
        card2.put("bgColor", "#f0f9eb");
        indicatorCards.add(card2);

        data.put("indicatorCards", indicatorCards);

        List<Map<String, Object>> warningList = new ArrayList<>();
        Map<String, Object> warning = new HashMap<>();
        warning.put("id", 1);
        warning.put("indicator", "流动比率");
        warning.put("level", "yellow");
        warning.put("value", "1.85");
        warning.put("threshold", "< 2.0");
        warning.put("suggestion", "建议优化短期偿债能力");
        warning.put("time", "2026-04-24 09:30");
        warningList.add(warning);
        data.put("warningList", warningList);

        Map<String, Object> revenueChart = new HashMap<>();
        revenueChart.put("months",
                Arrays.asList("1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"));
        revenueChart.put("revenue", Arrays.asList(180, 165, 195, 210, 198, 220, 205, 230, 215, 240, 225, 245));
        revenueChart.put("profit", Arrays.asList(28, 25, 32, 35, 30, 38, 33, 40, 36, 42, 38, 45));
        data.put("revenueChart", revenueChart);

        Map<String, Object> ratioChart = new HashMap<>();
        ratioChart.put("months",
                Arrays.asList("1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"));
        ratioChart.put("currentRatio",
                Arrays.asList(2.1, 2.0, 1.95, 1.9, 1.92, 1.88, 1.85, 1.82, 1.86, 1.83, 1.80, 1.85));
        ratioChart.put("quickRatio",
                Arrays.asList(1.2, 1.15, 1.1, 1.05, 1.08, 1.02, 0.98, 0.95, 0.92, 0.90, 0.88, 0.92));
        ratioChart.put("cashRatio",
                Arrays.asList(0.35, 0.32, 0.28, 0.25, 0.23, 0.22, 0.20, 0.18, 0.17, 0.16, 0.15, 0.15));
        data.put("ratioChart", ratioChart);

        return data;
    }

    @Override
    public Map<String, Object> getChartsData(String period, String chartType) {
        Map<String, Object> data = new HashMap<>();

        Map<String, Object> profitTrend = new HashMap<>();
        profitTrend.put("months", Arrays.asList("1月", "2月", "3月", "4月", "5月", "6月"));
        profitTrend.put("revenue", Arrays.asList(180, 165, 195, 210, 198, 220));
        profitTrend.put("cost", Arrays.asList(120, 110, 130, 140, 132, 147));
        profitTrend.put("grossProfit", Arrays.asList(60, 55, 65, 70, 66, 73));
        profitTrend.put("netProfit", Arrays.asList(28, 25, 32, 35, 30, 38));
        data.put("profitTrend", profitTrend);

        List<Map<String, Object>> structure = new ArrayList<>();
        Map<String, Object> item1 = new HashMap<>();
        item1.put("name", "营业成本");
        item1.put("value", 1659.6);
        structure.add(item1);

        Map<String, Object> item2 = new HashMap<>();
        item2.put("name", "销售费用");
        item2.put("value", 245.8);
        structure.add(item2);

        Map<String, Object> item3 = new HashMap<>();
        item3.put("name", "管理费用");
        item3.put("value", 196.7);
        structure.add(item3);
        data.put("structure", structure);

        List<Map<String, Object>> comparison = new ArrayList<>();
        Map<String, Object> comp = new HashMap<>();
        comp.put("indicator", "营业收入");
        comp.put("current", 2458.6);
        comp.put("lastYear", 2185.2);
        comp.put("yoy", 12.5);
        comp.put("mom", 8.7);
        comparison.add(comp);
        data.put("comparison", comparison);

        List<Map<String, Object>> balanceSheet = new ArrayList<>();
        Map<String, Object> bs = new HashMap<>();
        bs.put("label", "资产总额");
        bs.put("value", "5,426.8 万元");
        balanceSheet.add(bs);
        data.put("balanceSheet", balanceSheet);

        List<Map<String, Object>> incomeStatement = new ArrayList<>();
        Map<String, Object> is = new HashMap<>();
        is.put("label", "营业收入");
        is.put("value", "2,458.6 万元");
        incomeStatement.add(is);
        data.put("incomeStatement", incomeStatement);

        List<Map<String, Object>> cashFlow = new ArrayList<>();
        Map<String, Object> cf = new HashMap<>();
        cf.put("label", "经营活动");
        cf.put("value", "521.8 万元");
        cashFlow.add(cf);
        data.put("cashFlow", cashFlow);

        return data;
    }

    @Override
    public Map<String, Object> generatePdfReport(String name, String type, String period, Boolean includeWarning,
            Boolean includeRatio, Boolean includeTrend, Boolean includeInvestment) {
        Map<String, Object> result = new HashMap<>();

        try {
            PdfReport report = new PdfReport();
            report.setName(name);
            report.setType(type);
            report.setPeriod(period);
            report.setStatus("completed");
            report.setCreateTime(LocalDateTime.now());
            report.setFileSize("2.8MB");
            report.setCreatorName("admin");
            pdfReportMapper.insert(report);

            result.put("id", report.getId());
            result.put("status", "completed");
            result.put("message", "PDF报告生成成功");
        } catch (Exception e) {
            // 处理数据库异常，返回友好的错误信息
            result.put("status", "failed");
            result.put("message", "PDF报告生成失败：" + e.getMessage());
        }

        return result;
    }

    @Override
    public List<PdfReport> getPdfReportHistory() {
        try {
            return pdfReportMapper.selectAll();
        } catch (Exception e) {
            // 处理数据库异常，返回空列表
            return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> getBenchmarkData(String period, String industry) {
        List<Map<String, Object>> data = new ArrayList<>();

        Map<String, Object> item1 = new HashMap<>();
        item1.put("indicator", "流动比率");
        item1.put("indicatorCode", "R001");
        item1.put("enterprise", 1.85);
        item1.put("industryAvg", 2.1);
        item1.put("industryBest", 3.2);
        item1.put("deviation", 88.1);
        data.add(item1);

        Map<String, Object> item2 = new HashMap<>();
        item2.put("indicator", "资产负债率");
        item2.put("indicatorCode", "R002");
        item2.put("enterprise", 45.2);
        item2.put("industryAvg", 50.0);
        item2.put("industryBest", 35.0);
        item2.put("deviation", 110.5);
        data.add(item2);

        Map<String, Object> item3 = new HashMap<>();
        item3.put("indicator", "净资产收益率");
        item3.put("indicatorCode", "R003");
        item3.put("enterprise", 12.8);
        item3.put("industryAvg", 10.5);
        item3.put("industryBest", 18.2);
        item3.put("deviation", 92.3);
        data.add(item3);

        return data;
    }

    @Override
    public Map<String, Object> uploadBenchmarkData(org.springframework.web.multipart.MultipartFile file) {
        Map<String, Object> result = new HashMap<>();
        result.put("status", "success");
        result.put("message", "行业对标数据上传成功");
        result.put("fileName", file.getOriginalFilename());
        result.put("fileSize", file.getSize() + " bytes");
        result.put("uploadTime", java.time.LocalDateTime.now());
        return result;
    }

    @Override
    public void downloadBenchmarkTemplate(HttpServletResponse response) {
        try {
            response.setContentType("application/vnd.ms-excel");
            response.setHeader("Content-Disposition", "attachment; filename=benchmark_template.xlsx");

            // 模拟生成Excel模板文件
            byte[] templateData = "indicator,indicatorCode,industryAvg,industryBest\n流动比率,R001,2.1,3.2\n资产负债率,R002,50.0,35.0\n净资产收益率,R003,10.5,18.2"
                    .getBytes();
            response.getOutputStream().write(templateData);
            response.getOutputStream().flush();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
