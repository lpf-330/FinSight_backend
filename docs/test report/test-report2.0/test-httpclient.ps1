Add-Type -AssemblyName System.Net.Http

$handler = New-Object System.Net.Http.HttpClientHandler
$client = New-Object System.Net.Http.HttpClient($handler)
$client.DefaultRequestHeaders.Accept.Add([System.Net.Http.Headers.MediaTypeWithQualityHeaderValue]"application/json")

$body = New-Object System.Net.Http.StringContent('{"username":"testuser","password":"123456"}', [System.Text.Encoding]::UTF8, "application/json")

try {
    Write-Host "Sending login request..."
    $response = $client.PostAsync("http://localhost:8080/auth/login", $body).Result
    $content = $response.Content.ReadAsStringAsync().Result

    Write-Host "Status Code: $($response.StatusCode)"
    Write-Host "Response: $content"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}