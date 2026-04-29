# FinSight 生产级API接口测试 Spec

## Why

需要根据 api-design.md 和 database-design.md 中的接口定义，对 FinSight 项目的所有接口进行全面的生产级请求测试，确保接口功能、认证、参数验证、边界情况和错误处理均符合预期。

## What Changes

* 基于 api-design.md 中的所有接口端点进行测试

* 为每个接口设计 3-5 个不同测试场景

* 测试覆盖：正常场景、边界条件、认证场景、错误处理

* 为每个接口生成独立的子测试报告

* 汇总生成综合主测试报告

## Impact

* 测试报告输出目录：docs/test report/test-report2.0

* 影响范围：认证模块、数据接入模块、算法引擎模块、配置管理模块、可视化报表模块、系统支撑模块

## 接口测试范围

### 1. 认证模块 `/auth` (4个接口)

| 接口              | 方法   | 路径                    | 需要认证 |
| --------------- | ---- | --------------------- | ---- |
| login           | POST | /auth/login           | 否    |
| user-info       | GET  | /auth/user-info       | 是    |
| logout          | POST | /auth/logout          | 是    |
| change-password | PUT  | /auth/change-password | 是    |

### 2. 数据接入模块 `/data` (13个接口)

| 接口        | 方法     | 路径                         | 需要认证 |
| --------- | ------ | -------------------------- | ---- |
| 获取ETL任务列表 | GET    | /data/etl/tasks            | 是    |
| 手动触发ETL   | POST   | /data/etl/trigger          | 是    |
| 获取ETL任务详情 | GET    | /data/etl/tasks/:id        | 是    |
| 上传Excel   | POST   | /data/import/excel         | 是    |
| 下载导入模板    | GET    | /data/import/template      | 是    |
| 获取导入历史    | GET    | /data/import/history       | 是    |
| 获取校验规则    | GET    | /data/validation/rules     | 是    |
| 创建校验规则    | POST   | /data/validation/rules     | 是    |
| 更新校验规则    | PUT    | /data/validation/rules/:id | 是    |
| 删除校验规则    | DELETE | /data/validation/rules/:id | 是    |
| 获取科目映射    | GET    | /data/mapping              | 是    |
| 创建科目映射    | POST   | /data/mapping              | 是    |
| 更新科目映射    | PUT    | /data/mapping/:id          | 是    |
| 删除科目映射    | DELETE | /data/mapping/:id          | 是    |

### 3. 算法引擎模块 `/algorithm` (12个接口)

| 接口       | 方法   | 路径                                    | 需要认证 |
| -------- | ---- | ------------------------------------- | ---- |
| 获取比率分析结果 | GET  | /algorithm/ratio/results              | 是    |
| 触发比率计算   | POST | /algorithm/ratio/calculate            | 是    |
| 获取比率分类   | GET  | /algorithm/ratio/categories           | 是    |
| 获取预警记录   | GET  | /algorithm/warning/records            | 是    |
| 忽略预警     | PUT  | /algorithm/warning/records/:id/ignore | 是    |
| 获取预警汇总   | GET  | /algorithm/warning/summary            | 是    |
| 计算投资评估   | POST | /algorithm/investment/calculate       | 是    |
| 保存投资方案   | POST | /algorithm/investment/scheme          | 是    |
| 获取投资方案   | GET  | /algorithm/investment/schemes         | 是    |
| 损益预测计算   | POST | /algorithm/forecast/profit            | 是    |
| 获取趋势数据   | GET  | /algorithm/trend/data                 | 是    |
| 获取杜邦分析   | GET  | /algorithm/trend/dupont               | 是    |

### 4. 配置管理模块 `/config` (15个接口)

| 接口       | 方法     | 路径                                                  | 需要认证 |
| -------- | ------ | --------------------------------------------------- | ---- |
| 获取公式列表   | GET    | /config/formula                                     | 是    |
| 创建公式     | POST   | /config/formula                                     | 是    |
| 更新公式     | PUT    | /config/formula/:id                                 | 是    |
| 删除公式     | DELETE | /config/formula/:id                                 | 是    |
| 验证公式     | POST   | /config/formula/validate                            | 是    |
| 获取阈值列表   | GET    | /config/threshold                                   | 是    |
| 创建阈值     | POST   | /config/threshold                                   | 是    |
| 更新阈值     | PUT    | /config/threshold/:id                               | 是    |
| 获取动态基准建议 | GET    | /config/threshold/dynamic-suggestion/:indicatorCode | 是    |
| 获取知识库    | GET    | /config/knowledge                                   | 是    |
| 创建知识条目   | POST   | /config/knowledge                                   | 是    |
| 更新知识条目   | PUT    | /config/knowledge/:id                               | 是    |
| 删除知识条目   | DELETE | /config/knowledge/:id                               | 是    |
| 导出知识库    | GET    | /config/knowledge/export                            | 是    |
| 导入知识库    | POST   | /config/knowledge/import                            | 是    |
| 获取版本列表   | GET    | /config/version                                     | 是    |
| 模拟版本计算   | POST   | /config/version/simulate                            | 是    |
| 切换版本     | PUT    | /config/version/switch                              | 是    |

