Add-Type -AssemblyName System.Net.Http
Add-Type -AssemblyName System.Web

function Test-ApiEndpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [string]$Body = $null,
        [hashtable]$Headers = @{}
    )

    Write-Host "`n=== $Name ===" -ForegroundColor Cyan
    Write-Host "Method: $Method"
    Write-Host "URL: $Url"

    $handler = New-Object System.Net.Http.HttpClientHandler
    $client = New-Object System.Net.Http.HttpClient($handler)
    $client.Timeout = [TimeSpan]::FromSeconds(10)

    try {
        $request = New-Object System.Net.Http.HttpRequestMessage([System.Net.Http.HttpMethod]$Method, $Url)

        foreach ($key in $Headers.Keys) {
            $request.Headers.Add($key, $Headers[$key])
        }

        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Compress
            $request.Content = New-Object System.Net.Http.StringContent($jsonBody, [System.Text.Encoding]::UTF8, "application/json")
            Write-Host "Body: $jsonBody"
        }

        $response = $client.SendAsync($request).Result
        $statusCode = [int]$response.StatusCode
        $content = $response.Content.ReadAsStringAsync().Result

        Write-Host "Status: $statusCode" -ForegroundColor $(if ($statusCode -eq 200) { "Green" } else { "Yellow" })
        Write-Host "Response: $content"

        return @{ Status = $statusCode; Content = $content; Success = ($statusCode -ge 200 -and $statusCode -lt 300) }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return @{ Status = 0; Content = $_.Exception.Message; Success = $false }
    }
    finally {
        $client.Dispose()
    }
}

Write-Host "=================== AUTH MODULE API TESTS ===================" -ForegroundColor Green

$baseUrl = "http://localhost:8080/api"

Write-Host "`n--- POST /auth/login ---" -ForegroundColor Yellow

$result1 = Test-ApiEndpoint -Name "Login with correct credentials" -Method "POST" -Url "$baseUrl/auth/login" -Body '{"username":"testuser","password":"123456"}'
$result2 = Test-ApiEndpoint -Name "Login with wrong password" -Method "POST" -Url "$baseUrl/auth/login" -Body '{"username":"testuser","password":"wrongpass"}'
$result3 = Test-ApiEndpoint -Name "Login with empty username" -Method "POST" -Url "$baseUrl/auth/login" -Body '{"username":"","password":"123456"}'
$result4 = Test-ApiEndpoint -Name "Login with empty password" -Method "POST" -Url "$baseUrl/auth/login" -Body '{"username":"testuser","password":""}'

Write-Host "`n--- GET /auth/user-info ---" -ForegroundColor Yellow

$token = $null
if ($result1.Success) {
    $tokenObj = $result1.Content | ConvertFrom-Json
    $token = $tokenObj.data.token
    Write-Host "Token obtained: $($token.Substring(0, [Math]::Min(50, $token.Length)))..." -ForegroundColor Green
}

if ($token) {
    Test-ApiEndpoint -Name "Get user info with valid token" -Method "GET" -Url "$baseUrl/auth/user-info" -Headers @{ "Authorization" = "Bearer $token" }
}
Test-ApiEndpoint -Name "Get user info without token" -Method "GET" -Url "$baseUrl/auth/user-info"
Test-ApiEndpoint -Name "Get user info with invalid token" -Method "GET" -Url "$baseUrl/auth/user-info" -Headers @{ "Authorization" = "Bearer invalid.token.here" }

Write-Host "`n--- POST /auth/logout ---" -ForegroundColor Yellow

if ($token) {
    Test-ApiEndpoint -Name "Logout with valid token" -Method "POST" -Url "$baseUrl/auth/logout" -Headers @{ "Authorization" = "Bearer $token" }
}
Test-ApiEndpoint -Name "Logout without token" -Method "POST" -Url "$baseUrl/auth/logout"

Write-Host "`n--- PUT /auth/change-password ---" -ForegroundColor Yellow

if ($token) {
    Test-ApiEndpoint -Name "Change password - wrong old password" -Method "PUT" -Url "$baseUrl/auth/change-password" -Headers @{ "Authorization" = "Bearer $token" } -Body '{"oldPassword":"wrongpass","newPassword":"newpass123"}'
    Test-ApiEndpoint -Name "Change password - empty new password" -Method "PUT" -Url "$baseUrl/auth/change-password" -Headers @{ "Authorization" = "Bearer $token" } -Body '{"oldPassword":"123456","newPassword":""}'
}

Write-Host "`n=================== TESTS COMPLETED ===================" -ForegroundColor Green