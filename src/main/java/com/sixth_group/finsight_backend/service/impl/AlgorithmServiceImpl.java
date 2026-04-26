package com.sixth_group.finsight_backend.service.impl;

import com.sixth_group.finsight_backend.dto.ForecastProfitRequest;
import com.sixth_group.finsight_backend.dto.InvestmentCalculateRequest;
import com.sixth_group.finsight_backend.entity.InvestmentScheme;
import com.sixth_group.finsight_backend.entity.WarningRecord;
import com.sixth_group.finsight_backend.mapper.InvestmentSchemeMapper;
import com.sixth_group.finsight_backend.mapper.WarningRecordMapper;
import com.sixth_group.finsight_backend.service.AlgorithmService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 算法服务实现类
 * 实现财务比率计算、预警管理、投资分析、利润预测、趋势分析等算法相关业务逻辑
 */
@Service
public class AlgorithmServiceImpl implements AlgorithmService {

    @Autowired
    private WarningRecordMapper warningRecordMapper;

    @Autowired
    private InvestmentSchemeMapper investmentSchemeMapper;

    @Override
    public Map<String, Object> getRatioResults(String period, String category) {
        Map<String, Object> result = new HashMap<>();

        List<Map<String, Object>> solvency = new ArrayList<>();
        solvency.add(createRatioItem("R001", "流动比率", "流动资产/流动负债", 1.85, 1.95, -5.13, "≥2.0"));

        List<Map<String, Object>> operating = new ArrayList<>();
        operating.add(createRatioItem("R002", "资产周转率", "营业收入/平均资产", 0.85, 0.90, -5.56, "≥1.0"));

        List<Map<String, Object>> profitability = new ArrayList<>();
        profitability.add(createRatioItem("R003", "销售净利率", "净利润/营业收入", 15.7, 18.3, -14.21, "≥15%"));

        List<Map<String, Object>> growth = new ArrayList<>();
        growth.add(createRatioItem("R004", "营业收入增长率", "(本期-上期)/上期", 12.5, 10.2, 22.55, "≥10%"));

        if (category == null || category.equals("solvency")) {
            result.put("solvency", solvency);
        } else {
            result.put("solvency", new ArrayList<>());
        }

        if (category == null || category.equals("operating")) {
            result.put("operating", operating);
        } else {
            result.put("operating", new ArrayList<>());
        }

        if (category == null || category.equals("profitability")) {
            result.put("profitability", profitability);
        } else {
            result.put("profitability", new ArrayList<>());
        }

        if (category == null || category.equals("growth")) {
            result.put("growth", growth);
        } else {
            result.put("growth", new ArrayList<>());
        }

        return result;
    }

    private Map<String, Object> createRatioItem(String code, String name, String formula, double value, double prevValue, double changePct, String standard) {
        Map<String, Object> item = new HashMap<>();
        item.put("code", code);
        item.put("name", name);
        item.put("formula", formula);
        item.put("value", value);
        item.put("prevValue", prevValue);
        item.put("change_pct", changePct);
        item.put("standard", standard);
        return item;
    }

    @Override
    public void calculateRatios(String period) {
    }

    @Override
    public List<String> getRatioCategories() {
        return Arrays.asList("solvency", "operating", "profitability", "growth");
    }

    @Override
    public List<WarningRecord> getWarningRecords(String level, String status) {
        if (level == null && status == null) {
            return warningRecordMapper.selectAll();
        }
        return warningRecordMapper.search(level, status);
    }

    @Override
    public void ignoreWarning(Long id) {
        WarningRecord record = warningRecordMapper.selectById(id);
        if (record != null) {
            record.setStatus("ignored");
            warningRecordMapper.update(record);
        }
    }

    @Override
    public Map<String, Integer> getWarningSummary() {
        Map<String, Integer> summary = new HashMap<>();
        summary.put("red", warningRecordMapper.countByLevel("red"));
        summary.put("orange", warningRecordMapper.countByLevel("orange"));
        summary.put("yellow", warningRecordMapper.countByLevel("yellow"));
        return summary;
    }

