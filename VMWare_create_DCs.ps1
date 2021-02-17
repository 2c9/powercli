
$vcsa = 'vcsacluster.ouiit.local'
Connect-VIServer -Server $vcsa

$competitors = @('user1','user2','user3','user4','userX')
$modules = @('linux','windows','cisco')
$num = 1
foreach($competitor in $competitors) {
    foreach ($module in $modules ){
        $dc_name = "dc_$($module)_s$($num.toString('00'))_$($competitor)"
        $newdc = New-Datacenter -Name $dc_name -Location $module;
    }
    $num+=1
}

Disconnect-VIServer -Server $vcsa -Confirm:$false