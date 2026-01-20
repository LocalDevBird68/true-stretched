@echo off
set

del stretched.bat
del /f /q GameUserSettings.ini
del /f /q %USERPROFILE%\Desktop\VALORANT.lnk
del /f /q C:\Users\Public\Desktop\VALORANT.lnk
del /f /q "%cd%\resources\SilentVibranceGUI.lnk"
del "%cd%\resources\accounts.txt"
del "%cd%\resources\temp\*.txt"

cls



echo please move this to ur C: drive before continuing
echo.
echo close this window and move the folder to anywhere on ur C: drive, otherwise press any key to continue
echo.
cls
pause



:: ask for resolution details
:askwidth
echo.
set /p choice="what is the width of your display resolution? (ex: 1920 in 1920x1080 or 2560 in 2560x1440): "
set /a widthInt=%choice%
IF %widthInt% == 0 (
    echo.
    echo that was not an integer, please try again
    echo.
    goto askwidth
) ELSE (
    goto askheight
)

:askheight
echo.
set /p choice="what is the height of your display resolution? (ex: 1080 in 1920x1080 or 1440 in 2560x1440): "
set /a heightInt=%choice%
set /a stretchedWidthInt= (%heightInt%*29)/20
IF %heightInt% == 0 (
    echo.
    echo that was not an integer, please try again
    echo.
    goto askheight
) ELSE (
    goto askrefreshrate
)

:askrefreshrate
echo.
set /p refreshrate="what is the refresh rate of your display? (ex: 165 in 1920x1080 165hz): "
set /a refreshrateInt=%refreshrate%
IF %refreshrateInt% == 0 (
    echo.
    echo that was not an integer, please try again
    echo.
    goto askrefreshrate
) ELSE (
    goto generatestretched
)









:generatestretched
:: creating stretched.bat

type "%cd%\parts\part1.txt" >> stretched.bat

echo start QRes.exe /x:%stretchedWidthInt% /y:%heightInt% /r:%refreshrateInt% >> stretched.bat

type "%cd%\parts\part2.txt" >> stretched.bat
echo start QRes.exe /x:%widthInt% /y:%heightInt% /r:%refreshrateInt% >> stretched.bat

type "%cd%\parts\part3.txt" >> stretched.bat

:: process watcher into stretched.bat

type "%cd%\parts\pwpart1.txt" >> stretched.bat
echo start QRes.exe /x:%widthInt% /y:%heightInt% /r:%refreshrateInt% >> stretched.bat

:: adding rest of stretched.bat

type "%cd%\parts\part4.txt" >> stretched.bat

goto generateini














:generateini

:: generates GameUserSettings.ini with custom res for valorant

type "%cd%\parts\ini1.txt" >> GameUserSettings.ini

echo ResolutionSizeX=%stretchedWidthInt%>> GameUserSettings.ini
echo ResolutionSizeY=%heightInt%>> GameUserSettings.ini
echo LastUserConfirmedResolutionSizeX=%stretchedWidthInt%>> GameUserSettings.ini
echo LastUserConfirmedResolutionSizeY=%heightInt%>> GameUserSettings.ini

type "%cd%\parts\ini2.txt" >> GameUserSettings.ini

echo DesiredScreenWidth=%stretchedWidthInt%>> GameUserSettings.ini
echo DesiredScreenHeight=%heightInt%>> GameUserSettings.ini
echo LastUserConfirmedDesiredScreenWidth=%stretchedWidthInt%>> GameUserSettings.ini
echo LastUserConfirmedDesiredScreenHeight=%heightInt%>> GameUserSettings.ini

type "%cd%\parts\ini3.txt" >> GameUserSettings.ini

attrib +r "GameUserSettings.ini"

goto createshortcuts












:createshortcuts

:: throws an error when stored on another drive for some reason? works fine on my pc though...

set "vibranceTarget=%cd%\resources\vibranceGUI.exe"
set "vibranceShortcut=%cd%\resources\SilentVibranceGUI.lnk"
set "vibranceWorkingDir=%cd%\resources\"
set "valorantWorkingDir=%cd%\"
set "valorantTarget=C:\Windows\System32\cmd.exe"
set "valorantArguments= /c "
set "valorantShortcut=%USERPROFILE%\Desktop\VALORANT.lnk"

echo.

