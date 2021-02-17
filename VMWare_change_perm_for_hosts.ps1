$vcsa = "vcsacluster.ouiit.local"
Connect-VIServer -Server $vcsa

$competitors = Import-Csv -Path .\OTF6.csv
$role = Get-VIRole VirtualMachineUser

foreach($competitor in $competitors) {
  $username = $competitor.DOM -replace '(\w+)@.+','CLOUD\$1'
  $vm = $competitor.MAC -replace '(OT)(MAC)(\d+)','$1-$2-$3'
  $perm = Get-VIPermission -Entity $vm -Principal $username
  if(!$perm){
    Write-Host "$($username): Add permissions to $($vm)"
    New-VIPermission -Entity $vm -Principal $username -Role $role -Propagate:$true
    Write-Host '---------------------------------------------'
  } else {
    Write-Host "$($username) already has permissions to $($vm)"
    Write-Host '---------------------------------------------'
  }
}

Disconnect-VIServer -Server $vcsa -Confirm:$false