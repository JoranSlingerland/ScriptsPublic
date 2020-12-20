function get-groupmemberscustom {
    [cmdletbinding()]
    param (
        [Parameter(position=1,mandatory=$true)]
        [String]$OU
    )
    #getadgroups
    $groups = get-adgroup -filter $OU
    #static variables
    $SelectProperty = @(
    @{ Label = 'Groupname'; Expression = { $group.Name } }
    @{ Label = 'Name'; Expression = { $_.Name } }
    @{ Label = 'SamAccountName'; Expression = { $_.SamAccountName } }
    )

    #get-members
    foreach ($group in $groups) {     
        get-adgroupmember $group.name | select-Object -Property $SelectProperty
    }
}