# Tasks - FinSight 生产级API接口测试

## 总体任务
对 FinSight_backend 项目中的所有 API 接口进行生产级测试，每个接口进行 3-5 次不同请求的测试，覆盖正常场景、边界条件、认证场景和错误处理。

---

## Phase 1: 认证模块测试

- [x] Task 1.1: 测试 POST /auth/login (登录接口)
  - [x] 正常登录成功测试
  - [x] 密码错误测试
  - [x] 用户不存在测试
  - [x] 空用户名测试
  - [x] 空密码测试

- [x] Task 1.2: 测试 GET /auth/user-info (获取用户信息)
  - [x] 有效Token获取用户信息
  - [x] 无Token访问
  - [x] 过期Token访问
  - [x] 无效Token访问

- [x] Task 1.3: 测试 POST /auth/logout (退出登录)
  - [x] 有效Token退出登录
  - [x] 无Token退出

- [x] Task 1.4: 测试 PUT /auth/change-password (修改密码)
  - [x] 正常修改密码
  - [x] 旧密码错误
  - [x] 新密码为空
  - [x] 新旧密码相同

---

## Phase 2: 数据接入模块测试

- [x] Task 2.1: 测试 ETL 管理接口
  - [x] GET /data/etl/tasks - 获取ETL任务列表
  - [x] POST /data/etl/trigger - 手动触发ETL
  - [x] GET /data/etl/tasks/:id - 获取任务详情

- [x] Task 2.2: 测试 Excel 导入接口
  - [x] POST /data/import/excel - 上传Excel
  - [x] GET /data/import/template - 下载导入模板
  - [x] GET /data/import/history - 获取导入历史

- [x] Task 2.3: 测试数据校验规则接口
  - [x] GET /data/validation/rules - 获取校验规则列表
  - [x] POST /data/validation/rules - 创建校验规则
  - [x] PUT /data/validation/rules/:id - 更新校验规则
  - [x] DELETE /data/validation/rules/:id - 删除校验规则

- [x] Task 2.4: 测试科目映射接口
  - [x] GET /data/mapping - 获取科目映射列表
  - [x] POST /data/mapping - 创建科目映射
  - [x] PUT /data/mapping/:id - 更新科目映射
  - [x] DELETE /data/mapping/:id - 删除科目映射

---

## Phase 3: 算法引擎模块测试

- [x] Task 3.1: 测试比率分析接口
  - [x] GET /algorithm/ratio/results - 获取比率分析结果
  - [x] POST /algorithm/ratio/calculate - 触发比率计算
  - [x] GET /algorithm/ratio/categories - 获取比率分类

- [x] Task 3.2: 测试预警模型接口
  - [x] GET /algorithm/warning/records - 获取预警记录
  - [x] PUT /algorithm/warning/records/:id/ignore - 忽略预警
  - [x] GET /algorithm/warning/summary - 获取预警汇总

- [x] Task 3.3: 测试投资评估接口
  - [x] POST /algorithm/investment/calculate - 计算投资评估
  - [x] POST /algorithm/investment/scheme - 保存投资方案
  - [x] GET /algorithm/investment/schemes - 获取投资方案列表

- [x] Task 3.4: 测试损益预测接口
  - [x] POST /algorithm/forecast/profit - 损益预测计算

- [x] Task 3.5: 测试趋势与杜邦分析接口
  - [x] GET /algorithm/trend/data - 获取趋势数据
  - [x] GET /algorithm/trend/dupont - 获取杜邦分析数据

---

## Phase 4: 配置管理模块测试

- [x] Task 4.1: 测试公式配置接口
  - [x] GET /config/formula - 获取公式列表
  - [x] POST /config/formula - 创建公式
  - [x] PUT /config/formula/:id - 更新公式
  - [x] DELETE /config/formula/:id - 删除公式
  - [x] POST /config/formula/validate - 验证公式表达式

- [x] Task 4.2: 测试预警阈值配置接口
  - [x] GET /config/threshold - 获取阈值列表
  - [x] POST /config/threshold - 创建阈值
  - [x] PUT /config/threshold/:id - 更新阈值
  - [x] GET /config/threshold/dynamic-suggestion/:indicatorCode - 获取动态基准建议

