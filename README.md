# Goal is to copy json file to nutanix cvm alog with permissions and installation via sh script
# This will be a CVM File Transfer Script using SFTP (testing as it failed in 2 ocations)
# Requires Posh-SSH module installed on cx14. You can add as Install-Module -Name Posh-SSH -Scope CurrentUser 
# version   date   
#####################################################################################################################

1 get creds
2 copy file and script
3 change script permissios
4 execute
5 catch errors
*************************
# Load WinSCP .NET assembly (adjust path as needed)
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Setup session options
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "1.1.1.1"              # Nutanix CVM IP
    UserName = "nutanix"                 # Use nutanix user for port 22
    Password = "YourPassword"
    PortNumber = 22                      # Default SSH port
    # You should specify the SSH host key fingerprint for security
    SshHostKeyFingerprint = "ssh-rsa 2048 xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
}

$session = New-Object WinSCP.Session

try {
    # Open the session
    $session.Open($sessionOptions)

    # Upload file
    $transferOptions = New-Object WinSCP.TransferOptions
    $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

    $transferResult = $session.PutFiles("path to script.sh", "/home/nutanix/script.sh", $false, $transferOptions)

    # Check for errors
    $transferResult.Check()

    Write-Host "File transfer succeeded."

    # test this part or just use invoke 
    $commandResult = $session.ExecuteCommand("chmod +x /home/nutanix/script.sh && bash /home/nutanix/script.sh")
    Write-Host "Command output:`n$($commandResult.Output)"
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
}
finally {
    $session.Dispose()
}
