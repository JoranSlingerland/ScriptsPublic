Function Get-PnPPermission
{
    <#
        .SYNOPSIS
        Script will get sharepermissions of a sharepoint folder

        .DESCRIPTION
        
        .INPUTS
        folderrelativeurl requires a link formatted as "/sites/sitename/Gedeelde documenten/foldername"

        .OUTPUTS
        Will output the sharepermissions

        .example
        Connect-PnPOnline -url "https://example.sharepoint.com/sites/example/" -SPOManagementShell -ClearTokenCache
        Get-PnPPermission -FolderRelativeURL "/site/sitename/Gedeelde documenten/foldername"
    #>
    param (
    [Parameter(position=0,mandatory=$true)]
    [string]$FolderRelativeURL
    )
    
    $folder = Get-PnPFolder -Url $FolderRelativeURL -Includes ListItemAllFields.RoleAssignments
    $object = $Folder.ListItemAllFields

    #set up selectproperties
    $SelectPropertydirectpermissions = @(
        @{ Label = 'Title'; Expression = { $RoleAssignment.Member.Title } }
        @{ Label = 'PermissionType'; Expression = { $PermissionType } }
        @{ Label = 'Permissions'; Expression = { $PermissionLevels } }
        @{ Label = 'GrantedThrough'; Expression = { "Direct Permissions" } }
        @{ Label = 'folder'; Expression = { $FolderRelativeURL } }
        @{ Label = 'uniquepermissions'; Expression = { $object.HasUniqueRoleAssignments } } 
    )
    $SelectPropertygrouppermissions = @(
        'Title',
        @{ Label = 'PermissionType'; Expression = { $PermissionType } }
        @{ Label = 'Permissions'; Expression = { $PermissionLevels } }
        @{ Label = 'GrantedThrough'; Expression = { ("SharePoint Group: $($RoleAssignment.Member.LoginName)") } }
        @{ Label = 'folder'; Expression = { $FolderRelativeURL } }
        @{ Label = 'uniquepermissions'; Expression = { $object.HasUniqueRoleAssignments } }
    )
            
    #Get permissions assigned to the Folder
    Get-PnPProperty -ClientObject $Object -Property HasUniqueRoleAssignments, RoleAssignments

    Foreach($RoleAssignment in $Object.RoleAssignments)
    {   
        #Get the Permission Levels assigned and Member
        Get-PnPProperty -ClientObject $RoleAssignment -Property RoleDefinitionBindings, Member

        #Get the Principal Type: User, SP Group, AD Group
        $PermissionType = $RoleAssignment.Member.PrincipalType
        $PermissionLevels = $RoleAssignment.RoleDefinitionBindings | Select-Object -ExpandProperty Name

        #Remove Limited Access
        $PermissionLevels = ($PermissionLevels | Where-Object {$_ -ne "Limited Access"}) -join ","
        If($PermissionLevels.Length -eq 0) {Continue}

        #Get SharePoint group members
        If($PermissionType -eq "SharePointGroup")
        {
            #Get Group Members
            $GroupMembers = Get-PnPGroupMembers -Identity $RoleAssignment.Member.LoginName
                
            #Leave Empty Groups
            If($GroupMembers.count -eq 0){Continue}

            ForEach($User in $GroupMembers)
            {   
                $user | Select-Object -Property $SelectPropertygrouppermissions
            }
        }
        Else
        {           
            $RoleAssignment | Select-Object -Property $SelectPropertydirectpermissions
        }
    } 
}


Function Get-PnPFolderRecurse{
    <#
        .SYNOPSIS
        Script will get all sharepoint folders

        .DESCRIPTION
        
        .INPUTS
        folderrelativeurl requires a link formatted as "/Gedeelde documenten"

        .OUTPUTS
        Will output all folders

        .example
        Connect-PnPOnline -url "https://example.sharepoint.com/sites/example/" -SPOManagementShell -ClearTokenCache
        Get-PnPFolderRecurse -shorturl "/Gedeelde documenten"
    #>
    param (
    [Parameter(position=0,mandatory=$true)]
    [string]$shorturl
    )
    $folderColl = Get-PnPFolderItem -FolderSiteRelativeUrl $shorturl -ItemType Folder
    # Loop through the folders  
    foreach($folder in $folderColl)  
    {                   
       $newFolderURL = $shorturl+"/"+$folder.Name
       $newFolderURL
       # Call the function to get the folders inside folder  
       Get-PnPFolderRecurse -shorturl $newFolderURL
    }
}

function Get-PnPPermissionsRecurse{
    <#
        .SYNOPSIS
        Script will get all sharepoint accesrights recursivly  

        .DESCRIPTION
        
        .INPUTS
        folderrelativeurl requires a link formatted as "/Gedeelde documenten"

        .OUTPUTS
        Will output all folders

        .NOTES
        Makes use of 

        .example
        Connect-PnPOnline -url "https://example.sharepoint.com/sites/example/" -SPOManagementShell -ClearTokenCache
        get-pnppermissionsrecurse -shorturl "/Gedeelde documenten" -site "/sites/example"
    #>
    param (
    [Parameter(position=0,mandatory=$true)]
    [string]$shorturl,
    [Parameter(position=1,mandatory=$true)]
    [string]$site
    )

    $folders = Get-PnPFolderRecurse -shorturl $shorturl
    foreach ($folder in $folders) {
        $FolderRelativeURL = $site + $folder
        Get-PnPPermission -FolderRelativeURL $FolderRelativeURL
    }
}

function Set-ExcludeFromOfflineClient {
    <#
        .SYNOPSIS
        set $false to turn on set $true to turn off
        .DESCRIPTION
        
        .INPUTS
        username with and without domain

        .example
        set-ExcludeFromOfflineClient -siteurl https://contoso.sharepoint.com/sites/test -ExcludeFromOfflineClient $true
        command above will turn the sync client off
    #>
    param (
        [Parameter(position=0,Mandatory=$true)]
        [String]$SiteURL,
        [Parameter(position=1,Mandatory=$true)]
        [bool]$ExcludeFromOfflineClient
    )   
    #Connect to SharePoint Online site
    Connect-PnPOnline -SPOManagementShell -Url $SiteURL -cleartokencache
    
    #Get the Web
    $Web = Get-PnPWeb -Includes ExcludeFromOfflineClient 
    
    #Set "$True turns it off $false turns it on
    $web.ExcludeFromOfflineClient = $ExcludeFromOfflineClient
    $web.Update()
    Invoke-PnPQuery
}