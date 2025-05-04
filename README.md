$maxRetries = 3
$retryDelaySeconds = 60
$attempt = 0
$success = $false

while (-not $success -and $attempt -lt $maxRetries) {
    try {
        $attempt++
        Write-Host "Attempt #$attempt to send email..."

        # email function here 
        #Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer $smtpServer

        Write-Host "Email sent successfully." -ForegroundColor Green
        $success = $true
    }
    catch {
        Write-Warning "Send-MailMessage failed: $_"
        if ($attempt -lt $maxRetries) {
            Write-Host "Retrying in $retryDelaySeconds seconds..."
            Start-Sleep -Seconds $retryDelaySeconds
        }
        else {
            Write-Error "All retry attempts failed. Giving up."
        }
    }
}










