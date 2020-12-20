$mailboxes = Import-Csv .\groups.csv

foreach($line in $mailboxes){
    $mailbox = $line.name
    $trustee = $line.trustee
    Add-RecipientPermission $mailbox -AccessRights SendAs -Trustee $trustee
}