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
6 debug


-------------------------------
  # Output details
            [PSCustomObject]@{
                Hostname            = $host.Name
                DatastoreName       = $ds.Name
                DatastoreStatus     = $ds.State
                DatastoreType       = $ds.Type
                DatastoreCluster    = $dsCluster.Name
                CapacityGB          = [math]::Round($ds.CapacityGB,2)
                FreeSpaceGB         = [math]::Round($ds.FreeSpaceGB,2)
                NumberOfPaths       = $numberOfPaths
                Protocol            = $protocol
            }
