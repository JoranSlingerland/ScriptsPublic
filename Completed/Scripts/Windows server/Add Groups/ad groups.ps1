#import prerequisits
$inputfile = import-csv -path "C:\import2.csv" -Delimiter .

foreach ($line in $inputfile) {
    #Load csv file to variables
    $group      = $line.group
    $gcat       = $line.GroupCategory
    $gscope     = $line.groupscope
    $dname      = $line.displayname
    $ou         = $line.ou

    #create new group
    New-ADGroup `
        -Name $group `
        -SamAccountName $group `
        -GroupCategory $gcat `
        -GroupScope $gscope `
        -DisplayName $dname `
        -Path $ou  
}