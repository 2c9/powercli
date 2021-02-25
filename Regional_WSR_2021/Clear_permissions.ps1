
$vcsa = 'vcsacluster.ouiit.local'
Connect-VIServer -Server $vcsa

$esxi_hosts = Get-VM | Where-Object { $_.Name -match "REG-(Win|Linux)-2020-0[0-3]" } | Sort-Object -Property Name
$datacenters = Get-Datacenter | Where-Object { $_.Name -match "dc_(linux|windows)_0[1-3]" } | Sort-Object -Property Name

ForEach( $datacenter in $datacenters ){

    Write-Host "$($datacenter.Name):"

    # Clean permissions
    $perms = Get-VIPermission -Entity $datacenter.Name -Principal 'CLOUD\*'
    ForEach($perm in $perms){
        Write-Host "   [-] Remove $($perm.Principal) from $($datacenter.Name)"
        Remove-VIPermission -Permission $perm -Confirm:$false
    }

}

Disconnect-VIServer -Server * -Confirm:$false