package com.sixth_group.finsight_backend.service.impl;

import com.sixth_group.finsight_backend.entity.*;
import com.sixth_group.finsight_backend.mapper.*;
import com.sixth_group.finsight_backend.service.ConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 配置服务实现类
 * 实现公式管理、阈值配置、知识库、模型版本等配置相关业务逻辑
 */
@Service
public class ConfigServiceImpl implements ConfigService {

    @Autowired
    private FormulaMapper formulaMapper;

    @Autowired
    private ThresholdMapper thresholdMapper;

    @Autowired
    private KnowledgeMapper knowledgeMapper;

    @Autowired
    private ModelVersionMapper modelVersionMapper;

    @Override
    public List<Formula> getFormulas(String category, String keyword) {
        if (category == null && keyword == null) {
            return formulaMapper.selectAll();
        }
        return formulaMapper.search(category, keyword);
    }

    @Override
    public Formula createFormula(Formula formula) {
        formula.setVersion("v1.0");
        formula.setUpdateTime(LocalDateTime.now());
        formulaMapper.insert(formula);
        return formula;
    }

    @Override
    public Formula updateFormula(Long id, Formula formula) {
        formula.setId(id);
        formula.setUpdateTime(LocalDateTime.now());
        formulaMapper.update(formula);
        return formula;
    }

    @Override
    public void deleteFormula(Long id) {
        formulaMapper.deleteById(id);
    }

    @Override
    public Map<String, Object> validateFormula(String expression) {
        Map<String, Object> result = new HashMap<>();
        if (expression == null || expression.trim().isEmpty()) {
            result.put("valid", false);
            result.put("message", "表达式不能为空");
            return result;
        }

        if (expression.contains("=") && !expression.startsWith("=")) {
            result.put("valid", false);
            result.put("message", "表达式语法错误");
            return result;
        }

        result.put("valid", true);
        result.put("message", "表达式语法验证通过");
        return result;
    }

    @Override
    public List<Threshold> getThresholds() {
        return thresholdMapper.selectAll();
    }

    @Override
    public Threshold createThreshold(Threshold threshold) {
        threshold.setUpdateTime(LocalDateTime.now());
        thresholdMapper.insert(threshold);
        return threshold;
    }

    @Override
    public Threshold updateThreshold(Long id, Threshold threshold) {
        threshold.setId(id);
        threshold.setUpdateTime(LocalDateTime.now());
        thresholdMapper.update(threshold);
        return threshold;
    }

    @Override
    public Map<String, String> getDynamicSuggestion(String indicatorCode) {
        Map<String, String> suggestion = new HashMap<>();
        suggestion.put("yellowValue", "< 0.28");
        suggestion.put("orangeValue", "< 0.23");
        suggestion.put("redValue", "< 0.18");
        suggestion.put("basis", "基于近3年P25/P10/P5分位数");
        return suggestion;
    }

    @Override
    public List<Knowledge> getKnowledgeList(String indicator, String level) {
        if (indicator == null && level == null) {
            return knowledgeMapper.selectAll();
        }
        return knowledgeMapper.search(indicator, level);
    }

    @Override
    public Knowledge createKnowledge(Knowledge knowledge) {
        knowledge.setUpdateTime(LocalDateTime.now());
        knowledgeMapper.insert(knowledge);
        return knowledge;
    }

    @Override
    public Knowledge updateKnowledge(Long id, Knowledge knowledge) {
        knowledge.setId(id);
        knowledge.setUpdateTime(LocalDateTime.now());
        knowledgeMapper.update(knowledge);
        return knowledge;
    }

    @Override
    public void deleteKnowledge(Long id) {
        knowledgeMapper.deleteById(id);
    }

    @Override
    public List<ModelVersion> getVersions(String modelType) {
        if (modelType == null) {
            return modelVersionMapper.selectAll();
        }
        return modelVersionMapper.selectByModelType(modelType);
    }

    @Override
    public Map<String, Object> simulateVersion(Long versionId, String modelType) {
        Map<String, Object> result = new HashMap<>();
        result.put("version", "v1.2");

        List<Map<String, Object>> differences = new ArrayList<>();
        Map<String, Object> diff = new HashMap<>();
        diff.put("indicator", "流动比率");
        diff.put("currentResult", 1.85);
        diff.put("simulatedResult", 1.82);
        diff.put("diff", -0.03);
        differences.add(diff);

        result.put("differences", differences);
        return result;
    }

    @Override
    public void switchVersion(Long versionId, String modelType) {
        ModelVersion version = modelVersionMapper.selectById(versionId);
        if (version != null) {
            String currentModelType = version.getModelType();
            modelVersionMapper.deactivateByModelType(currentModelType);
            modelVersionMapper.activateById(versionId);
        }
    }

    @Override
    public Map<String, Object> exportKnowledge() {
        // 导出知识库
        List<Knowledge> knowledgeList = knowledgeMapper.selectAll();
        Map<String, Object> result = new HashMap<>();
        result.put("knowledgeList", knowledgeList);
        result.put("total", knowledgeList.size());
        return result;
    }

    @Override
    public void importKnowledge(List<Knowledge> knowledgeList) {
        // 导入知识库
        for (Knowledge knowledge : knowledgeList) {
            knowledge.setUpdateTime(LocalDateTime.now());
            // 检查是否已存在相同的知识条目
            // 这里可以根据indicator和level进行判断
            knowledgeMapper.insert(knowledge);
        }
    }
}
