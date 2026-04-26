package com.sixth_group.finsight_backend.service;

import com.sixth_group.finsight_backend.dto.ImportResultResponse;
import com.sixth_group.finsight_backend.entity.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * 数据服务接口
 * 定义ETL任务管理、数据导入、验证规则、科目映射等数据相关业务方法
 */
public interface DataService {
    List<EtlTask> getEtlTasks(String status);
    EtlTask getEtlTaskById(Long id);
    void triggerEtlTask(Long taskId);
    ImportResultResponse importExcel(MultipartFile file, String type, String mode, String operatorName);
    void downloadTemplate(String type);
    List<ImportHistory> getImportHistory(Integer page, Integer pageSize, String type, String status);
    List<ValidationRule> getValidationRules();
    ValidationRule createValidationRule(ValidationRule rule);
    ValidationRule updateValidationRule(Long id, ValidationRule rule);
    void deleteValidationRule(Long id);
    List<AccountMapping> getAccountMappings(String category);
    AccountMapping createAccountMapping(AccountMapping mapping);
    AccountMapping updateAccountMapping(Long id, AccountMapping mapping);
    void deleteAccountMapping(Long id);
}
