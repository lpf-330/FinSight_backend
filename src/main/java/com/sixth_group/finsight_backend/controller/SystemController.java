package com.sixth_group.finsight_backend.controller;

import com.sixth_group.finsight_backend.entity.AuditLog;
import com.sixth_group.finsight_backend.entity.Role;
import com.sixth_group.finsight_backend.entity.User;
import com.sixth_group.finsight_backend.service.SystemService;
import com.sixth_group.finsight_backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 系统控制器
 * 处理用户管理、角色管理、审计日志、ETL监控、系统参数等系统相关HTTP请求
 */
@RestController
@RequestMapping("/api/system")
public class SystemController {

    @Autowired
    private SystemService systemService;

    @GetMapping("/user")
    public Result<List<User>> getUsers(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long roleId,
            @RequestParam(required = false) String status) {
        List<User> users = systemService.getUsers(keyword, roleId, status);
        return Result.success(users);
    }

    @PostMapping("/user")
    public Result<User> createUser(@RequestBody User user) {
        User created = systemService.createUser(user);
        return Result.success(created);
    }

    @PutMapping("/user/{id}")
    public Result<User> updateUser(@PathVariable Long id, @RequestBody User user) {
        User updated = systemService.updateUser(id, user);
        return Result.success(updated);
    }

    @DeleteMapping("/user/{id}")
    public Result<Void> deleteUser(@PathVariable Long id) {
        systemService.deleteUser(id);
        return Result.success();
    }

    @PutMapping("/user/{id}/reset-password")
    public Result<Void> resetPassword(@PathVariable Long id) {
        systemService.resetPassword(id);
        return Result.success();
    }

    @GetMapping("/role")
    public Result<List<Role>> getRoles() {
        List<Role> roles = systemService.getRoles();
        return Result.success(roles);
    }

    @PostMapping("/role")
    public Result<Role> createRole(@RequestBody Role role) {
        Role created = systemService.createRole(role);
        return Result.success(created);
    }

    @PutMapping("/role/{id}")
    public Result<Role> updateRole(@PathVariable Long id, @RequestBody Role role) {
        Role updated = systemService.updateRole(id, role);
        return Result.success(updated);
    }

    @DeleteMapping("/role/{id}")
    public Result<Void> deleteRole(@PathVariable Long id) {
        systemService.deleteRole(id);
        return Result.success();
    }

    @GetMapping("/permission/tree")
    public Result<List<Map<String, Object>>> getPermissionTree() {
        List<Map<String, Object>> tree = systemService.getPermissionTree();
        return Result.success(tree);
    }

    @GetMapping("/audit-log")
    public Result<Map<String, Object>> getAuditLogs(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer pageSize,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String operation) {
        List<AuditLog> list = systemService.getAuditLogs(page, pageSize, startDate, endDate, username, operation);
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("list", list);
        result.put("total", list.size());
        return Result.success(result);
    }

    @GetMapping("/etl-monitor")
    public Result<Map<String, Object>> getEtlMonitorData(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer pageSize) {
        Map<String, Object> data = systemService.getEtlMonitorData(page, pageSize);
        return Result.success(data);
    }

    @PostMapping("/etl-monitor/trigger")
    public Result<Void> triggerEtl(@RequestBody Map<String, Object> request) {
        Long taskId = ((Number) request.get("taskId")).longValue();
        systemService.triggerEtl(taskId);
        return Result.success();
    }

    @PutMapping("/etl-monitor/{id}/stop")
    public Result<Void> stopEtl(@PathVariable Long id) {
        systemService.stopEtl(id);
        return Result.success();
    }

    @GetMapping("/params")
    public Result<Map<String, Object>> getSystemParams() {
        Map<String, Object> params = systemService.getSystemParams();
        return Result.success(params);
    }

    @PutMapping("/params")
    public Result<Void> updateSystemParams(@RequestBody Map<String, Object> params) {
        systemService.updateSystemParams(params);
        return Result.success();
    }
}
