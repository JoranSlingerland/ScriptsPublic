function set-alliasfromportal {
    <#
        .SYNOPSIS
        Script wil get the alliases currently set on the office 365 portal and set them on the ad users. Run from a computer with access to the AD. users UPN as anchor object.

        .DESCRIPTION
        
        .INPUTS
        None

        .OUTPUTS
        None

        .example
        connect-exchangeonline
        set-alliasfromportal
    #>
    
    write-Host "getting allias list"
    $users = Get-Recipient | Select-object Name, EmailAddresses

    foreach($line in $users){
        [string]$upn = $line.name
        [string]$allias = $line.EmailAddresses

        #split string to one entry per line
        
        #check if user exists
        if(get-aduser -filter "samaccountname -eq '$($upn)'"){
            $allias_list = $allias.split()

            foreach($line2 in $allias_list){
                $allias_list_split = $line2
                #create user
                set-ADUser -Identity $upn -Add @{proxyAddresses=$allias_list_split}
                #check if user has been created
                $confirm = Get-ADUser $upn -Properties proxyaddresses | Select-Object proxyaddresses
                if($confirm -contains "$allias_list_split"){
                    write-host "$allias_list_split has been created for user $upn"
                }
                else {
                    Write-Error "$allias_list_split could not be created for user $upn"
                }
            }
        else{
            Write-Error "user $upn does not exist in AD"
        }   
        }
    } 
}

function Set-ImmutableID {
    <#
        .SYNOPSIS
        set the immutableID to fix sync issues

        .DESCRIPTION
        
        .INPUTS
        username with and without domain

        .EXAMPLE
        connect-msolservice
        Set-ImmutableID -aduser username -365user username@contoso.com
    #>
    [cmdletbinding()]
    param (
        [Parameter(position=0,Mandatory=$true)]
        [String]$ADUser,

        [Parameter(position=1,mandatory=$true)]
        [string]$365User
    )

    $guid =(Get-ADUser $ADUser).Objectguid
    $immutableID=[system.convert]::ToBase64String($guid.tobytearray())
    Set-MsolUser -UserPrincipalName "$365User" -ImmutableId $immutableID
}

function Get-AdSyncStats {
    <#
        .SYNOPSIS
        get ad sync statistics if enabled

        .DESCRIPTION
        
        .INPUTS
        Get-AdSyncStats

        .EXAMPLE
        connect-msolservice
        Get-AdSyncStats
    #>
    $company = Get-MsolCompanyInformation
    if ($company.DirectorySynchronizationEnabled){
        $company | Select-Object DirectorySynchronizationEnabled,LastDirSyncTime,LastPasswordSyncTime,PasswordSynchronizationEnabled
    }else {
        "Dirsync is not enabled"
    }    
}