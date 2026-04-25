# FinSight API 接口文档

> Base URL: `/api`  
> 认证方式: Bearer Token (JWT)  
> 响应格式: JSON `{ code: 200, message: "success", data: ... }`

---

## 1. 认证模块 `/auth`

### POST /auth/login
用户登录

**请求体：**
```json
{
  "username": "admin",
  "password": "123456"
}
```

**响应：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 86400
  }
}
```

### GET /auth/user-info
获取当前登录用户信息（需认证）

**响应：**
```json
{
  "code": 200,
  "data": {
    "username": "admin",
    "name": "系统管理员",
    "roles": ["ADMIN"],
    "department": "信息部"
  }
}
```

### POST /auth/logout
退出登录（需认证）

### PUT /auth/change-password
修改密码（需认证）

**请求体：**
```json
{
  "oldPassword": "123456",
  "newPassword": "654321"
}
```

---

## 2. 数据接入模块 `/data`

### 2.1 ETL管理

#### GET /data/etl/tasks
获取ETL任务列表

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| status | string | 筛选状态(success/failed/running/pending) |

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "K8科目余额表抽取",
      "source": "金蝶K8",
      "target": "科目余额事实表",
      "cron": "0 2 * * *",
      "status": "success",
      "lastRun": "2026-04-24 02:00:00",
      "nextRun": "2026-04-25 02:00:00",
      "records": 12580,
      "duration": "3m 25s"
    }
  ]
}
```

#### POST /data/etl/trigger
手动触发ETL任务

**请求体：**
```json
{ "taskId": 1 }
```

#### GET /data/etl/tasks/:id
获取ETL任务详情（含运行日志）

**响应：**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "name": "K8科目余额表抽取",
    "logs": [
      { "time": "2026-04-24 02:00:00", "level": "INFO", "message": "任务开始执行" }
    ]
  }
}
```

### 2.2 Excel导入

#### POST /data/import/excel
上传Excel文件（multipart/form-data）

**请求体：** FormData
- `file`: 文件 (.xlsx/.xls)
- `type`: 报表类型 (balance/income/cashflow)
- `mode`: 导入模式 (append/overwrite)

**响应：**
```json
{
  "code": 200,
  "data": {
    "records": 156,
    "fileName": "资产负债表_2026Q1.xlsx"
  }
}
```

#### GET /data/import/template
下载导入模板（返回blob）

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| type | string | 报表类型(balance/income/cashflow) |

#### GET /data/import/history
获取导入历史记录

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| page | number | 页码(默认1) |
| pageSize | number | 每页条数(默认20) |
| type | string | 报表类型筛选 |
| status | string | 状态筛选 |

**响应：**
```json
{
  "code": 200,
  "data": {
    "list": [
      {
        "id": 1,
        "fileName": "资产负债表_2026Q1.xlsx",
        "type": "balance",
        "mode": "append",
        "records": 156,
        "status": "success",
        "operatorName": "张三",
        "createdAt": "2026-04-20 14:30:00"
      }
    ],
    "total": 3
  }
}
```

### 2.3 数据校验

#### GET /data/validation/rules
获取校验规则列表

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "资产负债平衡校验",
      "expression": "ABS(asset - liability - equity) < 0.01",
      "level": "error",
      "message": "资产不等于负债+所有者权益",
      "enabled": true,
      "createdAt": "2026-01-15 10:00:00"
    }
  ]
}
```

#### POST /data/validation/rules
创建校验规则

**请求体：**
```json
{
  "name": "资产负债平衡校验",
  "expression": "ABS(asset - liability - equity) < 0.01",
  "level": "error",
  "message": "资产不等于负债+所有者权益",
  "enabled": true
}
```

#### PUT /data/validation/rules/:id
更新校验规则

#### DELETE /data/validation/rules/:id
删除校验规则

### 2.4 科目映射

