-- FinSight 数据库初始化脚本
-- 创建测试用户和角色数据

-- 创建角色表数据
INSERT INTO sys_role (id, name, code, description, created_at, updated_at) VALUES
(1, '系统管理员', 'ADMIN', '拥有所有功能权限', NOW(), NOW()),
(2, '财务经理', 'FINANCE_MANAGER', '财务管理权限', NOW(), NOW()),
(3, '数据分析师', 'ANALYST', '数据分析权限', NOW(), NOW())
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 创建管理员用户
-- 密码: 123456 (BCrypt加密后的值)
INSERT INTO sys_user (id, username, password_hash, name, department, role_id, status, created_at, updated_at) VALUES
(1, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '系统管理员', '信息部', 1, 'active', NOW(), NOW()),
(2, 'zhangsan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张三', '财务部', 2, 'active', NOW(), NOW()),
(3, 'lisi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '李四', '分析部', 3, 'active', NOW(), NOW())
ON DUPLICATE KEY UPDATE username=VALUES(username);

-- 创建测试用户（用于密码修改测试）
INSERT INTO sys_user (id, username, password_hash, name, department, role_id, status, created_at, updated_at) VALUES
(4, 'testuser', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '测试用户', '测试部', 3, 'active', NOW(), NOW())
ON DUPLICATE KEY UPDATE username=VALUES(username);
