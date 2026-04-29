# FinSight Comprehensive API Test Script v2.0 - All Modules
param(
    [string]$OutputDir = "c:\Users\yzyxt\Desktop\金融财务分析平台\FinSight_backend\docs\test report\test-report2.0"
)

$TestResults = @{
    Auth = @()
    Data = @()
    Algorithm = @()
    Config = @()
    Report = @()
    System = @()
}

$Global:Token = $null
$Global:BaseUrl = "http://localhost:8080"

function Get-TestToken {
    try {
        $response = Invoke-RestMethod -Uri "$Global:BaseUrl/auth/login" -Method POST -ContentType "application/json; charset=utf-8" -Body '{"username":"testuser","password":"123456"}'
        if ($response.code -eq 200) {
            $Global:Token = $response.data.token
            Write-Host "Token obtained: $($Global:Token.Substring(0, [Math]::Min(50, $Global:Token.Length)))..." -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "Failed to get token: $($_.Exception.Message)" -ForegroundColor Red
    }
    return $false
}

function Test-API {
    param(
        [string]$Module,
        [string]$TestId,
        [string]$TestName,
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers = @{},
        [object]$Body = $null,
        [string]$ExpectedCode,
        [string]$Description = ""
    )

    $startTime = Get-Date
    $result = @{
        TestId = $TestId
        TestName = $TestName
        Method = $Method
        Endpoint = $Endpoint
        ExpectedCode = $ExpectedCode
        ActualCode = $null
        ResponseTime = $null
        Passed = $false
        ErrorMessage = $null
        Description = $Description
        ResponseData = $null
    }

    try {
        $uri = "$Global:BaseUrl$Endpoint"
        $params = @{
            Uri = $uri
            Method = $Method
            ContentType = "application/json; charset=utf-8"
            Headers = @{}
        }

        if ($Headers.Count -gt 0) {
            $params.Headers = $Headers
        }

        if ($Body -ne $null) {
            $params.Body = $Body | ConvertTo-Json -Compress
        }

        $response = Invoke-RestMethod @params
        $endTime = Get-Date
        $result.ActualCode = $response.code
        $result.ResponseTime = [math]::Round(($endTime - $startTime).TotalMilliseconds, 2)
        $result.ResponseData = $response

        $result.Passed = ($result.ActualCode -eq $ExpectedCode)

    } catch {
        $endTime = Get-Date
        $result.ResponseTime = [math]::Round(($endTime - $startTime).TotalMilliseconds, 2)
        if ($_.Exception.Response) {
            $result.ActualCode = [int]$_.Exception.Response.StatusCode
            $result.Passed = ($result.ActualCode -eq $ExpectedCode)
        } else {
            $result.ActualCode = "Error"
            $result.ErrorMessage = $_.Exception.Message
        }
    }

    return $result
}

function Write-TestResult {
    param($result)
    $status = if ($result.Passed) { "PASS" } else { "FAIL" }
    $color = if ($result.Passed) { "Green" } else { "Red" }
    Write-Host "[$($result.TestId)] $($result.TestName): $status (Expected: $($result.ExpectedCode), Actual: $($result.ActualCode), Time: $($result.ResponseTime)ms)" -ForegroundColor $color
}

# ==================== PHASE 1: AUTH MODULE ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "PHASE 1: AUTH MODULE TESTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (-not (Get-TestToken)) {
    Write-Host "Failed to get test token!" -ForegroundColor Red
    exit 1
}

# Login tests
Write-Host "`n--- Login Tests ---" -ForegroundColor Yellow
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-001" -TestName "正常登录" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password="123456"} -ExpectedCode "200" -Description "使用正确凭据登录"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-002" -TestName "错误密码" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password="wrongpass"} -ExpectedCode "400" -Description "使用错误密码登录"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-003" -TestName "用户不存在" -Method "POST" -Endpoint "/auth/login" -Body @{username="nonexistent";password="123456"} -ExpectedCode "400" -Description "使用不存在用户登录"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-004" -TestName "空用户名" -Method "POST" -Endpoint "/auth/login" -Body @{username="";password="123456"} -ExpectedCode "400" -Description "使用空用户名登录"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-005" -TestName "空密码" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password=""} -ExpectedCode "400" -Description "使用空密码登录"

foreach ($r in $TestResults.Auth) { Write-TestResult $r }

# User info tests
Write-Host "`n--- User Info Tests ---" -ForegroundColor Yellow
$headers = @{Authorization="Bearer $Global:Token"}
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-006" -TestName "有效Token获取用户信息" -Method "GET" -Endpoint "/auth/user-info" -Headers $headers -ExpectedCode "200" -Description "使用有效Token获取用户信息"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-007" -TestName "无Token获取用户信息" -Method "GET" -Endpoint "/auth/user-info" -ExpectedCode "401" -Description "不带Token获取用户信息"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-008" -TestName "无效Token获取用户信息" -Method "GET" -Endpoint "/auth/user-info" -Headers @{Authorization="Bearer invalid.token.here"} -ExpectedCode "401" -Description "使用无效Token获取用户信息"

foreach ($r in $TestResults.Auth | Where-Object { $_.TestId -match "^AUTH-00[6-8]" }) { Write-TestResult $r }

# Logout tests
Write-Host "`n--- Logout Tests ---" -ForegroundColor Yellow
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-009" -TestName "有效Token登出" -Method "POST" -Endpoint "/auth/logout" -Headers $headers -ExpectedCode "200" -Description "使用有效Token登出"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-010" -TestName "无Token登出" -Method "POST" -Endpoint "/auth/logout" -ExpectedCode "401" -Description "不带Token登出"

