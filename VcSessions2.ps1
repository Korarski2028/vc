#   Script to count sessions per Vcenter if you provide a txt file with the list
#   # Prompt for credentials
#    $cred = Get-Credential
# Export to XML with encryption tied to current user
# $cred | Export-Clixml -Path "$env:USERPROFILE\secure_cred.xml"
#
#
#######################################################################################################
# Load the list of vCenter servers
$vcenterList = Get-Content -Path ".\vcenters.txt"

function Get-ViSession {
    param($Server)
    $sessionMgr = Get-View $Server.ExtensionData.Client.ServiceContent.SessionManager
    $allSessions = @()
    
    foreach ($session in $sessionMgr.SessionList) {
        $sessionObj = [PSCustomObject]@{
            vCenterServer = $Server.Name
            UserName      = $session.UserName
            LoginTime     = $session.LoginTime.ToLocalTime()
            LastActive    = $session.LastActiveTime.ToLocalTime()
            IdleMinutes   = [math]::Round(([DateTime]::Now - $session.LastActiveTime.ToLocalTime()).TotalMinutes)
            SessionType   = if ($session.Key -eq $sessionMgr.CurrentSession.Key) { "Current" } else { "Idle" }
        }
        $allSessions += $sessionObj
    }
    return $allSessions
}

# Initialize variables
$vCenters = Get-Content $InputFile
$credential = Get-Credential -Message "Enter vCenter credentials"
$totalSessions = 0
$reportData = @()

# Process each vCenter server
foreach ($vc in $vCenters) {
    try {
        # Connect to vCenter
        $connection = Connect-VIServer -Server $vc -Credential $credential -ErrorAction Stop
        
        # Collect sessions
        $sessions = Get-ViSession -Server $connection
        $sessionCount = $sessions.Count
        $totalSessions += $sessionCount
        
        # Add to report
        $reportData += $sessions
        
        # Display progress
        Write-Host "Processed $vc - $sessionCount sessions found" -ForegroundColor Cyan
        
        # Disconnect cleanly
        Disconnect-VIServer -Server $connection -Confirm:$false -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "Failed to connect to $vc : $_"
    }
}

# Generate report
$reportData | Export-Csv -Path $OutputFile -NoTypeInformation -UseCulture

# Display summary
Write-Host "`nReport Summary:"
$reportData | Group-Object vCenterServer | ForEach-Object {
    Write-Host ("{0}: {1} sessions" -f $_.Name, $_.Count)
}
Write-Host ("`nGrand Total: {0} sessions across {1} vCenters" -f $totalSessions, $vCenters.Count)