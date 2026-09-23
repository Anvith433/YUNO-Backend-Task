param(
    [int]$RequestCount = 50000,
    [string]$BaseUrl = "http://localhost:8080"
)

Add-Type -AssemblyName System.Net.Http

$endpoint = "$BaseUrl/api/v1/ingestion/audio-event"

Write-Host ""
Write-Host "========================================"
Write-Host " YUNO Backend Load Test"
Write-Host "========================================"
Write-Host "Endpoint      : $endpoint"
Write-Host "Requests      : $RequestCount"
Write-Host "Mode          : Concurrent"
Write-Host "========================================"
Write-Host ""

$client = New-Object System.Net.Http.HttpClient
$client.Timeout = [TimeSpan]::FromSeconds(30)

$tasks = @()

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Create all requests concurrently
for ($i = 1; $i -le $RequestCount; $i++) {

    $json = @{
        deviceId   = "load-device-$($i % 10)"
        timestamp  = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        event      = "load_test_event"
        durationMs = $i
    } | ConvertTo-Json -Compress

    $content = New-Object System.Net.Http.StringContent(
        $json,
        [System.Text.Encoding]::UTF8,
        "application/json"
    )

    $tasks += $client.PostAsync(
        $endpoint,
        $content
    )
}

$success = 0
$failed = 0

# Collect actual responses
foreach ($task in $tasks) {

    try {

        $response = $task.GetAwaiter().GetResult()

        if ([int]$response.StatusCode -eq 202) {
            $success++
        }
        else {
            $failed++

            Write-Host "Unexpected HTTP status:" `
                ([int]$response.StatusCode)
        }

    }
    catch {

        $failed++

        Write-Host "Request failed:" `
            $_.Exception.Message
    }
}

$stopwatch.Stop()

$elapsed = $stopwatch.Elapsed.TotalSeconds

if ($elapsed -gt 0) {
    $rps = $RequestCount / $elapsed
}
else {
    $rps = 0
}

Write-Host ""
Write-Host "========================================"
Write-Host " LOAD TEST RESULT"
Write-Host "========================================"
Write-Host "Total Requests : $RequestCount"
Write-Host "HTTP 202       : $success"
Write-Host "Failed         : $failed"
Write-Host "Time (seconds) : $([math]::Round($elapsed, 2))"
Write-Host "Throughput     : $([math]::Round($rps, 2)) req/sec"
Write-Host "========================================"
Write-Host ""

$client.Dispose()