foreach ($r in $TestResults.Auth | Where-Object { $_.TestId -match "^AUTH-00[9-10]" }) { Write-TestResult $r }

# Change password tests
Write-Host "`n--- Change Password Tests ---" -ForegroundColor Yellow
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-011" -TestName "旧密码错误修改密码" -Method "PUT" -Endpoint "/auth/change-password" -Headers $headers -Body @{oldPassword="wrongpass";newPassword="newpass123"} -ExpectedCode "400" -Description "使用错误旧密码修改密码"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-012" -TestName "新密码为空修改密码" -Method "PUT" -Endpoint "/auth/change-password" -Headers $headers -Body @{oldPassword="123456";newPassword=""} -ExpectedCode "400" -Description "新密码为空修改密码"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-013" -TestName "无Token修改密码" -Method "PUT" -Endpoint "/auth/change-password" -Body @{oldPassword="123456";newPassword="newpass123"} -ExpectedCode "401" -Description "不带Token修改密码"

foreach ($r in $TestResults.Auth | Where-Object { $_.TestId -match "^AUTH-01[1-3]" }) { Write-TestResult $r }

Write-Host "`nAuth module completed: $($TestResults.Auth.Count) tests" -ForegroundColor Green

# ==================== PHASE 2: DATA MODULE ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "PHASE 2: DATA MODULE TESTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$headers = @{Authorization="Bearer $Global:Token"}

# ETL Tests
Write-Host "`n--- ETL Management Tests ---" -ForegroundColor Yellow
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-001" -TestName "获取ETL任务列表" -Method "GET" -Endpoint "/data/etl/tasks" -Headers $headers -ExpectedCode "200" -Description "获取ETL任务列表"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-002" -TestName "按状态筛选ETL任务" -Method "GET" -Endpoint "/data/etl/tasks?status=success" -Headers $headers -ExpectedCode "200" -Description "按状态筛选ETL任务"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-003" -TestName "无Token获取ETL任务" -Method "GET" -Endpoint "/data/etl/tasks" -ExpectedCode "401" -Description "无Token访问ETL任务"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-004" -TestName "手动触发ETL" -Method "POST" -Endpoint "/data/etl/trigger" -Headers $headers -Body @{taskId=1} -ExpectedCode "200" -Description "手动触发ETL任务"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-005" -TestName "ETL触发空taskId" -Method "POST" -Endpoint "/data/etl/trigger" -Headers $headers -Body @{} -ExpectedCode "400" -Description "空taskId触发ETL"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-006" -TestName "获取ETL任务详情" -Method "GET" -Endpoint "/data/etl/tasks/1" -Headers $headers -ExpectedCode "200" -Description "获取指定ETL任务详情"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-007" -TestName "获取不存在ETL任务" -Method "GET" -Endpoint "/data/etl/tasks/999999" -Headers $headers -ExpectedCode "404" -Description "获取不存在的ETL任务"

foreach ($r in $TestResults.Data) { Write-TestResult $r }

# Import Tests
Write-Host "`n--- Excel Import Tests ---" -ForegroundColor Yellow
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-008" -TestName "获取导入历史" -Method "GET" -Endpoint "/data/import/history" -Headers $headers -ExpectedCode "200" -Description "获取导入历史记录"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-009" -TestName "导入历史分页" -Method "GET" -Endpoint "/data/import/history?page=1&pageSize=10" -Headers $headers -ExpectedCode "200" -Description "分页查询导入历史"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-010" -TestName "获取导入模板" -Method "GET" -Endpoint "/data/import/template?type=balance" -Headers $headers -ExpectedCode "200" -Description "下载导入模板"

# Validation Rules Tests
Write-Host "`n--- Validation Rules Tests ---" -ForegroundColor Yellow
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-011" -TestName "获取校验规则" -Method "GET" -Endpoint "/data/validation/rules" -Headers $headers -ExpectedCode "200" -Description "获取校验规则列表"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-012" -TestName "创建校验规则" -Method "POST" -Endpoint "/data/validation/rules" -Headers $headers -Body @{name="测试规则";expression="a > 0";level="error";message="测试";enabled=$true} -ExpectedCode "200" -Description "创建新校验规则"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-013" -TestName "创建校验规则缺少字段" -Method "POST" -Endpoint "/data/validation/rules" -Headers $headers -Body @{name="测试规则"} -ExpectedCode "400" -Description "缺少必填字段创建校验规则"

# Mapping Tests
Write-Host "`n--- Mapping Tests ---" -ForegroundColor Yellow
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-014" -TestName "获取科目映射" -Method "GET" -Endpoint "/data/mapping" -Headers $headers -ExpectedCode "200" -Description "获取科目映射列表"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-015" -TestName "按类别筛选科目映射" -Method "GET" -Endpoint "/data/mapping?category=资产类" -Headers $headers -ExpectedCode "200" -Description "按类别筛选科目映射"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-016" -TestName "创建科目映射" -Method "POST" -Endpoint "/data/mapping" -Headers $headers -Body @{k8Code="T001";k8Name="测试科目";targetCode="A001";targetName="目标科目";category="资产类"} -ExpectedCode "200" -Description "创建新科目映射"

Write-Host "`nData module completed: $($TestResults.Data.Count) tests" -ForegroundColor Green

# Save intermediate results
$TestResults | ConvertTo-Json -Depth 10 | Out-File "$OutputDir\intermediate-results.json" -Encoding UTF8

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "PHASE 1-2 COMPLETED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
