REM zip_clean_db.bat
REM batch file for archiving clean db backups and deleting originals if no errors
REM inputs: %1 - full name and path of zip archive to be created
REM           %2  - folder to be zipped
REM           %3  - path where zip archives to be created

"C:\Program Files\7-Zip\7z.exe" a -tzip %1  %2 -r -w%3  |  find "Everything is Ok"

if ERRORLEVEL 1 goto :EOF

rmdir /Q /S %2


:EOF 



