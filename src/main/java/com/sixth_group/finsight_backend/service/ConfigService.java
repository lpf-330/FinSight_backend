package com.sixth_group.finsight_backend.service;

import com.sixth_group.finsight_backend.entity.*;

import java.util.List;
import java.util.Map;

/**
 * 配置服务接口
 * 定义公式管理、阈值配置、知识库、模型版本等配置相关业务方法
 */
public interface ConfigService {
    List<Formula> getFormulas(String category, String keyword);
    Formula createFormula(Formula formula);
    Formula updateFormula(Long id, Formula formula);
    void deleteFormula(Long id);
    Map<String, Object> validateFormula(String expression);

    List<Threshold> getThresholds();
    Threshold createThreshold(Threshold threshold);
    Threshold updateThreshold(Long id, Threshold threshold);
    Map<String, String> getDynamicSuggestion(String indicatorCode);

    List<Knowledge> getKnowledgeList(String indicator, String level);
    Knowledge createKnowledge(Knowledge knowledge);
    Knowledge updateKnowledge(Long id, Knowledge knowledge);
    void deleteKnowledge(Long id);

    List<ModelVersion> getVersions(String modelType);
    Map<String, Object> simulateVersion(Long versionId, String modelType);
    void switchVersion(Long versionId, String modelType);
}
