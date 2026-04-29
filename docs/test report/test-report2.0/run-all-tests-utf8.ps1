# FinSight API Production Test Script v2.0
# Tests all API endpoints with comprehensive scenarios
param(
    [string]$OutputDir = "c:\Users\yzyxt\Desktop\閲戣瀺璐㈠姟鍒嗘瀽骞冲彴\FinSight_backend\docs\test report\test-report2.0"
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

$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-001" -TestName "姝ｅ父鐧诲綍" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password="123456"} -ExpectedCode "200"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-002" -TestName "閿欒瀵嗙爜鐧诲綍" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password="wrongpass"} -ExpectedCode "400"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-003" -TestName "鐢ㄦ埛涓嶅瓨鍦? -Method "POST" -Endpoint "/auth/login" -Body @{username="nonexistent";password="123456"} -ExpectedCode "400"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-004" -TestName "绌虹敤鎴峰悕" -Method "POST" -Endpoint "/auth/login" -Body @{username="";password="123456"} -ExpectedCode "400"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-005" -TestName "绌哄瘑鐮? -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password=""} -ExpectedCode "400"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-006" -TestName "鏈夋晥Token鑾峰彇鐢ㄦ埛淇℃伅" -Method "GET" -Endpoint "/auth/user-info" -Headers $headers -ExpectedCode "200"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-007" -TestName "鏃燭oken鑾峰彇鐢ㄦ埛淇℃伅" -Method "GET" -Endpoint "/auth/user-info" -ExpectedCode "401"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-008" -TestName "鏃犳晥Token鑾峰彇鐢ㄦ埛淇℃伅" -Method "GET" -Endpoint "/auth/user-info" -Headers @{Authorization="Bearer invalid.token"} -ExpectedCode "401"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-009" -TestName "鏈夋晥Token鐧诲嚭" -Method "POST" -Endpoint "/auth/logout" -Headers $headers -ExpectedCode "200"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-010" -TestName "鏃燭oken鐧诲嚭" -Method "POST" -Endpoint "/auth/logout" -ExpectedCode "401"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-011" -TestName "閿欒鏃у瘑鐮佷慨鏀? -Method "PUT" -Endpoint "/auth/change-password" -Headers $headers -Body @{oldPassword="wrong";newPassword="new123"} -ExpectedCode "400"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-012" -TestName "鏃燭oken淇敼瀵嗙爜" -Method "PUT" -Endpoint "/auth/change-password" -Body @{oldPassword="123456";newPassword="new123"} -ExpectedCode "401"

foreach ($r in $TestResults.Auth) { Write-TestResult $r }

