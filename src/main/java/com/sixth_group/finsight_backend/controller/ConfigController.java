package com.sixth_group.finsight_backend.controller;

import com.sixth_group.finsight_backend.entity.*;
import com.sixth_group.finsight_backend.service.ConfigService;
import com.sixth_group.finsight_backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 配置控制器
 * 处理公式管理、阈值配置、知识库、模型版本等配置相关HTTP请求
 */
@RestController
@RequestMapping("/config")
public class ConfigController {
    //
    @Autowired
    private ConfigService configService;

    @GetMapping("/formula")
    public Result<List<Formula>> getFormulas(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword) {
        List<Formula> formulas = configService.getFormulas(category, keyword);
        return Result.success(formulas);
    }

    @PostMapping("/formula")
    public Result<Formula> createFormula(@RequestBody Formula formula) {
        Formula created = configService.createFormula(formula);
        return Result.success(created);
    }

    @PutMapping("/formula/{id}")
    public Result<Formula> updateFormula(@PathVariable Long id, @RequestBody Formula formula) {
        Formula updated = configService.updateFormula(id, formula);
        return Result.success(updated);
    }

    @DeleteMapping("/formula/{id}")
    public Result<Void> deleteFormula(@PathVariable Long id) {
        configService.deleteFormula(id);
        return Result.success();
    }

    @PostMapping("/formula/validate")
    public Result<Map<String, Object>> validateFormula(@RequestBody Map<String, String> request) {
        String expression = request.get("expression");
        Map<String, Object> result = configService.validateFormula(expression);
        return Result.success(result);
    }

    @GetMapping("/threshold")
    public Result<List<Threshold>> getThresholds() {
        List<Threshold> thresholds = configService.getThresholds();
        return Result.success(thresholds);
    }

    @PostMapping("/threshold")
    public Result<Threshold> createThreshold(@RequestBody Threshold threshold) {
        Threshold created = configService.createThreshold(threshold);
        return Result.success(created);
    }

    @PutMapping("/threshold/{id}")
    public Result<Threshold> updateThreshold(@PathVariable Long id, @RequestBody Threshold threshold) {
        Threshold updated = configService.updateThreshold(id, threshold);
        return Result.success(updated);
    }

    @GetMapping("/threshold/dynamic-suggestion/{indicatorCode}")
    public Result<Map<String, String>> getDynamicSuggestion(@PathVariable String indicatorCode) {
        Map<String, String> suggestion = configService.getDynamicSuggestion(indicatorCode);
        return Result.success(suggestion);
    }

    @GetMapping("/knowledge")
    public Result<List<Knowledge>> getKnowledgeList(
            @RequestParam(required = false) String indicator,
            @RequestParam(required = false) String level) {
        List<Knowledge> list = configService.getKnowledgeList(indicator, level);
        return Result.success(list);
    }

    @PostMapping("/knowledge")
    public Result<Knowledge> createKnowledge(@RequestBody Knowledge knowledge) {
        Knowledge created = configService.createKnowledge(knowledge);
        return Result.success(created);
    }

    @PutMapping("/knowledge/{id}")
    public Result<Knowledge> updateKnowledge(@PathVariable Long id, @RequestBody Knowledge knowledge) {
        Knowledge updated = configService.updateKnowledge(id, knowledge);
        return Result.success(updated);
    }

    @DeleteMapping("/knowledge/{id}")
    public Result<Void> deleteKnowledge(@PathVariable Long id) {
        configService.deleteKnowledge(id);
        return Result.success();
    }

    @GetMapping("/knowledge/export")
    public Result<Map<String, Object>> exportKnowledge() {
        Map<String, Object> result = configService.exportKnowledge();
        return Result.success(result);
    }

    @PostMapping("/knowledge/import")
    public Result<Void> importKnowledge(@RequestBody Map<String, Object> request) {
        if (request == null) {
            return Result.badRequest("请求体不能为空");
        }

        List<Knowledge> knowledgeList = (List<Knowledge>) request.get("knowledgeList");
        if (knowledgeList == null || knowledgeList.isEmpty()) {
            return Result.badRequest("知识库列表不能为空");
        }

        for (int i = 0; i < knowledgeList.size(); i++) {
            Knowledge knowledge = knowledgeList.get(i);
            if (knowledge == null) {
                return Result.badRequest("第 " + (i + 1) + " 条知识库记录不能为空");
            }
            if (knowledge.getIndicator() == null || knowledge.getIndicator().trim().isEmpty()) {
                return Result.badRequest("第 " + (i + 1) + " 条知识库记录的指标名称不能为空");
            }
            if (knowledge.getContent() == null || knowledge.getContent().trim().isEmpty()) {
                return Result.badRequest("第 " + (i + 1) + " 条知识库记录的内容不能为空");
            }
        }

        configService.importKnowledge(knowledgeList);
        return Result.success();
    }

    @GetMapping("/version")
    public Result<List<ModelVersion>> getVersions(@RequestParam(required = false) String modelType) {
        List<ModelVersion> versions = configService.getVersions(modelType);
        return Result.success(versions);
    }

    @PostMapping("/version/simulate")
    public Result<Map<String, Object>> simulateVersion(@RequestBody Map<String, Object> request) {
        Long versionId = ((Number) request.get("versionId")).longValue();
        String modelType = (String) request.get("modelType");
        Map<String, Object> result = configService.simulateVersion(versionId, modelType);
        return Result.success(result);
    }

    @PutMapping("/version/switch")
    public Result<Void> switchVersion(@RequestBody Map<String, Object> request) {
        try {
            Long versionId = ((Number) request.get("versionId")).longValue();
            String modelType = (String) request.get("modelType");
            configService.switchVersion(versionId, modelType);
            return Result.success();
        } catch (Exception e) {
            return Result.error("版本切换失败：" + e.getMessage());
        }
    }
}
