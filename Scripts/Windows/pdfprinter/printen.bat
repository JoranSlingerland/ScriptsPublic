: loop
for /R "C:\Users\joran.slingerland\Documents\OLAttachments" %%f in (*) do (if not "%%~xf"==".pdf" del "%%~f")
for /f %%f in ('dir /b C:\Users\joran.slingerland\Documents\OLAttachments\') do "PDFtoPrinter.exe"  "C:\Users\joran.slingerland\Documents\OLAttachments\%%f"
del "C:\Users\joran.slingerland\Documents\OLAttachments\*" /s /f /q
timeout 30 >nul
goto loop