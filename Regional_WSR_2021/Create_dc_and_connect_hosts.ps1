
$vcsa = 'vcsacluster.ouiit.local'
Connect-VIServer -Server $vcsa

$modules = @('linux','windows')

$windows_hosts = Get-VM | Where-Object { $_.Name -match "REG-Win-2020-0[0-3]" } | Sort-Object -Property Name
$linux_hosts = Get-VM | Where-Object { $_.Name -match "REG-Linux-2020-0[0-3]" } | Sort-Object -Property Name

$esxi_linux_cerds = ''
$esxi_windows_cerds = ''

foreach ($module in $modules ){

    $folder = Get-Folder -Name $module 2>$null
    if (!$folder){
        $folder = Get-Folder -NoRecursion | New-Folder -Name $module
        Write-Host " [+] New Folder ($($folder)) was created"
    }

    for ($num=1; $num -le 3; $num++){
        $dc_name = "dc_$($module)_$($num.toString('00'))"
        $dc = Get-Datacenter -Name $dc_name 2>$null
        if (!$dc){
            $newdc = New-Datacenter -Name $dc_name -Location $folder
            Write-Host " [+] New DC($($dc_name)) was created"
        }

        $connected_hosts = Get-VMHost -Location $dc_name
        if (!$connected_hosts){
            if ($module -eq 'linux'){
                if( $esxi_linux_cerds -eq '' ){ 
                    $esxi_linux_cerds = Get-Credential -Message "Get Creds for LINUX"
                }
                $fqdn = $linux_hosts[$num-1].Name+".cloud.kp11.local"
                Add-VMHost $fqdn -Location $dc_name -Credential $esxi_linux_cerds -RunAsync -Force
                Write-Host " [+] ESXi ($($vm_name)) was added to DC $($dc_name)"
            }
            
            if ($module -eq 'windows'){
                if( $esxi_windows_cerds -eq '' ){ 
                    $esxi_windows_cerds = Get-Credential -Message "Get Creds for WINDOWS"
                }
                $fqdn = $windows_hosts[$num-1].Name+".cloud.kp11.local"
                Add-VMHost $fqdn -Location $dc_name -Credential $esxi_windows_cerds -RunAsync -Force
                Write-Host " [+] ESXi ($($vm_name)) was added to DC $($dc_name)"
            }
        }
    }

}

Disconnect-VIServer -Server $vcsa -Confirm:$false