#### GET /data/mapping
获取科目映射列表

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| category | string | 科目类别筛选 |

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "k8Code": "1001",
      "k8Name": "库存现金",
      "targetCode": "A001",
      "targetName": "货币资金-现金",
      "category": "资产类",
      "enabled": true
    }
  ]
}
```

#### POST /data/mapping
创建科目映射

#### PUT /data/mapping/:id
更新科目映射

#### DELETE /data/mapping/:id
删除科目映射

---

## 3. 算法引擎模块 `/algorithm`

### 3.1 比率分析

#### GET /algorithm/ratio/results
获取比率分析结果

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| period | string | 期间(如2026-Q1) |
| category | string | 分类(solvency/operating/profitability/growth) |

**响应：**
```json
{
  "code": 200,
  "data": {
    "solvency": [
      { "code": "R001", "name": "流动比率", "formula": "流动资产/流动负债", "value": 1.85, "prevValue": 1.95, "change": -5.13, "standard": "≥2.0" }
    ],
    "operating": [],
    "profitability": [],
    "growth": []
  }
}
```

#### POST /algorithm/ratio/calculate
触发比率计算

**请求体：**
```json
{ "period": "2026-Q1" }
```

#### GET /algorithm/ratio/categories
获取比率分类列表

### 3.2 预警模型

#### GET /algorithm/warning/records
获取预警记录

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| level | string | 预警级别(yellow/orange/red) |
| status | string | 状态(active/ignored) |

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "indicator": "流动比率",
      "indicatorCode": "R001",
      "level": "yellow",
      "currentValue": 1.85,
      "yellowThreshold": "< 2.0",
      "orangeThreshold": "< 1.5",
      "redThreshold": "< 1.0",
      "trend": "持续下降",
      "suggestion": "建议优化短期偿债能力",
      "status": "active",
      "period": "2026-Q1",
      "triggeredAt": "2026-04-24 09:30:00"
    }
  ]
}
```

#### PUT /algorithm/warning/records/:id/ignore
忽略预警

#### GET /algorithm/warning/summary
获取预警汇总

**响应：**
```json
{
  "code": 200,
  "data": { "red": 1, "orange": 1, "yellow": 1 }
}
```

### 3.3 投资评估

#### POST /algorithm/investment/calculate
计算投资评估指标

**请求体：**
```json
{
  "projectName": "新产线投资",
  "initialInvestment": 1000,
  "discountRate": 8,
  "cashFlows": [
    { "year": 1, "amount": 200 },
    { "year": 2, "amount": 300 },
    { "year": 3, "amount": 350 },
    { "year": 4, "amount": 300 },
    { "year": 5, "amount": 250 }
  ]
}
```

**响应：**
```json
{
  "code": 200,
  "data": {
    "npv": 156.32,
    "irr": 12.5,
    "staticPayback": 3.43,
    "dynamicPayback": 4.12,
    "discountTable": [
      { "year": 1, "cashFlow": 200, "cumulative": -800, "discountFactor": 0.9259, "discountedCashFlow": 185.18, "cumulativeDiscounted": -814.82 }
    ]
  }
}
```

#### POST /algorithm/investment/scheme
保存投资方案

#### GET /algorithm/investment/schemes
获取投资方案列表

### 3.4 损益预测

#### POST /algorithm/forecast/profit
损益预测计算

**请求体：**
```json
{
  "baseRevenue": 2458.6,
  "revenueGrowthRate": 10,
  "costRate": 67.5,
  "expenseRate": 15,
  "taxRate": 25,
  "periods": 4
}
```

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "period": "2026-Q2",
      "revenue": 2704.46,
      "cost": 1825.51,
      "expense": 405.67,
      "profitBeforeTax": 473.28,
      "tax": 118.32,
      "netProfit": 354.96
    }
  ]
}
```

### 3.5 趋势与杜邦分析

#### GET /algorithm/trend/data
获取趋势数据

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| indicator | string | 指标名(如ROE) |
| months | number | 月数(默认12) |

**响应：**
```json
{
  "code": 200,
  "data": [
    { "month": "2025-05", "value": 16.8 },
    { "month": "2025-06", "value": 16.2 }
  ]
}
```

#### GET /algorithm/trend/dupont
获取杜邦分析数据

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| period | string | 期间 |

**响应：**
```json
{
  "code": 200,
  "data": {
    "roe": 15.6,
    "roeChange": -1.2,
    "factors": [
      { "name": "销售净利率", "value": 15.7, "prevValue": 18.3, "change": -14.2, "contribution": -4.1 },
      { "name": "总资产周转率", "value": 0.85, "prevValue": 0.9, "change": -5.6, "contribution": -0.9 },
      { "name": "权益乘数", "value": 1.83, "prevValue": 1.72, "change": 6.4, "contribution": 3.8 }
    ]
  }
}
```

---

## 4. 配置管理模块 `/config`

### 4.1 公式配置

#### GET /config/formula
获取公式列表

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| category | string | 分类筛选 |
| keyword | string | 名称搜索 |

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "流动比率",
      "expression": "流动资产 / 流动负债",
      "category": "偿债能力",
      "enabled": true,
      "version": "v1.3",
      "updateTime": "2026-04-10"
    }
  ]
}
```