### 5. 可视化报表模块 `/report` (8个接口)

| 接口       | 方法   | 路径                         | 需要认证 |
| -------- | ---- | -------------------------- | ---- |
| 获取仪表盘数据  | GET  | /report/dashboard          | 是    |
| 获取图表数据   | GET  | /report/charts             | 是    |
| 生成PDF报告  | POST | /report/pdf/generate       | 是    |
| 获取PDF历史  | GET  | /report/pdf/history        | 是    |
| 获取行业对标数据 | GET  | /report/benchmark/data     | 是    |
| 上传行业基准   | POST | /report/benchmark/upload   | 是    |
| 下载行业模板   | GET  | /report/benchmark/template | 是    |

### 6. 系统支撑模块 `/system` (14个接口)

| 接口        | 方法     | 路径                              | 需要认证 |
| --------- | ------ | ------------------------------- | ---- |
| 获取用户列表    | GET    | /system/user                    | 是    |
| 创建用户      | POST   | /system/user                    | 是    |
| 更新用户      | PUT    | /system/user/:id                | 是    |
| 删除用户      | DELETE | /system/user/:id                | 是    |
| 重置用户密码    | PUT    | /system/user/:id/reset-password | 是    |
| 获取角色列表    | GET    | /system/role                    | 是    |
| 创建角色      | POST   | /system/role                    | 是    |
| 更新角色      | PUT    | /system/role/:id                | 是    |
| 删除角色      | DELETE | /system/role/:id                | 是    |
| 获取权限树     | GET    | /system/permission/tree         | 是    |
| 获取审计日志    | GET    | /system/audit-log               | 是    |
| 导出审计日志    | GET    | /system/audit-log/export        | 是    |
| 获取ETL监控   | GET    | /system/etl-monitor             | 是    |
| 手动触发ETL监控 | POST   | /system/etl-monitor/trigger     | 是    |
| 停止ETL任务   | PUT    | /system/etl-monitor/:id/stop    | 是    |
| 获取系统参数    | GET    | /system/params                  | 是    |
| 更新系统参数    | PUT    | /system/params                  | 是    |

## 测试场景设计

### 每个接口的测试场景 (3-5个)

#### 场景类型

1. **正常场景**: 使用有效参数和认证访问
2. **边界条件**: 空值、特殊字符、超长参数
3. **认证场景**: 无Token、过期Token、无效Token、权限不足
4. **错误处理**: 缺失必填参数、格式错误、资源不存在

### 测试报告要求

#### 子测试报告 (每个接口单独一份)

```markdown
# [模块名] - [接口名] 子测试报告

## 接口信息
- 路径: [HTTP方法] /api/[路径]
- 需要认证: [是/否]

## 测试用例
| 用例编号 | 测试目标 | 输入参数 | 预期响应 | 实际响应 | 通过状态 | 响应时间 | 错误信息 |
|----------|----------|----------|----------|----------|----------|----------|----------|
| TC-001   | 正常访问 | ... | code:200 | code:200 | PASS | 120ms | - |
```

#### 主测试报告

```markdown
# FinSight API 综合测试报告

## 测试概述
- 测试日期: [日期]
- 测试模块数: 6
- 测试接口总数: [X]
- 总测试用例数: [X]
- 总体通过率: [X%]

## 模块测试统计
| 模块 | 接口数 | 测试用例数 | 通过数 | 失败数 | 通过率 |
|------|--------|------------|--------|--------|--------|

## 关键发现
- [按严重程度分类的问题列表]

## 性能统计
- 平均响应时间: [Xms]
- 最长响应时间: [Xms]
- 最短响应时间: [Xms]

## 改进建议
- [建议列表]
```

## ADDED Requirements

### Requirement: 生产级API测试执行

系统应按照预定的测试计划对所有接口进行测试，并生成详细的测试报告。

#### Scenario: 认证接口测试

* **WHEN** 测试 POST /auth/login

* **THEN** 应验证：正常登录成功、密码错误返回400、用户不存在返回401、空参数返回400

#### Scenario: 需认证接口无Token测试

* **WHEN** 访问需认证接口且无Token

* **THEN** 应返回 401 Unauthorized

#### Scenario: 边界条件测试

* **WHEN** 输入超长字符串或特殊字符

* **THEN** 应正确处理并返回合适的状态码

### Requirement: 测试报告生成

系统应生成结构化的测试报告，包括子报告和主报告。

#### Scenario: 子报告生成

* **WHEN** 完成一个接口的测试

* **THEN** 应生成独立的子测试报告文件

#### Scenario: 主报告生成

* **WHEN** 所有接口测试完成

* **THEN** 应汇总生成综合主测试报告

### Requirement: 报告存储

测试报告应按指定目录结构存储。

#### Scenario: 目录创建

* **WHEN** 开始生成报告

* **THEN** 应在 docs/test report/test-report2.0 目录下创建所有报告文件