    @Override
    public Map<String, Object> calculateInvestment(InvestmentCalculateRequest request) {
        Map<String, Object> result = new HashMap<>();

        double npv = 0;
        double cumulative = -request.getInitialInvestment();
        List<Map<String, Object>> discountTable = new ArrayList<>();

        for (InvestmentCalculateRequest.CashFlow cf : request.getCashFlows()) {
            double discountFactor = 1 / Math.pow(1 + request.getDiscountRate() / 100.0, cf.getYear());
            double discountedCashFlow = cf.getAmount() * discountFactor;
            cumulative += cf.getAmount();

            Map<String, Object> row = new HashMap<>();
            row.put("year", cf.getYear());
            row.put("cashFlow", cf.getAmount());
            row.put("cumulative", cumulative);
            row.put("discountFactor", Math.round(discountFactor * 10000.0) / 10000.0);
            row.put("discountedCashFlow", Math.round(discountedCashFlow * 100.0) / 100.0);
            row.put("cumulativeDiscounted", Math.round((npv + discountedCashFlow - request.getInitialInvestment()) * 100.0) / 100.0);

            discountTable.add(row);
            npv += discountedCashFlow;
        }

        npv -= request.getInitialInvestment();

        double staticPayback = 0;
        double runningTotal = 0;
        for (InvestmentCalculateRequest.CashFlow cf : request.getCashFlows()) {
            runningTotal += cf.getAmount();
            if (runningTotal >= request.getInitialInvestment()) {
                staticPayback = cf.getYear() - 1 + (request.getInitialInvestment() - (runningTotal - cf.getAmount())) / cf.getAmount();
                break;
            }
        }

        double dynamicPayback = 0;
        double discountedRunningTotal = 0;
        for (InvestmentCalculateRequest.CashFlow cf : request.getCashFlows()) {
            double discountFactor = 1 / Math.pow(1 + request.getDiscountRate() / 100.0, cf.getYear());
            discountedRunningTotal += cf.getAmount() * discountFactor;
            if (discountedRunningTotal >= request.getInitialInvestment()) {
                dynamicPayback = cf.getYear() - 1 + (request.getInitialInvestment() - (discountedRunningTotal - cf.getAmount() * discountFactor)) / (cf.getAmount() * discountFactor);
                break;
            }
        }

        double irr = calculateIrr(request.getInitialInvestment(), request.getCashFlows());

        result.put("npv", Math.round(npv * 100.0) / 100.0);
        result.put("irr", Math.round(irr * 100.0) / 100.0);
        result.put("staticPayback", Math.round(staticPayback * 100.0) / 100.0);
        result.put("dynamicPayback", Math.round(dynamicPayback * 100.0) / 100.0);
        result.put("discountTable", discountTable);

        return result;
    }

    private double calculateIrr(double initialInvestment, List<InvestmentCalculateRequest.CashFlow> cashFlows) {
        double low = 0;
        double high = 100;
        double irr = 0;

        for (int i = 0; i < 100; i++) {
            irr = (low + high) / 2;
            double npv = -initialInvestment;
            for (InvestmentCalculateRequest.CashFlow cf : cashFlows) {
                npv += cf.getAmount() / Math.pow(1 + irr / 100.0, cf.getYear());
            }

            if (Math.abs(npv) < 0.01) {
                break;
            } else if (npv > 0) {
                low = irr;
            } else {
                high = irr;
            }
        }

        return irr;
    }

