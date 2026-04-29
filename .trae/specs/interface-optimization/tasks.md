# FinSight 接口优化 - 实现计划

## [ ] Task 1: 实现SystemServiceImpl中的triggerEtl方法
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 实现triggerEtl方法，使其能够触发ETL任务
  - 参考DataServiceImpl中的triggerEtlTask方法实现
  - 更新任务状态为running，并记录开始时间
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `programmatic` TR-1.1: 调用triggerEtl方法后，对应ETL任务状态应更新为running
  - `programmatic` TR-1.2: 调用triggerEtl方法后，对应ETL任务的lastRun字段应更新为当前时间
- **Notes**: 依赖EtlTaskMapper进行数据库操作

## [ ] Task 2: 实现SystemServiceImpl中的stopEtl方法
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 实现stopEtl方法，使其能够停止ETL任务
  - 更新任务状态为stopped，并记录结束时间
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `programmatic` TR-2.1: 调用stopEtl方法后，对应ETL任务状态应更新为stopped
  - `programmatic` TR-2.2: 调用stopEtl方法后，对应ETL任务的endTime字段应更新为当前时间
- **Notes**: 依赖EtlTaskMapper进行数据库操作

## [ ] Task 3: 实现SystemServiceImpl中的updateSystemParams方法
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 实现updateSystemParams方法，使其能够更新系统参数
  - 支持更新通用参数和邮件配置
  - 对参数进行基本验证
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `programmatic` TR-3.1: 调用updateSystemParams方法后，config_system_param表中的对应参数应更新
  - `programmatic` TR-3.2: 调用updateSystemParams方法后，config_email_param表中的对应配置应更新
- **Notes**: 依赖ConfigSystemParamMapper和ConfigEmailParamMapper进行数据库操作

## [ ] Task 4: 实现ConfigServiceImpl中的exportKnowledge方法
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 实现exportKnowledge方法，使其能够导出知识库
  - 返回知识库数据，格式与API设计文档一致
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `programmatic` TR-4.1: 调用exportKnowledge方法后，应返回包含知识库数据的Map对象
  - `programmatic` TR-4.2: 返回的数据应包含所有知识条目
- **Notes**: 依赖KnowledgeMapper进行数据库操作

## [ ] Task 5: 实现ConfigServiceImpl中的importKnowledge方法
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 实现importKnowledge方法，使其能够导入知识库
  - 对导入数据进行基本验证
  - 批量插入或更新知识条目
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `programmatic` TR-5.1: 调用importKnowledge方法后，config_knowledge表中应新增或更新对应知识条目
  - `programmatic` TR-5.2: 导入的数据应包含必要的字段
- **Notes**: 依赖KnowledgeMapper进行数据库操作

## [ ] Task 6: 检查并修复PDF报告相关接口的500错误
- **Priority**: P1
- **Depends On**: None
- **Description**:
  - 排查PDF报告相关接口的500错误原因
  - 修复报告生成逻辑中的问题
  - 确保接口能够正常返回200状态码
- **Acceptance Criteria Addressed**: AC-3
- **Test Requirements**:
  - `programmatic` TR-6.1: 调用PDF报告生成接口后，应返回200状态码
  - `programmatic` TR-6.2: 调用PDF报告历史接口后，应返回200状态码
- **Notes**: 需要检查ReportServiceImpl中的相关方法实现

## [ ] Task 7: 生成优化报告文档
- **Priority**: P0
- **Depends On**: Task 1, Task 2, Task 3, Task 4, Task 5, Task 6
- **Description**:
  - 生成优化报告，记录修改内容
  - 列出因业务问题而不可修改的接口
  - 记录所有原未测试的接口的最终可测试性
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `human-judgment` TR-7.1: 报告应包含所有修改的方法和具体修改内容
  - `human-judgment` TR-7.2: 报告应包含因业务问题而不可修改的接口列表
  - `human-judgment` TR-7.3: 报告应包含所有原未测试的接口的最终可测试性状态
- **Notes**: 报告应存储在docs/test report/中断情况评估目录下