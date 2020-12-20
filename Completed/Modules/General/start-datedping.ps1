function start-datedping {
    param (
        $address
    )
    Ping.exe -t $address | ForEach-Object {"{0} - {1}" -f (Get-Date),$_}
}
