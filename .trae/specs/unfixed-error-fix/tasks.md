# FinSight 未修复错误修复 - 实现计划

## Task Dependencies
- Task 1 依赖 Task 3（知识库导出需要先在ConfigServiceImpl中实现）
- Task 2 依赖 Task 4（知识库导入需要先在ConfigServiceImpl中实现）

## [x] Task 1: 实现知识库导出功能
- **Priority**: P1
- **Depends On**: None
- **Description**:
  - 在ConfigServiceImpl中实现exportKnowledge方法
  - 从config_knowledge表查询所有知识条目
  - 返回包含知识库数据的Map对象
- **Acceptance Criteria Addressed**: 知识库导出接口正常工作
- **Status**: ✅ 已实现（ConfigServiceImpl第173-181行）

## [x] Task 2: 实现知识库导入功能
- **Priority**: P1
- **Depends On**: None
- **Description**:
  - 在ConfigServiceImpl中实现importKnowledge方法
  - 接收JSON格式的知识数据
  - 批量插入或更新知识条目
  - 对导入数据进行基本验证
- **Acceptance Criteria Addressed**: 知识库导入接口正常工作
- **Status**: ✅ 已实现（ConfigServiceImpl第183-192行）

## [x] Task 3: 实现ConfigController导入导出接口
- **Priority**: P1
- **Depends On**: Task 1, Task 2
- **Description**:
  - 在ConfigController中添加exportKnowledge接口
  - 在ConfigController中添加importKnowledge接口
  - 确保接口返回正确的数据格式和状态码
- **Acceptance Criteria Addressed**: 接口可正常访问并返回正确响应
- **Status**: ✅ 已实现（ConfigController第106-117行）

## [x] Task 4: 创建BenchmarkService服务类
- **Priority**: P1
- **Depends On**: None
- **Description**:
  - 创建BenchmarkService接口
  - 创建BenchmarkServiceImpl实现类
  - 实现uploadBenchmarkData方法处理Excel文件上传
  - 实现generateTemplate方法生成Excel模板
- **Acceptance Criteria Addressed**: Benchmark服务类可用
- **Status**: ✅ 已实现（使用ReportServiceImpl中的实现）

## [x] Task 5: 实现ReportController Benchmark接口
- **Priority**: P1
- **Depends On**: Task 4
- **Description**:
  - 在ReportController中添加POST /api/report/benchmark/upload接口
  - 在ReportController中添加GET /api/report/benchmark/template接口
  - 配置接口的请求参数和响应格式
- **Acceptance Criteria Addressed**: Benchmark接口可正常访问
- **Status**: ✅ 已实现（ReportController第76-85行）

## [x] Task 6: 添加请求参数校验
- **Priority**: P2
- **Depends On**: Task 3, Task 5
- **Description**:
  - 为新增接口添加参数校验注解
  - 确保上传文件不为空
  - 确保导入数据格式正确
- **Acceptance Criteria Addressed**: 接口输入验证完整
- **Status**: ✅ 已实现（ConfigController知识库导入接口、ReportController Benchmark上传接口）

## [x] Task 7: 更新错误修复报告
- **Priority**: P1
- **Depends On**: Task 1, Task 2, Task 3, Task 4, Task 5, Task 6
- **Description**:
  - 在docs/test report/错误修复报告.md中添加修复记录
  - 标记ERR-018、ERR-019、ERR-020、ERR-021为已修复
  - 记录修改的文件清单
- **Acceptance Criteria Addressed**: 文档记录完整
- **Status**: ✅ 已更新
