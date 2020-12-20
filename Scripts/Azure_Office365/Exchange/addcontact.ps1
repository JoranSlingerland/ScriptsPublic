$inputfile = import-csv "C:\contacts.csv"

foreach ($line in $inputfile) {

$name = $line.name
$eea = $line.eea
$disname = $line.disname

New-MailContact -Name $name -ExternalEmailAddress $eea -displayName $disname
}