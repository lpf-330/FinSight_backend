package com.sixth_group.finsight_backend.service;

import com.sixth_group.finsight_backend.entity.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 系统服务接口
 * 定义用户管理、角色管理、审计日志、ETL监控、系统参数等系统相关业务方法
 */
public interface SystemService {
    List<User> getUsers(String keyword, Long roleId, String status);
    User createUser(User user);
    User updateUser(Long id, User user);
    void deleteUser(Long id);
    void resetPassword(Long id);

    List<Role> getRoles();
    Role createRole(Role role);
    Role updateRole(Long id, Role role);
    void deleteRole(Long id);
    List<Map<String, Object>> getPermissionTree();

    List<AuditLog> getAuditLogs(Integer page, Integer pageSize, LocalDateTime startDate, LocalDateTime endDate, String username, String operation);

    Map<String, Object> getEtlMonitorData(Integer page, Integer pageSize);
    void triggerEtl(Long taskId);
    void stopEtl(Long id);

    Map<String, Object> getSystemParams();
    void updateSystemParams(Map<String, Object> params);
}
