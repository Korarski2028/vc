# vc to emaikl 
# Convert to HTML
$bodyHtml = $sessionResults | ConvertTo-Html -Property VCenter, UserName, SessionCount -Title "vCenter Sessions" | Out-String

# Send as HTML email
Send-MailMessage -From $from -To $to -Subject $subject -Body $bodyHtml -SmtpServer $smtpServer -BodyAsHtml
