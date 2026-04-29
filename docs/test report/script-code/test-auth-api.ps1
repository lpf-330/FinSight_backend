# FinSight Authentication Module API Test Script
$TestResults = @()
$BaseUrl = "http://localhost:8080"
$Global:Token = $null

function Write-TestHeader {
    param([string]$TestId, [string]$TestName)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Test ID: $TestId" -ForegroundColor Yellow
    Write-Host "Test Name: $TestName" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
}

# ==================== Task 1: Login API Tests ====================
Write-Host "`n==================== Task 1: Login API Tests ====================" -ForegroundColor Magenta

# 1.1 Test normal login
Write-TestHeader -TestId "1.1" -TestName "Normal login with correct credentials"
try {
    $body = @{username="testuser";password="123456"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $body
    Write-Host "Request: username=testuser, password=123456"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 200)
    if ($passed) { $Global:Token = $response.data.token; Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="1.1"; TestName="Normal login"; Passed=$passed; ActualCode=$response.code}
} catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Result: FAIL" -ForegroundColor Red
    $TestResults += @{TestId="1.1"; TestName="Normal login"; Passed=$false; ActualCode="Error"}
}

# 1.2 Test login with wrong password
Write-TestHeader -TestId "1.2" -TestName "Login with wrong password"
try {
    $body = @{username="testuser";password="wrongpassword"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $body
    Write-Host "Request: username=testuser, password=wrongpassword"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 400)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="1.2"; TestName="Wrong password login"; Passed=$passed; ActualCode=$response.code}
} catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Result: FAIL" -ForegroundColor Red
    $TestResults += @{TestId="1.2"; TestName="Wrong password login"; Passed=$false; ActualCode="Error"}
}

# 1.3 Test login with non-existent user
Write-TestHeader -TestId "1.3" -TestName "Login with non-existent user"
try {
    $body = @{username="nonexistent";password="123456"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $body
    Write-Host "Request: username=nonexistent, password=123456"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 400)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="1.3"; TestName="Non-existent user login"; Passed=$passed; ActualCode=$response.code}
} catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Result: FAIL" -ForegroundColor Red
    $TestResults += @{TestId="1.3"; TestName="Non-existent user login"; Passed=$false; ActualCode="Error"}
}

# 1.4 Test login with empty username
Write-TestHeader -TestId "1.4" -TestName "Login with empty username"
try {
    $body = @{username="";password="123456"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $body
    Write-Host "Request: username='', password=123456"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 400)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="1.4"; TestName="Empty username login"; Passed=$passed; ActualCode=$response.code}
} catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Result: FAIL" -ForegroundColor Red
    $TestResults += @{TestId="1.4"; TestName="Empty username login"; Passed=$false; ActualCode="Error"}
}

# 1.5 Test SQL injection protection
Write-TestHeader -TestId "1.5" -TestName "SQL injection protection"
try {
    $body = @{username="admin' OR '1'='1";password="anything"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $body
    Write-Host "Request: username=admin' OR '1'='1, password=anything"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 400)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="1.5"; TestName="SQL injection protection"; Passed=$passed; ActualCode=$response.code}
} catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Result: FAIL" -ForegroundColor Red
    $TestResults += @{TestId="1.5"; TestName="SQL injection protection"; Passed=$false; ActualCode="Error"}
}

# ==================== Task 2: Get User Info API Tests ====================
Write-Host "`n==================== Task 2: Get User Info API Tests ====================" -ForegroundColor Magenta

# 2.1 Test get user info with valid token
Write-TestHeader -TestId "2.1" -TestName "Get user info with valid token"
try {
    $headers = @{Authorization="Bearer $Global:Token"}
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/user-info" -Method GET -Headers $headers
    Write-Host "Request Header: Authorization=Bearer [Token]"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 200)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="2.1"; TestName="Get user info with valid token"; Passed=$passed; ActualCode=$response.code}
} catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Result: FAIL" -ForegroundColor Red
    $TestResults += @{TestId="2.1"; TestName="Get user info with valid token"; Passed=$false; ActualCode="Error"}
}

# 2.2 Test get user info without token
Write-TestHeader -TestId "2.2" -TestName "Get user info without token"
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/user-info" -Method GET
    Write-Host "Request: No token"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 401)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="2.2"; TestName="Get user info without token"; Passed=$passed; ActualCode=$response.code}
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "Request failed, status code: $statusCode"
    $passed = ($statusCode -eq 401)
    if ($passed) { Write-Host "Result: PASS (Expected 401 error)" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="2.2"; TestName="Get user info without token"; Passed=$passed; ActualCode=$statusCode}
}

