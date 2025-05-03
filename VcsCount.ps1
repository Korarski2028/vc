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

# Import the credential securely
$cred = Import-Clixml -Path "$env:USERPROFILE\secure_cred.xml"

# Store results
$sessionResults = @()

foreach ($vcenter in $vcenterList) {
    try {
        Write-Host "`nConnecting to vCenter: $vcenter..." -ForegroundColor Cyan
        Connect-VIServer -Server $vcenter -ErrorAction Stop

        # Get SessionManager view
        $sessionManager = Get-View -Id "SessionManager-SessionManager"

        if ($sessionManager.SessionList) {
            # Group sessions by user
            $groupedSessions = $sessionManager.SessionList |
                Group-Object -Property UserName | Sort-Object Count -Descending

            foreach ($group in $groupedSessions) {
                $sessionResults += [PSCustomObject]@{
                    VCenter      = $vcenter
                    UserName     = $group.Name
                    SessionCount = $group.Count
                }
            }

            # Add total session count
            $sessionResults += [PSCustomObject]@{
                VCenter      = $vcenter
                UserName     = "TOTAL"
                SessionCount = $sessionManager.SessionList.Count
            }
        }
        else {
            Write-Warning "No active sessions found on $vcenter."
        }

        Disconnect-VIServer -Server $vcenter -Confirm:$false
    }
    catch {
        Write-Warning "Error connecting to $vcenter: $_"
    }
}

# Display the session count per user and total
$sessionResults | Format-Table -AutoSize