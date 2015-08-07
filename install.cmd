@echo off

set install_dir=%~dp0
set steamcmd_dir=%ProgramFiles(x86)%\SteamCMD
set nssm_dir=%ProgramFiles%\NSSM

echo -- NEOTOKYO Dedicated Server Installer --

if not exist "steamcmd.exe" (
	echo.
	echo The File steamcmd.exe is missing!
	echo Get the File from https://developer.valvesoftware.com/wiki/SteamCMD
	echo and place it where the Install Script is located.
	exit /b 0
)

if not exist "nssm.exe" (
	echo.
	echo The File nssm.exe is missing!
	echo Get the File from http://www.nssm.cc
	echo and place it where the Install Script is located.
	exit /b 0
)

:menu
set select=0
echo.
if not exist "%steamcmd_dir%\steamcmd.exe" (
	echo 1^) Install SteamCMD
)
if exist "%steamcmd_dir%\steamcmd.exe" (
	echo 1^) Install SteamCMD ^(Already installed select 7 to uninstall^)
)
if not exist "%nssm_dir%\nssm.exe" (
	echo 2^) Install NSSM
)
if exist "%nssm_dir%\nssm.exe" (
	echo 2^) Install NSSM ^(Already installed select 8 to uninstall^)
)
if not exist "%steamcmd_dir%\steamapps\common\NEOTOKYO Dedicated Server\srcds.exe" (
	echo 3^) Install NEOTOKYO Dedicated Server
)
if exist "%steamcmd_dir%\steamapps\common\NEOTOKYO Dedicated Server\srcds.exe" (
	echo 3^) Install NEOTOKYO Dedicated Server ^(Already installed 9 to uninstall^)
)
sc query neotokyo >nul
if ERRORLEVEL 1060 (
	echo 4^) Register Service
)
if not ERRORLEVEL 1060 (
	echo 4^) Register Service ^(Already installed select 10 to uninstall^)
)
netsh advfirewall firewall show rule name="NEOTOKYO Dedicated Server" >nul
if ERRORLEVEL 1 (
	echo 5^) Add Firewall Rules
)
if not ERRORLEVEL 1 (
	echo 5^) Add Firewall Rules ^(Already installed select 11 to uninstall^)
)
sc query neotokyo >nul
if not ERRORLEVEL 1060 (
	if ERRORLEVEL 1077 (
		echo 6^) Start Service
	)
	if not ERRORLEVEL 1077 (
		echo 6^) Start Service ^(Already started select 12 to stop^)
	)
)
echo.
set /p select="Select an Operation: "
if %select%==1 (
	goto :steamcmd
)
if %select%==7 (
	goto :steamcmd_remove
)
if %select%==2 (
	goto :nssm
)
if %select%==8 (
	goto :nssm_remove
)
if %select%==3 (
	goto :neotokyo
)
if %select%==9 (
	goto :neotokyo_remove
)
if %select%==4 (
	goto :service
)
if %select%==10 (
	goto :service_remove
)
if %select%==5 (
	goto :rules
)
if %select%==11 (
	goto :rules_remove
)
if %select%==6 (
	goto :start
)
if %select%==12 (
	goto :stop
)
goto :abort

:steamcmd
echo.
if not exist "%steamcmd_dir%" (
	echo Creating SteamCMD Directory ...
	md "%steamcmd_dir%"
)
if not exist "%steamcmd_dir%\steamcmd.exe" (
	echo Copying SteamCMD Installer Executable ...
	copy "%install_dir:~0,-1%\steamcmd.exe" "%steamcmd_dir%"
)
if exist "%steamcmd_dir%" (
	netsh advfirewall firewall show rule name="SteamCMD" >nul
	if ERRORLEVEL 1 (
		echo Adding SteamCMD Firewall Rules ...
		netsh advfirewall firewall add rule name="SteamCMD" program="%steamcmd_dir%\steamcmd.exe" action=allow dir=in profile=any enable=yes
		netsh advfirewall firewall add rule name="SteamCMD" program="%steamcmd_dir%\steamcmd.exe" action=allow dir=out profile=any enable=yes
	)
	echo Installing SteamCMD ...
	cd "%steamcmd_dir%"
	"%steamcmd_dir%\steamcmd.exe" +login anonymous +quit
)
goto :menu

:steamcmd_remove
echo.
if exist "%steamcmd_dir%" (
	echo Removing "%steamcmd_dir%" ...
	rmdir /s /q "%steamcmd_dir%"
)
netsh advfirewall firewall show rule name="SteamCMD" >nul
if not ERRORLEVEL 1 (
	echo Removing SteamCMD Firewall Rules ...
	netsh advfirewall firewall delete rule name="SteamCMD"
)
goto :menu

