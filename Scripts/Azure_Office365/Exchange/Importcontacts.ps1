$contacts = Import-Csv C:\input.csv 

foreach($line in $contacts){
    new-mailcontact `
    -Name $line.Name `
    -DisplayName $line.Name `
    -ExternalEmailAddress $line.ExternalEmailAddress `
    -FirstName $line.FirstName `
    -LastName $line.LastName
}


ForEach($line in $contacts) {
    Set-Contact $line.Name `
    -StreetAddress $line.StreetAddress `
    -City $line.City `
    -StateorProvince $line.StateorProvince `
    -PostalCode $line.PostalCode `
    -Phone $line.Phone `
    -MobilePhone $line.MobilePhone `
    -Pager $line.Pager `
    -HomePhone $line.HomePhone `
    -Company $line.Company `
    -Title $line.Title `
    -OtherTelephone $line.OtherTelephone `
    -Department $line.Department `
    -Fax $line.Fax `
    -Initials $line.Initials `
    -Notes  $line.Notes `
    -Office $line.Office `
    -Manager $line.Manager
}