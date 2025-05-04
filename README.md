this is a test
function Send-Emails {
    param (
        [string]$SmtpServer,
        [string]$From,
        [string]$To,
        [string]$Subject,
        [string]$Body,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 10
    )

    $attempt = 0
    $success = $false

    while (-not $success -and $attempt -lt $MaxRetries) {
        try {
            $attempt++
            Write-Host "Sending email (Attempt $attempt of $MaxRetries)..."

            Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -SmtpServer $SmtpServer

            Write-Host "Email sent successfully." -ForegroundColor Green
            $success = $true
        }
        catch {
            $errorMessage = $_.Exception.Message

            if ($errorMessage -like "*timed out*") {
                Write-Warning "Send-MailMessage timed out. Attempt $attempt of $MaxRetries."
                if ($attempt -lt $MaxRetries) {
                    Write-Host "Retrying in $DelaySeconds seconds..." -ForegroundColor Yellow
                    Start-Sleep -Seconds $DelaySeconds
                } else {
                    Write-Error "Email failed after $MaxRetries attempts (timeout)."
                }
            } else {
                Write-Error "Unexpected error: $errorMessage"
                break
            }
        }
    }
}
