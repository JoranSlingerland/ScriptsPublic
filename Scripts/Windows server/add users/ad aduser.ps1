#import prerequisits
$inputfile = import-csv -Delimiter ";" -path "C:\eldermans.csv"


foreach ($line in $inputfile) {
    
    #load csv file to variables
    $Username = $line.username
    $password = $line.Password
    $Firstname = $line.firstname 
    $lastname = $line.lastname 
    $ou = $line.ou
    $domain = $line.domain
    #$customprofile = $line.customprofile
  
    #check if user exsists
    if (Get-ADUser -F { SamAccountName -eq $Username }) {
        #If user does exist, output a warning message
        Write-Warning "A user account $Username already exist in Active Directory."
    }
    else {
   
        #load home drive and profile
        # $customprofile = "\\server\share" + $username
        # $homedir = "\\dc01\" + $username
   
   
        #creating new aduser, check if the domain is correct 
        New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@$domain" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -ChangePasswordAtLogon $false `
            -DisplayName "$firstname $lastname" `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) `
            #-profilepath $customprofile 
            #-HomeDirectory $homedir -HomeDrive "H:"
            #check if user is created
        if (Get-ADUser -F { SamAccountName -eq $Username }) {
            #Output that user has been created
            Write-host "A user account $Username has been created in $OU"
        }
        else{
            Write-Host "user could not be created"
        }
            
    }
}
