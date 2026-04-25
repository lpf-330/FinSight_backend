# FinSight 数据库设计文档

> 数据库：MySQL 8.0+ / PostgreSQL 14+  
> 字符集：UTF-8  
> 命名规范：表名 snake_case，字段名 snake_case

---

## 1. 实体关系概览

```
sys_user ──── sys_role ──── sys_permission
   │
   └── sys_audit_log

data_etl_task ──── data_etl_run_log
data_subject_mapping
data_validation_rule
data_import_record

config_formula ──── config_model_version
config_threshold
config_knowledge
config_system_param
config_email_param

algo_ratio_result
algo_warning_record
algo_trend_data
algo_dupont_data
algo_investment_scheme
algo_profit_forecast

report_pdf_report
report_benchmark_data
report_dashboard_cache
```

---

## 2. 表结构详细设计

### 2.1 系统支撑域

#### sys_user 用户表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| username | VARCHAR(64) | UNIQUE, NOT NULL | 用户名 |
| password_hash | VARCHAR(256) | NOT NULL | 密码哈希(bcrypt) |
| name | VARCHAR(64) | NOT NULL | 姓名 |
| department | VARCHAR(128) | | 部门 |
| role_id | BIGINT | FK → sys_role.id, NOT NULL | 角色ID |
| status | ENUM('active','disabled') | NOT NULL DEFAULT 'active' | 状态 |
| last_login | DATETIME | | 最近登录时间 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### sys_role 角色表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| name | VARCHAR(64) | UNIQUE, NOT NULL | 角色名称 |
| code | VARCHAR(64) | UNIQUE, NOT NULL | 角色编码(ADMIN/ANALYST/MANAGER) |
| description | VARCHAR(256) | | 描述 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### sys_role_permission 角色权限关联表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| role_id | BIGINT | FK → sys_role.id, NOT NULL | 角色ID |
| permission_key | VARCHAR(128) | NOT NULL | 权限标识(如 data:import, algorithm:ratio) |
| UNIQUE | | (role_id, permission_key) | 联合唯一 |

#### sys_audit_log 审计日志表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| user_id | BIGINT | FK → sys_user.id | 操作用户ID |
| username | VARCHAR(64) | NOT NULL | 操作人(冗余) |
| operation | VARCHAR(64) | NOT NULL | 操作类型 |
| module | VARCHAR(64) | NOT NULL | 功能模块 |
| detail | TEXT | | 操作详情 |
| ip | VARCHAR(64) | | IP地址 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 操作时间 |
| INDEX | | (created_at) | 时间索引 |
| INDEX | | (user_id) | 用户索引 |

---

### 2.2 数据接入域

#### data_etl_task ETL任务配置表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| name | VARCHAR(128) | UNIQUE, NOT NULL | 任务名称 |
| source | VARCHAR(128) | NOT NULL | 数据源(如 金蝶K8) |
| target | VARCHAR(128) | NOT NULL | 目标表 |
| cron | VARCHAR(64) | | 调度Cron表达式 |
| db_url | VARCHAR(512) | | JDBC URL |
| db_username | VARCHAR(128) | | 认证用户名 |
| db_password | VARCHAR(256) | | 认证密码(加密存储) |
| db_driver | VARCHAR(256) | | 驱动类名 |
| status | ENUM('success','failed','running','pending') | NOT NULL DEFAULT 'pending' | 最近状态 |
| last_run | DATETIME | | 最近执行时间 |
| next_run | DATETIME | | 下次执行时间 |
| last_records | INT | DEFAULT 0 | 最近抽取记录数 |
| last_duration | VARCHAR(32) | | 最近耗时 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### data_etl_run_log ETL运行日志表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| task_id | BIGINT | FK → data_etl_task.id, NOT NULL | 任务ID |
| task_name | VARCHAR(128) | NOT NULL | 任务名称(冗余) |
| start_time | DATETIME | NOT NULL | 开始时间 |
| end_time | DATETIME | | 结束时间 |
| status | ENUM('success','failed','running','stopped') | NOT NULL | 状态 |
| records | INT | DEFAULT 0 | 抽取记录数 |
| error_count | INT | DEFAULT 0 | 错误数 |
| error_message | TEXT | | 错误信息 |
| duration | VARCHAR(32) | | 耗时 |
| log_content | TEXT | | 完整日志 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| INDEX | | (task_id, start_time DESC) | 复合索引 |

