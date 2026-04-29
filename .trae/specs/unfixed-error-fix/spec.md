# FinSight 未修复错误修复计划 Spec

## Why
根据错误修复报告，有4个接口未开发实现（ERR-018、ERR-019、ERR-020、ERR-021），需要实现这些接口以完善系统功能。

## What Changes
- 实现 benchmark/upload 接口（POST /api/report/benchmark/upload）
- 实现 benchmark/template 接口（GET /api/report/benchmark/template）
- 实现知识库导出接口（GET /api/config/knowledge/export）
- 实现知识库导入接口（POST /api/config/knowledge/import）

## Impact
- Affected specs: 测试报告总汇、接口优化
- Affected code:
  - controller/ReportController.java（新增benchmark接口）
  - controller/ConfigController.java（新增知识库导入导出接口）
  - service/ConfigServiceImpl.java（实现exportKnowledge、importKnowledge方法）
  - 新增 BenchmarkService 和实现类（处理基准数据上传和模板生成）

## ADDED Requirements

### Requirement: Benchmark数据上传接口
系统应提供基准数据上传功能，允许用户上传Excel格式的基准数据文件。

#### Scenario: 成功上传基准数据
- **WHEN** 用户通过 POST /api/report/benchmark/upload 上传有效的Excel文件
- **THEN** 系统解析文件内容，存储基准数据，返回上传成功状态和记录数

#### Scenario: 上传文件格式错误
- **WHEN** 用户上传非Excel格式文件
- **THEN** 系统返回400错误，提示文件格式不正确

### Requirement: Benchmark模板下载接口
系统应提供基准数据模板下载功能，允许用户下载空白或示例模板。

#### Scenario: 下载空白模板
- **WHEN** 用户通过 GET /api/report/benchmark/template 请求模板
- **THEN** 系统返回Excel模板文件

#### Scenario: 下载带数据的模板
- **WHEN** 用户通过 GET /api/report/benchmark/template?type=sample 请求示例模板
- **THEN** 系统返回包含示例数据的Excel模板文件

### Requirement: 知识库导出接口
系统应提供知识库数据导出功能，允许用户导出知识库内容。

#### Scenario: 成功导出知识库
- **WHEN** 用户通过 GET /api/config/knowledge/export 导出知识库
- **THEN** 系统返回知识库数据（JSON格式），包含所有知识条目

### Requirement: 知识库导入接口
系统应提供知识库数据导入功能，允许用户批量导入知识条目。

#### Scenario: 成功导入知识库
- **WHEN** 用户通过 POST /api/config/knowledge/import 提交有效的知识数据
- **THEN** 系统解析数据并批量插入/更新知识条目，返回导入成功状态和记录数

#### Scenario: 导入数据格式错误
- **WHEN** 用户提交的数据格式不正确
- **THEN** 系统返回400错误，提示数据格式不正确

## MODIFIED Requirements

### Requirement: ConfigController 知识库导入导出
**Original**: 知识库导出和导入功能未实现
**New**: 系统应实现完整的知识库导入导出功能，支持JSON格式的数据交换

### Requirement: ReportController Benchmark接口
**Original**: Benchmark相关接口不存在
**New**: 系统应实现Benchmark数据上传和模板下载接口

## REMOVED Requirements

### ERR-016 投资方案中文乱码
**Reason**: 需要调整数据库字符集配置，非代码问题，需DBA配合
**Migration**: 建议在数据库层面修改表的字符集为utf8mb4

### ERR-022 创建记录返回id为null
**Reason**: 数据库表自增ID配置问题，非代码问题，需DBA配合
**Migration**: 建议检查数据库表的自增ID配置
