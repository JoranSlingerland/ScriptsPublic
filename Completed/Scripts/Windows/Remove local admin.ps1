<#PSScriptInfo

.VERSION 1.1

.GUID 4dac2e59-90e6-42a7-975f-fdd9b9757ab5

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
 Script to remove currently logged on user from the local admin group

#>


#get current user
$user = $env:UserName
$fullusername = whoami 

#Fill variables
$group = "Administrators";
$groupObj =[ADSI]"WinNT://./$group,group" 
$membersObj = @($groupObj.psbase.Invoke("Members")) 
$members = ($membersObj | ForEach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)})

#remove user if member and logout
If ($members -contains $user) {
    net localgroup administrators /delete $fullusername
 }