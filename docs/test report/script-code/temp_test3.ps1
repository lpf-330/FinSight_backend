try {
    $body = '{"username":"admin","password":"123456"}'
    $response = Invoke-RestMethod -Uri "http://localhost:8080/auth/login" -Method POST -ContentType "application/json" -Body $body -ErrorAction Stop
    Write-Host "Success! Code:" $response.code
    Write-Host "Token:" $response.data.token
} catch {
    Write-Host "Error:" $_.Exception.Message
    if ($_.Exception.Response) {
        Write-Host "Status Code:" $_.Exception.Response.StatusCode.value__
    }
}