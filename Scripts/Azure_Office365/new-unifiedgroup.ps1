<#PSScriptInfo

.VERSION 1.0

.GUID 68740d17-45af-4dcb-bbae-b074df0fe917

.AUTHOR Joran.slingerland@think4.nl

.COMPANYNAME Think4

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Script to generate office 365 groups using a input csv file.

#>

#load inputfile
$inputfile = import-csv -Delimiter "," -path "C:\Users\joran.slingerland\Documents\GitHub\Scripts\Azure_office365\groups.csv"

#start foreacht loop
foreach ($line in $inputfile) {
    
    #load csv file to variables
    $displayname = $line.displayname
    $smtp = $line.smtp
    $owner = $line.owner
    
    #create group
    New-UnifiedGroup -DisplayName $displayname -PrimarySmtpAddress $smtp -AccessType private -Owner $owner

    Add-UnifiedGroupLinks -Identity $displayname -LinkType Member -Links "t4admin@noordwijksegolfclub.nl"
    Add-UnifiedGroupLinks -Identity $displayname -LinkType Owner -Links "t4admin@noordwijksegolfclub.nl"
    Add-UnifiedGroupLinks -Identity $displayname -LinkType Member -Links "digitaal@noordwijksegolfclub.nl"
    Add-UnifiedGroupLinks -Identity $displayname -LinkType Owner -Links "digitaal@noordwijksegolfclub.nl"
    Set-UnifiedGroup $smtp -RequireSenderAuthenticationEnabled $false
}

