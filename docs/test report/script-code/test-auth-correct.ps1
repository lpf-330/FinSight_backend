Add-Type -AssemblyName System.Net.Http

$Global:Token = $null
$Global:BaseUrl = "http://localhost:8080"

function Get-TestToken {
    $client = New-Object System.Net.Http.HttpClient
    try {
        $body = '{"username":"testuser","password":"123456"}'
        $content = New-Object System.Net.Http.StringContent($body, [System.Text.Encoding]::UTF8, "application/json")
        $response = $client.PostAsync("$Global:BaseUrl/auth/login", $content).Result
        $json = $response.Content.ReadAsStringAsync().Result | ConvertFrom-Json
        if ($json.code -eq 200) {
            $Global:Token = $json.data.token
            return $true
        }
    } catch {}
    finally { $client.Dispose() }
    return $false
}

function Test-API {
    param(
        [string]$TestId,
        [string]$TestName,
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [string]$ExpectedCode,
        [string]$Description = ""
    )

    $result = @{
        TestId = $TestId
        TestName = $TestName
        Method = $Method
        Endpoint = $Endpoint
        ExpectedCode = $ExpectedCode
        ActualCode = $null
        Passed = $false
        Description = $Description
    }

    $client = New-Object System.Net.Http.HttpClient
    $client.Timeout = [TimeSpan]::FromSeconds(10)

    try {
        $url = "$Global:BaseUrl$Endpoint"
        $request = New-Object System.Net.Http.HttpRequestMessage([System.Net.Http.HttpMethod]$Method, $url)

        foreach ($key in $Headers.Keys) {
            $request.Headers.Add($key, $Headers[$key])
        }

        if ($Body) {
            $request.Content = New-Object System.Net.Http.StringContent($Body, [System.Text.Encoding]::UTF8, "application/json")
        }

        $response = $client.SendAsync($request).Result
        $result.ActualCode = [int]$response.StatusCode
        $result.Passed = ($result.ActualCode -eq $ExpectedCode)

        $result | Add-Member -NotePropertyName "Response" -NotePropertyValue "$($response.StatusCode)"
    }
    catch {
        $result.ActualCode = "Error"
        $result | Add-Member -NotePropertyName "Response" -NotePropertyValue $_.Exception.Message
    }
    finally {
        $client.Dispose()
    }

    return $result
}

Write-Host "`n========== PHASE 1: AUTH MODULE TESTS ==========" -ForegroundColor Cyan

if (-not (Get-TestToken)) {
    Write-Host "Failed to get test token!" -ForegroundColor Red
    exit 1
}
Write-Host "Token obtained successfully" -ForegroundColor Green

$testResults = @()

$headers = @{Authorization="Bearer $Global:Token"}

Write-Host "`n--- Login Tests ---" -ForegroundColor Yellow
$testResults += Test-API -TestId "AUTH-001" -TestName "Normal login" -Method "POST" -Endpoint "/auth/login" -Body '{"username":"testuser","password":"123456"}' -ExpectedCode 200 -Description "Normal login with correct credentials"
$testResults += Test-API -TestId "AUTH-002" -TestName "Wrong password" -Method "POST" -Endpoint "/auth/login" -Body '{"username":"testuser","password":"wrongpass"}' -ExpectedCode 400 -Description "Login with incorrect password"
$testResults += Test-API -TestId "AUTH-003" -TestName "Non-existent user" -Method "POST" -Endpoint "/auth/login" -Body '{"username":"nonexistent","password":"123456"}' -ExpectedCode 400 -Description "Login with non-existent user"
$testResults += Test-API -TestId "AUTH-004" -TestName "Empty username" -Method "POST" -Endpoint "/auth/login" -Body '{"username":"","password":"123456"}' -ExpectedCode 400 -Description "Login with empty username"
$testResults += Test-API -TestId "AUTH-005" -TestName "Empty password" -Method "POST" -Endpoint "/auth/login" -Body '{"username":"testuser","password":""}' -ExpectedCode 400 -Description "Login with empty password"

Write-Host "`n--- User Info Tests ---" -ForegroundColor Yellow
$testResults += Test-API -TestId "AUTH-006" -TestName "Get user info with valid token" -Method "GET" -Endpoint "/auth/user-info" -Headers $headers -ExpectedCode 200 -Description "Get user info with valid JWT token"
$testResults += Test-API -TestId "AUTH-007" -TestName "Get user info without token" -Method "GET" -Endpoint "/auth/user-info" -ExpectedCode 401 -Description "Get user info without providing token"
$testResults += Test-API -TestId "AUTH-008" -TestName "Get user info with invalid token" -Method "GET" -Endpoint "/auth/user-info" -Headers @{Authorization="Bearer invalid.token.here"} -ExpectedCode 401 -Description "Get user info with malformed token"

Write-Host "`n--- Logout Tests ---" -ForegroundColor Yellow
$testResults += Test-API -TestId "AUTH-009" -TestName "Logout with valid token" -Method "POST" -Endpoint "/auth/logout" -Headers $headers -ExpectedCode 200 -Description "Logout with valid token"
$testResults += Test-API -TestId "AUTH-010" -TestName "Logout without token" -Method "POST" -Endpoint "/auth/logout" -ExpectedCode 401 -Description "Logout without providing token"

Write-Host "`n--- Change Password Tests ---" -ForegroundColor Yellow
$testResults += Test-API -TestId "AUTH-011" -TestName "Change password - wrong old password" -Method "PUT" -Endpoint "/auth/change-password" -Headers $headers -Body '{"oldPassword":"wrongpass","newPassword":"newpass123"}' -ExpectedCode 400 -Description "Change password with incorrect old password"
$testResults += Test-API -TestId "AUTH-012" -TestName "Change password - empty new password" -Method "PUT" -Endpoint "/auth/change-password" -Headers $headers -Body '{"oldPassword":"123456","newPassword":""}' -ExpectedCode 400 -Description "Change password with empty new password"

Write-Host "`n`n========== TEST RESULTS SUMMARY ==========" -ForegroundColor Cyan
Write-Host ("{0,-10} {1,-35} {2,-10} {3,-10} {4}" -f "Test ID", "Test Name", "Expected", "Actual", "Result") -ForegroundColor White
Write-Host ("-" * 80)

$passCount = 0
$failCount = 0

foreach ($t in $testResults) {
    $status = if ($t.Passed) { "PASS" } else { "FAIL" }
    $color = if ($t.Passed) { "Green" } else { "Red" }
    Write-Host ("{0,-10} {1,-35} {2,-10} {3,-10} {4}" -f $t.TestId, $t.TestName, $t.ExpectedCode, $t.ActualCode, $status) -ForegroundColor $color
    if ($t.Passed) { $passCount++ } else { $failCount++ }
}

Write-Host ("-" * 80)
Write-Host "Total: $($testResults.Count) | Passed: $passCount | Failed: $failCount" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "`n========== PHASE 1 COMPLETED ==========" -ForegroundColor Cyan