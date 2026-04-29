# Checklist - FinSight 生产级API接口测试

## 测试准备
- [ ] 测试环境确认（后端服务运行中）
- [ ] 测试凭据确认（admin账号可用）
- [ ] 测试报告目录创建完成

## 认证模块测试检查点
- [ ] POST /auth/login - 正常登录成功
- [ ] POST /auth/login - 密码错误返回400
- [ ] POST /auth/login - 用户不存在返回401
- [ ] POST /auth/login - 空用户名返回400
- [ ] POST /auth/login - 空密码返回400
- [ ] GET /auth/user-info - 有效Token获取用户信息
- [ ] GET /auth/user-info - 无Token返回401
- [ ] GET /auth/user-info - 过期Token返回401
- [ ] GET /auth/user-info - 无效Token返回401
- [ ] POST /auth/logout - 有效Token退出成功
- [ ] POST /auth/logout - 无Token返回401
- [ ] PUT /auth/change-password - 正常修改密码成功
- [ ] PUT /auth/change-password - 旧密码错误返回400
- [ ] PUT /auth/change-password - 新密码为空返回400
- [ ] PUT /auth/change-password - 新旧密码相同返回400

## 数据接入模块测试检查点
- [ ] GET /data/etl/tasks - 获取ETL任务列表成功
- [ ] GET /data/etl/tasks?status=success - 状态筛选成功
- [ ] GET /data/etl/tasks - 无Token返回401
- [ ] POST /data/etl/trigger - 正常触发ETL成功
- [ ] POST /data/etl/trigger - taskId为空返回400
- [ ] POST /data/etl/trigger - taskId不存在返回404
- [ ] GET /data/etl/tasks/:id - 获取任务详情成功
- [ ] GET /data/etl/tasks/999 - 不存在的任务返回404
- [ ] POST /data/import/excel - 上传Excel成功
- [ ] POST /data/import/excel - 无文件返回400
- [ ] GET /data/import/template?type=balance - 下载模板成功
- [ ] GET /data/import/history - 获取导入历史成功
- [ ] GET /data/import/history?page=1&pageSize=10 - 分页查询成功
- [ ] GET /data/validation/rules - 获取校验规则成功
- [ ] POST /data/validation/rules - 创建校验规则成功
- [ ] POST /data/validation/rules - 缺少必填字段返回400
- [ ] PUT /data/validation/rules/:id - 更新校验规则成功
- [ ] DELETE /data/validation/rules/:id - 删除校验规则成功
- [ ] GET /data/mapping - 获取科目映射成功
- [ ] GET /data/mapping?category=资产类 - 分类筛选成功
- [ ] POST /data/mapping - 创建科目映射成功
- [ ] PUT /data/mapping/:id - 更新科目映射成功
- [ ] DELETE /data/mapping/:id - 删除科目映射成功

## 算法引擎模块测试检查点
- [ ] GET /algorithm/ratio/results - 获取比率分析结果成功
- [ ] GET /algorithm/ratio/results?period=2026-Q1 - 按期间筛选成功
- [ ] GET /algorithm/ratio/results?category=solvency - 按分类筛选成功
- [ ] POST /algorithm/ratio/calculate - 触发比率计算成功
- [ ] POST /algorithm/ratio/calculate - period为空返回400
- [ ] GET /algorithm/ratio/categories - 获取比率分类成功
- [ ] GET /algorithm/warning/records - 获取预警记录成功
- [ ] GET /algorithm/warning/records?level=yellow - 按级别筛选成功
- [ ] PUT /algorithm/warning/records/:id/ignore - 忽略预警成功
- [ ] PUT /algorithm/warning/records/999/ignore - 不存在的预警返回404
- [ ] GET /algorithm/warning/summary - 获取预警汇总成功
- [ ] POST /algorithm/investment/calculate - 计算投资评估成功
- [ ] POST /algorithm/investment/calculate - 缺少必填参数返回400
- [ ] POST /algorithm/investment/scheme - 保存投资方案成功
- [ ] GET /algorithm/investment/schemes - 获取投资方案列表成功
- [ ] POST /algorithm/forecast/profit - 损益预测计算成功
- [ ] POST /algorithm/forecast/profit - 负数增长率测试
- [ ] POST /algorithm/forecast/profit - 超大预测期数测试
- [ ] GET /algorithm/trend/data?indicator=ROE - 获取趋势数据成功
- [ ] GET /algorithm/trend/data?months=6 - 自定义月数成功
- [ ] GET /algorithm/trend/dupont - 获取杜邦分析成功
- [ ] GET /algorithm/trend/dupont?period=2026-Q1 - 按期间查询成功