# ==================== DATA MODULE ====================
Write-Host "`n=================== DATA MODULE ===================" -ForegroundColor Magenta
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-001" -TestName "鑾峰彇ETL浠诲姟鍒楄〃" -Method "GET" -Endpoint "/data/etl/tasks" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-002" -TestName "ETL鐘舵€佺瓫閫? -Method "GET" -Endpoint "/data/etl/tasks?status=success" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-003" -TestName "鏃燭oken鑾峰彇ETL" -Method "GET" -Endpoint "/data/etl/tasks" -ExpectedCode "401"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-004" -TestName "鎵嬪姩瑙﹀彂ETL" -Method "POST" -Endpoint "/data/etl/trigger" -Headers $headers -Body @{taskId=1} -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-005" -TestName "绌簍askId瑙﹀彂ETL" -Method "POST" -Endpoint "/data/etl/trigger" -Headers $headers -Body @{} -ExpectedCode "400"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-006" -TestName "鑾峰彇ETL浠诲姟璇︽儏" -Method "GET" -Endpoint "/data/etl/tasks/1" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-007" -TestName "鑾峰彇瀵煎叆鍘嗗彶" -Method "GET" -Endpoint "/data/import/history" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-008" -TestName "瀵煎叆鍘嗗彶鍒嗛〉" -Method "GET" -Endpoint "/data/import/history?page=1&pageSize=10" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-009" -TestName "鑾峰彇瀵煎叆妯℃澘" -Method "GET" -Endpoint "/data/import/template?type=balance" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-010" -TestName "鑾峰彇鏍￠獙瑙勫垯" -Method "GET" -Endpoint "/data/validation/rules" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-011" -TestName "鍒涘缓鏍￠獙瑙勫垯" -Method "POST" -Endpoint "/data/validation/rules" -Headers $headers -Body @{name="娴嬭瘯瑙勫垯";expression="a > 0";level="error";message="娴嬭瘯";enabled=$true} -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-012" -TestName "鍒涘缓鏍￠獙瑙勫垯缂哄皯瀛楁" -Method "POST" -Endpoint "/data/validation/rules" -Headers $headers -Body @{name="娴嬭瘯瑙勫垯"} -ExpectedCode "400"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-013" -TestName "鑾峰彇绉戠洰鏄犲皠" -Method "GET" -Endpoint "/data/mapping" -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-014" -TestName "鎸夌被鍒瓫閫夌鐩槧灏? -Method "GET" -Endpoint "/data/mapping?category=璧勪骇绫? -Headers $headers -ExpectedCode "200"
$TestResults.Data += Test-API -Module "Data" -TestId "DATA-015" -TestName "鍒涘缓绉戠洰鏄犲皠" -Method "POST" -Endpoint "/data/mapping" -Headers $headers -Body @{k8Code="T001";k8Name="娴嬭瘯绉戠洰";targetCode="A001";targetName="鐩爣绉戠洰";category="璧勪骇绫?} -ExpectedCode "200"

foreach ($r in $TestResults.Data) { Write-TestResult $r }

# ==================== ALGORITHM MODULE ====================
Write-Host "`n=================== ALGORITHM MODULE ===================" -ForegroundColor Magenta
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-001" -TestName "鑾峰彇姣旂巼鍒嗘瀽缁撴灉" -Method "GET" -Endpoint "/algorithm/ratio/results" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-002" -TestName "鎸夋湡闂寸瓫閫夋瘮鐜? -Method "GET" -Endpoint "/algorithm/ratio/results?period=2026-Q1" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-003" -TestName "瑙﹀彂姣旂巼璁＄畻" -Method "POST" -Endpoint "/algorithm/ratio/calculate" -Headers $headers -Body @{period="2026-Q1"} -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-004" -TestName "璁＄畻缂哄皯period" -Method "POST" -Endpoint "/algorithm/ratio/calculate" -Headers $headers -Body @{} -ExpectedCode "400"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-005" -TestName "鑾峰彇姣旂巼鍒嗙被" -Method "GET" -Endpoint "/algorithm/ratio/categories" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-006" -TestName "鑾峰彇棰勮璁板綍" -Method "GET" -Endpoint "/algorithm/warning/records" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-007" -TestName "鎸夌骇鍒瓫閫夐璀? -Method "GET" -Endpoint "/algorithm/warning/records?level=yellow" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-008" -TestName "鑾峰彇棰勮姹囨€? -Method "GET" -Endpoint "/algorithm/warning/summary" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-009" -TestName "璁＄畻鎶曡祫璇勪及" -Method "POST" -Endpoint "/algorithm/investment/calculate" -Headers $headers -Body @{projectName="娴嬭瘯椤圭洰";initialInvestment=1000;discountRate=8;cashFlows=@(@{year=1;amount=200},@{year=2;amount=300})} -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-010" -TestName "鎶曡祫璁＄畻缂哄皯鍙傛暟" -Method "POST" -Endpoint "/algorithm/investment/calculate" -Headers $headers -Body @{projectName="娴嬭瘯"} -ExpectedCode "400"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-011" -TestName "鑾峰彇鎶曡祫鏂规鍒楄〃" -Method "GET" -Endpoint "/algorithm/investment/schemes" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-012" -TestName "鎹熺泭棰勬祴璁＄畻" -Method "POST" -Endpoint "/algorithm/forecast/profit" -Headers $headers -Body @{baseRevenue=2458.6;revenueGrowthRate=10;costRate=67.5;expenseRate=15;taxRate=25;periods=4} -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-013" -TestName "鑾峰彇瓒嬪娍鏁版嵁" -Method "GET" -Endpoint "/algorithm/trend/data?indicator=ROE" -Headers $headers -ExpectedCode "200"
$TestResults.Algorithm += Test-API -Module "Algorithm" -TestId "ALGO-014" -TestName "鑾峰彇鏉滈偊鍒嗘瀽" -Method "GET" -Endpoint "/algorithm/trend/dupont" -Headers $headers -ExpectedCode "200"

foreach ($r in $TestResults.Algorithm) { Write-TestResult $r }

# ==================== CONFIG MODULE ====================
Write-Host "`n=================== CONFIG MODULE ===================" -ForegroundColor Magenta
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-001" -TestName "鑾峰彇鍏紡鍒楄〃" -Method "GET" -Endpoint "/config/formula" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-002" -TestName "鍏紡鍒嗙被绛涢€? -Method "GET" -Endpoint "/config/formula?category=鍋垮€鸿兘鍔? -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-003" -TestName "鍏紡鍏抽敭璇嶆悳绱? -Method "GET" -Endpoint "/config/formula?keyword=娴佸姩姣旂巼" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-004" -TestName "鍒涘缓鍏紡" -Method "POST" -Endpoint "/config/formula" -Headers $headers -Body @{name="娴嬭瘯鍏紡";expression="a/b";category="娴嬭瘯";enabled=$true} -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-005" -TestName "楠岃瘉鍏紡琛ㄨ揪寮? -Method "POST" -Endpoint "/config/formula/validate" -Headers $headers -Body @{expression="娴佸姩璧勪骇/娴佸姩璐熷€?} -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-006" -TestName "鏃犳晥鍏紡楠岃瘉" -Method "POST" -Endpoint "/config/formula/validate" -Headers $headers -Body @{expression="a +"} -ExpectedCode "400"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-007" -TestName "鑾峰彇闃堝€煎垪琛? -Method "GET" -Endpoint "/config/threshold" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-008" -TestName "鍒涘缓闃堝€? -Method "POST" -Endpoint "/config/threshold" -Headers $headers -Body @{indicator="娴嬭瘯鎸囨爣";indicatorCode="T001";direction="lower";yellowValue="< 2.0";orangeValue="< 1.5";redValue="< 1.0"} -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-009" -TestName "鑾峰彇鍔ㄦ€佸熀鍑嗗缓璁? -Method "GET" -Endpoint "/config/threshold/dynamic-suggestion/R001" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-010" -TestName "鑾峰彇鐭ヨ瘑搴? -Method "GET" -Endpoint "/config/knowledge" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-011" -TestName "鐭ヨ瘑搴撴寚鏍囩瓫閫? -Method "GET" -Endpoint "/config/knowledge?indicator=娴佸姩姣旂巼" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-012" -TestName "鍒涘缓鐭ヨ瘑鏉＄洰" -Method "POST" -Endpoint "/config/knowledge" -Headers $headers -Body @{indicator="娴嬭瘯鎸囨爣";level="yellow";content="娴嬭瘯鍐呭";version="v1.0"} -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-013" -TestName "鑾峰彇鐗堟湰鍒楄〃" -Method "GET" -Endpoint "/config/version" -Headers $headers -ExpectedCode "200"
$TestResults.Config += Test-API -Module "Config" -TestId "CONFIG-014" -TestName "鐗堟湰妯″瀷绫诲瀷绛涢€? -Method "GET" -Endpoint "/config/version?modelType=ratio" -Headers $headers -ExpectedCode "200"

