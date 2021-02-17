$vcsa = "vcsacluster.ouiit.local"
Connect-VIServer -Server $vcsa

$chairs = @('linux','windows','cisco')
$competitors = @('user1','user2','user3','user4','userX')

$module = $chairs | Out-GridView -Title 'Select Module' -OutputMode Single;
$vms = Get-Vm | Where Name -like 'Euro*' | Out-GridView -Title 'Select VMs' -OutputMode Multiple;
$password = Read-Host -Prompt 'Enter root password'
$num = 1
foreach($vm in $vms) {
    $competitor = $competitors[$num-1]
    $dc_name = "dc_$($module)_s$($num.ToString('00'))_$($competitor)"
    $fqdn = $vm.Name + '.cloud.mydomain.local'
    Write-Host "$($vm.Name):"
    Write-Host "   [o] DC                 : $($dc_name)"
    Write-Host "   [o] Competitor         : $($competitor)"
    Write-Host "   [o] Expected hostname  : $($fqdn)"
    Write-Host "   [o] Retrieved hostname : $($vm.Guest.HostName)"
    Write-Host "   [o] IPAddress          : $($vm.Guest.IPAddress)"
    Add-VMHost $fqdn -Location $dc_name -User root -Password $password -RunAsync -Force
    Write-Host '------------------------------------------'
    $num+=1
}

Disconnect-VIServer -Server $vcsa -Confirm:$false