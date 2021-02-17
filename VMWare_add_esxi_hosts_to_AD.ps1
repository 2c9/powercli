$cred = Get-Credential

# Linux
#$users = ( "OUIIT\user1", "OUIIT\user2" )
# Windows
$users = ( "OUIIT\user1", "OUIIT\user2" )

Connect-VIServer -Server $vcsa -Credential $cred
#$vms = ( Get-VM | Where-Object {$_.Name -like 'Linux-[0-2][0-9]-Demo' } | Sort-Object Name | Select-Object -First 18 )
#$vms = Get-VM | Sort Name | Out-GridView -Title 'Select VMs' -OutputMode Multiple;
$vms = ( Get-VM | Where-Object {$_.Name -like 'Win-[0-2][0-9]-DEMO2020' } | Sort-Object Name | Select-Object -First 19 )

$count=0
ForEach($vm in $vms){
    Set-VM $vm -Notes $users[$count] -confirm:$false | select Name,Notes
    $vms[$count] | Add-Member -Name User -MemberType NoteProperty -Value $users[$count]
    $count=$count+1
}
$vms.Guest.IPAddress
Disconnect-VIServer -Server $vcsa -Confirm:$false

$vms | select Name,Notes
$vms.Guest.IPAddress

$count = 0
ForEach($vm in $vms){
    Write-Host "VM: $($vm.Name), IP: $($vm.Guest.IPAddress), User: $($vm.Notes)"
    
    Connect-VIServer -Server $vm.Guest.IPAddress -User root -Password 'Pa$$w0rd'

    #Get-VIPrivilege -PrivilegeGroup |select name,id
    New-VIRole -Name CompetitorWSR -Privilege (Get-VIPrivilege -id System,Datacenter,Datastore,VirtualMachine,VirtualMachine.Inventory,VirtualMachine.Interact,VirtualMachine.GuestOperations,VirtualMachine.Config,VirtualMachine.State,VirtualMachine.Hbr,VirtualMachine.Provisioning,VirtualMachine.Namespace)
    
    #Get-VIPermission -Principal WSR | Remove-VIPermission
    New-VIPermission -Entity $(Get-VMHost) -Principal "WSR" -Role "CompetitorWSR" -Propagate:$true -Confirm:$false

    #You can enter the domain name in one of two ways:
    #    name.tld (for example, domain.com): The account is created under the default container.
    #    name.tld/container/path (for example, domain.com/OU1/OU2): The account is created under a particular organizational unit (OU).
    Get-VMHostAuthentication | Set-VMHostAuthentication -JoinDomain "ouiit.local/esxi/windowsdemo" -Credential $cred -Confirm:$false
    # Get-VIRole | Select Name, Description
    New-VIPermission -Entity $(Get-VMHost) -Principal $vm.User -Role "CompetitorWSR" -Propagate:$true
    New-VIPermission -Entity $(Get-VMHost) -Principal "OUIIT\dmitry" -Role "Admin" -Propagate:$true

    Disconnect-VIServer -Server $vm.Guest.IPAddress -confirm:$false

}

Disconnect-VIServer -Server * -Force