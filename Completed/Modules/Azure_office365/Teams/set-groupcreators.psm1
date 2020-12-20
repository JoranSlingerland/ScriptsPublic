function Set-GroupCreators {
    <#
        .SYNOPSIS
        Will restrict accces for creating groups

        .DESCRIPTION
        Script stolen from https://docs.microsoft.com/en-us/microsoft-365/solutions/manage-creation-of-groups?view=o365-worldwide recreated as a module.
        
        .INPUTS
        Groupname

        .OUTPUTS
        None

        .example
        connect-azuread
        Set-GroupCreators -GroupName "Group_creators"
        Command above will only allow only the group Group_creators to create new groups

        connect-azuread
        Set-GroupCreators -GroupName "" -AllowGroupCreation $true
        Command Above will reset the group creation and allow everybody to create groups again
    #>
    param (
        [Parameter(position=0,mandatory=$true)]
        [string]$GroupName,
        [Parameter(position=1,mandatory=$false)]
        $AllowGroupCreation = $false
    )

    $settingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id
    if(!$settingsObjectID)
    {
        $template = Get-AzureADDirectorySettingTemplate | Where-object {$_.displayname -eq "group.unified"}
        $settingsCopy = $template.CreateDirectorySetting()
        New-AzureADDirectorySetting -DirectorySetting $settingsCopy
        $settingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id
    }

    $settingsCopy = Get-AzureADDirectorySetting -Id $settingsObjectID
    $settingsCopy["EnableGroupCreation"] = $AllowGroupCreation

    if($GroupName)
    {
        $settingsCopy["GroupCreationAllowedGroupId"] = (Get-AzureADGroup -SearchString $GroupName).objectid
    }
    else {
    $settingsCopy["GroupCreationAllowedGroupId"] = $GroupName
    }
    Set-AzureADDirectorySetting -Id $settingsObjectID -DirectorySetting $settingsCopy

    (Get-AzureADDirectorySetting -Id $settingsObjectID).Values
}



