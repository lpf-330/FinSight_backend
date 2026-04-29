Add-Type -AssemblyName System.Net.Http

$client = New-Object System.Net.Http.HttpClient
$client.DefaultRequestHeaders.Accept.Add([System.Net.Http.Headers.MediaTypeWithQualityHeaderValue]"application/json")

$users = @(
    '{"username":"admin","password":"123456"}',
    '{"username":"zhangsan","password":"123456"}',
    '{"username":"lisi","password":"123456"}'
)

foreach ($userJson in $users) {
    Write-Host "Testing user: $userJson"
    $body = New-Object System.Net.Http.StringContent($userJson, [System.Text.Encoding]::UTF8, "application/json")
    try {
        $response = $client.PostAsync("http://localhost:8080/auth/login", $body).Result
        $content = $response.Content.ReadAsStringAsync().Result
        Write-Host "Status: $($response.StatusCode), Response: $content"
        Write-Host ""
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
        Write-Host ""
    }
}