#### data_subject_mapping 科目映射表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| k8_code | VARCHAR(32) | NOT NULL | K8科目编码 |
| k8_name | VARCHAR(128) | NOT NULL | K8科目名称 |
| target_code | VARCHAR(32) | NOT NULL | 目标科目编码 |
| target_name | VARCHAR(128) | NOT NULL | 目标科目名称 |
| category | VARCHAR(32) | NOT NULL | 科目类别(资产类/负债类/所有者权益类/损益类/成本类) |
| enabled | TINYINT(1) | NOT NULL DEFAULT 1 | 是否启用 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### data_validation_rule 数据校验规则表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| name | VARCHAR(128) | NOT NULL | 规则名称 |
| expression | TEXT | NOT NULL | 校验表达式 |
| level | ENUM('warning','error') | NOT NULL DEFAULT 'error' | 校验级别 |
| message | VARCHAR(512) | | 失败提示信息 |
| enabled | TINYINT(1) | NOT NULL DEFAULT 1 | 是否启用 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### data_import_record 数据导入记录表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| file_name | VARCHAR(256) | NOT NULL | 文件名 |
| type | ENUM('balance','income','cashflow') | NOT NULL | 报表类型 |
| mode | ENUM('append','overwrite') | NOT NULL DEFAULT 'append' | 导入模式 |
| records | INT | DEFAULT 0 | 导入记录数 |
| status | ENUM('success','failed','processing') | NOT NULL | 状态 |
| operator_id | BIGINT | FK → sys_user.id | 操作人ID |
| operator_name | VARCHAR(64) | | 操作人(冗余) |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 操作时间 |

---

### 2.3 配置管理域

#### config_formula 公式配置表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| name | VARCHAR(128) | NOT NULL | 公式名称 |
| expression | TEXT | NOT NULL | 表达式 |
| category | VARCHAR(32) | NOT NULL | 分类(偿债能力/营运能力/盈利能力/发展能力) |
| enabled | TINYINT(1) | NOT NULL DEFAULT 1 | 是否启用 |
| version | VARCHAR(16) | NOT NULL | 版本号 |
| created_by | VARCHAR(64) | | 创建人 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### config_threshold 预警阈值配置表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| indicator | VARCHAR(64) | NOT NULL | 预警指标名称 |
| indicator_code | VARCHAR(16) | UNIQUE, NOT NULL | 指标编码(R001-R012) |
| direction | ENUM('lower','upper') | NOT NULL DEFAULT 'lower' | 判断方向 |
| yellow_value | VARCHAR(32) | NOT NULL | 黄色阈值 |
| orange_value | VARCHAR(32) | NOT NULL | 橙色阈值 |
| red_value | VARCHAR(32) | NOT NULL | 红色阈值 |
| dynamic_base | TINYINT(1) | NOT NULL DEFAULT 0 | 是否启用动态基准 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### config_knowledge 知识库表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| indicator | VARCHAR(64) | NOT NULL | 预警指标名称 |
| level | ENUM('yellow','orange','red') | NOT NULL | 预警级别 |
| content | TEXT | NOT NULL | 建议内容 |
| version | VARCHAR(16) | NOT NULL | 版本号 |
| useful_count | INT | DEFAULT 0 | 有用反馈数 |
| useless_count | INT | DEFAULT 0 | 无用反馈数 |
| created_by | VARCHAR(64) | | 创建人 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| INDEX | | (indicator, level) | 复合索引 |

#### config_model_version 模型版本表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| model_type | ENUM('ratio','warning') | NOT NULL | 模型类型 |
| version | VARCHAR(16) | NOT NULL | 版本号 |
| description | TEXT | | 变更说明 |
| creator | VARCHAR(64) | | 创建人 |
| is_active | TINYINT(1) | NOT NULL DEFAULT 0 | 是否当前版本 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| UNIQUE | | (model_type, version) | 联合唯一 |

#### config_system_param 系统参数表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| param_key | VARCHAR(128) | UNIQUE, NOT NULL | 参数键 |
| param_value | TEXT | NOT NULL | 参数值 |
| description | VARCHAR(256) | | 说明 |
| editable | TINYINT(1) | NOT NULL DEFAULT 1 | 是否可编辑 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### config_email_param 邮件配置表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| smtp_host | VARCHAR(128) | NOT NULL | SMTP服务器 |
| smtp_port | INT | NOT NULL | SMTP端口 |
| sender | VARCHAR(128) | NOT NULL | 发件人地址 |
| username | VARCHAR(128) | NOT NULL | 认证用户名 |
| password | VARCHAR(256) | NOT NULL | 认证密码(加密存储) |
| ssl_enabled | TINYINT(1) | NOT NULL DEFAULT 1 | 是否启用SSL |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