echo creating shortcuts with powershell...
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%vibranceShortcut%'); $s.TargetPath = '%vibranceTarget%'; $s.WorkingDirectory = '%vibranceWorkingDir%'; $s.WindowStyle = 7; $s.IconLocation = '%vibranceTarget%'; $s.Save()"
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%valorantShortcut%'); $s.TargetPath = '%valorantTarget%'; $s.WorkingDirectory = '%valorantWorkingDir%'; $s.Arguments = '/c \""%cd%\stretched.bat"\"'; $s.IconLocation = '%SystemDrive%/ProgramData/Riot Games/Metadata/valorant.live/valorant.live.ico'; $s.Save()"

goto importsettings











:importsettings
echo.

:: remove >nul for debugging, gpu detection and xml writing process should work fine though

echo importing vibranceGUI settings... >nul
cd /d %appdata%
mkdir vibranceGUI

cd /d "%appdata%\vibranceGUI"
del /f /q applicationData.xml
del /f /q vibranceGUI.ini

set "amd=<?xml version="1.0" encoding="utf-8"?><ArrayOfApplicationSetting xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ApplicationSetting><Name>VALORANT-Win64-Shipping</Name><FileName>C:\Riot Games\VALORANT\live\ShooterGame\Binaries\Win64\VALORANT-Win64-Shipping.exe</FileName><IngameLevel>180</IngameLevel><IsResolutionChangeNeeded>false</IsResolutionChangeNeeded><ResolutionSettings><DmPelsWidth>640</DmPelsWidth><DmPelsHeight>480</DmPelsHeight><DmBitsPerPel>32</DmBitsPerPel><DmDisplayFrequency>60</DmDisplayFrequency><DmDisplayFixedOutput>0</DmDisplayFixedOutput></ResolutionSettings></ApplicationSetting></ArrayOfApplicationSetting>"
set "nvidia=<?xml version="1.0" encoding="utf-8"?><ArrayOfApplicationSetting xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ApplicationSetting><Name>VALORANT-Win64-Shipping</Name><FileName>C:\Riot Games\VALORANT\live\ShooterGame\Binaries\Win64\VALORANT-Win64-Shipping.exe</FileName><IngameLevel>38</IngameLevel><IsResolutionChangeNeeded>false</IsResolutionChangeNeeded><ResolutionSettings><DmPelsWidth>640</DmPelsWidth><DmPelsHeight>480</DmPelsHeight><DmBitsPerPel>32</DmBitsPerPel><DmDisplayFrequency>59</DmDisplayFrequency><DmDisplayFixedOutput>0</DmDisplayFixedOutput></ResolutionSettings></ApplicationSetting></ArrayOfApplicationSetting>"

setlocal EnableDelayedExpansion
powershell -Command "$gpu = 'NONE'; Get-CimInstance win32_VideoController | ForEach-Object { if ($_.Name -like '*Radeon*') { $gpu = 'AMD' } elseif ($_.Name -like '*GeForce*') { $gpu = 'NVIDIA' } }; $gpu | Out-File -FilePath gpuinfo.txt -Encoding ASCII"
set /p gpu=<gpuinfo.txt
if !gpu!==NVIDIA (
    echo Detected NVIDIA GPU >nul
    echo !nvidia! > temp.xml
    type temp.xml >> applicationData.xml
    del temp.xml
) else (
    if !gpu!==AMD (
        echo Detected AMD GPU >nul
        echo !amd! > temp.xml
        type temp.xml >> applicationData.xml
        del temp.xml
    ) else (
        echo No supported GPU found. Skipping vibranceGUI settings import.
    )
)
endlocal
del gpuinfo.txt

echo [Settings] >> vibranceGUI.ini
echo inactiveValue=100 >> vibranceGUI.ini
echo affectPrimaryMonitorOnly=True >> vibranceGUI.ini
echo neverSwitchResolution=True >> vibranceGUI.ini



goto final

















:final

cls

echo all done installing! set this custom resolution into NVIDIA control panel or AMD Adrenaline:
echo %stretchedWidthInt% x %heightInt%
echo.
echo also don't forget to disable all ur monitors in device manager (yes its safe)

echo.

echo copy the GameUserSettings.ini file
echo navigate to the folder with a bunch of gibberish, go to the WindowsClient folder, and paste it there, yes to replace
echo press any key when ur ready
echo.
pause
explorer %localappdata%\VALORANT\Saved\Config\

echo.
echo.
echo.
echo one more thing, you can also add a file called "accounts.txt" in the resources folder
echo follow the example formatting in "accounts_example.txt"
echo.
pause
echo.
echo press any key twice to exit
echo.
pause
echo.
pause

exit /b

