package com.sixth_group.finsight_backend.service.impl;

import com.sixth_group.finsight_backend.entity.PdfReport;
import com.sixth_group.finsight_backend.mapper.PdfReportMapper;
import com.sixth_group.finsight_backend.service.ReportService;
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
        revenueChart.put("months", Arrays.asList("1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"));
        revenueChart.put("revenue", Arrays.asList(180, 165, 195, 210, 198, 220, 205, 230, 215, 240, 225, 245));
        revenueChart.put("profit", Arrays.asList(28, 25, 32, 35, 30, 38, 33, 40, 36, 42, 38, 45));
        data.put("revenueChart", revenueChart);

        Map<String, Object> ratioChart = new HashMap<>();
        ratioChart.put("months", Arrays.asList("1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"));
        ratioChart.put("currentRatio", Arrays.asList(2.1, 2.0, 1.95, 1.9, 1.92, 1.88, 1.85, 1.82, 1.86, 1.83, 1.80, 1.85));
        ratioChart.put("quickRatio", Arrays.asList(1.2, 1.15, 1.1, 1.05, 1.08, 1.02, 0.98, 0.95, 0.92, 0.90, 0.88, 0.92));
        ratioChart.put("cashRatio", Arrays.asList(0.35, 0.32, 0.28, 0.25, 0.23, 0.22, 0.20, 0.18, 0.17, 0.16, 0.15, 0.15));
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
    public Map<String, Object> generatePdfReport(String name, String type, String period, Boolean includeWarning, Boolean includeRatio, Boolean includeTrend, Boolean includeInvestment) {
        Map<String, Object> result = new HashMap<>();

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

        return result;
    }

    @Override
    public List<PdfReport> getPdfReportHistory() {
        return pdfReportMapper.selectAll();
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
        item2.put("indicator", "速动比率");
        item2.put("indicatorCode", "R002");
        item2.put("enterprise", 0.92);
        item2.put("industryAvg", 1.5);
        item2.put("industryBest", 2.5);
        item2.put("deviation", 61.3);
        data.add(item2);

        Map<String, Object> item3 = new HashMap<>();
        item3.put("indicator", "资产负债率");
        item3.put("indicatorCode", "R003");
        item3.put("enterprise", 45.6);
        item3.put("industryAvg", 40.0);
        item3.put("industryBest", 30.0);
        item3.put("deviation", 114.0);
        data.add(item3);

        return data;
    }
}