foreach ($r in $TestResults.Config) { Write-TestResult $r }

# ==================== REPORT MODULE ====================
Write-Host "`n=================== REPORT MODULE ===================" -ForegroundColor Magenta
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-001" -TestName "鑾峰彇浠〃鐩樻暟鎹? -Method "GET" -Endpoint "/report/dashboard" -Headers $headers -ExpectedCode "200"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-002" -TestName "鑾峰彇鍥捐〃鏁版嵁" -Method "GET" -Endpoint "/report/charts" -Headers $headers -ExpectedCode "200"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-003" -TestName "鍥捐〃鏈熼棿绛涢€? -Method "GET" -Endpoint "/report/charts?period=2026" -Headers $headers -ExpectedCode "200"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-004" -TestName "鐢熸垚PDF鎶ュ憡" -Method "POST" -Endpoint "/report/pdf/generate" -Headers $headers -Body @{name="娴嬭瘯鎶ュ憡";type="comprehensive";period="2026-Q1";includeWarning=$true;includeRatio=$true;includeTrend=$true;includeInvestment=$false} -ExpectedCode "200"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-005" -TestName "PDF鐢熸垚缂哄皯瀛楁" -Method "POST" -Endpoint "/report/pdf/generate" -Headers $headers -Body @{name="娴嬭瘯鎶ュ憡"} -ExpectedCode "400"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-006" -TestName "鑾峰彇PDF鍘嗗彶" -Method "GET" -Endpoint "/report/pdf/history" -Headers $headers -ExpectedCode "200"
$TestResults.Report += Test-API -Module "Report" -TestId "REPORT-007" -TestName "鑾峰彇琛屼笟瀵规爣鏁版嵁" -Method "GET" -Endpoint "/report/benchmark/data" -Headers $headers -ExpectedCode "200"

