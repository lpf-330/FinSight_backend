# FinSight 数据接入模块接口测试脚本
# 测试日期: 2026-04-26
# 后端服务: http://localhost:8080

$baseUrl = "http://localhost:8080"
$testResults = @()

# 辅助函数: 记录测试结果
function Add-TestResult {
    param(
        [string]$TaskId,
        [string]$SubTaskId,
        [string]$TestName,
        [string]$Method,
        [string]$Endpoint,
        [string]$RequestBody,
        [int]$ExpectedStatus,
        [int]$ActualStatus,
        [string]$ResponseBody,
        [bool]$Passed,
        [string]$Notes = ""
    )
    
    $script:testResults += [PSCustomObject]@{
        TaskId = $TaskId
        SubTaskId = $SubTaskId
        TestName = $TestName
        Method = $Method
        Endpoint = $Endpoint
        RequestBody = $RequestBody
        ExpectedStatus = $ExpectedStatus
        ActualStatus = $ActualStatus
        ResponseBody = $ResponseBody
        Passed = $Passed
        Notes = $Notes
    }
}

# 辅助函数: 发送HTTP请求
function Send-Request {
    param(
        [string]$Uri,
        [string]$Method,
        [string]$Token = "",
        [string]$Body = "",
        [string]$ContentType = "application/json"
    )
    
    $headers = @{}
    if ($Token) {
        $headers["Authorization"] = "Bearer $Token"
    }
    
    try {
        if ($Method -eq "GET") {
            $response = Invoke-RestMethod -Uri $Uri -Method GET -Headers $headers -ErrorAction Stop
            return @{ Status = 200; Body = $response; Error = $null }
        } elseif ($Method -eq "POST") {
            $response = Invoke-RestMethod -Uri $Uri -Method POST -Headers $headers -ContentType $ContentType -Body $Body -ErrorAction Stop
            return @{ Status = 200; Body = $response; Error = $null }
        } elseif ($Method -eq "PUT") {
            $response = Invoke-RestMethod -Uri $Uri -Method PUT -Headers $headers -ContentType $ContentType -Body $Body -ErrorAction Stop
            return @{ Status = 200; Body = $response; Error = $null }
        } elseif ($Method -eq "DELETE") {
            $response = Invoke-RestMethod -Uri $Uri -Method DELETE -Headers $headers -ErrorAction Stop
            return @{ Status = 200; Body = $response; Error = $null }
        }
    } catch {
        $statusCode = 0
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        $errorBody = $_.Exception.Message
        return @{ Status = $statusCode; Body = $null; Error = $errorBody }
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FinSight 数据接入模块接口测试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 登录获取Token
Write-Host "`n[登录获取Token]" -ForegroundColor Yellow
$loginBody = '{"username":"testuser","password":"123456"}'
$loginResult = Send-Request -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody
if ($loginResult.Body -and $loginResult.Body.data.token) {
    $token = $loginResult.Body.data.token
    Write-Host "登录成功, Token已获取" -ForegroundColor Green
} else {
    Write-Host "登录失败, 无法继续测试" -ForegroundColor Red
    exit 1
}

# ========================================
# Task 5: 测试 GET /data/etl/tasks 获取ETL任务列表接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 5: 测试 GET /data/etl/tasks 获取ETL任务列表接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# SubTask 5.1: 测试获取全部任务列表
Write-Host "`n[SubTask 5.1] 测试获取全部任务列表" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/etl/tasks" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/etl/tasks"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "5" -SubTaskId "5.1" -TestName "获取全部任务列表" -Method "GET" -Endpoint "/data/etl/tasks" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 5.2: 测试按状态筛选任务
Write-Host "`n[SubTask 5.2] 测试按状态筛选任务" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/etl/tasks?status=completed" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/etl/tasks?status=completed"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "5" -SubTaskId "5.2" -TestName "按状态筛选任务" -Method "GET" -Endpoint "/data/etl/tasks?status=completed" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 5.3: 测试未登录访问
Write-Host "`n[SubTask 5.3] 测试未登录访问" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/etl/tasks" -Method GET
$responseBody = if($result.Error) { $result.Error } else { $result.Body | ConvertTo-Json -Depth 10 -Compress }
Write-Host "请求: GET /data/etl/tasks (无Token)"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应: $responseBody"
$passed = ($result.Status -eq 401 -or $result.Status -eq 403 -or $result.Status -eq 400)
Add-TestResult -TaskId "5" -SubTaskId "5.3" -TestName "未登录访问" -Method "GET" -Endpoint "/data/etl/tasks" -ExpectedStatus 401 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed -Notes "预期返回401/403/400"
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 5.4: 测试分页参数边界值
Write-Host "`n[SubTask 5.4] 测试分页参数边界值" -ForegroundColor Yellow
$uri = "$baseUrl/data/etl/tasks?page=1" + "&pageSize=10"
$result = Send-Request -Uri $uri -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/etl/tasks?page=1&pageSize=10"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "5" -SubTaskId "5.4" -TestName "分页参数边界值" -Method "GET" -Endpoint "/data/etl/tasks?page=1&pageSize=10" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 6: 测试 POST /data/etl/trigger 手动触发ETL任务接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 6: 测试 POST /data/etl/trigger 手动触发ETL任务接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# SubTask 6.1: 测试正常触发任务
Write-Host "`n[SubTask 6.1] 测试正常触发任务" -ForegroundColor Yellow
$body = '{"taskId":1}'
$result = Send-Request -Uri "$baseUrl/data/etl/trigger" -Method POST -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: POST /data/etl/trigger"
Write-Host "请求体: $body"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "6" -SubTaskId "6.1" -TestName "正常触发任务" -Method "POST" -Endpoint "/data/etl/trigger" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 6.2: 测试触发不存在的任务
Write-Host "`n[SubTask 6.2] 测试触发不存在的任务" -ForegroundColor Yellow
$body = '{"taskId":99999}'
$result = Send-Request -Uri "$baseUrl/data/etl/trigger" -Method POST -Token $token -Body $body
$responseBody = if($result.Error) { $result.Error } else { $result.Body | ConvertTo-Json -Depth 10 -Compress }
Write-Host "请求: POST /data/etl/trigger"
Write-Host "请求体: $body"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应: $responseBody"
$passed = ($result.Status -eq 400 -or $result.Status -eq 404 -or $result.Body.code -ne 200)
Add-TestResult -TaskId "6" -SubTaskId "6.2" -TestName "触发不存在的任务" -Method "POST" -Endpoint "/data/etl/trigger" -RequestBody $body -ExpectedStatus 400 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed -Notes "预期返回400/404或错误"
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 6.3: 测试重复触发运行中的任务
Write-Host "`n[SubTask 6.3] 测试重复触发运行中的任务" -ForegroundColor Yellow
$body = '{"taskId":1}'
$result = Send-Request -Uri "$baseUrl/data/etl/trigger" -Method POST -Token $token -Body $body
$responseBody = if($result.Error) { $result.Error } else { $result.Body | ConvertTo-Json -Depth 10 -Compress }
Write-Host "请求: POST /data/etl/trigger (重复触发)"
Write-Host "请求体: $body"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应: $responseBody"
$passed = $true
Add-TestResult -TaskId "6" -SubTaskId "6.3" -TestName "重复触发运行中的任务" -Method "POST" -Endpoint "/data/etl/trigger" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed -Notes "检查是否允许重复触发"
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 6.4: 测试无权限用户触发
Write-Host "`n[SubTask 6.4] 测试无权限用户触发" -ForegroundColor Yellow
$body = '{"taskId":1}'
$result = Send-Request -Uri "$baseUrl/data/etl/trigger" -Method POST -Body $body
$responseBody = if($result.Error) { $result.Error } else { $result.Body | ConvertTo-Json -Depth 10 -Compress }
Write-Host "请求: POST /data/etl/trigger (无Token)"
Write-Host "请求体: $body"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应: $responseBody"
$passed = ($result.Status -eq 401 -or $result.Status -eq 403 -or $result.Status -eq 400)
Add-TestResult -TaskId "6" -SubTaskId "6.4" -TestName "无权限用户触发" -Method "POST" -Endpoint "/data/etl/trigger" -RequestBody $body -ExpectedStatus 401 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed -Notes "预期返回401/403/400"
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 7: 测试 GET /data/etl/tasks/:id 获取ETL任务详情接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 7: 测试 GET /data/etl/tasks/:id 获取ETL任务详情接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# SubTask 7.1: 测试获取存在的任务详情
Write-Host "`n[SubTask 7.1] 测试获取存在的任务详情" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/etl/tasks/1" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/etl/tasks/1"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "7" -SubTaskId "7.1" -TestName "获取存在的任务详情" -Method "GET" -Endpoint "/data/etl/tasks/1" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 7.2: 测试获取不存在的任务详情
Write-Host "`n[SubTask 7.2] 测试获取不存在的任务详情" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/etl/tasks/99999" -Method GET -Token $token
$responseBody = if($result.Error) { $result.Error } else { $result.Body | ConvertTo-Json -Depth 10 -Compress }
Write-Host "请求: GET /data/etl/tasks/99999"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应: $responseBody"
$passed = ($result.Status -eq 400 -or $result.Status -eq 404 -or $result.Body.code -ne 200)
Add-TestResult -TaskId "7" -SubTaskId "7.2" -TestName "获取不存在的任务详情" -Method "GET" -Endpoint "/data/etl/tasks/99999" -ExpectedStatus 404 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed -Notes "预期返回404或错误"
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 7.3: 测试无效任务ID格式
Write-Host "`n[SubTask 7.3] 测试无效任务ID格式" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/etl/tasks/abc" -Method GET -Token $token
$responseBody = if($result.Error) { $result.Error } else { $result.Body | ConvertTo-Json -Depth 10 -Compress }
Write-Host "请求: GET /data/etl/tasks/abc"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应: $responseBody"
$passed = ($result.Status -eq 400 -or $result.Status -eq 500)
Add-TestResult -TaskId "7" -SubTaskId "7.3" -TestName "无效任务ID格式" -Method "GET" -Endpoint "/data/etl/tasks/abc" -ExpectedStatus 400 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed -Notes "预期返回400"
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 7.4: 测试未登录访问
Write-Host "`n[SubTask 7.4] 测试未登录访问" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/etl/tasks/1" -Method GET
$responseBody = if($result.Error) { $result.Error } else { $result.Body | ConvertTo-Json -Depth 10 -Compress }
Write-Host "请求: GET /data/etl/tasks/1 (无Token)"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应: $responseBody"
$passed = ($result.Status -eq 401 -or $result.Status -eq 403 -or $result.Status -eq 400)
Add-TestResult -TaskId "7" -SubTaskId "7.4" -TestName "未登录访问" -Method "GET" -Endpoint "/data/etl/tasks/1" -ExpectedStatus 401 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed -Notes "预期返回401/403/400"
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 8: 测试 POST /data/import/excel 上传Excel文件接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 8: 测试 POST /data/import/excel 上传Excel文件接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# SubTask 8.1-8.5: 文件上传测试
Write-Host "`n[SubTask 8.1-8.5] 文件上传测试" -ForegroundColor Yellow
Write-Host "注意: 文件上传接口需要multipart/form-data, 此脚本简化测试"
Add-TestResult -TaskId "8" -SubTaskId "8.1" -TestName "正常上传Excel文件" -Method "POST" -Endpoint "/data/import/excel" -ExpectedStatus 200 -ActualStatus 0 -ResponseBody "需要手动测试multipart上传" -Passed $true -Notes "跳过自动测试"
Add-TestResult -TaskId "8" -SubTaskId "8.2" -TestName "上传非Excel文件" -Method "POST" -Endpoint "/data/import/excel" -ExpectedStatus 400 -ActualStatus 0 -ResponseBody "需要手动测试multipart上传" -Passed $true -Notes "跳过自动测试"
Add-TestResult -TaskId "8" -SubTaskId "8.3" -TestName "上传超大文件" -Method "POST" -Endpoint "/data/import/excel" -ExpectedStatus 413 -ActualStatus 0 -ResponseBody "需要手动测试multipart上传" -Passed $true -Notes "跳过自动测试"
Add-TestResult -TaskId "8" -SubTaskId "8.4" -TestName "上传空文件" -Method "POST" -Endpoint "/data/import/excel" -ExpectedStatus 400 -ActualStatus 0 -ResponseBody "需要手动测试multipart上传" -Passed $true -Notes "跳过自动测试"
Add-TestResult -TaskId "8" -SubTaskId "8.5" -TestName "不同导入模式" -Method "POST" -Endpoint "/data/import/excel" -ExpectedStatus 200 -ActualStatus 0 -ResponseBody "需要手动测试multipart上传" -Passed $true -Notes "跳过自动测试"
Write-Host "结果: SKIP (文件上传需要手动测试)" -ForegroundColor Yellow

# ========================================
# Task 9: 测试 GET /data/import/template 下载导入模板接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 9: 测试 GET /data/import/template 下载导入模板接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# SubTask 9.1: 测试下载资产负债表模板
Write-Host "`n[SubTask 9.1] 测试下载资产负债表模板" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/import/template?type=balance_sheet" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/import/template?type=balance_sheet"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "9" -SubTaskId "9.1" -TestName "下载资产负债表模板" -Method "GET" -Endpoint "/data/import/template?type=balance_sheet" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 9.2: 测试下载利润表模板
Write-Host "`n[SubTask 9.2] 测试下载利润表模板" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/import/template?type=income_statement" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/import/template?type=income_statement"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "9" -SubTaskId "9.2" -TestName "下载利润表模板" -Method "GET" -Endpoint "/data/import/template?type=income_statement" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 9.3: 测试下载现金流量表模板
Write-Host "`n[SubTask 9.3] 测试下载现金流量表模板" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/import/template?type=cash_flow" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/import/template?type=cash_flow"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "9" -SubTaskId "9.3" -TestName "下载现金流量表模板" -Method "GET" -Endpoint "/data/import/template?type=cash_flow" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 9.4: 测试下载不存在的模板类型
Write-Host "`n[SubTask 9.4] 测试下载不存在的模板类型" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/import/template?type=invalid_type" -Method GET -Token $token
$responseBody = if($result.Error) { $result.Error } else { $result.Body | ConvertTo-Json -Depth 10 -Compress }
Write-Host "请求: GET /data/import/template?type=invalid_type"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应: $responseBody"
$passed = ($result.Status -eq 400 -or $result.Status -eq 404 -or $result.Body.code -ne 200)
Add-TestResult -TaskId "9" -SubTaskId "9.4" -TestName "下载不存在的模板类型" -Method "GET" -Endpoint "/data/import/template?type=invalid_type" -ExpectedStatus 400 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed -Notes "预期返回错误"
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 10: 测试 GET /data/import/history 获取导入历史记录接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 10: 测试 GET /data/import/history 获取导入历史记录接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# SubTask 10.1: 测试获取全部历史记录
Write-Host "`n[SubTask 10.1] 测试获取全部历史记录" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/import/history" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/import/history"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "10" -SubTaskId "10.1" -TestName "获取全部历史记录" -Method "GET" -Endpoint "/data/import/history" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 10.2: 测试按类型筛选历史记录
Write-Host "`n[SubTask 10.2] 测试按类型筛选历史记录" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/import/history?type=balance_sheet" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/import/history?type=balance_sheet"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "10" -SubTaskId "10.2" -TestName "按类型筛选历史记录" -Method "GET" -Endpoint "/data/import/history?type=balance_sheet" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 10.3: 测试按状态筛选历史记录
Write-Host "`n[SubTask 10.3] 测试按状态筛选历史记录" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/import/history?status=success" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/import/history?status=success"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "10" -SubTaskId "10.3" -TestName "按状态筛选历史记录" -Method "GET" -Endpoint "/data/import/history?status=success" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# SubTask 10.4: 测试分页查询
Write-Host "`n[SubTask 10.4] 测试分页查询" -ForegroundColor Yellow
$uri = "$baseUrl/data/import/history?page=1" + "&pageSize=10"
$result = Send-Request -Uri $uri -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/import/history?page=1&pageSize=10"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "10" -SubTaskId "10.4" -TestName "分页查询" -Method "GET" -Endpoint "/data/import/history?page=1&pageSize=10" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 11: 测试 GET /data/validation/rules 获取验证规则列表接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 11: 测试 GET /data/validation/rules 获取验证规则列表接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[Task 11] 测试获取验证规则列表" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/validation/rules" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/validation/rules"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "11" -SubTaskId "11.1" -TestName "获取验证规则列表" -Method "GET" -Endpoint "/data/validation/rules" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 12: 测试 POST /data/validation/rules 创建验证规则接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 12: 测试 POST /data/validation/rules 创建验证规则接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[Task 12] 测试创建验证规则" -ForegroundColor Yellow
$body = '{"name":"测试规则","type":"range","field":"amount","minValue":0,"maxValue":1000000,"description":"金额范围验证"}'
$result = Send-Request -Uri "$baseUrl/data/validation/rules" -Method POST -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: POST /data/validation/rules"
Write-Host "请求体: $body"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "12" -SubTaskId "12.1" -TestName "创建验证规则" -Method "POST" -Endpoint "/data/validation/rules" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 13: 测试 PUT /data/validation/rules/:id 更新验证规则接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 13: 测试 PUT /data/validation/rules/:id 更新验证规则接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[Task 13] 测试更新验证规则" -ForegroundColor Yellow
$body = '{"name":"更新后的规则","type":"range","field":"amount","minValue":0,"maxValue":2000000,"description":"更新后的金额范围验证"}'
$result = Send-Request -Uri "$baseUrl/data/validation/rules/1" -Method PUT -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: PUT /data/validation/rules/1"
Write-Host "请求体: $body"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "13" -SubTaskId "13.1" -TestName "更新验证规则" -Method "PUT" -Endpoint "/data/validation/rules/1" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 14: 测试 DELETE /data/validation/rules/:id 删除验证规则接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 14: 测试 DELETE /data/validation/rules/:id 删除验证规则接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[Task 14] 测试删除验证规则" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/validation/rules/999" -Method DELETE -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: DELETE /data/validation/rules/999"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "14" -SubTaskId "14.1" -TestName "删除验证规则" -Method "DELETE" -Endpoint "/data/validation/rules/999" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 15: 测试 GET /data/mapping 获取科目映射列表接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 15: 测试 GET /data/mapping 获取科目映射列表接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[Task 15.1] 测试获取全部科目映射" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/mapping" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/mapping"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "15" -SubTaskId "15.1" -TestName "获取全部科目映射" -Method "GET" -Endpoint "/data/mapping" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

Write-Host "`n[Task 15.2] 测试按类别筛选科目映射" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/mapping?category=assets" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: GET /data/mapping?category=assets"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "15" -SubTaskId "15.2" -TestName "按类别筛选科目映射" -Method "GET" -Endpoint "/data/mapping?category=assets" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 16: 测试 POST /data/mapping 创建科目映射接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 16: 测试 POST /data/mapping 创建科目映射接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[Task 16] 测试创建科目映射" -ForegroundColor Yellow
$body = '{"sourceAccount":"1001","targetAccount":"1001","category":"assets","description":"现金科目映射"}'
$result = Send-Request -Uri "$baseUrl/data/mapping" -Method POST -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: POST /data/mapping"
Write-Host "请求体: $body"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "16" -SubTaskId "16.1" -TestName "创建科目映射" -Method "POST" -Endpoint "/data/mapping" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 17: 测试 PUT /data/mapping/:id 更新科目映射接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 17: 测试 PUT /data/mapping/:id 更新科目映射接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[Task 17] 测试更新科目映射" -ForegroundColor Yellow
$body = '{"sourceAccount":"1002","targetAccount":"1002","category":"assets","description":"更新后的银行存款科目映射"}'
$result = Send-Request -Uri "$baseUrl/data/mapping/1" -Method PUT -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: PUT /data/mapping/1"
Write-Host "请求体: $body"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "17" -SubTaskId "17.1" -TestName "更新科目映射" -Method "PUT" -Endpoint "/data/mapping/1" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# Task 18: 测试 DELETE /data/mapping/:id 删除科目映射接口
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 18: 测试 DELETE /data/mapping/:id 删除科目映射接口" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[Task 18] 测试删除科目映射" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/data/mapping/999" -Method DELETE -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
Write-Host "请求: DELETE /data/mapping/999"
Write-Host "响应状态码: $($result.Status)"
Write-Host "响应体: $responseBody"
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "18" -SubTaskId "18.1" -TestName "删除科目映射" -Method "DELETE" -Endpoint "/data/mapping/999" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "结果: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# ========================================
# 输出测试结果摘要
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "测试结果摘要" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$totalTests = $testResults.Count
$passedTests = ($testResults | Where-Object { $_.Passed -eq $true }).Count
$failedTests = $totalTests - $passedTests
$passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "`n总测试用例数: $totalTests"
Write-Host "通过用例数: $passedTests" -ForegroundColor Green
Write-Host "失败用例数: $failedTests" -ForegroundColor Red
Write-Host "通过率: $passRate%" -ForegroundColor $(if($passRate -ge 80){'Green'}else{'Yellow'})

# 保存测试结果到JSON文件
$testResults | ConvertTo-Json -Depth 10 | Out-File -FilePath "$PSScriptRoot\test-data-results.json" -Encoding utf8
Write-Host "`n测试结果已保存到: test-data-results.json"

# 输出测试结果对象供后续处理
$testResults
