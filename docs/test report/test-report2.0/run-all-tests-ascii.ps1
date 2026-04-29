# FinSight API Production Test Script v2.0 (ASCII Version)
# Tests all API endpoints with comprehensive scenarios
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
            Write-Host "Token obtained successfully" -ForegroundColor Green
            return $true
        }
        Write-Host "Login failed, code: $($response.code), message: $($response.message)" -ForegroundColor Red
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
    Write-Host "[$($result.TestId)] $($result.TestName): $status (Exp: $($result.ExpectedCode), Act: $($result.ActualCode), $($result.ResponseTime)ms)" -ForegroundColor $color
}

# ==================== GET TOKEN ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "FinSight API Production Test v2.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (-not (Get-TestToken)) {
    Write-Host "Failed to get test token!" -ForegroundColor Red
    exit 1
}

# ==================== AUTH MODULE ====================
Write-Host "`n=================== AUTH MODULE ===================" -ForegroundColor Magenta
$headers = @{Authorization="Bearer $Global:Token"}

$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-001" -TestName "Normal Login" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password="123456"} -ExpectedCode "200"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-002" -TestName "Wrong Password" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password="wrongpass"} -ExpectedCode "400"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-003" -TestName "User Not Found" -Method "POST" -Endpoint "/auth/login" -Body @{username="nonexistent";password="123456"} -ExpectedCode "400"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-004" -TestName "Empty Username" -Method "POST" -Endpoint "/auth/login" -Body @{username="";password="123456"} -ExpectedCode "400"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-005" -TestName "Empty Password" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password=""} -ExpectedCode "400"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-006" -TestName "Get UserInfo with Token" -Method "GET" -Endpoint "/auth/user-info" -Headers $headers -ExpectedCode "200"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-007" -TestName "Get UserInfo without Token" -Method "GET" -Endpoint "/auth/user-info" -ExpectedCode "401"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-008" -TestName "Get UserInfo with Invalid Token" -Method "GET" -Endpoint "/auth/user-info" -Headers @{Authorization="Bearer invalid.token"} -ExpectedCode "401"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-009" -TestName "Logout with Token" -Method "POST" -Endpoint "/auth/logout" -Headers $headers -ExpectedCode "200"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-010" -TestName "Logout without Token" -Method "POST" -Endpoint "/auth/logout" -ExpectedCode "401"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-011" -TestName "Change Password Wrong Old" -Method "PUT" -Endpoint "/auth/change-password" -Headers $headers -Body @{oldPassword="wrong";newPassword="new123"} -ExpectedCode "400"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-012" -TestName "Change Password without Token" -Method "PUT" -Endpoint "/auth/change-password" -Body @{oldPassword="123456";newPassword="new123"} -ExpectedCode "401"

foreach ($r in $TestResults.Auth) { Write-TestResult $r }

# ==================== DATA MODULE ====================
Write-Host "`n=================== DATA MODULE ===================" -ForegroundColor Magenta
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-001" -TestName "Get ETL Task List" -Method "GET" -Endpoint "/data/etl/tasks" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-002" -TestName "ETL Status Filter" -Method "GET" -Endpoint "/data/etl/tasks?status=success" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-003" -TestName "Get ETL without Token" -Method "GET" -Endpoint "/data/etl/tasks" -ExpectedCode "401"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-004" -TestName "Manual Trigger ETL" -Method "POST" -Endpoint "/data/etl/trigger" -Headers $headers -Body @{taskId=1} -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-005" -TestName "Trigger ETL Empty taskId" -Method "POST" -Endpoint "/data/etl/trigger" -Headers $headers -Body @{} -ExpectedCode "400"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-006" -TestName "Get ETL Task Detail" -Method "GET" -Endpoint "/data/etl/tasks/1" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-007" -TestName "Get Import History" -Method "GET" -Endpoint "/data/import/history" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-008" -TestName "Import History Pagination" -Method "GET" -Endpoint "/data/import/history?page=1&pageSize=10" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-009" -TestName "Get Import Template" -Method "GET" -Endpoint "/data/import/template?type=balance" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-010" -TestName "Get Validation Rules" -Method "GET" -Endpoint "/data/validation/rules" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-011" -TestName "Create Validation Rule" -Method "POST" -Endpoint "/data/validation/rules" -Headers $headers -Body @{name="Test Rule";expression="a > 0";level="error";message="Test";enabled=$true} -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-012" -TestName "Create Validation Rule Missing Fields" -Method "POST" -Endpoint "/data/validation/rules" -Headers $headers -Body @{name="Test Rule"} -ExpectedCode "400"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-013" -TestName "Get Account Mapping" -Method "GET" -Endpoint "/data/mapping" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-014" -TestName "Filter Account Mapping by Category" -Method "GET" -Endpoint "/data/mapping?category=Asset" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-015" -TestName "Create Account Mapping" -Method "POST" -Endpoint "/data/mapping" -Headers $headers -Body @{k8Code="T001";k8Name="Test Account";targetCode="A001";targetName="Target Account";category="Asset"} -ExpectedCode "200"

