Add-Type -AssemblyName System.Net.Http

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

    $client = New-Object System.Net.Http.HttpClient
    $client.Timeout = [TimeSpan]::FromSeconds(10)

    try {
        $request = New-Object System.Net.Http.HttpRequestMessage([System.Net.Http.HttpMethod]$Method, $Url)

        foreach ($key in $Headers.Keys) {
            $request.Headers.Add($key, $Headers[$key])
        }

        if ($Body) {
            $request.Content = New-Object System.Net.Http.StringContent($Body, [System.Text.Encoding]::UTF8, "application/json")
            Write-Host "Body: $Body"
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

Write-Host "Testing without /api prefix..." -ForegroundColor Yellow

$baseUrl = "http://localhost:8080"

Write-Host "`n--- POST /auth/login (without /api) ---" -ForegroundColor Yellow

$result1 = Test-ApiEndpoint -Name "Login with correct credentials" -Method "POST" -Url "$baseUrl/auth/login" -Body '{"username":"testuser","password":"123456"}'