- [x] Task 4.3: 测试知识库接口
  - [x] GET /config/knowledge - 获取知识库列表
  - [x] POST /config/knowledge - 创建知识条目
  - [x] PUT /config/knowledge/:id - 更新知识条目
  - [x] DELETE /config/knowledge/:id - 删除知识条目
  - [x] GET /config/knowledge/export - 导出知识库
  - [x] POST /config/knowledge/import - 导入知识库

- [x] Task 4.4: 测试模型版本管理接口
  - [x] GET /config/version - 获取版本列表
  - [x] POST /config/version/simulate - 模拟版本计算
  - [x] PUT /config/version/switch - 切换版本

---

## Phase 5: 可视化报表模块测试

- [x] Task 5.1: 测试仪表盘接口
  - [x] GET /report/dashboard - 获取仪表盘数据

- [x] Task 5.2: 测试图表展示接口
  - [x] GET /report/charts - 获取图表数据

- [x] Task 5.3: 测试 PDF 报告接口
  - [x] POST /report/pdf/generate - 生成PDF报告
  - [x] GET /report/pdf/history - 获取PDF报告历史

- [x] Task 5.4: 测试行业对标接口
  - [x] GET /report/benchmark/data - 获取行业对标数据
  - [x] POST /report/benchmark/upload - 上传行业基准数据
  - [x] GET /report/benchmark/template - 下载行业数据模板

---

## Phase 6: 系统支撑模块测试

- [x] Task 6.1: 测试用户管理接口
  - [x] GET /system/user - 获取用户列表
  - [x] POST /system/user - 创建用户
  - [x] PUT /system/user/:id - 更新用户
  - [x] DELETE /system/user/:id - 删除用户
  - [x] PUT /system/user/:id/reset-password - 重置用户密码

- [x] Task 6.2: 测试角色管理接口
  - [x] GET /system/role - 获取角色列表
  - [x] POST /system/role - 创建角色
  - [x] PUT /system/role/:id - 更新角色
  - [x] DELETE /system/role/:id - 删除角色
  - [x] GET /system/permission/tree - 获取权限树

- [x] Task 6.3: 测试审计日志接口
  - [x] GET /system/audit-log - 获取审计日志
  - [x] GET /system/audit-log/export - 导出审计日志

- [x] Task 6.4: 测试 ETL 监控接口
  - [x] GET /system/etl-monitor - 获取ETL监控数据
  - [x] POST /system/etl-monitor/trigger - 手动触发ETL
  - [x] PUT /system/etl-monitor/:id/stop - 停止ETL任务

- [x] Task 6.5: 测试系统参数接口
  - [x] GET /system/params - 获取系统参数
  - [x] PUT /system/params - 更新系统参数

---

## Phase 7: 生成测试报告

- [x] Task 7.1: 创建测试报告目录结构
  - [x] 创建 docs/test report/test-report2.0 目录

- [x] Task 7.2: 生成认证模块子测试报告
  - [x] 01-认证模块子测试报告.md

- [x] Task 7.3: 生成数据接入模块子测试报告
  - [x] 02-数据接入模块子测试报告.md

- [x] Task 7.4: 生成算法引擎模块子测试报告
  - [x] 03-算法引擎模块子测试报告.md

- [x] Task 7.5: 生成配置管理模块子测试报告
  - [x] 04-配置管理模块子测试报告.md

- [x] Task 7.6: 生成可视化报表模块子测试报告
  - [x] 05-可视化报表模块子测试报告.md

- [x] Task 7.7: 生成系统支撑模块子测试报告
  - [x] 06-系统支撑模块子测试报告.md

- [x] Task 7.8: 生成综合主测试报告
  - [x] 00-综合主测试报告.md

---

## Task Dependencies
- Phase 2-6 依赖于 Phase 1 的登录测试完成（获取有效Token）
- Phase 7 依赖于 Phase 1-6 所有测试完成

---

## 完成状态

**所有任务已完成** - 2026-04-29

测试报告已生成并存放在: `docs/test report/test-report2.0/`
