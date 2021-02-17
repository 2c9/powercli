$pairs = import-csv 'vm.csv'

Foreach ( $pair in $pairs){
    Set-DhcpServerv4OptionValue -ReservedIP $pair.ip -Option 12 -Value $pair.name
    Get-DHCPServerV4Lease -IPAddress $pair.ip | Add-DhcpServerv4Reservation -Name "$($pair.name).oavt.local"
    Add-DnsServerResourceRecordA -Name $pair.name -ZoneName "oavt.local" -IPv4Address $pair.ip
}