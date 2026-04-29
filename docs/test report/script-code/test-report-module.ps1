# FinSight Report Module API Test Script
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
Write-Host "FinSight Report Module API Tests" -ForegroundColor Cyan
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

# Task 51: GET /report/dashboard
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 51: GET /report/dashboard" -ForegroundColor Cyan

Test-Endpoint -TaskId "51" -SubTaskId "51.1" -TestName "Get dashboard data" -Method "GET" -Endpoint "/report/dashboard"

# Task 52: GET /report/charts
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 52: GET /report/charts" -ForegroundColor Cyan

Test-Endpoint -TaskId "52" -SubTaskId "52.1" -TestName "Get charts data" -Method "GET" -Endpoint "/report/charts"
Test-Endpoint -TaskId "52" -SubTaskId "52.2" -TestName "Get charts data with period" -Method "GET" -Endpoint "/report/charts?period=monthly"
Test-Endpoint -TaskId "52" -SubTaskId "52.3" -TestName "Get charts data with type" -Method "GET" -Endpoint "/report/charts?chartType=trend"

# Task 53: POST /report/pdf/generate
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 53: POST /report/pdf/generate" -ForegroundColor Cyan

Test-Endpoint -TaskId "53" -SubTaskId "53.1" -TestName "Generate PDF report" -Method "POST" -Endpoint "/report/pdf/generate" -RequestBody '{"name":"Test Report","type":"financial","period":"2024-01","includeWarning":true,"includeRatio":true,"includeTrend":true,"includeInvestment":true}'

# Task 54: GET /report/pdf/history
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 54: GET /report/pdf/history" -ForegroundColor Cyan

Test-Endpoint -TaskId "54" -SubTaskId "54.1" -TestName "Get PDF history" -Method "GET" -Endpoint "/report/pdf/history"

# Task 55: GET /report/benchmark/data
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 55: GET /report/benchmark/data" -ForegroundColor Cyan

Test-Endpoint -TaskId "55" -SubTaskId "55.1" -TestName "Get benchmark data" -Method "GET" -Endpoint "/report/benchmark/data"
Test-Endpoint -TaskId "55" -SubTaskId "55.2" -TestName "Get benchmark data with period" -Method "GET" -Endpoint "/report/benchmark/data?period=2024-01"
Test-Endpoint -TaskId "55" -SubTaskId "55.3" -TestName "Get benchmark data with industry" -Method "GET" -Endpoint "/report/benchmark/data?industry=finance"

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

$testResults | ConvertTo-Json -Depth 10 | Out-File -FilePath "test-report-results.json" -Encoding utf8
Write-Host "`nTest results saved to: test-report-results.json"

$testResults | Format-Table -Property TaskId, SubTaskId, TestName, ExpectedStatus, ActualStatus, Passed