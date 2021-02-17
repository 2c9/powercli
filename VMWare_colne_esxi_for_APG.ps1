$vcsa = 'vcsacluster.ouiit.local'
Connect-VIServer -Server $vcsa

# Clone VMs
$ln = Get-VM -Name EuroLinux2020-XX
for($num=1; $num -lt 11; $num++){
   New-VM -Name "EuroLinux2020-$($num.ToString('00'))" `
          -VM $ln.Name `
          -ResourcePool $ln.ResourcePool `
          -Datastore 'vsandatastore' `
          -AdvancedOption $(Get-SpbmStoragePolicy 'RAID0') `
          -RunAsync:$true
}

while ( Get-Task -Status Running | Where { $_.ExtensionData.Info.EntityName -eq 'EuroLinux2020-XX' } ) { Sleep 10 }

#Vars
$password = 'Pa$$w0rd-2020'
$vms = Get-VM | Where-Object { $_.Name -match "EuroLinux2020-[0-1][0-9]" } | Sort-Object -Property Name

#Add stands to VM Group
$dcg = Get-DrsClusterGroup -Name Euro
Write-Host "Euro VM Group:"
foreach($vm in $vms){
  if ( !$dcg.Member.Contains($vm) ){ Set-DrsClusterGroup -DrsClusterGroup $dcg -VM $vm.Name -Add }
  Write-Host "  [+] - $($vm.Name)"
}
(Get-DrsClusterGroup -Name Euro).Member | Sort-Object -Property Name

#Change vmk
foreach($vm in $vms){
  $vm | Start-VM -Confirm:$false
  while(!$vm.Guest.IPAddress){
    sleep 2
    $vm = Get-VM -Name $vm.Name
  }
  $ipaddr = $vm.Guest.IPAddress[0]
  $nested = Connect-VIServer -Server $ipaddr -User 'root' -Password $password
    # Connect to nested esx, set its hostname and create new vmk interface 
    Get-AdvancedSetting -Entity (Get-VMhost $nested) `
                        -Name Misc.PreferredHostName | Set-AdvancedSetting -Value $vm.Name -Confirm:$false
    Get-AdvancedSetting -Entity (Get-VMhost $nested) `
                        -Name Misc.HostName | Set-AdvancedSetting -Value $vm.Name -Confirm:$false
    $vmhost = Get-VMHost -Name $ipaddr
    $vmks_before = $vmhost | Get-VMHostNetworkAdapter -VMKernel
    $vSwitch = Get-VirtualSwitch -VMHost $vmhost -Name 'vSwitch0'
    $newNic = New-VMHostNetworkAdapter -VMHost $vmhost `
                                       -VirtualSwitch $vSwitch `
                                       -PortGroup 'mgmt' `
                                       -ManagementTrafficEnabled $true
    while ($newNic.IP -eq '0.0.0.0') { $newNic = Get-VMHostNetworkAdapter -Name $newNic.DeviceName }
    $new_vmk_ip = $newNic.IP
    $newNic.IP
    $new_vmk_dev = $newNic.DeviceName
    $new_mac = $newNic.mac
  Disconnect-VIServer -Server $ipaddr -Confirm:$false
  Sleep 2
  $nasted = Connect-VIServer -Server $new_vmk_ip -User 'root' -Password $password
    # Connect with new ip address and delete the old vmk interface
    $vmhost = Get-VMHost -Name $new_vmk_ip
    $new_vmk_ip
    $vmks_after = $vmhost | Get-VMHostNetworkAdapter -VMKernel
    foreach ( $vmk in $vmks_after ){
      if ( $vmk.DeviceName -ne $new_vmk_dev ) { Remove-VMHostNetworkAdapter -Nic $vmk -Confirm:$false }
    }
  Disconnect-VIServer -Server $new_vmk_ip -Confirm:$false
}

#Change network
$networkname = 'DPortGroupVLAN666'
$vms | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $networkname `
                                               -StartConnected $true `
                                               -Confirm:$false
$vms | Restart-VMGuest -Confirm:$false

#Take a snapshot
$vms = Get-VM | Where-Object { $_.Name -match "EuroLinux2020-[0-1][0-9]" } | Sort-Object -Property Name
$vms | New-Snapshot -Name 'work_2020.10.26' -Memory:$false -Confirm:$false -RunAsync:$true

Disconnect-VIServer -Server $vcsa -Confirm:$false