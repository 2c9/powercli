$vcsa = 'vcsacluster.ouiit.local'
Connect-VIServer -Server $vcsa

$regexp = 'Esxi1416-[0-9][0-9]'
$vms = Get-VM | Where-Object {$_.Name -like $regexp }

#Check
$vms | Sort-Object -Property Name

# Start all VMs
$vms | Start-VM

# $mac = $mac -replace ":",""
# Create CSV
$count = 91
Get-VM | Where-Object {$_.Name -like $regexp } | Sort-Object -Property Name |
    ForEach-Object{
        New-Object PSObject -Property @{NAME = $_.Name; MAC = $_.Guest.ExtensionData.Net.MacAddress -replace ":",""; IP = "172.30.66.$($count.ToString())" }
        $count = $count + 1
    } | Sort-Object -Property Name | Export-Csv -Path D:\otjs.csv -NoTypeInformation

# SnapShot
Get-VM | Where-Object {$_.Name -like $regexp } | New-Snapshot -Name 'work' -Memory:$false -Confirm:$false -RunAsync:$true

Disconnect-VIServer -Server * -Confirm:$false