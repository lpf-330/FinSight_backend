# FinSight Configuration Module API Test Script
$baseUrl = "http://localhost:8080/api"
$testResults = @()

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
    
    $result = [PSCustomObject]@{
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
    $script:testResults += $result
}

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

function Test-Endpoint {
    param(
        [string]$TaskId,
        [string]$SubTaskId,
        [string]$TestName,
        [string]$Method,
        [string]$Endpoint,
        [string]$RequestBody = "",
        [int]$ExpectedStatus = 200
    )
    
    Write-Host "`n[SubTask $SubTaskId] $TestName" -ForegroundColor Yellow
    
    if ($RequestBody) {
        $result = Send-Request -Uri "$baseUrl$Endpoint" -Method $Method -Token $token -Body $RequestBody
    } else {
        $result = Send-Request -Uri "$baseUrl$Endpoint" -Method $Method -Token $token
    }
    
    $passed = ($result.Status -eq $ExpectedStatus)
    
    $responseStr = ""
    if ($result.Body) {
        $responseStr = $result.Body | ConvertTo-Json -Compress
    }
    
    Add-TestResult -TaskId $TaskId -SubTaskId $SubTaskId -TestName $TestName -Method $Method -Endpoint $Endpoint -RequestBody $RequestBody -ExpectedStatus $ExpectedStatus -ActualStatus $result.Status -ResponseBody $responseStr -Passed $passed
    
    if ($passed) {
        Write-Host "Result: PASS" -ForegroundColor Green
    } else {
        Write-Host "Result: FAIL" -ForegroundColor Red
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FinSight Configuration Module API Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[Login to get Token]" -ForegroundColor Yellow
$loginBody = '{"username":"testuser","password":"123456"}'
$loginResult = Send-Request -Uri "http://localhost:8080/auth/login" -Method POST -Body $loginBody
if ($loginResult.Body -and $loginResult.Body.data.token) {
    $token = $loginResult.Body.data.token
    Write-Host "Login successful, Token obtained" -ForegroundColor Green
} else {
    Write-Host "Login failed, cannot continue testing" -ForegroundColor Red
    exit 1
}

# Task 33: GET /config/formula
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 33: GET /config/formula" -ForegroundColor Cyan

Test-Endpoint -TaskId "33" -SubTaskId "33.1" -TestName "Get all formulas" -Method "GET" -Endpoint "/config/formula"
Test-Endpoint -TaskId "33" -SubTaskId "33.2" -TestName "Get formulas by category" -Method "GET" -Endpoint "/config/formula?category=ratio"

# Task 34: POST /config/formula
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 34: POST /config/formula" -ForegroundColor Cyan

Test-Endpoint -TaskId "34" -SubTaskId "34.1" -TestName "Create formula" -Method "POST" -Endpoint "/config/formula" -RequestBody '{"name":"Test Formula","code":"TEST001","expression":"(a+b)/c","category":"ratio","description":"Test formula"}'

# Task 35: PUT /config/formula/:id
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 35: PUT /config/formula/:id" -ForegroundColor Cyan

Test-Endpoint -TaskId "35" -SubTaskId "35.1" -TestName "Update formula" -Method "PUT" -Endpoint "/config/formula/1" -RequestBody '{"name":"Updated Formula","code":"TEST001","expression":"(a+b+c)/d","category":"ratio","description":"Updated"}'

# Task 36: DELETE /config/formula/:id
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 36: DELETE /config/formula/:id" -ForegroundColor Cyan

Test-Endpoint -TaskId "36" -SubTaskId "36.1" -TestName "Delete formula" -Method "DELETE" -Endpoint "/config/formula/1"

# Task 37: POST /config/formula/validate
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 37: POST /config/formula/validate" -ForegroundColor Cyan

Test-Endpoint -TaskId "37" -SubTaskId "37.1" -TestName "Validate formula expression" -Method "POST" -Endpoint "/config/formula/validate" -RequestBody '{"expression":"(a+b)/c"}'

# Task 38: GET /config/threshold
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 38: GET /config/threshold" -ForegroundColor Cyan

Test-Endpoint -TaskId "38" -SubTaskId "38.1" -TestName "Get thresholds" -Method "GET" -Endpoint "/config/threshold"

# Task 39: POST /config/threshold
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 39: POST /config/threshold" -ForegroundColor Cyan

Test-Endpoint -TaskId "39" -SubTaskId "39.1" -TestName "Create threshold" -Method "POST" -Endpoint "/config/threshold" -RequestBody '{"indicatorCode":"ratio_current","name":"Current Ratio","lowThreshold":1.0,"highThreshold":3.0,"warningLevel":"medium"}'

# Task 40: PUT /config/threshold/:id
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 40: PUT /config/threshold/:id" -ForegroundColor Cyan

Test-Endpoint -TaskId "40" -SubTaskId "40.1" -TestName "Update threshold" -Method "PUT" -Endpoint "/config/threshold/1" -RequestBody '{"indicatorCode":"ratio_current","name":"Current Ratio Updated","lowThreshold":1.2,"highThreshold":2.8,"warningLevel":"high"}'

# Task 41: GET /config/threshold/dynamic-suggestion
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 41: GET /config/threshold/dynamic-suggestion" -ForegroundColor Cyan

Test-Endpoint -TaskId "41" -SubTaskId "41.1" -TestName "Get dynamic suggestion" -Method "GET" -Endpoint "/config/threshold/dynamic-suggestion/ratio_current"

# Task 42: GET /config/knowledge
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 42: GET /config/knowledge" -ForegroundColor Cyan

Test-Endpoint -TaskId "42" -SubTaskId "42.1" -TestName "Get knowledge list" -Method "GET" -Endpoint "/config/knowledge"

# Task 43: POST /config/knowledge
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 43: POST /config/knowledge" -ForegroundColor Cyan

Test-Endpoint -TaskId "43" -SubTaskId "43.1" -TestName "Create knowledge" -Method "POST" -Endpoint "/config/knowledge" -RequestBody '{"indicatorCode":"ratio_current","title":"Current Ratio Guide","content":"Guide content","level":"medium","suggestion":"Improve current ratio"}'

# Task 44: PUT /config/knowledge/:id
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 44: PUT /config/knowledge/:id" -ForegroundColor Cyan

Test-Endpoint -TaskId "44" -SubTaskId "44.1" -TestName "Update knowledge" -Method "PUT" -Endpoint "/config/knowledge/1" -RequestBody '{"indicatorCode":"ratio_current","title":"Updated Guide","content":"Updated content","level":"high","suggestion":"Updated suggestion"}'

# Task 45: DELETE /config/knowledge/:id
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 45: DELETE /config/knowledge/:id" -ForegroundColor Cyan

Test-Endpoint -TaskId "45" -SubTaskId "45.1" -TestName "Delete knowledge" -Method "DELETE" -Endpoint "/config/knowledge/1"

# Task 46: GET /config/knowledge/export
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 46: GET /config/knowledge/export" -ForegroundColor Cyan

Test-Endpoint -TaskId "46" -SubTaskId "46.1" -TestName "Export knowledge" -Method "GET" -Endpoint "/config/knowledge/export"

# Task 47: POST /config/knowledge/import
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 47: POST /config/knowledge/import" -ForegroundColor Cyan

Test-Endpoint -TaskId "47" -SubTaskId "47.1" -TestName "Import knowledge" -Method "POST" -Endpoint "/config/knowledge/import" -RequestBody '{"knowledgeList":[{"indicatorCode":"ratio_test","title":"Test Import","content":"Test content","level":"low","suggestion":"Test suggestion"}]}'

# Task 48: GET /config/version
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 48: GET /config/version" -ForegroundColor Cyan

Test-Endpoint -TaskId "48" -SubTaskId "48.1" -TestName "Get versions" -Method "GET" -Endpoint "/config/version"

# Task 49: POST /config/version/simulate
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 49: POST /config/version/simulate" -ForegroundColor Cyan

Test-Endpoint -TaskId "49" -SubTaskId "49.1" -TestName "Simulate version" -Method "POST" -Endpoint "/config/version/simulate" -RequestBody '{"versionId":1,"modelType":"warning"}'

# Task 50: PUT /config/version/switch
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 50: PUT /config/version/switch" -ForegroundColor Cyan

Test-Endpoint -TaskId "50" -SubTaskId "50.1" -TestName "Switch version" -Method "PUT" -Endpoint "/config/version/switch" -RequestBody '{"versionId":1,"modelType":"warning"}'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Results Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$total = $testResults.Count
$passedCount = ($testResults | Where-Object { $_.Passed }).Count
$failedCount = $total - $passedCount
$passRate = [math]::Round(($passedCount / $total) * 100, 2)

Write-Host "`nTotal Tests: $total"
Write-Host "Passed: $passedCount"
Write-Host "Failed: $failedCount"
Write-Host "Pass Rate: $passRate%"

$testResults | ConvertTo-Json -Depth 10 | Out-File -FilePath "test-config-results.json" -Encoding utf8
Write-Host "`nTest results saved to: test-config-results.json"

$testResults | Format-Table -Property TaskId, SubTaskId, TestName, ExpectedStatus, ActualStatus, Passed