#### POST /config/formula
创建公式

**请求体：**
```json
{
  "name": "流动比率",
  "expression": "流动资产 / 流动负债",
  "category": "偿债能力",
  "enabled": true
}
```

#### PUT /config/formula/:id
更新公式

#### DELETE /config/formula/:id
删除公式

#### POST /config/formula/validate
验证公式表达式

**请求体：**
```json
{ "expression": "流动资产 / 流动负债" }
```

**响应：**
```json
{
  "code": 200,
  "data": { "valid": true, "message": "表达式语法验证通过" }
}
```

### 4.2 预警阈值配置

#### GET /config/threshold
获取阈值列表

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "indicator": "流动比率",
      "indicatorCode": "R001",
      "direction": "lower",
      "yellowValue": "< 2.0",
      "orangeValue": "< 1.5",
      "redValue": "< 1.0",
      "dynamicBase": false,
      "updateTime": "2026-04-10"
    }
  ]
}
```

#### POST /config/threshold
创建阈值

#### PUT /config/threshold/:id
更新阈值

#### GET /config/threshold/dynamic-suggestion/:indicatorCode
获取动态基准建议值

**响应：**
```json
{
  "code": 200,
  "data": {
    "yellowValue": "< 0.28",
    "orangeValue": "< 0.23",
    "redValue": "< 0.18",
    "basis": "基于近3年P25/P10/P5分位数"
  }
}
```

### 4.3 知识库

#### GET /config/knowledge
获取知识库列表

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| indicator | string | 预警指标筛选 |
| level | string | 预警级别筛选 |

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "indicator": "流动比率",
      "level": "yellow",
      "content": "建议优化短期偿债能力...",
      "version": "v2.1",
      "usefulCount": 15,
      "uselessCount": 2,
      "updateTime": "2026-04-15"
    }
  ]
}
```

#### POST /config/knowledge
创建知识条目

#### PUT /config/knowledge/:id
更新知识条目

#### DELETE /config/knowledge/:id
删除知识条目

#### GET /config/knowledge/export
导出知识库（返回blob）

#### POST /config/knowledge/import
导入知识库（multipart/form-data）

### 4.4 模型版本管理

