Add-Type -AssemblyName System.Net.Http

$client = New-Object System.Net.Http.HttpClient
$client.DefaultRequestHeaders.Accept.Add([System.Net.Http.Headers.MediaTypeWithQualityHeaderValue]"application/json")

function Get-Token {
    param($username, $password)
    $bodyJson = "{`"username`":`"$username`",`"password`":`"$password`"}"
    $body = New-Object System.Net.Http.StringContent($bodyJson, [System.Text.Encoding]::UTF8, "application/json")
    $response = $client.PostAsync("http://localhost:8080/auth/login", $body).Result
    $content = $response.Content.ReadAsStringAsync().Result | ConvertFrom-Json
    if ($content.code -eq 200) {
        return $content.data.token
    }
    return $null
}

function Create-User {
    param($token, $username, $name, $password, $department, $roleId)
    $bodyJson = @{
        username = $username
        name = $name
        password = $password
        department = $department
        roleId = $roleId
        status = "active"
    } | ConvertTo-Json
    $body = New-Object System.Net.Http.StringContent($bodyJson, [System.Text.Encoding]::UTF8, "application/json")
    $client.DefaultRequestHeaders.Remove("Authorization") | Out-Null
    $client.DefaultRequestHeaders.Add("Authorization", "Bearer $token")
    $response = $client.PostAsync("http://localhost:8080/system/user", $body).Result
    $content = $response.Content.ReadAsStringAsync().Result
    return $content
}

Write-Host "Step 1: Trying to login with admin..."
$token = Get-Token "admin" "admin123"
if (-not $token) {
    Write-Host "admin login failed, trying testuser..."
    $token = Get-Token "testuser" "123456"
}

if (-not $token) {
    Write-Host "All login attempts failed. Token: $token"
    exit 1
}

Write-Host "Got token: $token"
Write-Host ""

Write-Host "Step 2: Creating test user via API..."
$result = Create-User $token "testuser2" "Test User 2" "123456" "Test Dept" 1
Write-Host "Create user result: $result"