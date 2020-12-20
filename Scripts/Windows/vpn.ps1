$vpnName = "vpn naam"
$yournetwork = "netwerk naam"
while($true){
    $network = Get-NetConnectionProfile | Select-Object Name 
    if($network.Name -ne $yournetwork){
        rasdial $vpnName
        }
    else{
        start-sleep -seconds 10
    }
}