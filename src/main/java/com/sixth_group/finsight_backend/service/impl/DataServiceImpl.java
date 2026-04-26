package com.sixth_group.finsight_backend.service.impl;

import com.sixth_group.finsight_backend.dto.ImportResultResponse;
import com.sixth_group.finsight_backend.entity.*;
import com.sixth_group.finsight_backend.mapper.*;
import com.sixth_group.finsight_backend.service.DataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 数据服务实现类
 * 实现ETL任务管理、数据导入、验证规则、科目映射等数据相关业务逻辑
 */
@Service
public class DataServiceImpl implements DataService {

    @Autowired
    private EtlTaskMapper etlTaskMapper;

    @Autowired
    private ImportHistoryMapper importHistoryMapper;

    @Autowired
    private ValidationRuleMapper validationRuleMapper;

    @Autowired
    private AccountMappingMapper accountMappingMapper;

    @Override
    public List<EtlTask> getEtlTasks(String status) {
        if (status == null || status.isEmpty()) {
            return etlTaskMapper.selectAll();
        }
        return etlTaskMapper.selectByStatus(status);
    }

    @Override
    public EtlTask getEtlTaskById(Long id) {
        return etlTaskMapper.selectById(id);
    }

    @Override
    public void triggerEtlTask(Long taskId) {
        EtlTask task = etlTaskMapper.selectById(taskId);
        if (task != null) {
            task.setStatus("running");
            task.setLastRun(LocalDateTime.now());
            etlTaskMapper.update(task);
        }
    }

    @Override
    public ImportResultResponse importExcel(MultipartFile file, String type, String mode, String operatorName) {
        ImportHistory history = new ImportHistory();
        history.setFileName(file.getOriginalFilename());
        history.setType(type);
        history.setMode(mode);
        history.setRecords(0);
        history.setStatus("success");
        history.setOperatorName(operatorName);
        history.setCreatedAt(LocalDateTime.now());

        importHistoryMapper.insert(history);

        return new ImportResultResponse(0, file.getOriginalFilename());
    }

    @Override
    public void downloadTemplate(String type) {
    }

    @Override
    public List<ImportHistory> getImportHistory(Integer page, Integer pageSize, String type, String status) {
        if (page == null) page = 1;
        if (pageSize == null) pageSize = 20;
        int offset = (page - 1) * pageSize;
        return importHistoryMapper.search(type, status, offset, pageSize);
    }

    @Override
    public List<ValidationRule> getValidationRules() {
        return validationRuleMapper.selectAll();
    }

    @Override
    public ValidationRule createValidationRule(ValidationRule rule) {
        rule.setCreatedAt(LocalDateTime.now());
        validationRuleMapper.insert(rule);
        return rule;
    }

    @Override
    public ValidationRule updateValidationRule(Long id, ValidationRule rule) {
        rule.setId(id);
        validationRuleMapper.update(rule);
        return rule;
    }

    @Override
    public void deleteValidationRule(Long id) {
        validationRuleMapper.deleteById(id);
    }

    @Override
    public List<AccountMapping> getAccountMappings(String category) {
        if (category == null || category.isEmpty()) {
            return accountMappingMapper.selectAll();
        }
        return accountMappingMapper.selectByCategory(category);
    }

    @Override
    public AccountMapping createAccountMapping(AccountMapping mapping) {
        accountMappingMapper.insert(mapping);
        return mapping;
    }

    @Override
    public AccountMapping updateAccountMapping(Long id, AccountMapping mapping) {
        mapping.setId(id);
        accountMappingMapper.update(mapping);
        return mapping;
    }

    @Override
    public void deleteAccountMapping(Long id) {
        accountMappingMapper.deleteById(id);
    }
}
