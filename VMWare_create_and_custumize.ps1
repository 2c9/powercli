Connect-VIServer -Server vcsacluster.ouiit.local

$oscust = Get-OSCustomizationSpec -Name "ubuntu"
$template = Get-Template 'ubuntu'
$rp = 'k8s-ubuntu'
$ds = Get-Datastore -Name 'vsandatastore'

for($num=1; $num -le 3; $num++){
   New-VM -Name "k8s-uc-$($num.ToString('00'))" `
          -Template $template `
          -ResourcePool $rp `
          –OSCustomizationSpec $oscust `
          -Datastore $ds `
          -RunAsync:$true
}

Get-VM -Name 'k8s-uc-0[1-3]' | sort | Format-Table -Property Name,@{Label='MAC'; Expression={$_.ExtensionData.Guest.Net.MacAddress}}
Get-VM -Name 'k8s-uc-0[1-3]' | Restart-VMGuest -Confirm:$false

Disconnect-VIServer -Server *