# 2.3 Test get user info with invalid token
Write-TestHeader -TestId "2.3" -TestName "Get user info with invalid token"
try {
    $headers = @{Authorization="Bearer invalid.token.here"}
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/user-info" -Method GET -Headers $headers
    Write-Host "Request Header: Authorization=Bearer invalid.token.here"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 401)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="2.3"; TestName="Get user info with invalid token"; Passed=$passed; ActualCode=$response.code}
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "Request failed, status code: $statusCode"
    $passed = ($statusCode -eq 401)
    if ($passed) { Write-Host "Result: PASS (Expected 401 error)" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="2.3"; TestName="Get user info with invalid token"; Passed=$passed; ActualCode=$statusCode}
}

# 2.4 Test get user info with expired token
Write-TestHeader -TestId "2.4" -TestName "Get user info with expired token"
try {
    # Create an expired token (this is a dummy expired token for testing)
    $expiredToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImV4cCI6MTc3NzIxMzMyN30.InvalidSignature"
    $headers = @{Authorization="Bearer $expiredToken"}
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/user-info" -Method GET -Headers $headers
    Write-Host "Request Header: Authorization=Bearer [Expired Token]"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 401)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="2.4"; TestName="Get user info with expired token"; Passed=$passed; ActualCode=$response.code}
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "Request failed, status code: $statusCode"
    $passed = ($statusCode -eq 401)
    if ($passed) { Write-Host "Result: PASS (Expected 401 error)" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="2.4"; TestName="Get user info with expired token"; Passed=$passed; ActualCode=$statusCode}
}

# ==================== Task 3: Logout API Tests ====================
Write-Host "`n==================== Task 3: Logout API Tests ====================" -ForegroundColor Magenta

# 3.1 Test normal logout
Write-TestHeader -TestId "3.1" -TestName "Normal logout"
try {
    $headers = @{Authorization="Bearer $Global:Token"}
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/logout" -Method POST -Headers $headers
    Write-Host "Request Header: Authorization=Bearer [Token]"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 200)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="3.1"; TestName="Normal logout"; Passed=$passed; ActualCode=$response.code}
} catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Result: FAIL" -ForegroundColor Red
    $TestResults += @{TestId="3.1"; TestName="Normal logout"; Passed=$false; ActualCode="Error"}
}

# 3.2 Test logout without login
Write-TestHeader -TestId "3.2" -TestName "Logout without login"
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/logout" -Method POST
    Write-Host "Request: No token"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 401)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="3.2"; TestName="Logout without login"; Passed=$passed; ActualCode=$response.code}
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "Request failed, status code: $statusCode"
    $passed = ($statusCode -eq 401)
    if ($passed) { Write-Host "Result: PASS (Expected 401 error)" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="3.2"; TestName="Logout without login"; Passed=$passed; ActualCode=$statusCode}
}

# ==================== Task 4: Change Password API Tests ====================
Write-Host "`n==================== Task 4: Change Password API Tests ====================" -ForegroundColor Magenta

# Re-login to get new token
Write-Host "`nRe-login to get token..." -ForegroundColor Gray
$loginBody = @{username="testuser";password="123456"} | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
$Global:Token = $loginResponse.data.token
Write-Host "Token updated" -ForegroundColor Gray

# 4.1 Test normal password change
Write-TestHeader -TestId "4.1" -TestName "Normal password change"
try {
    $headers = @{Authorization="Bearer $Global:Token"}
    $body = @{oldPassword="123456";newPassword="newpass123"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/change-password" -Method PUT -ContentType "application/json" -Headers $headers -Body $body
    Write-Host "Request: oldPassword=123456, newPassword=newpass123"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 200)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="4.1"; TestName="Normal password change"; Passed=$passed; ActualCode=$response.code}
} catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Result: FAIL" -ForegroundColor Red
    $TestResults += @{TestId="4.1"; TestName="Normal password change"; Passed=$false; ActualCode="Error"}
}

