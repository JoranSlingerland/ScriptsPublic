<#PSScriptInfo

.VERSION 1.0

.GUID f4faf227-f463-41cc-87d2-360f5675da3f

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
 Version
    Script that sets to regkey
#>

#set paramters
$Path1 = "HKCR:\jpegfile\shell\open\command"
$path2 = "HKCR:\pngfile\shell\open\command"
$value1 = '%SystemRoot%\\system32\\mspaint.EXE \"%1\"'
$value2 = '@="%SystemRoot%\\system32\\mspaint.EXE \"%1\"'



#create psdrive
if(!(test-path "hkcr:\")){
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
}

if(![System.IO.File]::Exists($path1)){
    New-Item -Force -Path $Path1
}
if(![System.IO.File]::Exists($path2)){
    New-Item -Force -Path $Path2
}

New-ItemProperty -name "(Default)" -Path $Path1 -Value $value1 -PropertyType String -Force | Out-Null
New-ItemProperty -name "(Default)" -Path $Path2 -Value $value2 -PropertyType String -Force | Out-Null