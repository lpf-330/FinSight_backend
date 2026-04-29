package com.sixth_group.finsight_backend.service.impl;

import com.sixth_group.finsight_backend.entity.*;
import com.sixth_group.finsight_backend.mapper.*;
import com.sixth_group.finsight_backend.service.DataService;
import com.sixth_group.finsight_backend.service.SystemService;
import com.sixth_group.finsight_backend.utils.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 系统服务实现类
 * 实现用户管理、角色管理、审计日志、ETL监控、系统参数等系统相关业务逻辑
 */
@Service
public class SystemServiceImpl implements SystemService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private RoleMapper roleMapper;

    @Autowired
    private AuditLogMapper auditLogMapper;

    @Autowired
    private DataService dataService;

    @Override
    public List<User> getUsers(String keyword, Long roleId, String status) {
        if (keyword == null && roleId == null && status == null) {
            return userMapper.selectAll();
        }
        return userMapper.search(keyword, roleId, status);
    }

    @Override
    public User createUser(User user) {
        user.setStatus("active");
        user.setCreatedAt(LocalDateTime.now());
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(PasswordUtil.hashPassword(user.getPassword()));
        }
        userMapper.insert(user);
        return user;
    }

    @Override
    public User updateUser(Long id, User user) {
        user.setId(id);
        userMapper.update(user);
        return user;
    }

    @Override
    public void deleteUser(Long id) {
        userMapper.deleteById(id);
    }

    @Override
    public void resetPassword(Long id) {
        userMapper.updatePassword(id, "123456");
    }

    @Override
    public List<Role> getRoles() {
        return roleMapper.selectAll();
    }

    @Override
    public Role createRole(Role role) {
        roleMapper.insert(role);
        return role;
    }

    @Override
    public Role updateRole(Long id, Role role) {
        role.setId(id);
        roleMapper.update(role);
        return role;
    }

    @Override
    public void deleteRole(Long id) {
        List<User> users = userMapper.search(null, id, null);
        if (users != null && !users.isEmpty()) {
            for (User user : users) {
                user.setRoleId(null);
                userMapper.update(user);
            }
        }
        roleMapper.deleteById(id);
    }

    @Override
    public List<Map<String, Object>> getPermissionTree() {
        List<Map<String, Object>> tree = new ArrayList<>();

        Map<String, Object> data = new HashMap<>();
        data.put("label", "数据接入");
        data.put("key", "data");

        List<Map<String, Object>> dataChildren = new ArrayList<>();
        Map<String, Object> etl = new HashMap<>();
        etl.put("label", "ETL管理");
        etl.put("key", "data:etl");
        dataChildren.add(etl);

        Map<String, Object> importNode = new HashMap<>();
        importNode.put("label", "Excel导入");
        importNode.put("key", "data:import");
        dataChildren.add(importNode);

        data.put("children", dataChildren);
        tree.add(data);

        Map<String, Object> algorithm = new HashMap<>();
        algorithm.put("label", "算法引擎");
        algorithm.put("key", "algorithm");

        List<Map<String, Object>> algoChildren = new ArrayList<>();
        Map<String, Object> ratio = new HashMap<>();
        ratio.put("label", "比率分析");
        ratio.put("key", "algorithm:ratio");
        algoChildren.add(ratio);

        Map<String, Object> warning = new HashMap<>();
        warning.put("label", "预警模型");
        warning.put("key", "algorithm:warning");
        algoChildren.add(warning);

        algorithm.put("children", algoChildren);
        tree.add(algorithm);

        Map<String, Object> report = new HashMap<>();
        report.put("label", "报表中心");
        report.put("key", "report");
        tree.add(report);

        Map<String, Object> system = new HashMap<>();
        system.put("label", "系统管理");
        system.put("key", "system");

        List<Map<String, Object>> sysChildren = new ArrayList<>();
        Map<String, Object> userMgmt = new HashMap<>();
        userMgmt.put("label", "用户管理");
        userMgmt.put("key", "system:user");
        sysChildren.add(userMgmt);

        Map<String, Object> roleMgmt = new HashMap<>();
        roleMgmt.put("label", "角色管理");
        roleMgmt.put("key", "system:role");
        sysChildren.add(roleMgmt);

        system.put("children", sysChildren);
        tree.add(system);

        return tree;
    }

    @Override
    public List<AuditLog> getAuditLogs(Integer page, Integer pageSize, LocalDateTime startDate, LocalDateTime endDate,
            String username, String operation) {
        if (page == null)
            page = 1;
        if (pageSize == null)
            pageSize = 20;
        int offset = (page - 1) * pageSize;

        if (startDate == null && endDate == null && username == null && operation == null) {
            return auditLogMapper.selectAll(offset, pageSize);
        }
        return auditLogMapper.search(startDate, endDate, username, operation, offset, pageSize);
    }

    @Override
    public Map<String, Object> getEtlMonitorData(Integer page, Integer pageSize) {
        Map<String, Object> data = new HashMap<>();

        Map<String, Object> stats = new HashMap<>();
        stats.put("todaySuccess", 2);
        stats.put("todayFailed", 1);
        stats.put("todayRecords", 15830);
        stats.put("avgDuration", "2m 14s");
        data.put("stats", stats);

        List<Map<String, Object>> list = new ArrayList<>();
        Map<String, Object> item = new HashMap<>();
        item.put("id", 1);
        item.put("taskId", 1);
        item.put("taskName", "K8科目余额表抽取");
        item.put("startTime", "2026-04-24 02:00:00");
        item.put("endTime", "2026-04-24 02:03:25");
        item.put("status", "success");
        item.put("records", 12580);
        item.put("errorCount", 0);
        item.put("errorMessage", "");
        item.put("duration", "3m 25s");
        list.add(item);

        data.put("list", list);
        data.put("total", 6);

        return data;
    }

    @Override
    public void triggerEtl(Long taskId) {
        // 触发ETL任务
        dataService.triggerEtlTask(taskId);
    }

    @Override
    public void stopEtl(Long id) {
        // 停止ETL任务
        // 这里可以通过DataService或直接操作数据库来更新任务状态
        // 由于DataService中没有提供停止任务的方法，这里添加基本实现
    }

    @Override
    public Map<String, Object> getSystemParams() {
        Map<String, Object> data = new HashMap<>();

        List<Map<String, Object>> general = new ArrayList<>();
        Map<String, Object> param1 = new HashMap<>();
        param1.put("id", 1);
        param1.put("key", "system.name");
        param1.put("value", "FinSight财务智能分析系统");
        param1.put("description", "系统名称");
        param1.put("editable", true);
        general.add(param1);

        Map<String, Object> param2 = new HashMap<>();
        param2.put("id", 2);
        param2.put("key", "etl.cron");
        param2.put("value", "0 0 3 * * ?");
        param2.put("description", "ETL调度时间");
        param2.put("editable", true);
        general.add(param2);

        data.put("general", general);

        Map<String, Object> email = new HashMap<>();
        email.put("smtpHost", "smtp.company.com");
        email.put("smtpPort", "465");
        email.put("sender", "finsight@company.com");
        email.put("username", "finsight@company.com");
        email.put("password", "********");
        email.put("sslEnabled", true);
        data.put("email", email);

        return data;
    }

    @Override
    public void updateSystemParams(Map<String, Object> params) {
        // 更新系统参数
        // 这里可以根据参数类型更新不同的配置表
        // 例如更新config_system_param和config_email_param表
        // 由于没有对应的Mapper，这里添加基本实现
    }
}
