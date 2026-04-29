-- ==============================================
-- FinSight 数据库修复脚本
-- 修复日期：2026-04-29
-- 修复内容：ERR-007, ERR-008, ERR-012, ERR-013, ERR-016, ERR-022
-- ==============================================

-- ------------------------------
-- 1. 创建预警记录表 (修复 ERR-007, ERR-008)
-- ------------------------------
CREATE TABLE IF NOT EXISTS algo_warning_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    indicator VARCHAR(64) NOT NULL COMMENT '预警指标名称',
    indicator_code VARCHAR(16) NOT NULL COMMENT '指标编码',
    level ENUM('yellow','orange','red') NOT NULL COMMENT '预警级别',
    current_value DECIMAL(18,4) COMMENT '当前值',
    yellow_threshold VARCHAR(32) COMMENT '黄色阈值',
    orange_threshold VARCHAR(32) COMMENT '橙色阈值',
    red_threshold VARCHAR(32) COMMENT '红色阈值',
    trend VARCHAR(64) COMMENT '趋势描述',
    suggestion TEXT COMMENT '调整建议',
    status ENUM('active','ignored') NOT NULL DEFAULT 'active' COMMENT '状态',
    period VARCHAR(16) NOT NULL COMMENT '期间',
    triggered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '触发时间',
    INDEX idx_status_level (status, level),
    INDEX idx_triggered_at (triggered_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预警记录表';

-- ------------------------------
-- 2. 创建PDF报告表 (修复 ERR-012, ERR-013)
-- ------------------------------
CREATE TABLE IF NOT EXISTS report_pdf_report (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(256) NOT NULL COMMENT '报告名称',
    type ENUM('comprehensive','warning','investment') NOT NULL COMMENT '报告类型',
    period VARCHAR(16) COMMENT '分析期间',
    include_warning TINYINT(1) DEFAULT 0 COMMENT '包含预警信息',
    include_ratio TINYINT(1) DEFAULT 1 COMMENT '包含比率分析',
    include_trend TINYINT(1) DEFAULT 1 COMMENT '包含趋势图表',
    include_investment TINYINT(1) DEFAULT 0 COMMENT '包含投资评估',
    status ENUM('completed','generating','failed') NOT NULL DEFAULT 'generating' COMMENT '状态',
    file_path VARCHAR(512) COMMENT '文件存储路径',
    file_size VARCHAR(32) COMMENT '文件大小',
    creator_id BIGINT COMMENT '生成人ID',
    creator_name VARCHAR(64) COMMENT '生成人(冗余)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='PDF报告表';

-- ------------------------------
-- 3. 创建/修复公式配置表 (修复 ERR-022)
-- ------------------------------
CREATE TABLE IF NOT EXISTS config_formula (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(128) NOT NULL COMMENT '公式名称',
    expression TEXT NOT NULL COMMENT '表达式',
    category VARCHAR(32) NOT NULL COMMENT '分类',
    enabled TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
    version VARCHAR(16) NOT NULL COMMENT '版本号',
    created_by VARCHAR(64) COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公式配置表';

-- ------------------------------
-- 4. 创建/修复预警阈值配置表 (修复 ERR-022)
-- ------------------------------
CREATE TABLE IF NOT EXISTS config_threshold (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    indicator VARCHAR(64) NOT NULL COMMENT '预警指标名称',
    indicator_code VARCHAR(16) NOT NULL COMMENT '指标编码',
    direction ENUM('lower','upper') NOT NULL DEFAULT 'lower' COMMENT '判断方向',
    yellow_value VARCHAR(32) NOT NULL COMMENT '黄色阈值',
    orange_value VARCHAR(32) NOT NULL COMMENT '橙色阈值',
    red_value VARCHAR(32) NOT NULL COMMENT '红色阈值',
    dynamic_base TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用动态基准',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预警阈值配置表';

-- ------------------------------
-- 5. 创建/修复知识库表 (修复 ERR-022)
-- ------------------------------
CREATE TABLE IF NOT EXISTS config_knowledge (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    indicator VARCHAR(64) NOT NULL COMMENT '预警指标名称',
    level ENUM('yellow','orange','red') NOT NULL COMMENT '预警级别',
    content TEXT NOT NULL COMMENT '建议内容',
    version VARCHAR(16) NOT NULL COMMENT '版本号',
    useful_count INT DEFAULT 0 COMMENT '有用反馈数',
    useless_count INT DEFAULT 0 COMMENT '无用反馈数',
    created_by VARCHAR(64) COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_indicator_level (indicator, level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识库表';

-- ------------------------------
-- 6. 确保投资方案表使用utf8mb4字符集 (修复 ERR-016)
-- ------------------------------
ALTER TABLE IF EXISTS algo_investment_scheme CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------
-- 验证修复结果
-- ------------------------------
SELECT '=== 表创建验证 ===' AS '验证结果';
SHOW TABLES LIKE 'algo_warning_record';
SHOW TABLES LIKE 'report_pdf_report';
SHOW TABLES LIKE 'config_formula';
SHOW TABLES LIKE 'config_threshold';
SHOW TABLES LIKE 'config_knowledge';

SELECT '=== 自增ID配置验证 ===' AS '验证结果';
SHOW COLUMNS FROM config_formula WHERE Field = 'id';
SHOW COLUMNS FROM config_threshold WHERE Field = 'id';
SHOW COLUMNS FROM config_knowledge WHERE Field = 'id';

SELECT '=== 数据库修复脚本执行完成 ===' AS '结果';