---

### 2.4 算法引擎域

#### algo_ratio_result 比率分析结果表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| code | VARCHAR(16) | UNIQUE, NOT NULL | 指标编码(R001-R012) |
| name | VARCHAR(64) | NOT NULL | 指标名称 |
| formula | VARCHAR(256) | | 计算公式 |
| category | ENUM('solvency','operating','profitability','growth') | NOT NULL | 分类 |
| value | DECIMAL(18,4) | | 本期值 |
| prev_value | DECIMAL(18,4) | | 上期值 |
| change | DECIMAL(10,4) | | 环比变化(%) |
| standard | VARCHAR(64) | | 参考标准 |
| period | VARCHAR(16) | NOT NULL | 期间(如 2026-Q1) |
| calculated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 计算时间 |
| INDEX | | (period, category) | 复合索引 |

#### algo_warning_record 预警记录表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| indicator | VARCHAR(64) | NOT NULL | 预警指标名称 |
| indicator_code | VARCHAR(16) | NOT NULL | 指标编码 |
| level | ENUM('yellow','orange','red') | NOT NULL | 预警级别 |
| current_value | DECIMAL(18,4) | | 当前值 |
| yellow_threshold | VARCHAR(32) | | 黄色阈值 |
| orange_threshold | VARCHAR(32) | | 橙色阈值 |
| red_threshold | VARCHAR(32) | | 红色阈值 |
| trend | VARCHAR(64) | | 趋势描述 |
| suggestion | TEXT | | 调整建议 |
| status | ENUM('active','ignored') | NOT NULL DEFAULT 'active' | 状态 |
| period | VARCHAR(16) | NOT NULL | 期间 |
| triggered_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 触发时间 |
| INDEX | | (status, level) | 复合索引 |
| INDEX | | (triggered_at DESC) | 时间索引 |

#### algo_trend_data 趋势数据表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| indicator_code | VARCHAR(16) | NOT NULL | 指标编码 |
| month | VARCHAR(16) | NOT NULL | 月份(如 2025-05) |
| value | DECIMAL(18,4) | NOT NULL | 指标值 |
| INDEX | | (indicator_code, month) | 复合索引 |

#### algo_dupont_data 杜邦分析数据表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| period | VARCHAR(16) | NOT NULL | 期间 |
| roe | DECIMAL(18,4) | | ROE值 |
| roe_change | DECIMAL(10,4) | | ROE变化 |
| factor_name | VARCHAR(64) | NOT NULL | 因子名称 |
| factor_value | DECIMAL(18,4) | | 本期值 |
| factor_prev_value | DECIMAL(18,4) | | 上期值 |
| factor_change | DECIMAL(10,4) | | 变化率(%) |
| contribution | DECIMAL(10,4) | | 对ROE贡献度(%) |
| calculated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 计算时间 |
| INDEX | | (period) | 期间索引 |

#### algo_investment_scheme 投资评估方案表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| project_name | VARCHAR(128) | NOT NULL | 项目名称 |
| initial_investment | DECIMAL(18,2) | NOT NULL | 初始投资额 |
| discount_rate | DECIMAL(10,4) | NOT NULL | 折现率(%) |
| cash_flows | JSON | | 各年净现金流 [{year, amount}] |
| npv | DECIMAL(18,2) | | 净现值 |
| irr | DECIMAL(10,4) | | 内部收益率(%) |
| static_payback | DECIMAL(10,2) | | 静态回收期(年) |
| dynamic_payback | DECIMAL(10,2) | | 动态回收期(年) |
| created_by | VARCHAR(64) | | 创建人 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |

#### algo_profit_forecast 损益预测记录表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| base_revenue | DECIMAL(18,2) | NOT NULL | 基准营业收入 |
| revenue_growth_rate | DECIMAL(10,4) | NOT NULL | 收入增长率(%) |
| cost_rate | DECIMAL(10,4) | NOT NULL | 营业成本率(%) |
| expense_rate | DECIMAL(10,4) | NOT NULL | 期间费用率(%) |
| tax_rate | DECIMAL(10,4) | NOT NULL | 所得税率(%) |
| periods | INT | NOT NULL | 预测期数 |
| results | JSON | | 预测结果 [{period, revenue, cost, expense, profitBeforeTax, tax, netProfit}] |
| created_by | VARCHAR(64) | | 创建人 |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |

