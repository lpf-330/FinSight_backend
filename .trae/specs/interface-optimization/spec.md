# FinSight 接口优化 - 产品需求文档

## Overview
- **Summary**: 对FinSight系统中未测试的接口进行优化，使其具备可测试性，包括实现未完成的方法和修复存在的问题。
- **Purpose**: 提高系统的可测试性和稳定性，为后续的完整测试做准备。
- **Target Users**: 开发团队、测试团队

## Goals
- 实现SystemServiceImpl中的空方法，包括triggerEtl、stopEtl、updateSystemParams
- 实现ConfigServiceImpl中的知识库导出/导入方法
- 检查并修复PDF报告相关接口的500错误
- 生成优化报告，记录修改内容和最终可测试性状态

## Non-Goals (Out of Scope)
- 不修改业务逻辑，只完善现有接口的实现
- 不添加新的功能或接口
- 不修改数据库结构
- 不处理可视化报表模块中不存在的接口（因业务文档未明确说明）

## Background & Context
- 根据测试完整度报告，系统支撑模块完全未测试，配置管理模块和可视化报表模块部分未测试
- 根据未测试代码可测试性分析，部分接口因方法未实现而不可测试
- 系统使用Spring Boot框架，后端API设计已在api-design.md中定义
- 数据库设计已在database-design.md中定义

## Functional Requirements
- **FR-1**: 实现SystemServiceImpl中的triggerEtl方法，使其能够触发ETL任务
- **FR-2**: 实现SystemServiceImpl中的stopEtl方法，使其能够停止ETL任务
- **FR-3**: 实现SystemServiceImpl中的updateSystemParams方法，使其能够更新系统参数
- **FR-4**: 实现ConfigServiceImpl中的exportKnowledge方法，使其能够导出知识库
- **FR-5**: 实现ConfigServiceImpl中的importKnowledge方法，使其能够导入知识库
- **FR-6**: 检查并修复PDF报告相关接口的500错误

## Non-Functional Requirements
- **NFR-1**: 代码实现应符合现有代码风格和架构
- **NFR-2**: 实现的方法应与API设计文档中的接口规范一致
- **NFR-3**: 实现的方法应具备基本的错误处理能力
- **NFR-4**: 实现的方法应具备可测试性

## Constraints
- **Technical**: 基于现有的Spring Boot框架和数据库设计
- **Business**: 不修改业务逻辑，只完善现有接口的实现
- **Dependencies**: 依赖现有的数据库结构和API设计

## Assumptions
- 系统参数的更新应存储在config_system_param表中
- ETL任务的触发和停止应与data_etl_task表交互
- 知识库的导出/导入应与config_knowledge表交互
- PDF报告相关接口的错误可能与报告生成逻辑有关

## Acceptance Criteria

### AC-1: SystemServiceImpl中的空方法实现
- **Given**: 系统运行正常
- **When**: 调用triggerEtl、stopEtl、updateSystemParams方法
- **Then**: 方法能够正常执行，不抛出异常
- **Verification**: `programmatic`

### AC-2: ConfigServiceImpl中的知识库导出/导入方法实现
- **Given**: 系统运行正常
- **When**: 调用exportKnowledge、importKnowledge方法
- **Then**: 方法能够正常执行，不抛出异常
- **Verification**: `programmatic`

### AC-3: PDF报告相关接口修复
- **Given**: 系统运行正常
- **When**: 调用PDF报告相关接口
- **Then**: 接口返回200状态码，不返回500错误
- **Verification**: `programmatic`

### AC-4: 优化报告生成
- **Given**: 所有接口优化完成
- **When**: 生成优化报告
- **Then**: 报告包含修改内容、不可修改的接口列表和最终可测试性状态
- **Verification**: `human-judgment`

## Open Questions
- [ ] 可视化报表模块中不存在的接口具体是哪些？（因业务文档未明确说明）
- [ ] PDF报告相关接口的具体错误原因是什么？（需要进一步排查）