    @Override
    public InvestmentScheme saveInvestmentScheme(InvestmentCalculateRequest request, Map<String, Object> result) {
        InvestmentScheme scheme = new InvestmentScheme();
        scheme.setProjectName(request.getProjectName());
        scheme.setInitialInvestment(request.getInitialInvestment());
        scheme.setDiscountRate(request.getDiscountRate());
        scheme.setNpv((Double) result.get("npv"));
        scheme.setIrr((Double) result.get("irr"));
        scheme.setStaticPayback((Double) result.get("staticPayback"));
        scheme.setDynamicPayback((Double) result.get("dynamicPayback"));
        scheme.setCreatedAt(LocalDateTime.now());

        investmentSchemeMapper.insert(scheme);
        return scheme;
    }

    @Override
    public List<InvestmentScheme> getInvestmentSchemes() {
        return investmentSchemeMapper.selectAll();
    }

    @Override
    public List<Map<String, Object>> forecastProfit(ForecastProfitRequest request) {
        List<Map<String, Object>> results = new ArrayList<>();
        double revenue = request.getBaseRevenue();

        for (int i = 1; i <= request.getPeriods(); i++) {
            Map<String, Object> forecast = new HashMap<>();
            forecast.put("period", "2026-Q" + (i + 1));

            revenue = revenue * (1 + request.getRevenueGrowthRate() / 100.0);
            double cost = revenue * request.getCostRate() / 100.0;
            double expense = revenue * request.getExpenseRate() / 100.0;
            double profitBeforeTax = revenue - cost - expense;
            double tax = profitBeforeTax * request.getTaxRate() / 100.0;
            double netProfit = profitBeforeTax - tax;

            forecast.put("revenue", Math.round(revenue * 100.0) / 100.0);
            forecast.put("cost", Math.round(cost * 100.0) / 100.0);
            forecast.put("expense", Math.round(expense * 100.0) / 100.0);
            forecast.put("profitBeforeTax", Math.round(profitBeforeTax * 100.0) / 100.0);
            forecast.put("tax", Math.round(tax * 100.0) / 100.0);
            forecast.put("netProfit", Math.round(netProfit * 100.0) / 100.0);

            results.add(forecast);
        }

        return results;
    }

    @Override
    public List<Map<String, Object>> getTrendData(String indicator, Integer months) {
        if (months == null) months = 12;

        List<Map<String, Object>> data = new ArrayList<>();
        String[] monthsArr = {"2025-05", "2025-06", "2025-07", "2025-08", "2025-09", "2025-10", "2025-11", "2025-12", "2026-01", "2026-02", "2026-03", "2026-04"};
        double[] values = {16.8, 16.2, 15.9, 16.1, 15.5, 15.8, 16.0, 15.7, 15.9, 16.2, 15.8, 15.6};

        for (int i = 0; i < Math.min(months, 12); i++) {
            Map<String, Object> item = new HashMap<>();
            item.put("month", monthsArr[i]);
            item.put("value", values[i]);
            data.add(item);
        }

        return data;
    }

    @Override
    public Map<String, Object> getDupontData(String period) {
        Map<String, Object> data = new HashMap<>();
        data.put("roe", 15.6);
        data.put("roeChange", -1.2);

        List<Map<String, Object>> factors = new ArrayList<>();

        Map<String, Object> factor1 = new HashMap<>();
        factor1.put("name", "销售净利率");
        factor1.put("value", 15.7);
        factor1.put("prevValue", 18.3);
        factor1.put("change_pct", -14.2);
        factor1.put("contribution", -4.1);
        factors.add(factor1);

        Map<String, Object> factor2 = new HashMap<>();
        factor2.put("name", "总资产周转率");
        factor2.put("value", 0.85);
        factor2.put("prevValue", 0.9);
        factor2.put("change_pct", -5.6);
        factor2.put("contribution", -0.9);
        factors.add(factor2);

        Map<String, Object> factor3 = new HashMap<>();
        factor3.put("name", "权益乘数");
        factor3.put("value", 1.83);
        factor3.put("prevValue", 1.72);
        factor3.put("change_pct", 6.4);
        factor3.put("contribution", 3.8);
        factors.add(factor3);

        data.put("factors", factors);

        return data;
    }
}
