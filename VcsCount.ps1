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

# Use it as needed, e.g., in a script that requires credentials
$cred.UserName
$cred.GetNetworkCredential().Password

# Disable certificate check for vc
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Output hashtable to store results of our query 
$sessionResults = @()

foreach ($vcenter in $vcenterList) {
    try {
        Write-Host "`nConnecting to vCenter: $vcenter..." -ForegroundColor Cyan
        $connection = Connect-VIServer -Server $vcenter -ErrorAction Stop

        # Get all sessions from the vCenter
        $sessions = Get-Session

        # Count sessions per user
        $grouped = $sessions | Group-Object -Property UserName | Sort-Object -Property Count -Descending

        foreach ($group in $grouped) {
            $sessionResults += [PSCustomObject]@{
                VCenter      = $vcenter
                UserName     = $group.Name
                SessionCount = $group.Count
            }
        }

        # Add total sessions
        $sessionResults += [PSCustomObject]@{
            VCenter      = $vcenter
            UserName     = "TOTAL"
            SessionCount = $sessions.Count
        }

        Disconnect-VIServer -Server $vcenter -Confirm:$false
    }
    catch {
        Write-Warning "Failed to connect to $vcenter: $_"
    }
}

# Display the results
$sessionResults | Format-Table -AutoSize

# Export to CSV
$sessionResults | Export-Csv -Path ".\Sessions.csv" -NoTypeInformation