# 4.2 Test password change with wrong old password
Write-TestHeader -TestId "4.2" -TestName "Password change with wrong old password"
try {
    # Re-login with new password
    $loginBody = @{username="testuser";password="newpass123"} | ConvertTo-Json
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
    $Global:Token = $loginResponse.data.token
    
    $headers = @{Authorization="Bearer $Global:Token"}
    $body = @{oldPassword="wrongpassword";newPassword="newpass456"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/change-password" -Method PUT -ContentType "application/json" -Headers $headers -Body $body
    Write-Host "Request: oldPassword=wrongpassword, newPassword=newpass456"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 400)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="4.2"; TestName="Wrong old password"; Passed=$passed; ActualCode=$response.code}
} catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Result: FAIL" -ForegroundColor Red
    $TestResults += @{TestId="4.2"; TestName="Wrong old password"; Passed=$false; ActualCode="Error"}
}

# 4.3 Test password change without login
Write-TestHeader -TestId "4.3" -TestName "Password change without login"
try {
    $body = @{oldPassword="123456";newPassword="newpass123"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/change-password" -Method PUT -ContentType "application/json" -Body $body
    Write-Host "Request: No token"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 401)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="4.3"; TestName="Password change without login"; Passed=$passed; ActualCode=$response.code}
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "Request failed, status code: $statusCode"
    $passed = ($statusCode -eq 401)
    if ($passed) { Write-Host "Result: PASS (Expected 401 error)" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="4.3"; TestName="Password change without login"; Passed=$passed; ActualCode=$statusCode}
}

# 4.4 Test password change with same old and new password
Write-TestHeader -TestId "4.4" -TestName "Password change with same old and new password"
try {
    # Re-login to get token
    $loginBody = @{username="testuser";password="123456"} | ConvertTo-Json
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
    $Global:Token = $loginResponse.data.token
    
    $headers = @{Authorization="Bearer $Global:Token"}
    $body = @{oldPassword="123456";newPassword="123456"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/change-password" -Method PUT -ContentType "application/json" -Headers $headers -Body $body
    Write-Host "Request: oldPassword=123456, newPassword=123456 (same as old)"
    Write-Host "Response:"; $response | ConvertTo-Json -Depth 10
    $passed = ($response.code -eq 400)
    if ($passed) { Write-Host "Result: PASS" -ForegroundColor Green }
    else { Write-Host "Result: FAIL" -ForegroundColor Red }
    $TestResults += @{TestId="4.4"; TestName="Same old and new password"; Passed=$passed; ActualCode=$response.code}
} catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Result: FAIL" -ForegroundColor Red
    $TestResults += @{TestId="4.4"; TestName="Same old and new password"; Passed=$false; ActualCode="Error"}
}

# Restore original password
Write-Host "`nRestoring original password..." -ForegroundColor Gray
$loginBody = @{username="testuser";password="newpass123"} | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
$restoreHeaders = @{Authorization="Bearer $($loginResponse.data.token)"}
$restoreBody = @{oldPassword="newpass123";newPassword="123456"} | ConvertTo-Json
$restoreResponse = Invoke-RestMethod -Uri "$BaseUrl/auth/change-password" -Method PUT -ContentType "application/json" -Headers $restoreHeaders -Body $restoreBody
Write-Host "Password restored to: 123456" -ForegroundColor Gray

# ==================== Test Results Summary ====================
Write-Host "`n==================== Test Results Summary ====================" -ForegroundColor Magenta

$passedCount = ($TestResults | Where-Object { $_.Passed }).Count
$failedCount = ($TestResults | Where-Object { -not $_.Passed }).Count
$totalCount = $TestResults.Count
$passRate = [math]::Round(($passedCount / $totalCount) * 100, 2)

Write-Host "`nTotal tests: $totalCount"
Write-Host "Passed: $passedCount" -ForegroundColor Green
Write-Host "Failed: $failedCount" -ForegroundColor Red
Write-Host "Pass rate: $passRate%" -ForegroundColor $(if ($passRate -ge 80) { "Green" } elseif ($passRate -ge 60) { "Yellow" } else { "Red" })

Write-Host "`nDetailed results:" -ForegroundColor Cyan
foreach ($result in $TestResults) {
    $status = if ($result.Passed) { "PASS" } else { "FAIL" }
    $color = if ($result.Passed) { "Green" } else { "Red" }
    Write-Host "[$($result.TestId)] $($result.TestName): $status (Actual code: $($result.ActualCode))" -ForegroundColor $color
}

# Export test results to JSON
$TestResults | ConvertTo-Json -Depth 10 | Out-File "test-results.json" -Encoding UTF8
Write-Host "`nTest results saved to test-results.json" -ForegroundColor Green
