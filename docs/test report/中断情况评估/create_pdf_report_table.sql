-- 创建PDF报告表
CREATE TABLE IF NOT EXISTS report_pdf_report (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL COMMENT '报告名称',
    type VARCHAR(50) NOT NULL COMMENT '报告类型',
    period VARCHAR(50) COMMENT '报告期间',
    status VARCHAR(50) DEFAULT 'pending' COMMENT '状态',
    file_size VARCHAR(50) COMMENT '文件大小',
    creator_name VARCHAR(100) COMMENT '创建者',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='PDF报告记录表';
