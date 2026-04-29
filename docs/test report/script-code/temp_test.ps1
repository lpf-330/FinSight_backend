$body = '{"username":"testuser","password":"123456"}'
$client = New-Object System.Net.Http.HttpClient
$content = New-Object System.Net.Http.StringContent($body, [System.Text.Encoding]::UTF8, "application/json")
$response = $client.PostAsync("http://localhost:8080/auth/login", $content).Result
Write-Host "Status:" $response.StatusCode
Write-Host "Content:" $response.Content.ReadAsStringAsync().Result
$client.Dispose()