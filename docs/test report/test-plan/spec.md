# 生产级API接口测试规范

## Why
为了确保FinSight财务智能分析系统的所有API接口在生产环境中能够稳定、可靠地运行，需要对所有接口进行全面的生产级请求测试。通过模拟真实业务场景的各种请求，验证接口的正确性、健壮性和安全性，及时发现潜在问题并确保系统质量。

## What Changes
- 创建完整的API接口测试计划，覆盖所有6大模块的接口
- 为每个接口设计3-5个不同的测试场景（正常场景、边界场景、异常场景）
- 执行生产级接口测试，记录详细的测试过程和结果
- 生成每个接口的子测试结果报告，存放在`docs/test report`目录
- 汇总所有测试结果，生成总测试结果报告

## Impact
- Affected specs: 无，这是新增的测试规范
- Affected code: 不影响现有代码，仅进行接口测试验证

## ADDED Requirements

### Requirement: API接口测试覆盖
系统 SHALL 对以下所有模块的接口进行全面测试：

#### 1. 认证模块 `/auth`
- POST /auth/login - 用户登录
- GET /auth/user-info - 获取用户信息
- POST /auth/logout - 退出登录
- PUT /auth/change-password - 修改密码

#### 2. 数据接入模块 `/data`
- GET /data/etl/tasks - 获取ETL任务列表
- POST /data/etl/trigger - 手动触发ETL任务
- GET /data/etl/tasks/:id - 获取ETL任务详情
- POST /data/import/excel - 上传Excel文件
- GET /data/import/template - 下载导入模板
- GET /data/import/history - 获取导入历史记录
- GET /data/validation/rules - 获取校验规则列表
- POST /data/validation/rules - 创建校验规则
- PUT /data/validation/rules/:id - 更新校验规则
- DELETE /data/validation/rules/:id - 删除校验规则
- GET /data/mapping - 获取科目映射列表
- POST /data/mapping - 创建科目映射
- PUT /data/mapping/:id - 更新科目映射
- DELETE /data/mapping/:id - 删除科目映射

#### 3. 算法引擎模块 `/algorithm`
- GET /algorithm/ratio/results - 获取比率分析结果
- POST /algorithm/ratio/calculate - 触发比率计算
- GET /algorithm/ratio/categories - 获取比率分类列表
- GET /algorithm/warning/records - 获取预警记录
- PUT /algorithm/warning/records/:id/ignore - 忽略预警
- GET /algorithm/warning/summary - 获取预警汇总
- POST /algorithm/investment/calculate - 计算投资评估指标
- POST /algorithm/investment/scheme - 保存投资方案
- GET /algorithm/investment/schemes - 获取投资方案列表
- POST /algorithm/forecast/profit - 损益预测计算
- GET /algorithm/trend/data - 获取趋势数据
- GET /algorithm/trend/dupont - 获取杜邦分析数据

#### 4. 配置管理模块 `/config`
- GET /config/formula - 获取公式列表
- POST /config/formula - 创建公式
- PUT /config/formula/:id - 更新公式
- DELETE /config/formula/:id - 删除公式
- POST /config/formula/validate - 验证公式表达式
- GET /config/threshold - 获取阈值列表
- POST /config/threshold - 创建阈值
- PUT /config/threshold/:id - 更新阈值
- GET /config/threshold/dynamic-suggestion/:indicatorCode - 获取动态基准建议值
- GET /config/knowledge - 获取知识库列表
- POST /config/knowledge - 创建知识条目
- PUT /config/knowledge/:id - 更新知识条目
- DELETE /config/knowledge/:id - 删除知识条目
- GET /config/knowledge/export - 导出知识库
- POST /config/knowledge/import - 导入知识库
- GET /config/version - 获取版本列表
- POST /config/version/simulate - 模拟版本计算
- PUT /config/version/switch - 切换版本

#### 5. 可视化报表模块 `/report`
- GET /report/dashboard - 获取仪表盘数据
- GET /report/charts - 获取图表数据
- POST /report/pdf/generate - 生成PDF报告
- GET /report/pdf/history - 获取PDF报告历史
- GET /report/benchmark/data - 获取行业对标数据
- POST /report/benchmark/upload - 上传行业基准数据
- GET /report/benchmark/template - 下载行业数据模板

#### 6. 系统支撑模块 `/system`
- GET /system/user - 获取用户列表
- POST /system/user - 创建用户
- PUT /system/user/:id - 更新用户
- DELETE /system/user/:id - 删除用户
- PUT /system/user/:id/reset-password - 重置用户密码
- GET /system/role - 获取角色列表
- POST /system/role - 创建角色
- PUT /system/role/:id - 更新角色
- DELETE /system/role/:id - 删除角色
- GET /system/permission/tree - 获取权限树
- GET /system/audit-log - 获取审计日志
- GET /system/audit-log/export - 导出审计日志
- GET /system/etl-monitor - 获取ETL监控数据
- POST /system/etl-monitor/trigger - 手动触发ETL
- PUT /system/etl-monitor/:id/stop - 停止ETL任务
- GET /system/params - 获取系统参数
- PUT /system/params - 更新系统参数

### Requirement: 测试场景设计
每个接口 SHALL 包含以下类型的测试场景：
- **正常场景测试**: 验证接口在正常输入下的正确响应
- **边界场景测试**: 验证接口在边界值（如空值、最大值、最小值）下的行为
- **异常场景测试**: 验证接口在异常输入（如错误参数、无效Token）下的错误处理
- **权限场景测试**: 验证接口的权限控制（如未登录访问、无权限访问）
- **性能场景测试**: 验证接口的响应时间和并发处理能力（可选）

### Requirement: 测试结果报告
系统 SHALL 生成以下测试报告：
- **子测试报告**: 每个接口的详细测试报告，包含：
  - 接口基本信息（URL、方法、描述）
  - 测试场景列表及每个场景的详细步骤
  - 测试结果（通过/失败）
  - 响应数据截图或日志
  - 问题记录和建议
- **总测试报告**: 汇总所有接口的测试结果，包含：
  - 测试概览（总接口数、测试场景数、通过率）
  - 各模块测试结果统计
  - 问题汇总和优先级分类
  - 测试结论和建议

## MODIFIED Requirements
无

## REMOVED Requirements
无
