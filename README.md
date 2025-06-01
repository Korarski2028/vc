# Goal is to copy json file to nutanix cvm alog with permissions and installation via sh script
# This will be a CVM File Transfer Script using SFTP (testing as it failed in 2 ocations)
# Requires Posh-SSH module installed on cx14. You can add as Install-Module -Name Posh-SSH -Scope CurrentUser 
# version   date   
#####################################################################################################################
# Parameters
$CvmIp = "1.1.1.1"              #   CVM IP
$Port = 2222                        # cvm SFTP port by default
$Username = "nutanix"                 # ssh pe admin 
$Password = "xxxxx"      # Replace with actual password
$LocalFilePath = ".\Files\disk.json"
$LocalFilePath2 = ".\Files\json.sh"
$RemotePath = "/nutanix/home/tmp"     # Ths is destination folder on cvm

# Create credential object
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

#  start file transfer
try {
    $Session = New-SFTPSession -ComputerName $CvmIp -Port $Port -Credential $Credential -AcceptKey
    Set-SFTPFile -SessionId $Session.SessionId -LocalFile $LocalFilePath -RemotePath $RemotePath
    Set-SFTPFile -SessionId $Session.SessionId -LocalFile $LocalFilePath2 -RemotePath $RemotePath

    try {
        # Change permissions
        $ChmodResult = Invoke-SSHCommand -SessionId $Session.SessionId -Command "chmod +x $RemotePath2/json.sh"
        
        if ($ChmodResult.Error) {
            throw "Permission change failed: $($ChmodResult.Error)"
        }

        # Execute script
        $ExecutionResult = Invoke-SSHCommand -SessionId $Session.SessionId -Command "bash $RemotePath2/json.sh"
        
        if ($ExecutionResult.ExitStatus -ne 0) {
            throw "Script execution failed (Exit $($ExecutionResult.ExitStatus)): $($ExecutionResult.Error)"
        }
        
        Write-Host "Script executed successfully. Output:"
        $ExecutionResult.Output
    }
    catch {
        Write-Error "Post-transfer operation failed: $_"
    }
}
catch {
    Write-Error "SFTP transfer failed: $_"
}
finally {
    if ($Session) { 
        Remove-SFTPSession -SessionId $Session.SessionId | Out-Null
        Write-Host "Session cleaned up"
    }
}





<#
# Establish SFTP connection to copy json and installer json.sh
try {
    $Session = New-SFTPSession -ComputerName $CvmIp -Port $Port -Credential $Credential -AcceptKey
    Set-SFTPFile -SessionId $Session.SessionId -LocalFile $LocalFilePath -RemotePath $RemotePath
    Set-SFTPFile -SessionId $Session.SessionId -LocalFile $LocalFilePath2 -RemotePath $RemotePath
    Write-Host "Files were  successfully transferred to $RemotePath"
    
try {
        # here Change permissions to script 
        $ChmodResult = Invoke-SSHCommand -SessionId $Session.SessionId -Command "chmod +x $RemotePath/newVM.sh"
        
        if ($ChmodResult.Error) {
            throw "Permission change failed: $($ChmodResult.Error)"
        }

        # Execute script
        $ExecutionResult = Invoke-SSHCommand -SessionId $Session.SessionId -Command "bash $RemotePath/newVM.sh"
        
        if ($ExecutionResult.ExitStatus -ne 0) {
            throw "Script execution failed (Exit $($ExecutionResult.ExitStatus)): $($ExecutionResult.Error)"
        }
        
        Write-Host "Script executed successfully. Output:"
        $ExecutionResult.Output
    }
    catch {
        Write-Error "Post-transfer operation failed: $_"
    }

finally {
    if ($Session) { 
        Remove-SFTPSession -SessionId $Session.SessionId | Out-Null
        Write-Host "Session closed"
    }
}
#>
