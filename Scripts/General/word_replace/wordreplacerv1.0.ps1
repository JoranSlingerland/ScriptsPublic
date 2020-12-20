<#PSScriptInfo

.VERSION 1.0

.GUID a566f813-daad-456b-8f65-e78a5f17c58d

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
 Script created to fill word file from csv file.

#>

#load assembly forms
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

## build the GUI

#load file browsers
$csvfilebrowser = New-Object System.Windows.Forms.openFileDialog
$csvfilebrowser.filter = "Comma seperated values | *.csv"
$docxfilebrowser = New-Object System.Windows.Forms.openFileDialog
$docxfilebrowser.filter = "Word Files| *.docx"
$outputfolderbrowser = new-object System.Windows.Forms.FolderBrowserDialog

#create form
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "Word Replacer V1.0"
$Form.TopMost                    = $false

#docx text 
$docxtext                        = New-Object system.Windows.Forms.TextBox
$docxtext.multiline              = $false
$docxtext.width                  = 213
$docxtext.height                 = 20
$docxtext.location               = New-Object System.Drawing.Point(27,18)
$docxtext.Font                   = 'Microsoft Sans Serif,10'

#docx button
$docxbutton                         = New-Object system.Windows.Forms.Button
$docxbutton.text                    = "Select docx"
$docxbutton.width                   = 60
$docxbutton.height                  = 40
$docxbutton.location                = New-Object System.Drawing.Point(272,9)
$docxbutton.Font                    = 'Microsoft Sans Serif,10'
$docxbutton.add_click({
    $docxfilebrowser.ShowDialog()
    $docxtext.text = $docxfilebrowser.filename
})

#csv text
$csvtext                        = New-Object system.Windows.Forms.TextBox
$csvtext.multiline              = $false
$csvtext.width                  = 213
$csvtext.height                 = 20
$csvtext.location               = New-Object System.Drawing.Point(27,65)
$csvtext.Font                   = 'Microsoft Sans Serif,10'

#csv button
$csvbutton                         = New-Object system.Windows.Forms.Button
$csvbutton.text                    = "Select csv"
$csvbutton.width                   = 60
$csvbutton.height                  = 40
$csvbutton.location                = New-Object System.Drawing.Point(272,55)
$csvbutton.Font                    = 'Microsoft Sans Serif,10'
$csvbutton.add_click({
    $csvfilebrowser.ShowDialog()
    $csvtext.text = $csvfilebrowser.filename
})

#output text
$outputtext                        = New-Object system.Windows.Forms.TextBox
$outputtext.multiline              = $false
$outputtext.width                  = 214
$outputtext.height                 = 20
$outputtext.location               = New-Object System.Drawing.Point(26,111)
$outputtext.Font                   = 'Microsoft Sans Serif,10'

#output button
$outputbutton                         = New-Object system.Windows.Forms.Button
$outputbutton.text                    = "Output folder"
$outputbutton.width                   = 60
$outputbutton.height                  = 40
$outputbutton.location                = New-Object System.Drawing.Point(272,102)
$outputbutton.Font                    = 'Microsoft Sans Serif,10'
$outputbutton.add_click({
    $outputfolderbrowser.ShowDialog()
    $outputtext.text = $outputfolderbrowser.SelectedPath
})


#run button
$runbutton                         = New-Object system.Windows.Forms.Button
$runbutton.text                    = "Run"
$runbutton.width                   = 60
$runbutton.height                  = 30
$runbutton.location                = New-Object System.Drawing.Point(151,330)
$runbutton.Font                    = 'Microsoft Sans Serif,10'

#run the code
$runbutton.add_click({

    #static word variables
    $MatchCase = $False
    $MatchWholeWord = $true
    $MatchWildCards = $False
    $MatchSoundsLike = $False
    $MatchAllWordForms = $False
    $Forward = $True
    $Wrap = $wdFindContinue
    $Format = $True
    $wdFindContinue = 1
    $ReplaceAll = 2

    #create word object
    $objword = new-object -ComObject word.application
    $objWord.Visible = $false

    #open files
    $idoc = get-item $docxfilebrowser.filename
    $csv = import-csv  $csvfilebrowser.filename -Delimiter  ";"

    #counters
    $namecounter = 0
    $start = 0
    $end = 1
    $columncount = ($csv | get-member -type NoteProperty).count
    $columncount -= 1

    foreach($line in $csv){
        
        #get objects
        $objDoc = $objWord.Documents.Open($idoc.FullName,$true)
        $objSelection = $objWord.Selection

        #loop for every 2 colums
        while ($end -le $columncount) {
            #placeholder to variable
            $placeholder = $line.$start
            $replace = $line.$end

            #text to replace
            $FindText = $placeholder
            $ReplaceWith = $replace

            #find and replace
            $a = $objSelection.Find.Execute($FindText,$MatchCase,$MatchWholeWord,
            $MatchWildCards,$MatchSoundsLike,$MatchAllWordForms,$Forward,
            $Wrap,$Format,$ReplaceWith,$ReplaceAll)

            #update counters
            $start += 2
            $end += 2
        
        }
            
        #save document
        $folderpath = $outputfolderbrowser.SelectedPath
        $path = "$folderpath\$namecounter.docx"
        $objDoc.Saveas($path)
        $objDoc.Close()
        $namecounter += 1

        #reset counters
        $start = 0
        $end = 1
    }
    $objword.quit()
    
    Write-Host -NoNewLine "Run completed, Press OK to exit";
    $form.Close() | Out-Null
})

#load GUI
$Form.controls.AddRange(@($docxtext,$csvtext,$docxbutton,$csvbutton,$runbutton,$outputtext,$outputbutton))
$form.showdialog() | Out-null