:nssm
echo.
if not exist "%nssm_dir%" (
	echo Creating NSSM Directory ...
	md "%nssm_dir%"
)
if not exist "%nssm_dir%\nssm.exe" (
	echo Copying NSSM Executable ...
	copy "%install_dir:~0,-1%\nssm.exe" "%nssm_dir%"
)
goto :menu

:nssm_remove
if exist "%nssm_dir%" (
	echo Removing "%nssm_dir%" ...
	rmdir /s /q "%nssm_dir%"
)
echo.
goto :menu

:neotokyo
echo.
if exist "%steamcmd_dir%" (
	echo Installing NEOTOKYO Dedicated Server ...
	cd "%steamcmd_dir%"
	"%steamcmd_dir%\steamcmd.exe" +login anonymous +app_update 313600 +validate +quit
)
goto :menu

:service
echo.
set App="neotokyo"
set Application="%steamcmd_dir%\steamapps\common\NEOTOKYO Dedicated Server\srcds.exe"
set AppDirectory="%steamcmd_dir%\steamapps\common\NEOTOKYO Dedicated Server"
set AppParameters="-console -game NeotokyoSource -port 27015 +maxplayers 24 +exec server.cfg +map nt_rise_ctg -allowdebug -dev"
set DisplayName="NEOTOKYO Dedicated Server"
set Description="NEOTOKYO is a first person shooter that aims to provide a visceral & realistic combat experience in a futuristic setting."
if exist "%nssm_dir%" (
	sc query %App% >nul
	if ERRORLEVEL 1060 (
		echo Installing NEOTOKYO Dedicated Server Service ...
		cd "%nssm_dir%"
		"%nssm_dir%\nssm.exe" install %App% %Application%
		"%nssm_dir%\nssm.exe" set %App% Application %Application%
		"%nssm_dir%\nssm.exe" set %App% AppDirectory %AppDirectory%
		"%nssm_dir%\nssm.exe" set %App% AppParameters %AppParameters%
		"%nssm_dir%\nssm.exe" set %App% DisplayName %DisplayName%
		"%nssm_dir%\nssm.exe" set %App% Description %Description%
		"%nssm_dir%\nssm.exe" set %App% Start SERVICE_AUTO_START
		"%nssm_dir%\nssm.exe" set %App% ObjectName LocalSystem
		"%nssm_dir%\nssm.exe" set %App% Type SERVICE_WIN32_OWN_PROCESS
	)
)
goto :menu

:service_remove
echo.
set App="neotokyo"
if exist "%nssm_dir%" (
	sc query %App% >nul
	if not ERRORLEVEL 1060 (
		echo Removing NEOTOKYO Dedicated Server Service ...
		cd "%nssm_dir%"
		"%nssm_dir%\nssm.exe" remove %App% confirm
	)
)
goto :menu

:rules
echo.
if exist "%steamcmd_dir%\steamapps\common\NEOTOKYO Dedicated Server\srcds.exe" (
	netsh advfirewall firewall show rule name="NEOTOKYO Dedicated Server" >nul
	if ERRORLEVEL 1 (
		echo Adding NEOTOKYO Dedicated Server Firewall Rules ...
		netsh advfirewall firewall add rule name="NEOTOKYO Dedicated Server" program="%steamcmd_dir%\steamapps\common\NEOTOKYO Dedicated Server\srcds.exe" action=allow dir=in profile=any enable=yes
		netsh advfirewall firewall add rule name="NEOTOKYO Dedicated Server" program="%steamcmd_dir%\steamapps\common\NEOTOKYO Dedicated Server\srcds.exe" action=allow dir=out profile=any enable=yes
	)
)
goto :menu

:rules_remove
netsh advfirewall firewall show rule name="NEOTOKYO Dedicated Server" >nul
if not ERRORLEVEL 1 (
	echo Removing NEOTOKYO Dedicated Server Firewall Rules ...
	netsh advfirewall firewall delete rule name="NEOTOKYO Dedicated Server"
)
goto :menu

:start
echo.
set App="neotokyo"
sc query %App% >nul
if ERRORLEVEL 1077 (
	echo Starting NEOTOKYO Dedicated Server Service ...
	net start %App%
)
goto :menu

:stop
echo.
set App="neotokyo"
sc query %App% >nul
if ERRORLEVEL 0 (
	echo Stopping NEOTOKYO Dedicated Server Service ...
	net start %App%
)
goto :menu

:abort
cd "%install_dir%"
exit /b 1
