
$vcsa = 'vcsacluster.ouiit.local'
Connect-VIServer -Server $vcsa

$name_tmpl = "LinuxDemo-2019-"

$count = 61
for($i=21; $i -lt 40; $i++){
    $name = $name_tmpl + $i.ToString('00')
    $vm = Get-VM $name
    $name = $vm.name.ToLower()
    $mac = $vm.Guest.ExtensionData.Net.MacAddress
    $reservation = "host $($name) { hardware ethernet $($mac); fixed-address 172.16.97.$($count); }"
    $count += 1
    #$reservation
    #$vm | Restart-VMGuest -Confirm:$false
    #$vm | Get-Snapshot -Name 'work' | Remove-Snapshot -Confirm:$false
    #$vm | Stop-VMGuest -Confirm:$false
    #$vm | New-Snapshot -Name 'work' -Memory:$false -Confirm:$false -RunAsync:$true
    $vm | Start-VM -Confirm:$false
}


Disconnect-VIServer -Server *