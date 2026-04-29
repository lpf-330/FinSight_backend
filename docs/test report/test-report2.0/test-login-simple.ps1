# Simple Login Test Script
$body = @{
    username = "testuser"
    password = "123456"
} | ConvertTo-Json

Write-Host "Testing login with body: $body"
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/auth/login" -Method POST -ContentType "application/json" -Body $body
    Write-Host "Response Code: $($response.code)"
    Write-Host "Response Message: $($response.message)"
    if ($response.code -eq 200) {
        Write-Host "Token: $($response.data.token)" -ForegroundColor Green
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $([int]$_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}