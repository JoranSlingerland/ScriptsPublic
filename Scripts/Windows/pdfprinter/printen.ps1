$path = "C:\Users\joran.slingerland\Documents\OLAttachments"

while ($true) {
    Get-childitem -Path $path | Where-Object {$_.Extension -ne '.pdf'} | 
    Remove-Item
    $files = Get-childitem -Path $path
        foreach($file in $files){
        .\pdftoprinter.exe "$path\$file"
        Start-Sleep -s 5
    }
    Get-childitem -Path $path | Remove-Item
    Start-Sleep -s 30
}