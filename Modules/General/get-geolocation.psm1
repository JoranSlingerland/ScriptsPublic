function get-geolocation {
    param (
        [Parameter(position=0,Mandatory=$true)]
        [String]$ip
    )
    $url = "http://api.db-ip.com/v2/free/$ip"
    Invoke-RestMethod -Uri $url
}