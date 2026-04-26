package com.sixth_group.finsight_backend.controller;

import com.sixth_group.finsight_backend.dto.EtlTriggerRequest;
import com.sixth_group.finsight_backend.dto.ImportResultResponse;
import com.sixth_group.finsight_backend.entity.AccountMapping;
import com.sixth_group.finsight_backend.entity.EtlTask;
import com.sixth_group.finsight_backend.entity.ImportHistory;
import com.sixth_group.finsight_backend.entity.ValidationRule;
import com.sixth_group.finsight_backend.service.DataService;
import com.sixth_group.finsight_backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 数据控制器
 * 处理ETL任务管理、数据导入、验证规则、科目映射等数据相关HTTP请求
 */
@RestController
@RequestMapping("/data")
public class DataController {

    @Autowired
    private DataService dataService;

    // 获取ETL任务列表
    @GetMapping("/etl/tasks")
    public Result<List<EtlTask>> getEtlTasks(@RequestParam(required = false) String status) {
        List<EtlTask> tasks = dataService.getEtlTasks(status);
        return Result.success(tasks);
    }

    // 触发ETL任务
    @PostMapping("/etl/trigger")
    public Result<Void> triggerEtlTask(@RequestBody EtlTriggerRequest request) {
        dataService.triggerEtlTask(request.getTaskId());
        return Result.success();
    }

    // 获取ETL任务详情
    @GetMapping("/etl/tasks/{id}")
    public Result<Map<String, Object>> getEtlTaskDetail(@PathVariable Long id) {
        EtlTask task = dataService.getEtlTaskById(id);
        Map<String, Object> result = new HashMap<>();
        result.put("id", task.getId());
        result.put("name", task.getName());
        result.put("logs", List.of());
        return Result.success(result);
    }

    // 导入Excel数据
    @PostMapping("/import/excel")
    public Result<ImportResultResponse> importExcel(
            @RequestParam("file") MultipartFile file,
            @RequestParam("type") String type,
            @RequestParam("mode") String mode) {
        try {
            ImportResultResponse result = dataService.importExcel(file, type, mode, "admin");
            return Result.success(result);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    // 下载导入模板
    @GetMapping("/import/template")
    public Result<Void> downloadTemplate(@RequestParam String type) {
        dataService.downloadTemplate(type);
        return Result.success();
    }

    // 获取导入历史记录
    @GetMapping("/import/history")
    public Result<Map<String, Object>> getImportHistory(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer pageSize,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String status) {
        List<ImportHistory> list = dataService.getImportHistory(page, pageSize, type, status);
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", list.size());
        return Result.success(result);
    }

    // 获取验证规则列表
    @GetMapping("/validation/rules")
    public Result<List<ValidationRule>> getValidationRules() {
        List<ValidationRule> rules = dataService.getValidationRules();
        return Result.success(rules);
    }

    // 创建验证规则
    @PostMapping("/validation/rules")
    public Result<ValidationRule> createValidationRule(@RequestBody ValidationRule rule) {
        ValidationRule created = dataService.createValidationRule(rule);
        return Result.success(created);
    }

    // 更新验证规则
    @PutMapping("/validation/rules/{id}")
    public Result<ValidationRule> updateValidationRule(@PathVariable Long id, @RequestBody ValidationRule rule) {
        ValidationRule updated = dataService.updateValidationRule(id, rule);
        return Result.success(updated);
    }

    // 删除验证规则
    @DeleteMapping("/validation/rules/{id}")
    public Result<Void> deleteValidationRule(@PathVariable Long id) {
        dataService.deleteValidationRule(id);
        return Result.success();
    }

    // 获取科目映射列表
    @GetMapping("/mapping")
    public Result<List<AccountMapping>> getAccountMappings(@RequestParam(required = false) String category) {
        List<AccountMapping> mappings = dataService.getAccountMappings(category);
        return Result.success(mappings);
    }

    // 创建科目映射
    @PostMapping("/mapping")
    public Result<AccountMapping> createAccountMapping(@RequestBody AccountMapping mapping) {
        AccountMapping created = dataService.createAccountMapping(mapping);
        return Result.success(created);
    }

    // 更新科目映射
    @PutMapping("/mapping/{id}")
    public Result<AccountMapping> updateAccountMapping(@PathVariable Long id, @RequestBody AccountMapping mapping) {
        AccountMapping updated = dataService.updateAccountMapping(id, mapping);
        return Result.success(updated);
    }

    // 删除科目映射
    @DeleteMapping("/mapping/{id}")
    public Result<Void> deleteAccountMapping(@PathVariable Long id) {
        dataService.deleteAccountMapping(id);
        return Result.success();
    }
}
