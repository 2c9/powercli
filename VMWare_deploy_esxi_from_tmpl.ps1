
$vcsa = 'vcsacluster.ouiit.local'
Connect-VIServer -Server $vcsa

# Clone VMs
$template = 'OTJS-XX' 
$ln = Get-VM -Name $template

for($num=3; $num -lt 56; $num++){
   New-VM -Name "OTJS-$($num.ToString('00'))" `
          -VM $ln.Name `
          -ResourcePool $ln.ResourcePool `
          -Datastore 'vsandatastore' `
          -RunAsync:$true
}

# Monitor the stage of creation
Get-Task -Status Running | Where { $_.ExtensionData.Info.EntityName -eq $template } | Measure-Object -Line

# Get VMs
$vmregex = 'OTJS-[0-9][0-9]'
$vms = Get-VM | Where-Object {$_.Name -like $vmregex }

#Check
$vms | Sort-Object -Property Name

# Start all VMs
$vms | Start-VM

# $mac = $mac -replace ":",""
# Create CSV for DHCP reservation
$count = 144
$vms | Sort-Object -Property Name |
    ForEach-Object{
        New-Object PSObject -Property @{NAME = $_.Name; MAC = $_.Guest.ExtensionData.Net.MacAddress -replace ":",""; IP = "172.30.66.$($count.ToString())" }
        $count = $count + 1
    } | Sort-Object -Property Name | Export-Csv -Path D:\otjs.csv -NoTypeInformation

#Restart ALL VM
$vms | Restart-VM -RunAsync -Confirm

# SnapShot
$vms | New-Snapshot -Name 'work' -Memory:$false -Confirm:$false -RunAsync:$true

############# The second day ( competitor's rotation) ################ 

#Revert
$vms | Set-VM -Snapshot 'work' -Confirm:$false

Disconnect-VIServer -Server $vcsa -Confirm:$false