foreach ($r in $TestResults.Report) { Write-TestResult $r }

# ==================== SYSTEM MODULE ====================
Write-Host "`n=================== SYSTEM MODULE ===================" -ForegroundColor Magenta
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-001" -TestName "鑾峰彇鐢ㄦ埛鍒楄〃" -Method "GET" -Endpoint "/system/user" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-002" -TestName "鐢ㄦ埛鍏抽敭璇嶆悳绱? -Method "GET" -Endpoint "/system/user?keyword=admin" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-003" -TestName "鐢ㄦ埛鐘舵€佺瓫閫? -Method "GET" -Endpoint "/system/user?status=active" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-004" -TestName "鍒涘缓鐢ㄦ埛" -Method "POST" -Endpoint "/system/user" -Headers $headers -Body @{username="newuser";name="鏂扮敤鎴?;password="123456";department="娴嬭瘯閮?;roleId=1;status="active"} -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-005" -TestName "鍒涘缓鐢ㄦ埛缂哄皯瀛楁" -Method "POST" -Endpoint "/system/user" -Headers $headers -Body @{username="newuser"} -ExpectedCode "400"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-006" -TestName "鑾峰彇瑙掕壊鍒楄〃" -Method "GET" -Endpoint "/system/role" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-007" -TestName "鍒涘缓瑙掕壊" -Method "POST" -Endpoint "/system/role" -Headers $headers -Body @{name="鏂拌鑹?;code="NEW_ROLE";description="娴嬭瘯瑙掕壊"} -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-008" -TestName "鑾峰彇鏉冮檺鏍? -Method "GET" -Endpoint "/system/permission/tree" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-009" -TestName "鑾峰彇瀹¤鏃ュ織" -Method "GET" -Endpoint "/system/audit-log" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-010" -TestName "瀹¤鏃ュ織鍒嗛〉" -Method "GET" -Endpoint "/system/audit-log?page=1&pageSize=20" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-011" -TestName "鑾峰彇ETL鐩戞帶" -Method "GET" -Endpoint "/system/etl-monitor" -Headers $headers -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-012" -TestName "鎵嬪姩瑙﹀彂ETL鐩戞帶" -Method "POST" -Endpoint "/system/etl-monitor/trigger" -Headers $headers -Body @{} -ExpectedCode "200"
$TestResults.System += Test-API -Module "System" -TestId "SYSTEM-013" -TestName "鑾峰彇绯荤粺鍙傛暟" -Method "GET" -Endpoint "/system/params" -Headers $headers -ExpectedCode "200"

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
