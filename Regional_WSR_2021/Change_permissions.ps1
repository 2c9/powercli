
$vcsa = 'vcsacluster.ouiit.local'
Connect-VIServer -Server $vcsa

$role = Get-VIRole "WSR39"
$competitors = 'user1', 'user2', 'user3', 'user4', 'userX'
$datacenters = Get-Datacenter | Where-Object { $_.Name -match "dc_(linux|windows)_0[1-3]" } | Sort-Object -Property Name

ForEach( $datacenter in $datacenters ){

    Write-Host "$($datacenter.Name):"

    # Clean permissions
    $perms = Get-VIPermission -Entity $datacenter.Name -Principal 'CLOUD\*'
    ForEach($perm in $perms){
        Write-Host "   [-] Remove $($perm.Principal) from $($datacenter.Name)"
        Remove-VIPermission -Permission $perm -Confirm:$false
    }

    # Select a competitor
    $competitor = $competitors | Out-GridView -Title "Select Kukusik for $($datacenter.Name)" -OutputMode Single;
    $competitors.Remove($competitor)

    # Set permission
    $np = New-VIPermission -Entity $datacenter.Name -Principal "CLOUD\$($competitor)" -Role $role -Propagate:$true
    Write-Host "   [+] $($competitor) is assigned to $($datacenter.Name)"

    Write-Host "DC permissions:"
    $perms = Get-VIPermission -Entity $datacenter.Name -Principal 'CLOUD\*'
    $perms.Principal
    Write-Host "--------"
    Write-Host ""
}

Disconnect-VIServer -Server $vcsa -Confirm:$false