## 配置管理模块测试检查点
- [ ] GET /config/formula - 获取公式列表成功
- [ ] GET /config/formula?category=偿债能力 - 分类筛选成功
- [ ] GET /config/formula?keyword=流动比率 - 关键词搜索成功
- [ ] POST /config/formula - 创建公式成功
- [ ] POST /config/formula - 无效表达式返回400
- [ ] PUT /config/formula/:id - 更新公式成功
- [ ] DELETE /config/formula/:id - 删除公式成功
- [ ] POST /config/formula/validate - 有效表达式验证成功
- [ ] POST /config/formula/validate - 无效表达式返回400
- [ ] GET /config/threshold - 获取阈值列表成功
- [ ] POST /config/threshold - 创建阈值成功
- [ ] PUT /config/threshold/:id - 更新阈值成功
- [ ] GET /config/threshold/dynamic-suggestion/R001 - 获取动态基准建议成功
- [ ] GET /config/knowledge - 获取知识库成功
- [ ] GET /config/knowledge?indicator=流动比率 - 按指标筛选成功
- [ ] POST /config/knowledge - 创建知识条目成功
- [ ] PUT /config/knowledge/:id - 更新知识条目成功
- [ ] DELETE /config/knowledge/:id - 删除知识条目成功
- [ ] GET /config/knowledge/export - 导出知识库成功
- [ ] POST /config/knowledge/import - 导入知识库成功
- [ ] GET /config/version - 获取版本列表成功
- [ ] GET /config/version?modelType=ratio - 按模型类型筛选成功
- [ ] POST /config/version/simulate - 模拟版本计算成功
- [ ] PUT /config/version/switch - 切换版本成功

## 可视化报表模块测试检查点
- [ ] GET /report/dashboard - 获取仪表盘数据成功
- [ ] GET /report/charts - 获取图表数据成功
- [ ] GET /report/charts?period=2026 - 按期间筛选成功
- [ ] POST /report/pdf/generate - 生成PDF报告成功
- [ ] POST /report/pdf/generate - 缺少必填字段返回400
- [ ] GET /report/pdf/history - 获取PDF历史成功
- [ ] GET /report/benchmark/data - 获取行业对标数据成功
- [ ] GET /report/benchmark/data?period=2026-Q1 - 按期间筛选成功
- [ ] POST /report/benchmark/upload - 上传行业基准成功
- [ ] GET /report/benchmark/template - 下载行业模板成功

## 系统支撑模块测试检查点
- [ ] GET /system/user - 获取用户列表成功
- [ ] GET /system/user?keyword=admin - 关键词搜索成功
- [ ] GET /system/user?status=active - 状态筛选成功
- [ ] POST /system/user - 创建用户成功
- [ ] POST /system/user - 用户名重复返回409
- [ ] PUT /system/user/:id - 更新用户成功
- [ ] DELETE /system/user/:id - 删除用户成功
- [ ] PUT /system/user/:id/reset-password - 重置密码成功
- [ ] GET /system/role - 获取角色列表成功
- [ ] POST /system/role - 创建角色成功
- [ ] PUT /system/role/:id - 更新角色成功
- [ ] DELETE /system/role/:id - 删除角色成功
- [ ] GET /system/permission/tree - 获取权限树成功
- [ ] GET /system/audit-log - 获取审计日志成功
- [ ] GET /system/audit-log?page=1&pageSize=20 - 分页查询成功
- [ ] GET /system/audit-log?startDate=2026-04-01 - 日期筛选成功
- [ ] GET /system/audit-log/export - 导出审计日志成功
- [ ] GET /system/etl-monitor - 获取ETL监控数据成功
- [ ] POST /system/etl-monitor/trigger - 手动触发ETL成功
- [ ] PUT /system/etl-monitor/:id/stop - 停止ETL任务成功
- [ ] GET /system/params - 获取系统参数成功
- [ ] PUT /system/params - 更新系统参数成功
- [ ] PUT /system/params - 测试邮件配置成功

## 测试报告生成检查点
- [ ] 认证模块子测试报告生成完成
- [ ] 数据接入模块子测试报告生成完成
- [ ] 算法引擎模块子测试报告生成完成
- [ ] 配置管理模块子测试报告生成完成
- [ ] 可视化报表模块子测试报告生成完成
- [ ] 系统支撑模块子测试报告生成完成
- [ ] 综合主测试报告生成完成
- [ ] 所有报告存储在 docs/test report/test-report2.0 目录