#### GET /config/version
获取版本列表

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| modelType | string | 模型类型(ratio/warning) |

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "modelType": "ratio",
      "version": "v1.3",
      "description": "新增现金比率公式",
      "creator": "张三",
      "isActive": true,
      "createdAt": "2026-04-10 14:30:00"
    }
  ]
}
```

#### POST /config/version/simulate
模拟版本计算

**请求体：**
```json
{
  "versionId": 2,
  "modelType": "ratio"
}
```

**响应：**
```json
{
  "code": 200,
  "data": {
    "version": "v1.2",
    "differences": [
      { "indicator": "流动比率", "currentResult": 1.85, "simulatedResult": 1.82, "diff": -0.03 }
    ]
  }
}
```

#### PUT /config/version/switch
切换版本

**请求体：**
```json
{
  "versionId": 2,
  "modelType": "ratio"
}
```

---

## 5. 可视化报表模块 `/report`

### 5.1 仪表盘

#### GET /report/dashboard
获取仪表盘数据

**响应：**
```json
{
  "code": 200,
  "data": {
    "indicatorCards": [
      { "label": "营业收入", "value": "2,458.6", "unit": "万元", "change": 12.5, "icon": "TrendCharts", "color": "#409eff", "bgColor": "#ecf5ff" }
    ],
    "warningList": [
      { "id": 1, "indicator": "流动比率", "level": "yellow", "value": "1.85", "threshold": "< 2.0", "suggestion": "建议优化短期偿债能力", "time": "2026-04-24 09:30" }
    ],
    "revenueChart": {
      "months": ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
      "revenue": [180, 165, 195, 210, 198, 220, 205, 230, 215, 240, 225, 245],
      "profit": [28, 25, 32, 35, 30, 38, 33, 40, 36, 42, 38, 45]
    },
    "ratioChart": {
      "months": ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
      "currentRatio": [2.1, 2.0, 1.95, 1.9, 1.92, 1.88, 1.85, 1.82, 1.86, 1.83, 1.80, 1.85],
      "quickRatio": [1.2, 1.15, 1.1, 1.05, 1.08, 1.02, 0.98, 0.95, 0.92, 0.90, 0.88, 0.92],
      "cashRatio": [0.35, 0.32, 0.28, 0.25, 0.23, 0.22, 0.20, 0.18, 0.17, 0.16, 0.15, 0.15]
    }
  }
}
```

### 5.2 图表展示

#### GET /report/charts
获取图表数据

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| period | string | 期间(如2026) |
| chartType | string | 图表类型 |

**响应：**
```json
{
  "code": 200,
  "data": {
    "profitTrend": { "months": [], "revenue": [], "cost": [], "grossProfit": [], "netProfit": [] },
    "structure": [{ "name": "营业成本", "value": 1659.6 }],
    "comparison": [{ "indicator": "营业收入", "current": 2458.6, "lastYear": 2185.2, "yoy": 12.5, "mom": 8.7 }],
    "balanceSheet": [{ "label": "资产总额", "value": "5,426.8 万元" }],
    "incomeStatement": [{ "label": "营业收入", "value": "2,458.6 万元" }],
    "cashFlow": [{ "label": "经营活动", "value": "521.8 万元" }]
  }
}
```

### 5.3 PDF报告

#### POST /report/pdf/generate
生成PDF报告（返回blob）

**请求体：**
```json
{
  "name": "2026年Q1财务分析报告",
  "type": "comprehensive",
  "period": "2026-Q1",
  "includeWarning": true,
  "includeRatio": true,
  "includeTrend": true,
  "includeInvestment": false
}
```

#### GET /report/pdf/history
获取PDF报告历史

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "2026年Q1财务分析报告",
      "type": "comprehensive",
      "period": "2026-Q1",
      "status": "completed",
      "createTime": "2026-04-20 15:30:00",
      "fileSize": "2.8MB",
      "creatorName": "张三"
    }
  ]
}
```

### 5.4 行业对标

#### GET /report/benchmark/data
获取行业对标数据

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| period | string | 期间 |
| industry | string | 行业名称 |

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "indicator": "流动比率",
      "indicatorCode": "R001",
      "enterprise": 1.85,
      "industryAvg": 2.1,
      "industryBest": 3.2,
      "deviation": 88.1
    }
  ]
}
```

#### POST /report/benchmark/upload
上传行业基准数据（multipart/form-data）

#### GET /report/benchmark/template
下载行业数据模板（返回blob）

---

## 6. 系统支撑模块 `/system`

### 6.1 用户管理

#### GET /system/user
获取用户列表

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| keyword | string | 搜索用户名/姓名 |
| roleId | number | 角色ID筛选 |
| status | string | 状态筛选(active/disabled) |

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "username": "admin",
      "name": "系统管理员",
      "department": "信息部",
      "roleId": 1,
      "roleName": "系统管理员",
      "status": "active",
      "lastLogin": "2026-04-24 08:30:00",
      "createdAt": "2026-01-01"
    }
  ]
}
```

#### POST /system/user
创建用户

**请求体：**
```json
{
  "username": "zhangsan",
  "name": "张三",
  "password": "123456",
  "department": "财务部",
  "roleId": 2,
  "status": "active"
}
```

#### PUT /system/user/:id
更新用户

#### DELETE /system/user/:id
删除用户

