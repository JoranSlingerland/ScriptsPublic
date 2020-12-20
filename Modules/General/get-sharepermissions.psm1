#main function
function get-sharepermissions {
    [cmdletbinding()]
    param (
        [Parameter(position=0,Mandatory=$true)]
        [String]$inputpath,

        [Parameter(position=1,mandatory=$false)]
        [int]$depth = 0
    )
    
    #static variable
    $SelectProperty = @(
    'IdentityReference',
    'FileSystemRights',
    'AccessControltype',
    @{ Label = 'FolderPath'; Expression = { $FolderPath } } )
        
    $ErrorActionPreference = "stop"
    
    #check if server, share or local filepath and get subfolders
    $count = [regex]::matches($inputpath,"\\").count
    
    #run the script in local/share context
    if(($count -ge 3) -or ($inputpath -contains ":")) {
        $temp = Get-ChildItem $inputpath -Depth $depth -Directory
        $sharename = $temp.FullName
        
        #get acl and output to csv
        foreach($name in $sharename){
            $folderpath = $name
            try {
                Get-Acl -Path $folderpath |
                Select-Object -ExpandProperty access |
                Select-Object -Property $SelectProperty
            }
            catch {
            write-warning "Could not execute on share $folderpath"
            }          
        }
    }
    #run the script in server context
    else{
        $sharename = net view "$inputpath" /all | Select-Object -Skip 7 | Where-Object{$_ -match 'disk*'} | ForEach-Object{$_ -match '^(.+?)\s+Disk*'|out-null;$matches[1]}
        if ($depth -le 0) {
            ##get acl and output to csv for depth 0
            foreach($name in $sharename){
                $folderpath = $inputpath + "\" + $name
                try {
                    Get-Acl -Path $folderpath |
                    Select-Object -ExpandProperty access |
                    Select-Object -Property $SelectProperty
                }
                catch {
                    write-warning "Could not execute on share $folderpath"
                }                   
            }
        }
        #get acl and output to csv for depth 1 or higher
        else {
            #get acl for top level
            foreach($name in $sharename){
                $folderpath = $inputpath + "\" + $name
                try {
                    Get-Acl -Path $folderpath |
                    Select-Object -ExpandProperty access |
                    Select-Object -Property $SelectProperty
                }
                catch {
                write-warning "Could not execute on share $folderpath"
                }            
            }
            $depth -= 1
            #get acl for lower levels
            foreach ($name in $sharename) {
                try {
                    $inputpath2 = "$inputpath\" + $name
                    $temp = Get-ChildItem $inputpath2 -Depth $depth -Directory
                    $sharename2 = $temp.FullName
                }
                catch {
                    write-warning "Could not execute on share $inputpath2"
                }
                
                foreach($name2 in $sharename2){
                    $folderpath = $name2
                    try {
                        Get-Acl -Path $folderpath |
                        Select-Object -ExpandProperty access |
                        Select-Object -Property $SelectProperty
                    }
                    catch {
                    write-warning "Could not execute on share $folderpath"
                    }                  
                }
            }
        }        
    }     
}