foreach ($r in $TestResults.Data) { Write-TestResult $r }

# ==================== ALGORITHM MODULE ====================
Write-Host "`n=================== ALGORITHM MODULE ===================" -ForegroundColor Magenta
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-001" -TestName "Get Ratio Analysis Results" -Method "GET" -Endpoint "/algorithm/ratio/results" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-002" -TestName "Filter Ratio by Period" -Method "GET" -Endpoint "/algorithm/ratio/results?period=2026-Q1" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-003" -TestName "Trigger Ratio Calculation" -Method "POST" -Endpoint "/algorithm/ratio/calculate" -Headers $headers -Body @{period="2026-Q1"} -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-004" -TestName "Calculation Missing period" -Method "POST" -Endpoint "/algorithm/ratio/calculate" -Headers $headers -Body @{} -ExpectedCode "400"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-005" -TestName "Get Ratio Categories" -Method "GET" -Endpoint "/algorithm/ratio/categories" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-006" -TestName "Get Warning Records" -Method "GET" -Endpoint "/algorithm/warning/records" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-007" -TestName "Filter Warning by Level" -Method "GET" -Endpoint "/algorithm/warning/records?level=yellow" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-008" -TestName "Get Warning Summary" -Method "GET" -Endpoint "/algorithm/warning/summary" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-009" -TestName "Calculate Investment Assessment" -Method "POST" -Endpoint "/algorithm/investment/calculate" -Headers $headers -Body @{projectName="Test Project";initialInvestment=1000;discountRate=8;cashFlows=@(@{year=1;amount=200},@{year=2;amount=300})} -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-010" -TestName "Investment Calculation Missing Params" -Method "POST" -Endpoint "/algorithm/investment/calculate" -Headers $headers -Body @{projectName="Test"} -ExpectedCode "400"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-011" -TestName "Get Investment Schemes" -Method "GET" -Endpoint "/algorithm/investment/schemes" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-012" -TestName "Profit Forecast Calculation" -Method "POST" -Endpoint "/algorithm/forecast/profit" -Headers $headers -Body @{baseRevenue=2458.6;revenueGrowthRate=10;costRate=67.5;expenseRate=15;taxRate=25;periods=4} -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-013" -TestName "Get Trend Data" -Method "GET" -Endpoint "/algorithm/trend/data?indicator=ROE" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-014" -TestName "Get Dupont Analysis" -Method "GET" -Endpoint "/algorithm/trend/dupont" -Headers $headers -ExpectedCode "200"

foreach ($r in $TestResults.Algorithm) { Write-TestResult $r }

# ==================== CONFIG MODULE ====================
Write-Host "`n=================== CONFIG MODULE ===================" -ForegroundColor Magenta
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-001" -TestName "Get Formula List" -Method "GET" -Endpoint "/config/formula" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-002" -TestName "Formula Category Filter" -Method "GET" -Endpoint "/config/formula?category=Solvency" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-003" -TestName "Formula Keyword Search" -Method "GET" -Endpoint "/config/formula?keyword=CurrentRatio" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-004" -TestName "Create Formula" -Method "POST" -Endpoint "/config/formula" -Headers $headers -Body @{name="Test Formula";expression="a/b";category="Test";enabled=$true} -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-005" -TestName "Validate Formula Expression" -Method "POST" -Endpoint "/config/formula/validate" -Headers $headers -Body @{expression="CurrentAssets/CurrentLiabilities"} -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-006" -TestName "Invalid Formula Validation" -Method "POST" -Endpoint "/config/formula/validate" -Headers $headers -Body @{expression="a +"} -ExpectedCode "400"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-007" -TestName "Get Threshold List" -Method "GET" -Endpoint "/config/threshold" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-008" -TestName "Create Threshold" -Method "POST" -Endpoint "/config/threshold" -Headers $headers -Body @{indicator="Test Indicator";indicatorCode="T001";direction="lower";yellowValue="< 2.0";orangeValue="< 1.5";redValue="< 1.0"} -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-009" -TestName "Get Dynamic Baseline Suggestion" -Method "GET" -Endpoint "/config/threshold/dynamic-suggestion/R001" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-010" -TestName "Get Knowledge Base" -Method "GET" -Endpoint "/config/knowledge" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-011" -TestName "Knowledge Base Indicator Filter" -Method "GET" -Endpoint "/config/knowledge?indicator=CurrentRatio" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-012" -TestName "Create Knowledge Entry" -Method "POST" -Endpoint "/config/knowledge" -Headers $headers -Body @{indicator="Test Indicator";level="yellow";content="Test Content";version="v1.0"} -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-013" -TestName "Get Version List" -Method "GET" -Endpoint "/config/version" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-014" -TestName "Version Model Type Filter" -Method "GET" -Endpoint "/config/version?modelType=ratio" -Headers $headers -ExpectedCode "200"

