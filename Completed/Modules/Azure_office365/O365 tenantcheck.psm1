function Get-PasswordPolicy {
    #properties to select
    $SelectProperty0 = @(
        @{ Label = 'validityperiod'; Expression = {$_.validityperiod } }
        @{ Label = 'notificationdays'; Expression = { $_.notificationdays } }
        @{ Label = 'domainname'; Expression = { $domain.Name } } )
    $SelectProperty1 = @(
        @{ Label = 'validityperiod'; Expression = {"No expiration" } }
        @{ Label = 'notificationdays'; Expression = { $_.notificationdays } }
        @{ Label = 'domainname'; Expression = { $domain.Name } } )
    #get domains
    $domains = Get-MsolDomain
    
    #get policies
    foreach($domain in $domains){
       $policies = Get-MsolPasswordPolicy -DomainName $domain.name
       #select output
       foreach ($policy in $policies) {
            if ($policy.validityperiod -lt 800) {
                $policy | Select-Object -property $SelectProperty0
            }
            else {
                $policy | Select-Object -property $SelectProperty1
            }         
       }
    }  
}


function Get-Admins {
    #properties to select
    $SelectProperty = @(
        @{ Label = 'RoleMemberType'; Expression = {$_.RoleMemberType } }
        @{ Label = 'EmailAddress'; Expression = { $_.EmailAddress } }
        @{ Label = 'DisplayName'; Expression = { $_.DisplayName } }
        @{ Label = 'Role'; Expression = { $role.Name } } )
    #get domains
    $roles = Get-Msolrole
    
    #get policies
    foreach($role in $roles){
       $admins = Get-MsolRoleMember -RoleObjectId $(Get-MsolRole -RoleName $role.Name).ObjectId
       foreach ($admin in $admins) {
       $admin | Select-Object -Property $SelectProperty
       }
    }
}


function Get-Licences {
    Get-MsolAccountSku | Select-Object accountskuid, activeunits, consumedunits
}


function Get-Domains {  
    $SelectProperty = @(
        @{ Label = 'Name'; Expression = {$_.Name } }
        @{ Label = 'Status'; Expression = { $_.Status } }
        @{ Label = 'Capabilities'; Expression = { $_.capabilities } }
        )  
    Get-MsolDomain | Select-Object -Property $SelectProperty
}

function Get-Delegatedpermissions {
    $sesion = Get-PSSession | Where-Object {$_.configurationname -eq "microsoft.exchange"}
    if ($sesion.count -gt 0) {
        get-mailbox | Get-MailboxPermission | Where-Object {$_.User -notlike "NT AUTHORITY\SELF"}
    }
    else {
        write-error -Message "not connected to exchange, Please run connect-exchangeonline first"
    }   
}

function Get-mailboxfowardingrule {
    $sesion = Get-PSSession | Where-Object {$_.configurationname -eq "microsoft.exchange"}
    if ($sesion.count -gt 0) {
        $SelectProperty = @(
        @{ Label = 'UserPrincipalName'; Expression = {$_.UserPrincipalName } }
        @{ Label = 'ForwardingAddress'; Expression = { $_.ForwardingAddress } }
        @{ Label = 'ForwardingSmtpAddress'; Expression = { $_.ForwardingSmtpAddress } }
        @{ Label = 'DeliverToMailboxAndForward'; Expression = { $_.DeliverToMailboxAndForward } }         
        ) 

        Get-Mailbox | Where-object {$null -ne $_.ForwardingAddress -or $null -ne $_.ForwardingSmtpAddress} | Select-Object -Property $SelectProperty
    }
    else {
        write-error -Message "not connected to exchange, Please run connect-exchangeonline first"
    }  
}

function Get-mailboxrule {
    $sesion = Get-PSSession | Where-Object {$_.configurationname -eq "microsoft.exchange"}
    if ($sesion.count -gt 0) {
        $mailboxes = get-mailbox
        $SelectProperty = @(
        @{ Label = 'UserPrincipalName'; Expression = {$mailbox.UserPrincipalName } }
        @{ Label = 'Name'; Expression = { $_.Name } }
        @{ Label = 'Enabled'; Expression = { $_.Enabled } }       
        @{ Label = 'Description'; Expression = { $_.Description } }
        ) 

        foreach ($mailbox in $mailboxes) {
            get-inboxrule -mailbox $mailbox.UserPrincipalName | Select-Object -Property $SelectProperty
        }
    }
    else {
        write-error -Message "not connected to exchange, Please run connect-exchangeonline first"
    }
    
}