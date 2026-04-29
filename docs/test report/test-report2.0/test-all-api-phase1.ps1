# FinSight Comprehensive API Test Script v2.0
# This script tests all API endpoints with 3-5 different scenarios each
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
$Global:BaseUrl = "http://localhost:8080/api"

function Get-TestToken {
    try {
        $response = Invoke-RestMethod -Uri "$Global:BaseUrl/auth/login" -Method POST -ContentType "application/json; charset=utf-8" -Body '{"username":"testuser","password":"123456"}'
        if ($response.code -eq 200) {
            $Global:Token = $response.data.token
            return $true
        }
    } catch {}
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
        }

        if ($Headers.Count -gt 0) {
            $params.Headers = $Headers
        } else {
            $params.Headers = @{}
        }

        if ($Body -ne $null) {
            $params.Body = $Body | ConvertTo-Json -Compress
        }

        $response = Invoke-RestMethod @params
        $endTime = Get-Date
        $result.ActualCode = $response.code
        $result.ResponseTime = [math]::Round(($endTime - $startTime).TotalMilliseconds, 2)

        if ($ExpectedCode -eq "200" -and $response.code -eq 200) {
            $result.Passed = $true
        } elseif ($ExpectedCode -eq "400" -and $response.code -eq 400) {
            $result.Passed = $true
        } elseif ($ExpectedCode -eq "401" -and $response.code -eq 401) {
            $result.Passed = $true
        } elseif ($ExpectedCode -eq "404" -and $response.code -eq 404) {
            $result.Passed = $true
        } elseif ($ExpectedCode -eq "500" -and $response.code -eq 500) {
            $result.Passed = $true
        }

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

# ==================== PHASE 1: AUTH MODULE ====================
Write-Host "`n=================== PHASE 1: AUTH MODULE TESTS ===================" -ForegroundColor Cyan

if (-not (Get-TestToken)) {
    Write-Host "Failed to get test token!" -ForegroundColor Red
    exit 1
}
Write-Host "Token obtained successfully" -ForegroundColor Green

# Login tests
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-001" -TestName "Normal login" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password="123456"} -ExpectedCode "200" -Description "Normal login with correct credentials"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-002" -TestName "Wrong password" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password="wrongpass"} -ExpectedCode "400" -Description "Login with incorrect password"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-003" -TestName "Non-existent user" -Method "POST" -Endpoint "/auth/login" -Body @{username="nonexistent";password="123456"} -ExpectedCode "400" -Description "Login with non-existent user"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-004" -TestName "Empty username" -Method "POST" -Endpoint "/auth/login" -Body @{username="";password="123456"} -ExpectedCode "400" -Description "Login with empty username"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-005" -TestName "Empty password" -Method "POST" -Endpoint "/auth/login" -Body @{username="testuser";password=""} -ExpectedCode "400" -Description "Login with empty password"

# User info tests
$headers = @{Authorization="Bearer $Global:Token"}
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-006" -TestName "Get user info with valid token" -Method "GET" -Endpoint "/auth/user-info" -Headers $headers -ExpectedCode "200" -Description "Get user info with valid JWT token"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-007" -TestName "Get user info without token" -Method "GET" -Endpoint "/auth/user-info" -ExpectedCode "401" -Description "Get user info without providing token"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-008" -TestName "Get user info with invalid token" -Method "GET" -Endpoint "/auth/user-info" -Headers @{Authorization="Bearer invalid.token.here"} -ExpectedCode "401" -Description "Get user info with malformed token"

# Logout tests
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-009" -TestName "Logout with valid token" -Method "POST" -Endpoint "/auth/logout" -Headers $headers -ExpectedCode "200" -Description "Logout with valid token"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-010" -TestName "Logout without token" -Method "POST" -Endpoint "/auth/logout" -ExpectedCode "401" -Description "Logout without providing token"

# Change password tests
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-011" -TestName "Change password - wrong old password" -Method "PUT" -Endpoint "/auth/change-password" -Headers $headers -Body @{oldPassword="wrongpass";newPassword="newpass123"} -ExpectedCode "400" -Description "Change password with incorrect old password"
$TestResults.Auth += Test-API -Module "Auth" -TestId "AUTH-012" -TestName "Change password - empty new password" -Method "PUT" -Endpoint "/auth/change-password" -Headers $headers -Body @{oldPassword="123456";newPassword=""} -ExpectedCode "400" -Description "Change password with empty new password"

Write-Host "Auth module tests completed: $($TestResults.Auth.Count) tests" -ForegroundColor Green

# Save intermediate results
$TestResults | ConvertTo-Json -Depth 10 | Out-File "$OutputDir\intermediate-results.json" -Encoding UTF8

Write-Host "`n=================== PHASE 1 COMPLETED ===================" -ForegroundColor Cyan
Write-Host "Results saved to $OutputDir\intermediate-results.json" -ForegroundColor Yellow
