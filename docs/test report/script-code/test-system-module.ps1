# FinSight System Module API Test Script
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
Write-Host "FinSight System Module API Tests" -ForegroundColor Cyan
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

# Task 56: GET /system/user
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 56: GET /system/user" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 56.1] Get all users" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/user" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "56" -SubTaskId "56.1" -TestName "Get all users" -Method "GET" -Endpoint "/system/user" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

Write-Host "`n[SubTask 56.2] Search users by keyword" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/user?keyword=admin" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "56" -SubTaskId "56.2" -TestName "Search users by keyword" -Method "GET" -Endpoint "/system/user?keyword=admin" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

Write-Host "`n[SubTask 56.3] Filter users by role" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/user?roleId=1" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "56" -SubTaskId "56.3" -TestName "Filter users by role" -Method "GET" -Endpoint "/system/user?roleId=1" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 57: POST /system/user
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 57: POST /system/user" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 57.1] Create user" -ForegroundColor Yellow
$body = '{"username":"testuser_new","name":"Test User","password":"123456","department":"Finance","roleId":1,"status":"active"}'
$result = Send-Request -Uri "$baseUrl/system/user" -Method POST -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "57" -SubTaskId "57.1" -TestName "Create user" -Method "POST" -Endpoint "/system/user" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 58: PUT /system/user/:id
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 58: PUT /system/user/:id" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 58.1] Update user" -ForegroundColor Yellow
$body = '{"username":"testuser_new","name":"Test User Updated","department":"Finance","roleId":1,"status":"active"}'
$result = Send-Request -Uri "$baseUrl/system/user/2" -Method PUT -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "58" -SubTaskId "58.1" -TestName "Update user" -Method "PUT" -Endpoint "/system/user/2" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 59: DELETE /system/user/:id
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 59: DELETE /system/user/:id" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 59.1] Delete user" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/user/2" -Method DELETE -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "59" -SubTaskId "59.1" -TestName "Delete user" -Method "DELETE" -Endpoint "/system/user/2" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 60: PUT /system/user/:id/reset-password
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 60: PUT /system/user/:id/reset-password" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 60.1] Reset password" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/user/1/reset-password" -Method PUT -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "60" -SubTaskId "60.1" -TestName "Reset password" -Method "PUT" -Endpoint "/system/user/1/reset-password" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 61: GET /system/role
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 61: GET /system/role" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 61.1] Get roles" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/role" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "61" -SubTaskId "61.1" -TestName "Get roles" -Method "GET" -Endpoint "/system/role" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 62: POST /system/role
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 62: POST /system/role" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 62.1] Create role" -ForegroundColor Yellow
$body = '{"name":"Test Role","code":"TEST","description":"Test role desc","permissions":["data:etl"]}'
$result = Send-Request -Uri "$baseUrl/system/role" -Method POST -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "62" -SubTaskId "62.1" -TestName "Create role" -Method "POST" -Endpoint "/system/role" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 63: PUT /system/role/:id
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 63: PUT /system/role/:id" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 63.1] Update role" -ForegroundColor Yellow
$body = '{"name":"Test Role Updated","code":"TEST","description":"Updated desc","permissions":["data:etl","data:import"]}'
$result = Send-Request -Uri "$baseUrl/system/role/2" -Method PUT -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "63" -SubTaskId "63.1" -TestName "Update role" -Method "PUT" -Endpoint "/system/role/2" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 64: DELETE /system/role/:id
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 64: DELETE /system/role/:id" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 64.1] Delete role" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/role/2" -Method DELETE -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "64" -SubTaskId "64.1" -TestName "Delete role" -Method "DELETE" -Endpoint "/system/role/2" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 65: GET /system/permission/tree
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 65: GET /system/permission/tree" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 65.1] Get permission tree" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/permission/tree" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "65" -SubTaskId "65.1" -TestName "Get permission tree" -Method "GET" -Endpoint "/system/permission/tree" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 66: GET /system/audit-log
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 66: GET /system/audit-log" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 66.1] Get audit logs" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/audit-log" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "66" -SubTaskId "66.1" -TestName "Get audit logs" -Method "GET" -Endpoint "/system/audit-log" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 68: GET /system/etl-monitor
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 68: GET /system/etl-monitor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 68.1] Get ETL monitor data" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/etl-monitor" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "68" -SubTaskId "68.1" -TestName "Get ETL monitor data" -Method "GET" -Endpoint "/system/etl-monitor" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 69: POST /system/etl-monitor/trigger
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 69: POST /system/etl-monitor/trigger" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 69.1] Trigger ETL" -ForegroundColor Yellow
$body = '{"taskId":1}'
$result = Send-Request -Uri "$baseUrl/system/etl-monitor/trigger" -Method POST -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "69" -SubTaskId "69.1" -TestName "Trigger ETL" -Method "POST" -Endpoint "/system/etl-monitor/trigger" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 70: PUT /system/etl-monitor/:id/stop
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 70: PUT /system/etl-monitor/:id/stop" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 70.1] Stop ETL task" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/etl-monitor/1/stop" -Method PUT -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "70" -SubTaskId "70.1" -TestName "Stop ETL task" -Method "PUT" -Endpoint "/system/etl-monitor/1/stop" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 71: GET /system/params
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 71: GET /system/params" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 71.1] Get system params" -ForegroundColor Yellow
$result = Send-Request -Uri "$baseUrl/system/params" -Method GET -Token $token
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "71" -SubTaskId "71.1" -TestName "Get system params" -Method "GET" -Endpoint "/system/params" -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Task 72: PUT /system/params
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Task 72: PUT /system/params" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[SubTask 72.1] Update system params" -ForegroundColor Yellow
$body = '{"general":[{"id":1,"key":"system.name","value":"FinSight Test","description":"System Name","editable":true}]}'
$result = Send-Request -Uri "$baseUrl/system/params" -Method PUT -Token $token -Body $body
$responseBody = $result.Body | ConvertTo-Json -Depth 10 -Compress
$passed = ($result.Status -eq 200 -and $result.Body.code -eq 200)
Add-TestResult -TaskId "72" -SubTaskId "72.1" -TestName "Update system params" -Method "PUT" -Endpoint "/system/params" -RequestBody $body -ExpectedStatus 200 -ActualStatus $result.Status -ResponseBody $responseBody -Passed $passed
Write-Host "Result: $(if($passed){'PASS'}else{'FAIL'})" -ForegroundColor $(if($passed){'Green'}else{'Red'})

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Results Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$totalTests = $testResults.Count
$passedTests = ($testResults | Where-Object { $_.Passed -eq $true }).Count
$failedTests = $totalTests - $passedTests
$passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "`nTotal Tests: $totalTests"
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if($passRate -ge 80){'Green'}else{'Yellow'})

$testResults | ConvertTo-Json -Depth 10 | Out-File -FilePath "test-system-results.json" -Encoding utf8
Write-Host "`nTest results saved to: test-system-results.json"

$testResults