---

### 2.5 报表展示域

#### report_pdf_report PDF报告表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| name | VARCHAR(256) | NOT NULL | 报告名称 |
| type | ENUM('comprehensive','warning','investment') | NOT NULL | 报告类型 |
| period | VARCHAR(16) | | 分析期间 |
| include_warning | TINYINT(1) | DEFAULT 0 | 包含预警信息 |
| include_ratio | TINYINT(1) | DEFAULT 1 | 包含比率分析 |
| include_trend | TINYINT(1) | DEFAULT 1 | 包含趋势图表 |
| include_investment | TINYINT(1) | DEFAULT 0 | 包含投资评估 |
| status | ENUM('completed','generating','failed') | NOT NULL DEFAULT 'generating' | 状态 |
| file_path | VARCHAR(512) | | 文件存储路径 |
| file_size | VARCHAR(32) | | 文件大小 |
| creator_id | BIGINT | FK → sys_user.id | 生成人ID |
| creator_name | VARCHAR(64) | | 生成人(冗余) |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 生成时间 |

#### report_benchmark_data 行业对标数据表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| indicator | VARCHAR(64) | NOT NULL | 指标名称 |
| indicator_code | VARCHAR(16) | NOT NULL | 指标编码 |
| enterprise | DECIMAL(18,4) | | 企业值 |
| industry_avg | DECIMAL(18,4) | | 行业平均值 |
| industry_best | DECIMAL(18,4) | | 行业优秀值 |
| deviation | DECIMAL(10,4) | | 偏离度(%) |
| period | VARCHAR(16) | NOT NULL | 期间 |
| industry | VARCHAR(64) | | 行业名称 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| INDEX | | (period, industry) | 复合索引 |

#### report_dashboard_cache 仪表盘缓存表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| cache_key | VARCHAR(128) | UNIQUE, NOT NULL | 缓存键(如 dashboard_summary) |
| cache_value | JSON | NOT NULL | 缓存数据 |
| period | VARCHAR(16) | | 期间 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

---

## 3. 初始数据

### sys_role 初始数据

| name | code | description |
|------|------|-------------|
| 系统管理员 | ADMIN | 拥有所有功能权限 |
| 财务分析人员 | ANALYST | 数据导入、算法配置、报告生成 |
| 管理层 | MANAGER | 查看仪表盘、报告和预警 |

### sys_user 初始数据

| username | password_hash | name | department | role_id | status |
|----------|--------------|------|------------|---------|--------|
| admin | $2a$10$... | 系统管理员 | 信息部 | 1 | active |
| zhangsan | $2a$10$... | 张三 | 财务部 | 2 | active |
| lisi | $2a$10$... | 李四 | 财务部 | 2 | active |
| wangwu | $2a$10$... | 王五 | 总经理办公室 | 3 | active |

### config_system_param 初始数据

| param_key | param_value | description | editable |
|-----------|------------|-------------|----------|
| system.name | FinSight财务智能分析系统 | 系统名称 | 1 |
| system.version | 1.0.0 | 系统版本 | 0 |
| etl.cron | 0 0 2 * * ? | ETL定时执行Cron表达式 | 1 |
| etl.timeout | 3600 | ETL任务超时时间(秒) | 1 |
| warning.auto_notify | true | 预警自动通知 | 1 |
| warning.notify_email | finance@company.com | 预警通知邮箱 | 1 |
| report.max_history | 100 | 报告最大保留数量 | 1 |
| data.retention_days | 365 | 数据保留天数 | 1 |

### config_threshold 初始数据

| indicator | indicator_code | direction | yellow_value | orange_value | red_value | dynamic_base |
|-----------|---------------|-----------|-------------|-------------|----------|-------------|
| 流动比率 | R001 | lower | < 2.0 | < 1.5 | < 1.0 | 0 |
| 速动比率 | R002 | lower | < 1.2 | < 1.0 | < 0.8 | 0 |
| 现金比率 | R003 | lower | < 0.3 | < 0.25 | < 0.2 | 1 |
| 资产负债率 | R004 | upper | > 50% | > 60% | > 70% | 0 |
