$vcsa = "vcsacluster.ouiit.local"
Connect-VIServer -Server $vcsa

$competitors = @('user1','user2','user3','user4','userX')
$chairs = @('linux','windows','cisco')
$today_is = $chairs | Out-GridView -Title 'Select Module' -OutputMode Single;
$role = Get-VIRole 'Admin'
$num = 1
foreach($competitor in $competitors) {
  Write-host "Competitor: $($competitor)"
  foreach($module in $chairs){
    $dc_name = "dc_$($module)_s$($num.ToString('00'))_$($competitor)"
    $perm = Get-VIPermission -Entity $dc_name -Principal "CLOUD\$($competitor)"
    if ( $today_is -eq $module ){
      if(!$perm){ $np = New-VIPermission -Entity $dc_name -Principal "CLOUD\$($competitor)" -Role $role -Propagate:$true }
      Write-Host "  [+] permissions to $($dc_name)"
    }
    else {
      if ($perm){  Remove-VIPermission -Permission $perm -Confirm:$false  }
      Write-Host "  [-] permissions to $($dc_name)"
    }
  }
  Write-Host '----------------------------------------------------'
  $num+=1
}

Disconnect-VIServer -Server $vcsa -Confirm:$false