foreach ($r in $TestResults.Config) { Write-TestResult $r }

# ==================== REPORT MODULE ====================
Write-Host "`n=================== REPORT MODULE ===================" -ForegroundColor Magenta
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-001" -TestName "Get Dashboard Data" -Method "GET" -Endpoint "/report/dashboard" -Headers $headers -ExpectedCode "200"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-002" -TestName "Get Chart Data" -Method "GET" -Endpoint "/report/charts" -Headers $headers -ExpectedCode "200"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-003" -TestName "Chart Period Filter" -Method "GET" -Endpoint "/report/charts?period=2026" -Headers $headers -ExpectedCode "200"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-004" -TestName "Generate PDF Report" -Method "POST" -Endpoint "/report/pdf/generate" -Headers $headers -Body @{name="Test Report";type="comprehensive";period="2026-Q1";includeWarning=$true;includeRatio=$true;includeTrend=$true;includeInvestment=$false} -ExpectedCode "200"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-005" -TestName "PDF Generation Missing Fields" -Method "POST" -Endpoint "/report/pdf/generate" -Headers $headers -Body @{name="Test Report"} -ExpectedCode "400"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-006" -TestName "Get PDF History" -Method "GET" -Endpoint "/report/pdf/history" -Headers $headers -ExpectedCode "200"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-007" -TestName "Get Industry Benchmark Data" -Method "GET" -Endpoint "/report/benchmark/data" -Headers $headers -ExpectedCode "200"

foreach ($r in $TestResults.Report) { Write-TestResult $r }

# ==================== SYSTEM MODULE ====================
Write-Host "`n=================== SYSTEM MODULE ===================" -ForegroundColor Magenta
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-001" -TestName "Get User List" -Method "GET" -Endpoint "/system/user" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-002" -TestName "User Keyword Search" -Method "GET" -Endpoint "/system/user?keyword=admin" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-003" -TestName "User Status Filter" -Method "GET" -Endpoint "/system/user?status=active" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-004" -TestName "Create User" -Method "POST" -Endpoint "/system/user" -Headers $headers -Body @{username="newuser";name="New User";password="123456";department="Test Dept";roleId=1;status="active"} -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-005" -TestName "Create User Missing Fields" -Method "POST" -Endpoint "/system/user" -Headers $headers -Body @{username="newuser"} -ExpectedCode "400"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-006" -TestName "Get Role List" -Method "GET" -Endpoint "/system/role" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-007" -TestName "Create Role" -Method "POST" -Endpoint "/system/role" -Headers $headers -Body @{name="New Role";code="NEW_ROLE";description="Test Role"} -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-008" -TestName "Get Permission Tree" -Method "GET" -Endpoint "/system/permission/tree" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-009" -TestName "Get Audit Log" -Method "GET" -Endpoint "/system/audit-log" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-010" -TestName "Audit Log Pagination" -Method "GET" -Endpoint "/system/audit-log?page=1&pageSize=20" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-011" -TestName "Get ETL Monitor" -Method "GET" -Endpoint "/system/etl-monitor" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-012" -TestName "Manual Trigger ETL Monitor" -Method "POST" -Endpoint "/system/etl-monitor/trigger" -Headers $headers -Body @{} -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-013" -TestName "Get System Params" -Method "GET" -Endpoint "/system/params" -Headers $headers -ExpectedCode "200"

foreach ($r in $TestResults.System) { Write-TestResult $r }

# ==================== SUMMARY ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$totalTests = 0
$totalPassed = 0

foreach ($module in $TestResults.Keys) {
    $passed = ($TestResults[$module] | Where-Object { $_.Passed }).Count
    $total = $TestResults[$module].Count
    $totalTests += $total
    $totalPassed += $passed
    $rate = if ($total -gt 0) { [math]::Round(($passed / $total) * 100, 2) } else { 0 }
    $color = if ($rate -ge 80) { "Green" } elseif ($rate -ge 60) { "Yellow" } else { "Red" }
    Write-Host "$module : $passed/$total ($rate%)" -ForegroundColor $color
}

$overallRate = if ($totalTests -gt 0) { [math]::Round(($totalPassed / $totalTests) * 100, 2) } else { 0 }
Write-Host "`nOverall: $totalPassed/$totalTests ($overallRate%)" -ForegroundColor $(if ($overallRate -ge 80) { "Green" } elseif ($overallRate -ge 60) { "Yellow" } else { "Red" })

# Save results to JSON
$TestResults | ConvertTo-Json -Depth 10 | Out-File "$OutputDir\test-results.json" -Encoding UTF8
Write-Host "`nResults saved to $OutputDir\test-results.json" -ForegroundColor Green