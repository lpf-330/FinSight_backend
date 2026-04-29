$headers = @{"Content-Type" = "application/json; charset=utf-8"}
$body = '{"username":"testuser","password":"123456"}'

try {
    $resp = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" -Method POST -Headers $headers -Body $body
    Write-Host "Status:" $resp.StatusCode
    Write-Host "Content:" $resp.Content
} catch {
    Write-Host "Error:" $_.Exception.Message
    if ($_.Exception.Response) {
        Write-Host "Status:" $_.Exception.Response.StatusCode
    }
}