#### PUT /system/user/:id/reset-password
重置用户密码

### 6.2 角色管理

#### GET /system/role
获取角色列表

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "系统管理员",
      "code": "ADMIN",
      "description": "拥有所有功能权限",
      "userCount": 1,
      "permissions": ["全部权限"]
    }
  ]
}
```

#### POST /system/role
创建角色

#### PUT /system/role/:id
更新角色（含权限）

#### DELETE /system/role/:id
删除角色

#### GET /system/permission/tree
获取权限树

**响应：**
```json
{
  "code": 200,
  "data": [
    {
      "label": "数据接入",
      "key": "data",
      "children": [
        { "label": "ETL管理", "key": "data:etl" },
        { "label": "Excel导入", "key": "data:import" }
      ]
    }
  ]
}
```

### 6.3 审计日志

#### GET /system/audit-log
获取审计日志

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| page | number | 页码(默认1) |
| pageSize | number | 每页条数(默认20) |
| startDate | string | 开始日期 |
| endDate | string | 结束日期 |
| username | string | 操作人 |
| operation | string | 操作类型 |

**响应：**
```json
{
  "code": 200,
  "data": {
    "list": [
      {
        "id": 1,
        "userId": 2,
        "username": "张三",
        "operation": "数据导入",
        "module": "数据接入",
        "detail": "导入资产负债表_2026Q1.xlsx",
        "ip": "192.168.1.50",
        "createdAt": "2026-04-24 14:30:00"
      }
    ],
    "total": 8
  }
}
```

#### GET /system/audit-log/export
导出审计日志CSV（返回blob）

### 6.4 ETL监控

#### GET /system/etl-monitor
获取ETL监控数据

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| page | number | 页码 |
| pageSize | number | 每页条数 |

**响应：**
```json
{
  "code": 200,
  "data": {
    "stats": {
      "todaySuccess": 2,
      "todayFailed": 1,
      "todayRecords": 15830,
      "avgDuration": "2m 14s"
    },
    "list": [
      {
        "id": 1,
        "taskId": 1,
        "taskName": "K8科目余额表抽取",
        "startTime": "2026-04-24 02:00:00",
        "endTime": "2026-04-24 02:03:25",
        "status": "success",
        "records": 12580,
        "errorCount": 0,
        "errorMessage": "",
        "duration": "3m 25s"
      }
    ],
    "total": 6
  }
}
```

#### POST /system/etl-monitor/trigger
手动触发ETL

#### PUT /system/etl-monitor/:id/stop
停止ETL任务

### 6.5 系统参数

#### GET /system/params
获取系统参数

**响应：**
```json
{
  "code": 200,
  "data": {
    "general": [
      { "id": 1, "key": "system.name", "value": "FinSight财务智能分析系统", "description": "系统名称", "editable": true }
    ],
    "email": {
      "smtpHost": "smtp.company.com",
      "smtpPort": "465",
      "sender": "finsight@company.com",
      "username": "finsight@company.com",
      "password": "********",
      "sslEnabled": true
    }
  }
}
```

#### PUT /system/params
更新系统参数

**请求体（通用参数）：**
```json
{
  "general": [
    { "id": 1, "key": "etl.cron", "value": "0 0 3 * * ?" }
  ]
}
```

**请求体（邮件配置）：**
```json
{
  "email": {
    "smtpHost": "smtp.company.com",
    "smtpPort": "465",
    "sender": "finsight@company.com",
    "username": "finsight@company.com",
    "password": "newpassword",
    "sslEnabled": true
  }
}
```

**请求体（测试邮件）：**
```json
{
  "testEmail": true
}
```

---

## 7. 通用错误码

| HTTP状态码 | code | 说明 |
|-----------|------|------|
| 200 | 200 | 成功 |
| 400 | 400 | 请求参数错误 |
| 401 | 401 | 未认证/Token过期 |
| 403 | 403 | 无权限 |
| 404 | 404 | 资源不存在 |
| 409 | 409 | 资源冲突(如用户名重复) |
| 500 | 500 | 服务器内部错误 |

**错误响应格式：**
```json
{
  "code": 400,
  "message": "请求参数错误: username不能为空",
  "data": null
}
```
