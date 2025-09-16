@echo off
set TITLE=WeModPatcher
set VERSION=1.2.5
set TOOLS=%TITLE%Tools
set HOME=%~dp0
cd /d "%HOME%"
color 07
title %TITLE%
::WINDOWS TOOLS USED:
rem %WINDIR%\System32\chcp.com
rem %WINDIR%\System32\conhost.exe
rem %WINDIR%\System32\cscript.exe
rem %WINDIR%\System32\curl.exe - was added to Windows 10 (1803) from build 17063 or later.
rem %WINDIR%\System32\mode.com
rem %WINDIR%\System32\mshta.exe
rem %WINDIR%\System32\net.exe
rem %WINDIR%\System32\Robocopy.exe
rem %WINDIR%\System32\tar.exe  - was added to Windows 10 (1803) from build 17063 or later.
rem %WINDIR%\System32\taskkill.exe
rem %WINDIR%\System32\tasklist.exe
rem %WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe
::EXTERNAL TOOLS USED:
rem 7z.exe
rem binmay.exe

if [%1] == [-csht] goto CMD_ARGUMENTS
if [%1] == [-dwmi] goto CMD_ARGUMENTS
if [%1] == [-dwmp] goto CMD_ARGUMENTS


: CHECK_WEMODPATCHER_UPDATES
if exist "CheckUpdatesOff.*" goto RUN_AS_ADMIN
if exist "Check Updates Off.*" goto RUN_AS_ADMIN
::WeModPatcher download online list [ ShowAll | ShowLast ]
set WMPDList=ShowLast
::last version online and changelog
set OnlineLastVer=&set ChangeLog=&set Message=

:: v CODE BELOW IS ONLY FOR TESTS v ::
set DeveloperTest=yes
if "%DeveloperTest%"=="no" (
	for /f "tokens=1-9 delims=<># eol=<" %%1 in (..\W3M0dP4tch32L1nk5.txt) do (
		if "%%1"=="LastVersion" set OnlineLastVer=%%2&set ChangeLog=%%3
		if "%%1"=="Message_ON" set Message=%%2
		set ListURL=..\W3M0dP4tch32L1nk5.txt
	)
)
:: ^ CODE ABOVE IS ONLY FOR TESTS ^ ::

::last version online and changelog from github
if not defined OnlineLastVer for /f "tokens=1-9 delims=<># eol=<" %%1 in ('curl -s https://raw.githubusercontent.com/brunolee-GIT/W3M0dP4tch32/main/W3M0dP4tch32L1nk5') do (
	if "%%1"=="LastVersion" set OnlineLastVer=%%2&set ChangeLog=%%3
	if "%%1"=="Message_ON" set Message=%%2
	set ListURL='curl -s https://raw.githubusercontent.com/brunolee-GIT/W3M0dP4tch32/main/W3M0dP4tch32L1nk5'
)
::last version online and changelog from gitlab (if github not work)
if not defined OnlineLastVer for /f "tokens=1-9 delims=<># eol=<" %%1 in ('curl -s https://gitlab.com/brunolee-GIT/W3M0dP4tch32/-/raw/main/W3M0dP4tch32L1nk5') do (
	if "%%1"=="LastVersion" set OnlineLastVer=%%2&set ChangeLog=%%3
	if "%%1"=="Message_ON" set Message=%%2
	set ListURL='curl -s https://gitlab.com/brunolee-GIT/W3M0dP4tch32/-/raw/main/W3M0dP4tch32L1nk5'
)
::last version online and changelog from pastebin (if gitlab not work)
if not defined OnlineLastVer for /f "tokens=1-9 delims=<># eol=<" %%1 in ('curl -s https://pastebin.com/raw/ebBuTvpj') do (
	if "%%1"=="LastVersion" set OnlineLastVer=%%2&set ChangeLog=%%3
	if "%%1"=="Message_ON" set Message=%%2
	set ListURL='curl -s https://pastebin.com/raw/ebBuTvpj'
)
if not defined OnlineLastVer goto RUN_AS_ADMIN
set "ChangeLog=%ChangeLog:W3M0dP4tch32=WeModPatcher%"
set "ChangeLog=%ChangeLog:W3M0d=WeMod%"
::show web message only one time a day
if not defined Message if exist "MSG_*" del "MSG_*">NUL
if defined Message for /f %%a in ('powerShell -Command "(Get-Date).ToString('dd-MM-yyyy')"') do (
	if not exist "MSG_%%a" (
		if exist "MSG_*" del "MSG_*">NUL
		echo.>MSG_%%a
		echo %Message%
	)
)
::check versions
if defined OnlineLastVer for /f %%a in ('powershell -Command "[string]([Version]'%VERSION%', [Version]'%OnlineLastVer%' | measure-object -maximum).maximum"') do set OWMPLastVersion=%%a
::show changelog
if defined OWMPLastVersion (
	if not "%VERSION%"=="%OWMPLastVersion%" (
		echo c=MsgBox("%TITLE% %OnlineLastVer% is available for download!"+vbNewline+"Do you want to download now?", vbInformation+vbYesNo+vbDefaultButton1, "NEW UPDATE"^): Wscript.echo(c^)>FoundNewUpdate.vbs
		if "%WMPDList%"=="ShowLast" (
			echo  [42;97m %TITLE% v%OnlineLastVer% [0m
			echo  [93m CHANGELOG [0m:
			echo  %ChangeLog%
		)	
	)
)
if exist "FoundNewUpdate.vbs" for /f "tokens=*" %%a in ('cscript FoundNewUpdate.vbs') do set UPDATE_ANSWER=%%a
if exist "FoundNewUpdate.vbs" del FoundNewUpdate.vbs>NUL
if defined UPDATE_ANSWER if "%UPDATE_ANSWER%"=="6" call :function_owmp_download


: RUN_AS_ADMIN
:: Requesting administrative privileges if necessary
echo.>IsAdminNecessary
net session 1>NUL 2>NUL:&&(set USER=Admin)||(set USER=Normal)
if not exist "IsAdminNecessary" (
	if "%USER%"=="Normal" powershell Start -File "'%~f0'" -Verb RunAs&exit
	if "%USER%"=="Admin" powershell -Command "Write-Output 'c=msgbox(\"DIRECTORY PERMISSIONS ERROR\",vbCritical,\"%TITLE% v%VERSION%\")' | Out-File -LiteralPath '%HOME%Info.vbs'">NUL&Info.vbs&del Info.vbs>NUL&exit
)
if exist "IsAdminNecessary" del "IsAdminNecessary">NUL


: WindowsTerminal
:: cmd without WindowsTerminal
rem for /f "tokens=1-4 delims= " %%1 in ('wmic os get Caption /Value') do if "%%1"=="Caption=Microsoft" set WINDOWS_VERSION=%%2 %%3&set WINDOWS_EDITION=%%4
if not "%1"=="conhost" (
	powershell -Command "[console]::title='%TITLE%'"
	for /f "tokens=2" %%a in ('tasklist /NH /FI "WindowTitle eq "%TITLE%""') do (
		for /f %%b in ('powershell -Command "(Get-Process -Id %%a).ProcessName"') do (
			if "%%b"=="WindowsTerminal" set WTPROCESSID=%%a&conhost "%~f0" conhost
		)
	)
)
if "%1"=="conhost" taskkill /PID %WTPROCESSID%>NUL


: START_BATCH
for /f "delims=." %%a in ("%~x0") do set EXTENSION=%%a
for /f "tokens=2 delims=:" %%a in ('chcp') do set CHCP_ORG=%%a


: COLORS
set [=powershell -Command ^"Write-Host&set ][= -NoNewline; Write-Host&set {=^";^^&set }= ^"Write-Host&set ]]= -NoNewline^"&set ]=^"
:: +-------------+-----+----------------+----------------+   +--------------+-----+----------------+----------------+
:: | DARK COLORS | PWS | CMD Background | CMD Foreground |   | LIGHT COLORS | PWS | CMD Background | CMD Foreground |
:: +-------------+-----+----------------+----------------+   +--------------+-----+----------------+----------------+
:: | Black       | 0   | [40m       | [30m        |   | Gray         | 8   | [100m       | [90m       |
:: | Blue        | 1   | [44m       | [34m        |   | Light Blue   | 9   | [104m       | [94m       |
:: | Green       | 2   | [42m       | [32m        |   | Light Green  | 10  | [102m       | [92m       |
:: | Aqua        | 3   | [46m       | [36m        |   | Light Aqua   | 11  | [106m       | [96m       |
:: | Red         | 4   | [41m       | [31m        |   | Light Red    | 12  | [101m       | [91m       |
:: | Purple      | 5   | [45m       | [35m        |   | Light Purple | 13  | [105m       | [95m       |
:: | Yellow      | 6   | [43m       | [33m        |   | Light Yellow | 14  | [103m       | [93m       |
:: | White       | 7   | [47m       | [37m        |   | Bright White | 15  | [107m       | [97m       |
:: +-------------+-----+----------------+----------------+   +--------------+-----+----------------+----------------+


: SCREEN_RESOLUTION
cls
chcp 850>NUL
set /a CONSOLE_COLS=24&set /a CONSOLE_LINES=10
mode con cols=%CONSOLE_COLS% lines=%CONSOLE_LINES%
::screen resolution width and height
for /f %%a in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms;([System.Windows.Forms.Screen]::AllScreens).WorkingArea.Width"') do set /a SCREEN_WIDTH=%%a
for /f %%a in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms;([System.Windows.Forms.Screen]::AllScreens).WorkingArea.Height"') do set /a SCREEN_HEIGHT=%%a
::process id to center window
powershell -Command "[console]::title='%TITLE%'"
for /f "tokens=2" %%a in ('tasklist /NH /FI "WindowTitle eq "%TITLE%""') do set PROCESSID=%%a
::show top bar
%[% -B 13 -F 13 '....'%][% -B 5 -F 5 '....'%][% -B 1 -F 1 '....'%][% -B 9 -F 9 '....'%][% -B 3 -F 3 '....'%][% -B 11 -F 11 '...' `n`n%][% -B 0 -F 10 '  %TITLE% v%VERSION%'%]%
::center text
set TEXT2CENTER=%SCREEN_WIDTH%x%SCREEN_HEIGHT%
call :function_center_text
::show center resolution
%[% -B 0 -F 0 ''.PadRight(%TEXTCENTER%)%][% -B 0 -F 14 '%TEXT2CENTER%'%]%
echo    [4m                  [0m
echo    [44;37m C:\^>_%EXTENSION%         [0m
echo    [44m                  [0m
echo    [44;90m    waiting...    [0m
echo    [44;4m                  [0m


: EXTERNAL_OPTIONS_FILE
::read options file
set FORCE_LANGUAGE=NONE&set FORCE_THEME_COLOR=LIGHT&set SKIP_SPLASH=NO&set BEEP=NO&set SPEECH=NO&set CUSTOM_DIRECTORY=NO
if exist Options.ini (
	for /f %%a in ('powershell -Command "(Get-FileHash Options.ini -Algorithm MD5).Hash"') do set MD5_OPTIONS=%%a
	for /f "tokens=1-2 delims='" %%1 in (Options.ini) do (
		if "%%1"=="FORCE_LANGUAGE_FILE=" set FORCE_LANGUAGE=%%2
		if "%%1"=="FORCE_THEME_COLOR=" set FORCE_THEME_COLOR=%%2
		if "%%1"=="SKIP_SPLASH=" set SKIP_SPLASH=%%2
		if "%%1"=="ENABLE_BEEP=" set BEEP=%%2
		if "%%1"=="ENABLE_SPEECH=" set SPEECH=%%2
		if "%%1"=="CUSTOM_DIRECTORY=" set CUSTOM_DIRECTORY=%%2
	)
	if not defined FORCE_LANGUAGE set FORCE_LANGUAGE=AUTO
	if not defined FORCE_THEME_COLOR for /f "tokens=2 delims=x" %%1 in ('reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /V "AppsUseLightTheme"') do if %%1 EQU 0 (set FORCE_THEME_COLOR=DARK) else (set FORCE_THEME_COLOR=LIGHT)
	if not defined CUSTOM_DIRECTORY set CUSTOM_DIRECTORY=NO
)


: CHECK_LANGUAGES
::check system language
for /f "tokens=*" %%a in ('powershell -Command "(Get-Culture).DisplayName"') do set SO_LANGUAGE=%%a
for /f "tokens=*" %%a in ('powershell -Command "(Get-Culture).Name"') do set SO_LOCALE=%%a
for /f "tokens=1 delims=-" %%1 in ("%SO_LOCALE%") do set SO_LANG=%%1
::select language file to read
if exist lang\lang_%FORCE_LANGUAGE%.ini (set LANGFILE=lang\lang_%FORCE_LANGUAGE%.ini&set BATCH_LANG=%FORCE_LANGUAGE%&goto LANG_EXTERNAL)
if exist lang\lang_%SO_LOCALE%.ini (set LANGFILE=lang\lang_%SO_LOCALE%.ini&set BATCH_LANG=%SO_LOCALE%&goto LANG_EXTERNAL) else (if exist lang\lang_%SO_LANG%.ini (set LANGFILE=lang\lang_%SO_LANG%.ini&set BATCH_LANG=%SO_LANG%&goto LANG_EXTERNAL) else (goto LANG_BATCH))


: LANG_BATCH
::internal language
set Translatedby=brunolee&set ForVersion=%VERSION%&set language=English&set codepage=850&set BATCH_LANG=en
set SYMBOLS=    ° ± ² Û
set LANG_Translated=Translated by:&set LANG_system=System&set LANG_beep=beep&set LANG_speaks=speaks
set LANG01=WELCOME&													set LANG21=OK&															set LANG41=DEVTOOLS PATCH:&													set LANG61=CUSTOM DIRECTORY
set LANG02=LANGUAGE&												set LANG22=FAILED&														set LANG42=NO ERRORS&														set LANG62=Custom username
set LANG03=and&														set LANG23=WEMOD AUTO-UPDATES&											set LANG43=DEVTOOLS PATCH FAIL
set LANG04=not found!&												set LANG24=Do you want to disable WeMod auto-updates?&					set LANG44=AUTO-UPDATE PATCH FAIL
set LANG05=Extract all files to the same folder&					set LANG25=Disable the Auto-Updates&									set LANG45=AUTO-UPDATE AND DEVTOOLS PATCH FAIL
set LANG06=Please install WeMod&									set LANG26=Keep the Auto-Updates enabled&								set LANG46=PRO AND DEVTOOLS PATCH FAIL
set LANG07=WeMod is open!&											set LANG27=WEMOD DEVTOOLS&												set LANG47=PRO AND AUTO-UPDAT PATCH FAIL
set LANG08=Close WeMod and try again&								set LANG28=Do you want to enable WeMod DevTools?&						set LANG48=FAILED EVERYTHING
set LANG09=Check the folder:&										set LANG29=Enable DevTools&												set LANG49=WEMOD PATCHED
set LANG10=SOUNDS&													set LANG30=Keep DevTools disabled&										set LANG50=GOODBYE
set LANG11=Do you want to enable beep sounds in this batch?&		set LANG31=LOCATE PRO&													set LANG51=Would you like to restore the last saved backup?
set LANG12=Do you want to enable speech readouts on this batch?&	set LANG32=PATCH PRO&													set LANG52=Yes
set LANG13=VERSIONS FOUND&											set LANG33=rejet25984 method&											set LANG53=No
set LANG14=LAST VERSION&											set LANG34=Sak32009 method&												set LANG54=Do you want to restore WeMod backup?
set LANG15=WEMOD PRO&												set LANG35=Trying the reject25984 method...&							set LANG55=Restore WeMod backup
set LANG16=Do you want to enable WeMod Pro Mode?&					set LANG36=Trying the Sak32009 method...&								set LANG56=Keep everything as it was
set LANG17=Keep the Pro Mode disabled&								set LANG37=PRO PATCH FAIL&												set LANG57=WEMOD BACKUP RESTORED
set LANG18=Choose the Pro method to be used:&						set LANG38=LOCATE AUTO-UPDATES:&										set LANG58=CONTINUE
set LANG19=Enable Pro Mode with the rejet25984 method&				set LANG39=AUTO-UPDATES PATCH:&											set LANG59=CANCEL
set LANG20=Enable Pro Mode with the Sak32009 method&				set LANG40=LOCATE DEVTOOLS:&											set LANG60=OPTIONS
::internal progress text language
set LANGBPT00=Checking if wemod is installed...&					set LANGBPT07=Creating the selector...&									set LANGBPT14=Running the patch to hide the WeMod remote button...&			set LANGBPT21=Clearing temporary work files...
set LANGBPT01=Checking if wemod is running...&						set LANGBPT08=Showing selector...&										set LANGBPT15=Running the patch to hide the WeMod objectives panel...&		set LANGBPT22=Restoring WeMod backup...
set LANGBPT02=Showing WeModPatcher and system languages...&			set LANGBPT09=Showing what was selected...&								set LANGBPT16=Running the patch to disable WeMod automatic updating...&		set LANGBPT23=Finished!
set LANGBPT03=Showing beep sounds from WeModPatcher...&				set LANGBPT10=Extracting app.asar...&									set LANGBPT17=Checking the auto-update patch...&							set LANGBPT24=Checking if wemod checks the asar integrity...
set LANGBPT04=Showing speech sounds from WeModPatcher...&			set LANGBPT11=Running the patch to activate WeMod PRO...&				set LANGBPT18=Running the patch to activate the WeMod developer tool...&	set LANGBPT25=Removing asar integrity check
set LANGBPT05=Checking the WeMod version...&						set LANGBPT12=Checking the PRO patch...&								set LANGBPT19=Checking the developer tool patch...
set LANGBPT06=Checking username to show in selector...&				set LANGBPT13=Running the patch to use a custom username on WeMod...&	set LANGBPT20=Creating a backup and packaging the app.asar...
goto MAKE_LAUNCHER

: LANG_EXTERNAL
::read language file
chcp 65001>NUL
for /f "tokens=1-2 delims='" %%1 in (%LANGFILE%) do (
	if "%%1"=="Translatedby=" set Translatedby=%%2
	if "%%1"=="ForVersion=" set ForVersion=%%2
	if "%%1"=="language=" set language=%%2
	if "%%1"=="codepage=" set codepage=%%2
	if "%%1"=="SYMBOLS=" set SYMBOLS=%%2
	if "%%1"=="LANG_Translated=" set LANG_Translated=%%2
	if "%%1"=="LANG_system=" set LANG_system=%%2
	if "%%1"=="LANG_beep=" set LANG_beep=%%2
	if "%%1"=="LANG_speaks=" set LANG_speaks=%%2
	if "%%1"=="LANG01=" set LANG01=%%2
	if "%%1"=="LANG02=" set LANG02=%%2
	if "%%1"=="LANG03=" set LANG03=%%2
	if "%%1"=="LANG04=" set LANG04=%%2
	if "%%1"=="LANG05=" set LANG05=%%2
	if "%%1"=="LANG06=" set LANG06=%%2
	if "%%1"=="LANG07=" set LANG07=%%2
	if "%%1"=="LANG08=" set LANG08=%%2
	if "%%1"=="LANG09=" set LANG09=%%2
	if "%%1"=="LANG10=" set LANG10=%%2
	if "%%1"=="LANG11=" set LANG11=%%2
	if "%%1"=="LANG12=" set LANG12=%%2
	if "%%1"=="LANG13=" set LANG13=%%2
	if "%%1"=="LANG14=" set LANG14=%%2
	if "%%1"=="LANG15=" set LANG15=%%2
	if "%%1"=="LANG16=" set LANG16=%%2
	if "%%1"=="LANG17=" set LANG17=%%2
	if "%%1"=="LANG18=" set LANG18=%%2
	if "%%1"=="LANG19=" set LANG19=%%2
	if "%%1"=="LANG20=" set LANG20=%%2
	if "%%1"=="LANG21=" set LANG21=%%2
	if "%%1"=="LANG22=" set LANG22=%%2
	if "%%1"=="LANG23=" set LANG23=%%2
	if "%%1"=="LANG24=" set LANG24=%%2
	if "%%1"=="LANG25=" set LANG25=%%2
	if "%%1"=="LANG26=" set LANG26=%%2
	if "%%1"=="LANG27=" set LANG27=%%2
	if "%%1"=="LANG28=" set LANG28=%%2
	if "%%1"=="LANG29=" set LANG29=%%2
	if "%%1"=="LANG30=" set LANG30=%%2
	if "%%1"=="LANG31=" set LANG31=%%2
	if "%%1"=="LANG32=" set LANG32=%%2
	if "%%1"=="LANG33=" set LANG33=%%2
	if "%%1"=="LANG34=" set LANG34=%%2
	if "%%1"=="LANG35=" set LANG35=%%2
	if "%%1"=="LANG36=" set LANG36=%%2
	if "%%1"=="LANG37=" set LANG37=%%2
	if "%%1"=="LANG38=" set LANG38=%%2
	if "%%1"=="LANG39=" set LANG39=%%2
	if "%%1"=="LANG40=" set LANG40=%%2
	if "%%1"=="LANG41=" set LANG41=%%2
	if "%%1"=="LANG42=" set LANG42=%%2
	if "%%1"=="LANG43=" set LANG43=%%2
	if "%%1"=="LANG44=" set LANG44=%%2
	if "%%1"=="LANG45=" set LANG45=%%2
	if "%%1"=="LANG46=" set LANG46=%%2
	if "%%1"=="LANG47=" set LANG47=%%2
	if "%%1"=="LANG48=" set LANG48=%%2
	if "%%1"=="LANG49=" set LANG49=%%2
	if "%%1"=="LANG50=" set LANG50=%%2
	if "%%1"=="LANG51=" set LANG51=%%2
	if "%%1"=="LANG52=" set LANG52=%%2
	if "%%1"=="LANG53=" set LANG53=%%2
	if "%%1"=="LANG54=" set LANG54=%%2
	if "%%1"=="LANG55=" set LANG55=%%2
	if "%%1"=="LANG56=" set LANG56=%%2
	if "%%1"=="LANG57=" set LANG57=%%2
	if "%%1"=="LANG58=" set LANG58=%%2
	if "%%1"=="LANG59=" set LANG59=%%2
	if "%%1"=="LANG60=" set LANG60=%%2
	if "%%1"=="LANG61=" set LANG61=%%2
	if "%%1"=="LANG62=" set LANG62=%%2
	if "%%1"=="LANGBPT00=" set LANGBPT00=%%2
	if "%%1"=="LANGBPT01=" set LANGBPT01=%%2
	if "%%1"=="LANGBPT02=" set LANGBPT02=%%2
	if "%%1"=="LANGBPT03=" set LANGBPT03=%%2
	if "%%1"=="LANGBPT04=" set LANGBPT04=%%2
	if "%%1"=="LANGBPT05=" set LANGBPT05=%%2
	if "%%1"=="LANGBPT06=" set LANGBPT06=%%2
	if "%%1"=="LANGBPT07=" set LANGBPT07=%%2
	if "%%1"=="LANGBPT08=" set LANGBPT08=%%2
	if "%%1"=="LANGBPT09=" set LANGBPT09=%%2
	if "%%1"=="LANGBPT10=" set LANGBPT10=%%2
	if "%%1"=="LANGBPT11=" set LANGBPT11=%%2
	if "%%1"=="LANGBPT12=" set LANGBPT12=%%2
	if "%%1"=="LANGBPT13=" set LANGBPT13=%%2
	if "%%1"=="LANGBPT14=" set LANGBPT14=%%2
	if "%%1"=="LANGBPT15=" set LANGBPT15=%%2
	if "%%1"=="LANGBPT16=" set LANGBPT16=%%2
	if "%%1"=="LANGBPT17=" set LANGBPT17=%%2
	if "%%1"=="LANGBPT18=" set LANGBPT18=%%2
	if "%%1"=="LANGBPT19=" set LANGBPT19=%%2
	if "%%1"=="LANGBPT20=" set LANGBPT20=%%2
	if "%%1"=="LANGBPT21=" set LANGBPT21=%%2
	if "%%1"=="LANGBPT22=" set LANGBPT22=%%2
	if "%%1"=="LANGBPT23=" set LANGBPT23=%%2
	if "%%1"=="LANGBPT24=" set LANGBPT24=%%2
	if "%%1"=="LANGBPT25=" set LANGBPT25=%%2
)

: MAKE_LAUNCHER
call :function_launcher

: RUN_LAUNCHER
chcp 850>NUL
for /f "tokens=*" %%a in ('mshta.exe "%HOME%Launcher.hta"') do (
	if "%%a"=="ABORT" del "Launcher.hta">NUL&exit
	if "%%a"=="CONTINUE" del "Launcher.hta">NUL&goto CHECK_REQUIRED_FILES
)
if exist Options.ini for /f %%a in ('powershell -Command "(Get-FileHash Options.ini -Algorithm MD5).Hash"') do if "%MD5_OPTIONS%"=="%%a" (goto RUN_LAUNCHER) else (goto EXTERNAL_OPTIONS_FILE)


: CHECK_REQUIRED_FILES
if exist "Launcher.hta" del "Launcher.hta">NUL
::check batch requred files (WeModPatcherTools)
if [%~x0] == [.bat] (
	if not exist "%TOOLS%" (
		powershell -Command "Write-Output 'c=msgbox(\"%TOOLS% %LANG04%\"+vbNewLine+\"%LANG05%\",vbCritical,\"%TITLE% v%VERSION%\")' | Out-File -LiteralPath '%HOME%Info.vbs'">NUL&Info.vbs&del Info.vbs>NUL&exit
	)
)
if exist "%TITLE%.ico" (set ICONALREADYPRESENT=TRUE) else (set ICONALREADYPRESENT=FALSE)


: SPLASH_IMAGE
cls
::from external options file
if /i "%SKIP_SPLASH%"=="YES" (goto TITLE)
::CenterBatchWindow columns 100 x 43 lines
set /a CONSOLE_COLS=100&set /a CONSOLE_LINES=43
call :function_center_window
::start splash image
if "%ICONALREADYPRESENT%"=="FALSE" tar -xf "%TOOLS%" "Splash.hta" "%TITLE%.ico">NUL
if "%ICONALREADYPRESENT%"=="TRUE" tar -xf "%TOOLS%" "Splash.hta">NUL
powershell -Command "(gc -LiteralPath '%HOME%Splash.hta') -replace 'REPLACE_TITLE', '%TITLE%' -replace 'REPLACE_VERSION', '%VERSION%' -replace 'REPLACE_LANG01', '%LANG01%' | Out-File -LiteralPath '%HOME%splash.hta' -encoding UTF8">NUL
mshta.exe "%HOME%splash.hta"
if "%ICONALREADYPRESENT%"=="FALSE" del "splash.hta" "%TITLE%.ico">NUL
if "%ICONALREADYPRESENT%"=="TRUE" del "splash.hta">NUL


: TITLE
rem chcp %CHCP_ORG%>NUL
chcp %codepage%>NUL
title %TITLE% v%VERSION%
::show top bar title
echo [105;97m                 [45m   _  _  ___  _  [44m_  __   __   __ [104m      ___  __   [46m     ___  __     [106m                 [0m
echo [105;97m                 [45m   ^|  ^| ^|__   ^|\/[44m^| /  \ ^|  \ ^|__)[104m  /\   ^|  /  ` ^|[46m__^| ^|__  ^|__)    [106m                 [0m
echo [105;97m                 [45m   ^|/\^| ^|___  ^|  [44m^| \__/ ^|__/ ^|   [104m /--\  ^|  \__, ^|[46m  ^| ^|___ ^|  \    [106m                 [0m
echo [105;37m                 [45m                 [44m     batch code [104mby brunolee     [46m                 [106m                 [0m


: Check WeMod
::from external options file
if /i "%CUSTOM_DIRECTORY%"=="YES" (goto WEMODISRUNNING)

: WEMODISINSTALLED
::progress text
set PROGRESS_TEXT=%LANGBPT00%
call :function_progress_text
::check if wemod is installed
if not exist "%localappdata%\WeMod\app-*" (
	powershell -Command "Write-Output 'c=msgbox(\"WeMod %LANG04%\"+vbNewLine+\"%LANG06%\",vbExclamation,\"%TITLE% v%VERSION%\")' | Out-File -LiteralPath '%HOME%Info.vbs'">NUL&Info.vbs&del Info.vbs>NUL&exit
)

: WEMODISRUNNING
::progress text
set PROGRESS_TEXT=%LANGBPT01%
call :function_progress_text
::check if wemod is running
tasklist /fi "ImageName eq WeMod.exe" /fo csv 2>NUL | find /i "WeMod.exe">NUL
if "%ERRORLEVEL%"=="0" (
	powershell -Command "Write-Output 'c=msgbox(\"%LANG07%\"+vbNewLine+\"%LANG08%\",vbInformation,\"%TITLE% v%VERSION%\")' | Out-File -LiteralPath '%HOME%Info.vbs'">NUL&Info.vbs&del Info.vbs>NUL&exit
)


: WEMODPATCHER
::separate symbols
set SYMBOL1=%SYMBOLS:~0,1%&set SYMBOL2=%SYMBOLS:~2,1%&set SYMBOL3=%SYMBOLS:~4,1%&set SYMBOL4=%SYMBOLS:~6,1%&set SYMBOL5=%SYMBOLS:~8,1%&set SYMBOL6=%SYMBOLS:~10,1%&set SYMBOL7=%SYMBOLS:~12,1%&set SYMBOL8=%SYMBOLS:~14,1%
::center text
set TEXT2CENTER= %TITLE% 
call :function_center_text
::show title centered WeModPatcher
%[% -B 0 -F 0 ''.PadRight(%TEXTCENTER%)%][% -B 0 -F 14 '%TEXT2CENTER%'%]%


: LANGUAGE
::progress text
set PROGRESS_TEXT=%LANGBPT02%
call :function_progress_text
::show title languages
%[% ' '%][% -B 5 -F 15 ' %LANG02% '%]%
set LANG_batch=Batch
::align text
set ALIGN1= @%LANG_system%
set ALIGN2= @%LANG_batch%
call :function_align_text
::text to right
set TEXTFROMLEFT=:  %language% [%BATCH_LANG%] 
call :function_right_text
set TEXT2RIGHT=%LANG_Translated% * %Translatedby% *
for /f %%a in ('powershell -Command "'%TEXT2RIGHT%'.length"') do set /a RIGHTTEXT=%%a
::correction for zh-CN
if /i "%BATCH_LANG%"=="zh-CN" (set /a ALIGN_ONE=%ALIGN_ONE% - 2&set /a RIGHTTEXT=%RIGHTTEXT% + 14)
::show system and batch languages
%[% -B 0 -F 11 '%ALIGN1%'.PadRight(%ALIGN_ONE%)%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' %SO_LANGUAGE% '%][% -B 7 -F 8 '[%SO_LOCALE%] '%]%
%[% -B 0 -F 11 '%ALIGN2%'.PadRight(%ALIGN_TWO%)%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' %language% '%][% -B 7 -F 8 '[%BATCH_LANG%] '%][% -B 0 -F 0 ''.PadRight(%TEXTRIGHT%-%ALIGN_TWO%-%RIGHTTEXT%)%]]%
%[% -B 0 -F 8 '%LANG_Translated%'%][% -B 0 -F 14 ' %SYMBOL1% '%][% -B 0 -F 10 '%Translatedby%'%][% -B 0 -F 14 ' %SYMBOL1%'%]%


: SOUNDS
::show title sounds
echo.
%[% ' '%][% -B 5 -F 15 ' %LANG10% '%]%

: BEEP
::progress text
set PROGRESS_TEXT=%LANGBPT03%
call :function_progress_text
::align text
set ALIGN1= @%LANG_batch%_%LANG_beep%
set ALIGN2= @%LANG_batch%_%LANG_speaks%
call :function_align_text
::from external options file (show beep status)
if exist "Options.ini" (
	if /i "%BEEP%"=="YES" (%[% -B 0 -F 11 '%ALIGN1%'.PadRight(%ALIGN_ONE%)%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' ON '%][% -B 10 -F 15 ' %SYMBOL2% '%]%&goto SPEECH)
	if /i "%BEEP%"=="NO" (%[% -B 0 -F 11 '%ALIGN1%'.PadRight(%ALIGN_ONE%)%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' OFF '%][% -B 4 -F 15 ' %SYMBOL2% '%]%&goto SPEECH)
)
::beep quest only if not exist options file
powershell -Command "Write-Output 'c=MsgBox(\"%LANG11%\",vbQuestion+vbYesNo,\"%TITLE% v%VERSION%\") : Wscript.echo(c)' | Out-File -LiteralPath '%HOME%BEEP_QUEST.vbs'">NUL
for /f "tokens=*" %%a in ('cscript BEEP_QUEST.vbs') do set BEEP_ANSWER=%%a
del BEEP_QUEST.vbs>NUL
::show beep status
if %BEEP_ANSWER%==6 (set BEEP=YES&%[% -B 0 -F 11 '%ALIGN1%'.PadRight(%ALIGN_ONE%)%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' ON '%][% -B 10 -F 15 ' %SYMBOL2% '%]%&goto SPEECH)
if %BEEP_ANSWER%==7 (set BEEP=NO&%[% -B 0 -F 11 '%ALIGN1%'.PadRight(%ALIGN_ONE%)%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' OFF '%][% -B 4 -F 15 ' %SYMBOL2% '%]%&goto SPEECH)


: SPEECH
::progress text
set PROGRESS_TEXT=%LANGBPT04%
call :function_progress_text
::from external options file (show speech status)
if exist "Options.ini" (
	if /i "%SPEECH%"=="YES" (%[% -B 0 -F 11 '%ALIGN2%'.PadRight(%ALIGN_TWO%)%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' ON '%][% -B 10 -F 15 ' %SYMBOL2% '%]%&goto WEMOD_VERSION)
	if /i "%SPEECH%"=="NO" (%[% -B 0 -F 11 '%ALIGN2%'.PadRight(%ALIGN_TWO%)%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' OFF '%][% -B 4 -F 15 ' %SYMBOL2% '%]%&goto WEMOD_VERSION)
)
::speech quest only if not exist options file
powershell -Command "Write-Output 'c=MsgBox(\"%LANG12%\",vbQuestion+vbYesNo,\"%TITLE% v%VERSION%\") : Wscript.echo(c)' | Out-File -LiteralPath '%HOME%SPEECH_QUEST.vbs'">NUL
for /f "tokens=*" %%a in ('cscript SPEECH_QUEST.vbs') do set SPEECH_ANSWER=%%a
del SPEECH_QUEST.vbs>NUL
::show speech status
if %SPEECH_ANSWER%==6 (set SPEECH=YES&%[% -B 0 -F 11 '%ALIGN2%'.PadRight(%ALIGN_TWO%)%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' ON '%][% -B 10 -F 15 ' %SYMBOL2% '%]%&goto WEMOD_VERSION)
if %SPEECH_ANSWER%==7 (set SPEECH=NO&%[% -B 0 -F 11 '%ALIGN2%'.PadRight(%ALIGN_TWO%)%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' OFF '%][% -B 4 -F 15 ' %SYMBOL2% '%]%&goto WEMOD_VERSION)


: WEMOD_VERSION
::center text
set TEXT2CENTER= WeMod 
call :function_center_text
::show title centered wemod
echo.
%[% -B 0 -F 0 ''.PadRight(%TEXTCENTER%)%][% -B 0 -F 14 '%TEXT2CENTER%'%]%
::progress text
set PROGRESS_TEXT=%LANGBPT05%
call :function_progress_text
::from external options file
if /i "%CUSTOM_DIRECTORY%"=="NO" (goto WEMOD_PATH_NORMAL)

: WEMOD_PATH_CUSTOM
%[% -B 0 -F 6 ' %LANG61%'%][% -B 0 -F 7 ':'%]]%
for /f "tokens=*" %%a in ('powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.OpenFileDialog;$f.InitialDirectory='';$f.FileName='app';$f.Filter='APP (*.asar)|*.asar';$f.showHelp=$false;$f.ShowDialog()|Out-Null;$f.FileName"') do set "WEMODPATH=%%a"
if "%WEMODPATH%" == "app" (echo c=msgbox("app.asar %LANG04%"+vbNewLine+"%LANG50%",vbExclamation,"%TITLE% v%VERSION%"^)>Info.vbs&Info.vbs&del Info.vbs>NUL&exit) else (set "WEMODPATH=%WEMODPATH:\app.asar=%")
set "WEMODDATA=%WEMODPATH:App\WeMod\resources=Data\WeMod\Local Storage\leveldb%"
goto PATCHED_BEFORE

: WEMOD_PATH_NORMAL
::align text
set ALIGN1= %LANG13%
set ALIGN2= %LANG14%
call :function_align_text
::correction for zh-CN
if /i "%BATCH_LANG%"=="zh-CN" (set /a ALIGN_ONE=%ALIGN_ONE%&set /a ALIGN_TWO=%ALIGN_TWO% + 1)
::show wemod versions
%[% -B 0 -F 6 '%ALIGN1%'.PadRight(%ALIGN_ONE%)%][% -B 0 -F 7 ':'%]]%
if exist "WMVER" del "WMVER">NUL
for /f "tokens=1-9 delims=-" %%1 in ('dir /A:D /B "%localappdata%\WeMod\app-*"') do echo | set /p="[Version]'%%2',">>WMVER&set /p WMVER=<WMVER
if exist "WMVER" del "WMVER">NUL
set WMVER=%WMVER:~0,-1%
for /f "tokens=*" %%1 in ('powershell -Command "[string](%WMVER% | Sort)"') do set WMVERSIONS=%%1
set WMVERSIONS=v%WMVERSIONS: = ^| v%
%[% -B 0 -F 8 ' | %WMVERSIONS% |'%]%
::show wemod last version
for /f "tokens=1-9 delims= " %%1 in ('powershell -Command "[string](%WMVER% | Sort -Descending)"') do set LASTVERSION=%%1
%[% -B 0 -F 6 '%ALIGN2%'.PadRight(%ALIGN_TWO%)%][% -B 0 -F 7 ': '%][% -B 2 -F 15 ' WeMod v%LASTVERSION% '%]]%
::check if exist a file to work on wemod last version directory
set WEMODPATH=%localappdata%\WeMod\app-%LASTVERSION%\resources
set "WEMODDATA=%appdata%\WeMod\Local Storage\leveldb"
if not exist "%WEMODPATH%\app.asar" (
	powershell -Command "Write-Output 'c=msgbox(\"app.asar %LANG04%\"+vbNewLine+vbNewLine+\"%LANG09%\"+vbNewLine+\"%WEMODPATH%\",vbExclamation,\"%TITLE% v%VERSION%\")' | Out-File -LiteralPath '%HOME%Info.vbs'">NUL&Info.vbs&del Info.vbs>NUL&exit
)


: PATCHED_BEFORE
::check if exist wemod backup
if exist "%WEMODPATH%\app.asar.bak" (set PATCHEDBEFORE=YES&set "APP_ASAR=%WEMODPATH%\app.asar.bak") else (set PATCHEDBEFORE=NO&set "APP_ASAR=%WEMODPATH%\app.asar")
::show WeMod version by app.asar
for /f "tokens=1-9 delims=:" %%1 in ('powershell -Command "(gc -LiteralPath '%APP_ASAR%') | Select-String '[version"":""]{10}[0-9]{1,2}[.]{1}[0-9]{1,2}[.]{1}[0-9]{1,2}' | ForEach-Object{$_.Matches.Value}"') do set APP_ASAR_VER=%%2
set APP_ASAR_VER=%APP_ASAR_VER:"=%
%[% -B 0 -F 0 ' '%][% -B 2 -F 15 ' app.asar v%APP_ASAR_VER% '%]%


: LOGIN_USERNAME
::progress text
set PROGRESS_TEXT=%LANGBPT06%
call :function_progress_text
set LOGINUSERNAME=
if exist "%WEMODDATA%\*.log" (
	for /f %%a in ('dir /A:A /B /O:D "%WEMODDATA%\*.log"') do (
		for /f "tokens=1-9 delims=:" %%1 in ('powershell -Command "(gc -LiteralPath '%WEMODDATA%\%%a') -replace \"\x00\", '' -replace ',', \"`r`n\" -replace '""', '' -replace '}', '' | findstr /irc:username:"') do (
			if "%%1"=="username" set LOGINUSERNAME=%%2
		)
	)
)
if not defined LOGINUSERNAME set LOGINUSERNAME=Custom Username


: WEMOD_QUESTS
::progress text
set PROGRESS_TEXT=%LANGBPT07%
call :function_progress_text
::start wemod quests
if "%ICONALREADYPRESENT%"=="FALSE" tar -xf "%TOOLS%" "Selector.hta" "%TITLE%.ico">NUL
if "%ICONALREADYPRESENT%"=="TRUE" tar -xf "%TOOLS%" "Selector.hta">NUL
powershell -Command "(gc -LiteralPath '%HOME%Selector.hta') -replace 'REPLACE_TITLE', '%TITLE%' -replace 'REPLACE_VERSION', '%VERSION%' -replace 'REPLACE_THEME_COLOR', '%FORCE_THEME_COLOR%' -replace 'REPLACE_LANG15', '%LANG15%' -replace 'REPLACE_LANG16', '%LANG16%' -replace 'REPLACE_LANG18', '%LANG18%' -replace 'REPLACE_LANG19', '%LANG19%' -replace 'REPLACE_LANG20', '%LANG20%' -replace 'REPLACE_LANG33', '%LANG33%' -replace 'REPLACE_LANG34', '%LANG34%' -replace 'REPLACE_LANG23', '%LANG23%' -replace 'REPLACE_LANG24', '%LANG24%' -replace 'REPLACE_LANG25', '%LANG25%' -replace 'REPLACE_LANG27', '%LANG27%' -replace 'REPLACE_LANG28', '%LANG28%' -replace 'REPLACE_LANG29', '%LANG29%' -replace 'REPLACE_LANG21', '%LANG21%' -replace 'REPLACE_LANG62', '%LANG62%' -replace 'REPLACE_LOGINUSERNAME', '%LOGINUSERNAME%' | Out-File -LiteralPath '%HOME%Selector.hta' -encoding UTF8">NUL
::progress text
set PROGRESS_TEXT=%LANGBPT08%
call :function_progress_text
for /f "tokens=1-2 delims==" %%1 in ('mshta.exe "%HOME%Selector.hta"') do (
	if "%%1"=="ENABLE_PRO" set PRO_PATCH=%%2
	if "%%1"=="PRO_METHOD" set PRO_METHOD=%%2
	if "%%1"=="Sak32009_VER" set Sak32009_VER=%%2
	if "%%1"=="DISABLE_AUTOUPDATES" set UPDATE_PATCH=%%2
	if "%%1"=="ENABLE_DEVTOOLS" set DEVTOOLS_PATCH=%%2
	if "%%1"=="CHANGE_CUSTOM_USERNAME" set CHANGE_CUSTOM_USERNAME=%%2
	if "%%1"=="WeMod_CUSTOM_USERNAME" set WeMod_CUSTOM_USERNAME=%%2
)
if "%ICONALREADYPRESENT%"=="FALSE" del "Selector.hta" "%TITLE%.ico">NUL
if "%ICONALREADYPRESENT%"=="TRUE" del "Selector.hta">NUL
::progress text
set PROGRESS_TEXT=%LANGBPT09%
call :function_progress_text

: PRO_QUEST
set SPEAK17=You choose to keep the Pro Mode disabled
::show title wemod pro
echo.
%[% ' '%][% -B 5 -F 15 ' %LANG15% '%]%
if "%PRO_PATCH%"=="YES" (goto PRO_SELECT)
if "%PRO_PATCH%"=="NO" (set ANSWER_SELECTED=NO&set CHOOSE=%LANG17%&set SPEAK=%SPEAK17%&call :function_selected&goto UPDATE_QUEST)

: PRO_SELECT
set SPEAK19=You choose to enable the Pro Mode with rejet25984 method&set SPEAK20=You choose to enable the Pro Mode with Sak32009 method
if "%PRO_METHOD%"=="rejet25984" (set ANSWER_SELECTED=YES&set CHOOSE=%LANG19%&set SPEAK=%SPEAK19%&call :function_selected&goto UPDATE_QUEST)
if "%PRO_METHOD%"=="Sak32009" (set ANSWER_SELECTED=YES&set CHOOSE=%LANG20% v%Sak32009_VER%&set SPEAK=%SPEAK20%&call :function_selected&goto UPDATE_QUEST)

: UPDATE_QUEST
set SPEAK25=You choose to disable the Auto-Updates&set SPEAK26=You choose to keep the Auto-Updates enabled
::show title wemod auto-updates
echo.
%[% ' '%][% -B 5 -F 15 ' %LANG23% '%]%
if "%UPDATE_PATCH%"=="YES" (set ANSWER_SELECTED=YES&set CHOOSE=%LANG25%&set SPEAK=%SPEAK25%&call :function_selected&goto DEVTOOLS_QUEST)
if "%UPDATE_PATCH%"=="NO" (set ANSWER_SELECTED=NO&set CHOOSE=%LANG26%&set SPEAK=%SPEAK26%&call :function_selected&goto DEVTOOLS_QUEST)

: DEVTOOLS_QUEST
set SPEAK29=You choose to enable the DevTools&set SPEAK30=You choose to keep the DevTools disabled
::show title wemod devtools
echo.
%[% ' '%][% -B 5 -F 15 ' %LANG27% '%]%
if "%DEVTOOLS_PATCH%"=="YES" (set ANSWER_SELECTED=YES&set CHOOSE=%LANG29%&set SPEAK=%SPEAK29%&call :function_selected&goto START)
if "%DEVTOOLS_PATCH%"=="NO" (set ANSWER_SELECTED=NO&set CHOOSE=%LANG30%&set SPEAK=%SPEAK30%&call :function_selected&goto START)


: START
powershell -Command "[Console]::CursorVisible=0"
::create empty progress bar
for /f %%a in ('powershell -Command "[Console]::CursorTop"') do set /a PROGRESSBACKTOLINE=%%a
setlocal enabledelayedexpansion
set PROGRESSBARPOINTEMPTY=..................................................................................................
set PROGRESSBAREMPTY=%PROGRESSBARPOINTEMPTY:.=!SYMBOL5!%
::correction for zh-CN
if /i "%BATCH_LANG%"=="zh-CN" (set PROGRESSBAREMPTY=%PROGRESSBARPOINTEMPTY:.=!SYMBOL8!%)
powershell -Command "[Console]::CursorTop=%CONSOLE_LINES%-2;"&echo [90m %PROGRESSBAREMPTY%[0m
endlocal
powershell -Command "[Console]::CursorTop=%PROGRESSBACKTOLINE%"
echo.
set PRO_ERROR=0&set UPD_ERROR=0&set DEV_ERROR=0
::p=4 | u=2 | d=1 | pu=6 | pd=5 | ud=3 | pud=7
set BEEN_HERE_BEFORE_rejet25984=NO&set BEEN_HERE_BEFORE_Sak32009=NO

::progress start 1%
set /a PROGRESSBAR=1
for /f %%a in ('powershell -Command "[Console]::CursorTop"') do (
	set /a PROGRESSBACKTOLINE=%%a
	set /a PROGRESSSTEP=1
	set /a PROGRESSPERCENTVALUE=%PROGRESSBAR%
	call :function_progress
)

set CONTINUE=%PRO_PATCH%;%UPDATE_PATCH%;%DEVTOOLS_PATCH%;%PATCHEDBEFORE%
if "%CONTINUE%"=="NO;NO;NO;NO" set /a PROGRESSBAR=80&call :function_progress_add&goto END
if "%CONTINUE%"=="NO;NO;NO;YES" set /a PROGRESSBAR=60&call :function_progress_add&goto ORIGINAL_RETURN


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::ASAR INTEGRITY @Sak32009
: ASAR_INTEGRITY
::progress text
set PROGRESS_TEXT=%LANGBPT24%
call :function_progress_text
set WEMODEXE=%WEMODPATH:~0,-10%\WeMod.exe
for /f %%a in ('powershell -Command "(get-content -LiteralPath '%WEMODEXE%' -Raw) | Select-String '00001101' | ForEach-Object{'true'}"') do (
	if "%%a"=="true" (
		rem progress text
		set PROGRESS_TEXT=%LANGBPT25%
		call :function_progress_text
		move "%WEMODEXE%" "%WEMODEXE%.bak">NUL
		tar -xf "%TOOLS%" "binmay.exe">NUL
		binmay.exe -i "%WEMODEXE%.bak" -o "%WEMODEXE%" -s "t:00001101" -r "t:00000101">NUL
		del "binmay.exe">NUL
	)
)

: EXTRACT
::progress text
set PROGRESS_TEXT=%LANGBPT10%
call :function_progress_text
copy "%APP_ASAR%" "app.asar">NUL
mkdir PATCH\P PATCH\UD>NUL
if exist "binmay.exe" del "binmay.exe">NUL
::extract wemod file to patch
tar -xf "%TOOLS%" "7z">NUL&7z\7z.exe e -y app.asar "app*bundle.js" "index.js">NUL&rmdir /s /q "7z">NUL
move "app*bundle.js" PATCH\P>NUL
move "index.js" PATCH\UD>NUL
goto ENABLE_PRO_MODE_%PRO_METHOD%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::PRO @rejet25984
: ENABLE_PRO_MODE_rejet25984
set BEEN_HERE_BEFORE_rejet25984=YES
set PRO_ERROR=0
:::::::::::::::::::::::::::::::::::::::::SELECTED
if "%PRO_PATCH%"=="YES" (set /a PROGRESSBAR=10&call :function_progress_add&goto PRO_FIND_rejet25984) else (set /a PROGRESSBAR=30&call :function_progress_add&goto DISABLE_UPDATES)

: PRO_FIND_rejet25984
set LINE1=NO&set LINE2=NO&set LINE3=NO&set LINE4=NO
:::::::::::::::::::::Find
::progress text
set PROGRESS_TEXT=%LANGBPT11%
call :function_progress_text
%[% -B 0 -F 6 ' %LANG31%'%][% -B 0 -F 8 ' (%LANG33%)'%][% -B 0 -F 6 ':'%]]%
cd /d "%HOME%PATCH\P"
for /f "tokens=*" %%a in ('dir /A /B') do (
	findstr /irc:"getUserAccount(.*)}async getUserAccountFlags" %%a>NUL:&&(set LINE1=YES&set LINE1FILE=%%a)||(set NIL=NUL)
	findstr /irc:"getUserAccountFlags(.*)).flags" %%a>NUL:&&(set LINE2=YES&set LINE2FILE=%%a)||(set NIL=NUL)
	findstr /irc:"changeAccountEmail(.*email:.*,currentPassword:.*})" %%a>NUL:&&(set LINE3=YES&set LINE3FILE=%%a)||(set NIL=NUL)
	findstr /irc:"getPromotion(.*promotion.,collectMetrics:!0})}}}" %%a>NUL:&&(set LINE4=YES&set LINE4FILE=%%a)||(set NIL=NUL)
)
cd /d "%HOME%"
:::::::::::::::::::::Check
set FOUNDLINES=%LINE1%;%LINE2%;%LINE3%;%LINE4%
if "%FOUNDLINES%"=="YES;YES;YES;YES" (
	if "%LINE1FILE%"=="%LINE2FILE%" (
		if "%LINE3FILE%"=="%LINE4FILE%" (
			if "%LINE1FILE%"=="%LINE3FILE%" (
				copy "PATCH\P\%LINE1FILE%" "%LINE1FILE%">NUL
				%[% -B 0 -F 2 ' %LANG21% '%]%&set /a PROGRESSBAR=3&call :function_progress_add
				goto PRO_REPLACED_FIND_rejet25984
			)
		)
	) else (
		set PRO_ERROR=4
		%[% -B 0 -F 4 ' %LANG22% '%]%&set /a PROGRESSBAR=1&call :function_progress_add
		goto PRO_PATCH_FAILED
	)
) else (
set PRO_ERROR=4
%[% -B 0 -F 4 ' %LANG22% '%]%&set /a PROGRESSBAR=1&call :function_progress_add
goto PRO_PATCH_FAILED
)

: PRO_REPLACED_FIND_rejet25984
set PRO_PATCH_USED=rejet25984
set PRO_FILE_rejet25984=%LINE1FILE%
:::::::::::::::::::::Get Original lines
for /f "tokens=*" %%1 in ('powershell -Command "(gc -LiteralPath '%HOME%%PRO_FILE_rejet25984%') | Select-String '(getUserAccount\()(.*)(\)}async getUserAccountFlags)' | ForEach-Object{$_.Matches.Value}"') do set PRO_ORIG_L1=%%1
set PRO_ORIG_L1=%PRO_ORIG_L1:}async getUserAccountFlags=%
for /f "tokens=*" %%1 in ('powershell -Command "(gc -LiteralPath '%HOME%%PRO_FILE_rejet25984%') | Select-String '(getUserAccountFlags\()(.*)(\)\).flags)' | ForEach-Object{$_.Matches.Value}"') do set PRO_ORIG_L2=%%1
for /f "tokens=*" %%1 in ('powershell -Command "(gc -LiteralPath '%HOME%%PRO_FILE_rejet25984%') | Select-String '(changeAccountEmail\()(.*)(email:.?,currentPassword:.?}\))' | ForEach-Object{$_.Matches.Value}"') do set PRO_ORIG_L3=%%1
for /f "tokens=*" %%1 in ('powershell -Command "(gc -LiteralPath '%HOME%%PRO_FILE_rejet25984%') | Select-String '(getPromotion\()(.*)(promotion"",collectMetrics:!0}\))' | ForEach-Object{$_.Matches.Value}"') do set PRO_ORIG_L4=%%1
:::::::::::::::::::::Set Patch lines
set PRO_REPLACE_L1=%PRO_ORIG_L1%.then(function(response){response.subscription = {period:"yearly",state:"active"};response.flags = 78;return response;})
set PRO_REPLACE_L2=%PRO_ORIG_L2%.then(function(response){if (response.mask==4){response.flags = 4};return response;})
set PRO_REPLACE_L3=%PRO_ORIG_L3%.then(function(response){response.subscription = {period:"yearly",state:"active"};response.flags = 78;return response;})
set PRO_REPLACE_L4=%PRO_ORIG_L4%.then(function(response){response.components.appBanner = null;response.flags = 0;return response;})
:::::::::::::::::::::HEX Original lines
set PRO_L1=%PRO_ORIG_L1:"=\"%&set PRO_L2=%PRO_ORIG_L2:"=\"%&set PRO_L3=%PRO_ORIG_L3:"=\"%&set PRO_L4=%PRO_ORIG_L4:"=\"%
for /f "tokens=*" %%1 in ('powershell -Command "$STRING='%PRO_L1%'; $MYCHAR_ARRAY=$STRING.ToCharArray(); Foreach ($CHAR in $MYCHAR_ARRAY) {$HEX = $HEX + '' + [System.String]::Format('{0:X2}', [System.Convert]::ToUInt32($CHAR))}; $HEX"') do set PRO_ORIG_HEX_L1=%%1
for /f "tokens=*" %%1 in ('powershell -Command "$STRING='%PRO_L2%'; $MYCHAR_ARRAY=$STRING.ToCharArray(); Foreach ($CHAR in $MYCHAR_ARRAY) {$HEX = $HEX + '' + [System.String]::Format('{0:X2}', [System.Convert]::ToUInt32($CHAR))}; $HEX"') do set PRO_ORIG_HEX_L2=%%1
for /f "tokens=*" %%1 in ('powershell -Command "$STRING='%PRO_L3%'; $MYCHAR_ARRAY=$STRING.ToCharArray(); Foreach ($CHAR in $MYCHAR_ARRAY) {$HEX = $HEX + '' + [System.String]::Format('{0:X2}', [System.Convert]::ToUInt32($CHAR))}; $HEX"') do set PRO_ORIG_HEX_L3=%%1
for /f "tokens=*" %%1 in ('powershell -Command "$STRING='%PRO_L4%'; $MYCHAR_ARRAY=$STRING.ToCharArray(); Foreach ($CHAR in $MYCHAR_ARRAY) {$HEX = $HEX + '' + [System.String]::Format('{0:X2}', [System.Convert]::ToUInt32($CHAR))}; $HEX"') do set PRO_ORIG_HEX_L4=%%1
:::::::::::::::::::::HEX Patch lines
set PRO_PATCH_L1=%PRO_REPLACE_L1:"=\"%&set PRO_PATCH_L2=%PRO_REPLACE_L2:"=\"%&set PRO_PATCH_L3=%PRO_REPLACE_L3:"=\"%&set PRO_PATCH_L4=%PRO_REPLACE_L4:"=\"%
for /f "tokens=*" %%1 in ('powershell -Command "$STRING='%PRO_PATCH_L1%'; $MYCHAR_ARRAY=$STRING.ToCharArray(); Foreach ($CHAR in $MYCHAR_ARRAY) {$HEX = $HEX + '' + [System.String]::Format('{0:X2}', [System.Convert]::ToUInt32($CHAR))}; $HEX"') do set PRO_REPLACE_HEX_L1=%%1
for /f "tokens=*" %%1 in ('powershell -Command "$STRING='%PRO_PATCH_L2%'; $MYCHAR_ARRAY=$STRING.ToCharArray(); Foreach ($CHAR in $MYCHAR_ARRAY) {$HEX = $HEX + '' + [System.String]::Format('{0:X2}', [System.Convert]::ToUInt32($CHAR))}; $HEX"') do set PRO_REPLACE_HEX_L2=%%1
for /f "tokens=*" %%1 in ('powershell -Command "$STRING='%PRO_PATCH_L3%'; $MYCHAR_ARRAY=$STRING.ToCharArray(); Foreach ($CHAR in $MYCHAR_ARRAY) {$HEX = $HEX + '' + [System.String]::Format('{0:X2}', [System.Convert]::ToUInt32($CHAR))}; $HEX"') do set PRO_REPLACE_HEX_L3=%%1
for /f "tokens=*" %%1 in ('powershell -Command "$STRING='%PRO_PATCH_L4%'; $MYCHAR_ARRAY=$STRING.ToCharArray(); Foreach ($CHAR in $MYCHAR_ARRAY) {$HEX = $HEX + '' + [System.String]::Format('{0:X2}', [System.Convert]::ToUInt32($CHAR))}; $HEX"') do set PRO_REPLACE_HEX_L4=%%1
:::::::::::::::::::::Replace
::progress text
set PROGRESS_TEXT=%LANGBPT12%
call :function_progress_text
%[% -B 0 -F 6 ' %LANG32%'%][% -B 0 -F 8 ' (%LANG33%)'%][% -B 0 -F 6 ':'%]]%
move "%PRO_FILE_rejet25984%" "%PRO_FILE_rejet25984%.bak">NUL
if not exist "binmay.exe" tar -xf "%TOOLS%" "binmay.exe">NUL
binmay.exe -i "%PRO_FILE_rejet25984%.bak" -o "%PRO_FILE_rejet25984%.L1" -s "h:%PRO_ORIG_HEX_L1%" -r "h:%PRO_REPLACE_HEX_L1%">NUL
binmay.exe -i "%PRO_FILE_rejet25984%.L1" -o "%PRO_FILE_rejet25984%.L2" -s "h:%PRO_ORIG_HEX_L2%" -r "h:%PRO_REPLACE_HEX_L2%">NUL
binmay.exe -i "%PRO_FILE_rejet25984%.L2" -o "%PRO_FILE_rejet25984%.L3" -s "h:%PRO_ORIG_HEX_L3%" -r "h:%PRO_REPLACE_HEX_L3%">NUL
binmay.exe -i "%PRO_FILE_rejet25984%.L3" -o "%PRO_FILE_rejet25984%" -s "h:%PRO_ORIG_HEX_L4%" -r "h:%PRO_REPLACE_HEX_L4%">NUL
del "%PRO_FILE_rejet25984%.bak" "%PRO_FILE_rejet25984%.L1" "%PRO_FILE_rejet25984%.L2" "%PRO_FILE_rejet25984%.L3">NUL
:::::::::::::::::::::Replaced find
findstr /c:"%PRO_PATCH_L1%" %PRO_FILE_rejet25984%>NUL:&&(set CHECKLINE1=YES)||(set CHECKLINE1=NO)
findstr /c:"%PRO_PATCH_L2%" %PRO_FILE_rejet25984%>NUL:&&(set CHECKLINE2=YES)||(set CHECKLINE2=NO)
findstr /c:"%PRO_PATCH_L3%" %PRO_FILE_rejet25984%>NUL:&&(set CHECKLINE3=YES)||(set CHECKLINE3=NO)
findstr /c:"%PRO_PATCH_L4%" %PRO_FILE_rejet25984%>NUL:&&(set CHECKLINE4=YES)||(set CHECKLINE4=NO)
set FOUNDREPLACELINES=%CHECKLINE1%;%CHECKLINE2%;%CHECKLINE3%;%CHECKLINE4%
if "%FOUNDREPLACELINES%"=="YES;YES;YES;YES" (%[% -B 0 -F 2 ' %LANG21% '%]%&set /a PROGRESSBAR=3&call :function_progress_add) else (set PRO_ERROR=4&%[% -B 0 -F 4 ' %LANG22% '%]%&set /a PROGRESSBAR=1&call :function_progress_add&goto PRO_PATCH_FAILED)
goto CUSTOM_USERNAME


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::PRO @Sak32009
: ENABLE_PRO_MODE_Sak32009
set BEEN_HERE_BEFORE_Sak32009=YES
set PRO_ERROR=0
:::::::::::::::::::::::::::::::::::::::::SELECTED
if "%PRO_PATCH%"=="YES" (set /a PROGRESSBAR=10&call :function_progress_add&goto PRO_FIND_AND_REPLACE_Sak32009) else (set /a PROGRESSBAR=30&call :function_progress_add&goto DISABLE_UPDATES)

: PRO_FIND_AND_REPLACE_Sak32009
:::::::::::::::::::::Original line
set PRO_ORIG={return"application/json"===e.headers.get("Content-Type")?await e.json():await e.text()}
:::::::::::::::::::::Transform Original line
set PROFIND=%PRO_ORIG:"=""%
set PRO=%PRO_ORIG:"=\"%
for /f "tokens=*" %%1 in ('powershell -Command "$STRING='%PRO%'; $MYCHAR_ARRAY=$STRING.ToCharArray(); Foreach ($CHAR in $MYCHAR_ARRAY) {$HEX = $HEX + '' + [System.String]::Format('{0:X2}', [System.Convert]::ToUInt32($CHAR))}; $HEX"') do set PRO_ORIG_HEX=%%1
:::::::::::::::::::::Find and replace with external file
if "%Sak32009_VER%"=="" set Sak32009_VER=1.0.4
set Sak32009_PATCH_VER=PRO_Sak32009_%Sak32009_VER:.=%.js
tar -xf "%TOOLS%" "%Sak32009_PATCH_VER%">NUL
set Gift_Sender=cs.rin.ru: @Sak32009, @rejet25984, @brunolee
powershell -Command "(gc -LiteralPath '%HOME%%Sak32009_PATCH_VER%') -replace '	', '' -replace 'Gift_Sender', '%Gift_Sender%' | Out-File -LiteralPath '%HOME%%Sak32009_PATCH_VER%' -NoNewline -encoding Default">NUL
::progress text
set PROGRESS_TEXT=%LANGBPT11%
call :function_progress_text
%[% -B 0 -F 6 ' %LANG31%'%][% -B 0 -F 8 ' (%LANG34% v%Sak32009_VER%)'%][% -B 0 -F 6 ':'%]]%
for /f "tokens=*" %%a in ('dir "PATCH\P" /A /B') do (
	find /C "%PROFIND%" PATCH\P\%%a>NUL:&&(
		set PRO_FILE_Sak32009=%%a
		%[% -B 0 -F 2 ' %LANG21% '%]%&set /a PROGRESSBAR=3&call :function_progress_add
		if not exist "binmay.exe" tar -xf "%TOOLS%" "binmay.exe">NUL
		binmay.exe -i "PATCH\P\%%a" -o "%%a" -s "h:%PRO_ORIG_HEX%" -r "f:%Sak32009_PATCH_VER%">NUL
	)||(set NIL=NUL)
)

: PRO_REPLACED_FIND_Sak32009
set PRO_PATCH_USED=Sak32009_v%Sak32009_VER%
:::::::::::::::::::::Patch line (+-)
set  PRO_REPLACED=%Gift_Sender%
:::::::::::::::::::::Replaced find
if exist "PRO_Sak3*" del "PRO_Sak3*">NUL
::progress text
set PROGRESS_TEXT=%LANGBPT12%
call :function_progress_text
if exist "%PRO_FILE_Sak32009%" (
	%[% -B 0 -F 6 ' %LANG32%'%][% -B 0 -F 8 ' (%LANG34% v%Sak32009_VER%)'%][% -B 0 -F 6 ':'%]]%
	find /C "%PRO_REPLACED%" %PRO_FILE_Sak32009%>NUL:&&(%[% -B 0 -F 2 ' %LANG21% '%]%&set /a PROGRESSBAR=3&call :function_progress_add&goto CUSTOM_USERNAME)||(%[% -B 0 -F 4 ' %LANG22% '%]%&set /a PROGRESSBAR=3&call :function_progress_add)
) else (%[% -B 0 -F 4 ' %LANG22% '%]%&set /a PROGRESSBAR=1&call :function_progress_add)
set PRO_ERROR=4&goto PRO_PATCH_FAILED


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::CUSTOM USERNAME
: CUSTOM_USERNAME
:::::::::::::::::::::::::::::::::::::::::SELECTED
if "%CHANGE_CUSTOM_USERNAME%"=="YES" (goto CUSTOM_USERNAME_FIND_AND_REPLACE) else (goto DISABLE_REMOTEBUTTON)

: CUSTOM_USERNAME_FIND_AND_REPLACE
::progress text
set PROGRESS_TEXT=%LANGBPT13%
call :function_progress_text
if "%PRO_PATCH_USED%" == "rejet25984" (
	set PRO_PATCH_FILE=%PRO_FILE_rejet25984%
	set CUSTOM_USERNAME=response.flags = 78;
	set CUSTOM_USERNAME_PATCH=response.flags = 78; response.username = '%WeMod_CUSTOM_USERNAME%';
)
if "%PRO_PATCH_USED%" == "Sak32009_v1.0.4" (
	set PRO_PATCH_FILE=%PRO_FILE_Sak32009%
	set CUSTOM_USERNAME=data.subscription=subscription;
	set CUSTOM_USERNAME_PATCH=data.subscription=subscription;data.username='%WeMod_CUSTOM_USERNAME%';
)
if "%PRO_PATCH_USED%" == "Sak32009_v1.0.7" (
	set PRO_PATCH_FILE=%PRO_FILE_Sak32009%
	set CUSTOM_USERNAME=t.subscription=o
	set CUSTOM_USERNAME_PATCH=t.subscription=o;t.username='%WeMod_CUSTOM_USERNAME%';
)
move "%PRO_PATCH_FILE%" "%PRO_PATCH_FILE%.org">NUL
binmay.exe -i "%PRO_PATCH_FILE%.org" -o "%PRO_PATCH_FILE%" -s "t:%CUSTOM_USERNAME%" -r "t:%CUSTOM_USERNAME_PATCH%">NUL
del "%PRO_PATCH_FILE%.org">NUL


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::REMOTE BUTTON @softkmo
: DISABLE_REMOTEBUTTON
::progress text
set PROGRESS_TEXT=%LANGBPT14%
call :function_progress_text
:::::::::::::::::::::Original line
set "REMOTEBUTTON_ORIG=remote-button{position:relative}"
:::::::::::::::::::::Patch line
set "REMOTEBUTTON_REPLACE=remote-button{position:relative;display:none}"
:::::::::::::::::::::Find and replace
for /f "tokens=*" %%a in ('dir "PATCH\P" /A /B') do (
	findstr /irc:"%REMOTEBUTTON_ORIG%" PATCH\P\%%a>NUL:&&(
		binmay.exe -i "PATCH\P\%%a" -o "%%a" -s "t:%REMOTEBUTTON_ORIG%" -r "t:%REMOTEBUTTON_REPLACE%">NUL
	)||(set NIL=NUL)
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::OBJECTIVES @softkmo
: DISABLE_OBJECTIVES
::progress text
set PROGRESS_TEXT=%LANGBPT15%
call :function_progress_text
:::::::::::::::::::::Original lines
set "OBJECTIVES_ORIG=.sections section.objectives{max-height:300px}"
set "ANNOUNCEMENTSGAP_ORIG=.sections section.announcements{"
:::::::::::::::::::::Patch lines
set "OBJECTIVES_REPLACE=.sections section.objectives{display:none}"
set "ANNOUNCEMENTSGAP_REPLACE=.sections section.announcements{margin-top:0px;"
:::::::::::::::::::::Find and replace
for /f "tokens=*" %%a in ('dir "PATCH\P" /A /B') do (
	findstr /irc:"%OBJECTIVES_ORIG%" PATCH\P\%%a>NUL:&&(
		binmay.exe -i "PATCH\P\%%a" -o "%%a.org" -s "t:%OBJECTIVES_ORIG%" -r "t:%OBJECTIVES_REPLACE%">NUL
		binmay.exe -i "%%a.org" -o "%%a" -s "t:%ANNOUNCEMENTSGAP_ORIG%" -r "t:%ANNOUNCEMENTSGAP_REPLACE%">NUL
		del "%%a.org">NUL
	)||(set NIL=NUL)
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::UPDATE @Sak32009
: DISABLE_UPDATES
:::::::::::::::::::::::::::::::::::::::::SELECTED
if "%UPDATE_PATCH%"=="YES" (set /a PROGRESSBAR=20&call :function_progress_add&goto UPDATE_FIND_AND_REPLACE) else (set /a PROGRESSBAR=30&call :function_progress_add&goto ENABLE_DEVTOOLS)

: UPDATE_FIND_AND_REPLACE
:::::::::::::::::::::Original line
set UPD_ORIG=function isUpdaterAvailable(){.*catch{return false}}
for /f "tokens=*" %%1 in ('powershell -Command "(gc -LiteralPath '%HOME%PATCH\UD\index.js') | Select-String '(function isUpdaterAvailable\(\){(.*)catch{return false}})' | ForEach-Object{$_.Matches.Value}"') do set UPD_ORG=%%1
:::::::::::::::::::::Patch line
set UPD_REPLACE=function isUpdaterAvailable(){return false}
:::::::::::::::::::::HEX Original line
set UPD=%UPD_ORG:"=\"%
for /f "tokens=*" %%1 in ('powershell -Command "$STRING='%UPD%'; $MYCHAR_ARRAY=$STRING.ToCharArray(); Foreach ($CHAR in $MYCHAR_ARRAY) {$HEX = $HEX + '' + [System.String]::Format('{0:X2}', [System.Convert]::ToUInt32($CHAR))}; $HEX"') do set UPD_ORIG_HEX=%%1
:::::::::::::::::::::Find and replace
::progress text
set PROGRESS_TEXT=%LANGBPT16%
call :function_progress_text
%[% -B 0 -F 6 ' %LANG38%'%]]%
findstr /irc:"%UPD_ORIG%" PATCH\UD\index.js>NUL:&&(
	%[% -B 0 -F 2 ' %LANG21% '%]%
	if not exist "binmay.exe" tar -xf "%TOOLS%" "binmay.exe">NUL
	binmay.exe -i "PATCH\UD\index.js" -o "index.js" -s "h:%UPD_ORIG_HEX%" -r "t:%UPD_REPLACE%">NUL
)||(set UPD_ERROR=2&%[% -B 0 -F 4 ' %LANG22% '%]%&set /a PROGRESSBAR=5&call :function_progress_add&goto ENABLE_DEVTOOLS)

: UPDATE_REPLACED_FIND
:::::::::::::::::::::Replaced find
::progress text
set PROGRESS_TEXT=%LANGBPT17%
call :function_progress_text
%[% -B 0 -F 6 ' %LANG39%'%]]%
find /C "%UPD_REPLACE%" index.js>NUL:&&(%[% -B 0 -F 2 ' %LANG21% '%]%&set /a PROGRESSBAR=5&call :function_progress_add)||(set UPD_ERROR=2&%[% -B 0 -F 4 ' %LANG22% '%]%&set /a PROGRESSBAR=5&call :function_progress_add)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::DEVTOOLS @Sak32009
: ENABLE_DEVTOOLS
:::::::::::::::::::::::::::::::::::::::::SELECTED
if "%DEVTOOLS_PATCH%"=="YES" (set /a PROGRESSBAR=20&call :function_progress_add&goto DEVTOOLS_FIND_AND_REPLACE) else (set /a PROGRESSBAR=30&call :function_progress_add&goto CHECK_ERRORS)

: DEVTOOLS_FIND_AND_REPLACE
:::::::::::::::::::::Original line
set DEV_ORIG=if(.*.devMode){openDevTools()
for /f "tokens=*" %%1 in ('powershell -Command "(gc -LiteralPath '%HOME%PATCH\UD\index.js') | Select-String '(if\((.?).devMode\){openDevTools\(\))' | ForEach-Object{$_.Matches.Value}"') do set DEV_ORG=%%1
:::::::::::::::::::::Patch line
set DEV_REPLACE=if(true){openDevTools()
:::::::::::::::::::::Find and replace
if exist "index.js" (move "index.js" "index.js.org">NUL) else (copy "PATCH\UD\index.js" "index.js.org">NUL)
::progress text
set PROGRESS_TEXT=%LANGBPT18%
call :function_progress_text
%[% -B 0 -F 6 ' %LANG40%'%]]%
findstr /irc:"%DEV_ORIG%" index.js.org>NUL:&&(
	%[% -B 0 -F 2 ' %LANG21% '%]%&set /a PROGRESSBAR=5&call :function_progress_add
	if not exist "binmay.exe" tar -xf "%TOOLS%" "binmay.exe">NUL
	binmay.exe -i "index.js.org" -o "index.js" -s "t:%DEV_ORG%" -r "t:%DEV_REPLACE%">NUL
	del "index.js.org">NUL
)||(set DEV_ERROR=1&%[% -B 0 -F 4 ' %LANG22% '%]%&set /a PROGRESSBAR=5&call :function_progress_add&goto CHECK_ERRORS)

: DEVTOOLS_REPLACED_FIND
:::::::::::::::::::::Replaced find
::progress text
set PROGRESS_TEXT=%LANGBPT19%
call :function_progress_text
%[% -B 0 -F 6 ' %LANG41%'%]]%
find /C "%DEV_REPLACE%" index.js>NUL:&&(%[% -B 0 -F 2 ' %LANG21% '%]%&set /a PROGRESSBAR=5&call :function_progress_add)||(set DEV_ERROR=1&%[% -B 0 -F 4 ' %LANG22% '%]%&set /a PROGRESSBAR=5&call :function_progress_add)


: CHECK_ERRORS
::check errors
set /a ERROR_VALUE=%PRO_ERROR%+%UPD_ERROR%+%DEV_ERROR%
if %ERROR_VALUE%==0 (set BGCOLOR=10&set SHOWLANG=%LANG42%&set GOTO=PACK&goto SHOW_ERROR)
if %ERROR_VALUE%==1 (set BGCOLOR=4&set SHOWLANG=%LANG43%&set GOTO=CLEAN&goto SHOW_ERROR)
if %ERROR_VALUE%==2 (set BGCOLOR=4&set SHOWLANG=%LANG44%&set GOTO=CLEAN&goto SHOW_ERROR)
if %ERROR_VALUE%==3 (set BGCOLOR=4&set SHOWLANG=%LANG45%&set GOTO=CLEAN&goto SHOW_ERROR)
if %ERROR_VALUE%==4 (goto PRO_PATCH_FAILED)
if %ERROR_VALUE%==5 (set BGCOLOR=4&set SHOWLANG=%LANG46%&set GOTO=CLEAN&goto SHOW_ERROR)
if %ERROR_VALUE%==6 (set BGCOLOR=4&set SHOWLANG=%LANG47%&set GOTO=CLEAN&goto SHOW_ERROR)
if %ERROR_VALUE%==7 (set BGCOLOR=4&set SHOWLANG=%LANG48%&set GOTO=CLEAN&goto SHOW_ERROR)

: SHOW_ERROR
::center text
set TEXT2CENTER= %SHOWLANG% 
call :function_center_text
::show error
powershell -Command "[Console]::CursorTop=35"
%[% -B 0 -F 0 ''.PadRight(%TEXTCENTER%)%][% -B %BGCOLOR% -F 15 '%TEXT2CENTER%'%]%
goto %GOTO%


: PACK
::progress text
set PROGRESS_TEXT=%LANGBPT20%
call :function_progress_text
::pack wemod patched file and create a backup
copy "app.asar" "app.asar.bak">NUL
tar -xf "%TOOLS%" "7z">NUL&7z\7z.exe a -y app.asar "*.js">NUL&rmdir /s /q "7z">NUL
move "app.asar" "%WEMODPATH%\app.asar">NUL
move "app.asar.bak" "%WEMODPATH%\app.asar.bak">NUL
::center text
set TEXT2CENTER= %SYMBOL4% %LANG49% 
call :function_center_text
::show centered wemod patched
powershell -Command "[Console]::CursorTop=37"
%[% -B 0 -F 0 ''.PadRight(%TEXTCENTER%)%][% -B 0 -F 10 '%TEXT2CENTER%'%]%


: CLEAN
::progress text
set PROGRESS_TEXT=%LANGBPT21%
call :function_progress_text
::remove temp files
rmdir /s /q "PATCH">NUL
if exist "*.js" del "*.js">NUL
if exist "app.asar" del "app.asar">NUL
if exist "app.asar.bak" del "app.asar.bak">NUL
if exist "binmay.exe" del "binmay.exe">NUL
goto END


: END
::progress go to 100
if %PROGRESSPERCENTVALUE% NEQ 98 (
	set /a PROGRESSBAR=98-%PROGRESSPERCENTVALUE%
	set /a PROGRESSSTEP=1+%PROGRESSPERCENTVALUE%
	set /a PROGRESSPERCENTVALUE=100
	call :function_progress
)
::progress text
set PROGRESS_TEXT=%LANGBPT23%
call :function_progress_text
::blink center text
powershell -Command "[Console]::CursorTop=38"
set TEXT2CENTER= %LANG50% 
call :function_center_blink_text
exit


: ORIGINAL_RETURN
set SPEAK55=You choose to restore WeMod backup&set SPEAK56=You choose to keep everything as it was before
::show restore option quest
%[% -B 0 -F 5 ' @%TITLE%'%][% -B 0 -F 7 ': %LANG51% '%][% -B 0 -F 8 '(%LANG52%|%LANG53%)'%][% -B 0 -F 6 ' > '%]]%
powershell -Command "Write-Output 'c=MsgBox(\"%LANG54%\",vbQuestion+vbYesNo,\"%TITLE% v%VERSION%\") : Wscript.echo(c)' | Out-File -LiteralPath '%HOME%ORIGINAL_RETURN.vbs'">NUL
for /f "tokens=*" %%a in ('cscript ORIGINAL_RETURN.vbs') do set ORIGINAL_RETURN_ANSWER=%%a
del ORIGINAL_RETURN.vbs>NUL
if %ORIGINAL_RETURN_ANSWER%==6 (%[% -B 0 -F 10 '%LANG52%'%]%&set ANSWER_SELECTED=YES&set CHOOSE=%LANG55%&set SPEAK=%SPEAK55%&call :function_selected&goto RESTORE_BACKUP)
if %ORIGINAL_RETURN_ANSWER%==7 (%[% -B 0 -F 10 '%LANG53%'%]%&set ANSWER_SELECTED=NO&set CHOOSE=%LANG56%&set SPEAK=%SPEAK56%&call :function_selected&echo.&goto END)


: RESTORE_BACKUP
::progress text
set PROGRESS_TEXT=%LANGBPT22%
call :function_progress_text
del "%WEMODPATH%\app.asar">NUL
move "%WEMODPATH%\app.asar.bak" "%WEMODPATH%\app.asar">NUL
echo.
::center text
set TEXT2CENTER= %SYMBOL4% %LANG57% 
call :function_center_text
::show wemod backup restored
%[% -B 0 -F 0 ''.PadRight(%TEXTCENTER%)%][% -B 0 -F 10 '%TEXT2CENTER%'%]%&set /a PROGRESSBAR=30&call :function_progress_add
goto END


: PRO_PATCH_FAILED
::if pro method fail try another method
set BEEN_HERE_BEFORE=%BEEN_HERE_BEFORE_rejet25984%;%BEEN_HERE_BEFORE_Sak32009%
if "%BEEN_HERE_BEFORE%"=="NO;YES" %[% -B 0 -F 5 ' @%TITLE%'%][% -B 0 -F 14 ': %LANG35%'%]%&goto ENABLE_PRO_MODE_rejet25984
if "%BEEN_HERE_BEFORE%"=="YES;NO" %[% -B 0 -F 5 ' @%TITLE%'%][% -B 0 -F 14 ': %LANG36%'%]%&goto ENABLE_PRO_MODE_Sak32009
if "%BEEN_HERE_BEFORE%"=="YES;YES" (set BGCOLOR=4&set SHOWLANG=%LANG37%&set GOTO=CLEAN&goto SHOW_ERROR)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::FUNCTIONS
:function_owmp_download
::download list
setlocal enabledelayedexpansion

set count=0
for /f "tokens=1-9 delims=<> eol=#" %%1 in (%ListURL%) do (
	set OnlVerson=%%1
	set OnlDBFile=%%2
	set OnlDBRKey=%%3
	set OnlClasse=%%4
	rem show all releases
	if "%WMPDList%"=="ShowAll" (
		set /a count+=1
		for /f "tokens=1-9 delims=-" %%a in ("!OnlVerson!") do (
			set newver=%%a
			if not "!newver!"=="!oldver!" (
				echo.
				echo   [93mWeModPatcher v!OnlVerson![0m
			)
			echo    [93m!count![0m. !OnlClasse!
			set oldver=!newver!
		)
	)
	rem	show only last release
	if "%WMPDList%"=="ShowLast" (
		if "%%1"=="%OWMPLastVersion%" (
			if !count!==0 (
				echo.
			)
			set /a count+=1
			echo    [93m!count![0m. !OnlClasse!
		)
	)
	set download!count!=WeModPatcher v!OnlVerson! !OnlClasse!.zip
	set downloadV!count!=!OnlVerson!
	set downloadC!count!=!OnlClasse!
	rem github link
	set linkgithub!count!=https://github.com/brunolee-GIT/W3M0dP4tch32/releases/download/v!OnlVerson!/v!OnlVerson!.!OnlClasse!.zip
	rem dropbox link (if github and gitlab not work)
	set "linkdropbox!count!=https://www.dropbox.com/scl/fi/!OnlDBFile!/v!OnlVerson!-!OnlClasse!.zip?rlkey=!OnlDBRKey!&dl=1"
)
echo.
for /f %%a in ('powershell -Command "[Console]::CursorTop"') do set /a PROGRESSBACKTOLINE=%%a

: owmp_selectline
::select
set selectline=!count!
powershell -Command "[Console]::CursorLeft=1
set /p selectline="[35mSelect one to download[0m [ [93m1[0m - [93;4m!count![0m ]: "
if %selectline% GEQ 1 (
	if %selectline% LEQ !count! (
		set Download=!download%selectline%!
		set DownV=!downloadV%selectline%!
		set DownC=!downloadC%selectline%!
		set "githubLINK=!linkgithub%selectline%!"
		set "dropboxLINK=!linkdropbox%selectline%!"
		goto owmp_download
	) 
)
::clean incorrect imput and try again
powershell -Command "[Console]::CursorTop=%PROGRESSBACKTOLINE%"
echo                                                                 
powershell -Command "[Console]::CursorTop=%PROGRESSBACKTOLINE%"
goto owmp_selectline

: owmp_download
::download
echo.
echo  [93m[ ] Downloading %Download%...[0m
for /f "tokens=*" %%a in ('powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.SaveFileDialog;$f.InitialDirectory='%CD%';$f.FileName='%Download%';$f.Filter='WeModPatcher (*.zip)|*.zip';$f.showHelp=$false;$f.ShowDialog()|Out-Null;$f.FileName"') do set "OWMP_SAVEPATH=%%a"
if "%OWMP_SAVEPATH%" == "%Download%" echo  [94m[?] Canceled...[0m&goto owmp_end
::download from github
curl --progress-bar -L %githubLINK% -o "%OWMP_SAVEPATH%"
::get link and download from gitlab (if github not work)
if not exist "releases.json" curl -s https://gitlab.com/api/v4/projects/59393779/releases/v!DownV! -o "releases.json"
for /f "tokens=1-9 delims=([])" %%1 in ('powershell -Command "(gc -LiteralPath '%HOME%releases.json' | ConvertFrom-Json).description"') do (
	if "%%1"=="v!DownV!_!DownC!.zip" set gitlabLINK=https://gitlab.com/-/project/59393779%%2
)
del "releases.json">NUL
curl --progress-bar -L %gitlabLINK% -o "%OWMP_SAVEPATH%"
::download from dropbox (if gitlab not work)
if not exist "%OWMP_SAVEPATH%" powershell -Command "wget -Uri '%dropboxLINK%' -d -OutFile '%OWMP_SAVEPATH%'"
if exist "%OWMP_SAVEPATH%" (echo  [92m[X] Done![0m) else (echo  [31m[?] something went wrong...[0m)
endlocal
pause&exit

: owmp_end
endlocal
goto :EOF

:function_selected
::beep sounds
if /i "%BEEP%"=="YES" (
	if "%ANSWER_SELECTED%"=="YES" (
		powershell [console]::beep^(1000,300^)
		) else (
		powershell [console]::beep^(200,300^)
	)
)
::show selected choices
%[% -B 0 -F 3 ' @%username%'%][% -B 0 -F 7 ': '%][% -B 7 -F 0 ' %CHOOSE%! '%]]%
::speech if "Microsoft Zira Desktop" [en-US] is on system
setlocal enabledelayedexpansion
if /i "%SPEECH%"=="YES" (
	set VOICE=Zira
	set /a NBR=0
	for /f "tokens=1-2 delims=[]" %%1 in ('powershell "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices().VoiceInfo|foreach {$_.Name}" ^| find /n /i "!VOICE!"') do set /a NBR=%%1
	if "!NBR!"=="0" (
		%[% -B 4 -F 15 ' %SYMBOL2% '%]%
	) else (
		set /a VOICENR=!NBR! -1
		%[% -B 10 -F 15 ' %SYMBOL3% '%]%
		echo set !VOICE! = CreateObject^("SAPI.spVoice"^) : set !VOICE!.Voice = !VOICE!.GetVoices.Item^(!VOICENR!^) : !VOICE!.Rate = 0 : !VOICE!.Volume = 100 : !VOICE!.Speak "%SPEAK%">!VOICE!.vbs
		!VOICE!.vbs
		del !VOICE!.vbs>NUL
	)
) else (%[% %]%)
endlocal
goto :EOF

:function_center_window
::batch window width
for /f %%a in ('powershell -Command "[math]::Round(%CONSOLE_COLS% * 8.18)"') do set /a BATCH_WIDTH=%%a
::batch window height
for /f %%a in ('powershell -Command "[math]::Round(%CONSOLE_LINES% * 16.96)"') do set /a BATCH_HEIGHT=%%a
::screen x (Width screen - Width Batch window / 2)
for /f %%a in ('powershell -Command "[math]::Round((%SCREEN_WIDTH% - %BATCH_WIDTH%) / 2)"') do set /a ScreenX=%%a
::screen y (Height screen - Height Batch window / 2)
for /f %%a in ('powershell -Command "[math]::Round((%SCREEN_HEIGHT% - %BATCH_HEIGHT%) / 2)"') do set /a ScreenY=%%a
::center and resize - CenterWindow -ProcessId $ProcessId -X $ScreenX -Y $ScreenY -Width $WindowWidth -Height $WindowHeight -Passthru
powershell -Command Function Set-Window {[OutputType(\"System.Automation.WindowInfo\")] [cmdletbinding()] Param ([parameter(ValueFromPipelineByPropertyName=$True)] $ProcessId, [int]$X, [int]$Y, [int]$Width, [int]$Height, [switch]$Passthru ) Begin {Try{[void][Window]} Catch {Add-Type 'using System; using System.Runtime.InteropServices; public class Window {[DllImport(\"user32.dll\")] [return: MarshalAs(UnmanagedType.Bool)] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect); [DllImport(\"User32.dll\")] public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);}; public struct RECT{public int Left; public int Top; public int Right; public int Bottom;};'}}; Process {$Rectangle = New-Object RECT; $Handle = (Get-Process -Id $ProcessId).MainWindowHandle; if ( $Handle -eq [System.IntPtr]::Zero ) { Continue } $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle); If (-NOT $PSBoundParameters.ContainsKey(\"Width\")) {$Width = $Rectangle.Right - $Rectangle.Left}; If (-NOT $PSBoundParameters.ContainsKey(\"Height\")) {$Height = $Rectangle.Bottom - $Rectangle.Top}; If ($Return) {$Return = [Window]::MoveWindow($Handle, $x, $y, $Width, $Height, $True)}}}; Set-Alias CenterWindow Set-Window;^
CenterWindow -ProcessId %PROCESSID% -X %ScreenX% -Y %ScreenY% -Passthru
mode con cols=%CONSOLE_COLS% lines=%CONSOLE_LINES%
goto :EOF

:function_center_text
for /f %%a in ('powershell -Command "[math]::Round((%CONSOLE_COLS% - '%TEXT2CENTER%'.length) / 2)"') do set /a TEXTCENTER=%%a
goto :EOF

:function_right_text
for /f %%a in ('powershell -Command "[math]::Round((%CONSOLE_COLS% - '%TEXTFROMLEFT%'.length) - 1)"') do set /a TEXTRIGHT=%%a
goto :EOF
rem ::TEXT TO RIGHT
rem set TEXTFROMLEFT= @TEST:
rem call :function_right_text
rem %[% -B 0 -F 5 ' @TEST'%][% -B 0 -F 7 ':'%]]%
rem %[% -B 0 -F 2 '[OK]'.PadLeft(%TEXTRIGHT%)%]%

:function_align_text
for /f %%a in ('powershell -Command "'%ALIGN1%'.length"') do set /a ALIGN_TWO=%%a
for /f %%a in ('powershell -Command "'%ALIGN2%'.length"') do set /a ALIGN_ONE=%%a
goto :EOF

:function_center_blink_text
for /f %%a in ('powershell -Command "[math]::Round((%CONSOLE_COLS% + '%TEXT2CENTER%'.length) / 2 + 8)"') do set /a TEXTCENTER=%%a
::correction for zh-CN
if /i "%BATCH_LANG%"=="zh-CN" (set /a TEXTCENTER=%TEXTCENTER%-2)
set BLKDELAY_MSEC=500
set BLKCOUNT=10
set BLKCOLORS=0, 7
::center and blink - CenterBlink $Message $Delay $Count $Color1, $Color2, ...
powershell -Command function Blink-Message {param([String]$Message,[int]$Delay,[int]$Count,[ConsoleColor[]]$FColors); $startFColor = [Console]::ForegroundColor; $startLeft = [Console]::CursorLeft; $startTop = [Console]::CursorTop; $FcolorCount = $FColors.Length; for($i = 1; $i -lt $Count+1; $i++) {$timeout = ($Count - $i); [Console]::CursorLeft = $startLeft; [Console]::CursorTop = $startTop; [Console]::ForegroundColor = $FColors[$($i %% $FcolorCount)]; [Console]::WriteLine($Message+'[90m ('+$timeout+')[0m '); Start-Sleep -Milliseconds $Delay} [Console]::ForegroundColor = $startFColor}; Set-Alias CenterBlink Blink-Message;^
CenterBlink '[7m%TEXT2CENTER%[0m'.PadLeft(%TEXTCENTER%) %BLKDELAY_MSEC% %BLKCOUNT% %BLKCOLORS%
goto :EOF

:function_progress_text
for /f %%a in ('powershell -Command "[Console]::CursorTop"') do set /a BACKTOLINE=%%a
set /a PROGRESSTEXTLINE=%CONSOLE_LINES%
powershell -Command "[Console]::CursorTop=%PROGRESSTEXTLINE%-4"&echo                                                                                                     
powershell -Command "[Console]::CursorTop=%PROGRESSTEXTLINE%-4"&echo [90m %PROGRESS_TEXT% [0m
powershell -Command "[Console]::CursorTop=%BACKTOLINE%"
goto :EOF

:function_progress_add
for /f %%a in ('powershell -Command "[Console]::CursorTop"') do (
	set /a PROGRESSBACKTOLINE=%%a
	set /a PROGRESSSTEP=1+%PROGRESSPERCENTVALUE%
	set /a PROGRESSPERCENTVALUE=%PROGRESSPERCENTVALUE%+%PROGRESSBAR%
	call :function_progress
)
goto :EOF

:function_progress
setlocal enabledelayedexpansion
set PROGRESSBARVALUE=..................................................................................................
::correction for zh-CN
if /i "%BATCH_LANG%"=="zh-CN" (set PROGRESSBARVALUE=%PROGRESSBARVALUE:~1%)
set PROGRESSBARVALUE=%PROGRESSBARVALUE:.=!SYMBOL7!%
set /a PROGRESSBARLINE=%CONSOLE_LINES%
set PROGRESSBARCODE=!PROGRESSBARVALUE:~0,%PROGRESSBAR%!
powershell -Command "[Console]::CursorTop=%PROGRESSBARLINE%-3"&echo [90m %PROGRESSPERCENTVALUE%%% [0m
powershell -Command "[Console]::CursorTop=%PROGRESSBARLINE%-2; [Console]::CursorLeft=%PROGRESSSTEP%"&echo [92m%PROGRESSBARCODE%[0m
powershell -Command "[Console]::CursorTop=%PROGRESSBACKTOLINE%"
endlocal
goto :EOF

:function_launcher
if [%~x0] == [.bat] set HTAICON=WeModPatcher.ico
if [%~x0] == [.exe] set HTAICON=WeModPatcher.exe
if "%FORCE_THEME_COLOR%"=="DARK" (
	set bodybackground=#282828&set buttonbackground=#505050&set fontcolor=white&set linkcolor=LightBlue&set backcolor=LightGreen
	set "hyperlink=iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAABZklEQVR4nJ3UsU4VURDG8XuD0ZaACTW1icmFho7YSSU8AEorUBGggESNT8ADSKUV2EHsjKUQK7UixEogAYQoD8DPnDA3Odmc5e7l6/bMnP/uzHyzrVafwhDe4ht+4RNm+uV0YR2cKGujX9g4LjPAd2zhX3Y2fRfYNVbQjtgo/kZs5y6wxULOdsQPmgBH8BBP8bwQb+NnAL/eBnqAF9jEByxjuJC3mvXwVR3scViiqj+YyPIWog1JvzHYq2diiqfZ81bkzWewy2SpXrCUvIaB6NMcPmMSLzPYBcaawNKlJ/gSsAS9h/UKrFO3ATlsPs4/ZqWe4arSz07dbh5nsIUsNoHzwnAO8Khuom+yxJWaFy7hPd5hFveLsCTsB+xHd51yJTNjKsw90uolN5+ftF2ILVasMd4EuBsX0oKPxlk7NqA/WOvm8nTFxOmXlMrvqjksg24UJpl0VLRGQ+izKP8Qe3hd3M0e+g8WFOlYWPt2OgAAAABJRU5ErkJggg=="
	set "backhome=iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAqUlEQVR4nO3RsQpBYRiAYcViVCaDC1CyWtyC7UwmmztwC+7AaDe5BpPR4gIsFmWUoh6dIieccziEwVvf9NXT3/fnct8IxXDehZUwxQzlV7EK5i4tUM2K1bB02wqNZ7Em1uLboPUo1sZWejsEaVgXe493QC8O68veIArlMfR6IxSuXznOAI2TbvgRcBLe6DSTd4BBZB/8wbDEG3YiH3CeemRfv7PvxII/2RES1+KqjbfDYgAAAABJRU5ErkJggg=="
) else (
	set bodybackground=#EBEBEB&set buttonbackground=#CFCFCF&set fontcolor=Black&set linkcolor=Blue&set backcolor=Green
	set "hyperlink=iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAABZElEQVR4nJ3UPWsVURDG8d9F0VaiYG0dENY0dsFOK+MHMNpqbhVyUxhQ8RP4AbTSytgp6YKlipVaBbHyBXwL13yAKANz4bDsbvbuA1vsmTn/3TPzzGF+LeAB3uEzdnDNQFX4jn8Nz8N5YUvYLwDv8Qx/i7WVIbBDTDDK2DlMM/ZiCGzckLOd8b0+wLM4g8tYbYiP8DGBr7tAJ3EDj/EUGzjdkLdZ1PBuG+x8WqLeyd+4WOStZRki9gWn+nQzuvijeI/Ohm4XsP20VCcsku/gWNbpJnaxjFsF7A8u9IHFpkt4lbCAHsdWDVY1waoaLI4Tel4c9ScOavWs2mbzWwGLQs8UDfjV0Jzw22JzP7lfJE5aPriOJ3iE6zihQ28T9qEYp1Jh5itp7jD5kdpLYIxPXeOaNaJxR+plbpjmoMs/3RwCk1dOaeIwbhx/tjYXbKa4HJsuza9t1uijq3n8T3iDe22z2aX/nImHnsZYk44AAAAASUVORK5CYII="
	set "backhome=iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAt0lEQVR4nO3RL4pCURQH4A/GYhRMBhcgiHWKW5hmMtncgVtwB0a7adYwyWhxARaLYBRBQXlwL1weM88/b1AED/zgwOF+XM7hSVUN+Zeq4Qdz1MtiDSxwClmieS/WwirBYtbo3Ip9YvMLFrNF91rsC7sCLGaP3iVsgMMVWMwRw7+w0Q1QPuMU+sCkBHYKmaKS/+XsDmhWtMOHgN9hR+PQlwZ7yTzr36DCHfaTA8S0k3nW5+fZmxeqM2w8ntIjwx+nAAAAAElFTkSuQmCC"
)
>Launcher.hta (
	echo ^<!DOCTYPE HTML PUBLIC^>
	echo ^<html^>^<head^>^<meta charset="utf-8"/^>^<title^>WeModPatcher Launcher^</title^>^<HTA:APPLICATION APPLICATIONNAME = "WeModPatcher Launcher" BORDER = "THIN" BORDERSTYLE = "NORMAL" CAPTION = "NO" CONTEXTMENU = "NO" ICON = "%HTAICON%" INNERBORDER = "NO" MAXIMIZEBUTTON = "NO" MINIMIZEBUTTON = "NO" NAVIGABLE = "NO" SCROLL = "NO" SCROLLFLAT = "NO" SELECTION = "NO" SHOWINTASKBAR = "YES" SINGLEINSTANCE = "NO" SYSMENU = "NO" WINDOWSTATE = "NORMAL"/^>^</head^>
	echo ^<script Language="VBScript"^>
	echo Sub Window_onLoad : Width = Document.Body.OffsetHeight*1.700680272108844 : Height = Document.Body.OffsetHeight*1.428571428571429 : window.resizeTo Width,Height : With Window.Screen : posX = (.AvailWidth  - Width ^) / 2 : posY = (.AvailHeight - Height ^) / 2 : End With : Window.MoveTo posX, posY : Button_Options : TimerExit = setTimeout("window.close()", 300000^) : End Sub
	echo Sub Button_Options : Set fso = CreateObject("Scripting.FileSystemObject"^) : If fso.FileExists("Options.hta"^) Then : document.getElementById("OPTIONS"^).innerHTML = "<div class='buttonOPT right' onclick='OPTIONS()'>%LANG60%</div>" : End If : End Sub
	echo Sub CONTINUE : Set fso = CreateObject("Scripting.FileSystemObject"^) : fso.GetStandardStream(1^).WriteLine("CONTINUE"^) : window.close(^) : End Sub
	echo Sub CANCEL : Set fso = CreateObject("Scripting.FileSystemObject"^) : fso.GetStandardStream(1^).WriteLine("ABORT"^) : window.close(^) : End Sub
	echo Sub OPTIONS : Set objShell = CreateObject("Wscript.Shell"^) : objShell.Run ("Options.hta"^), 1, True : window.close(^) : End Sub
	echo Sub LINKS : document.getElementById("home"^).style.display = "none" : document.getElementById("links"^).style.display = "inline" : End Sub
	echo Sub HOME : document.getElementById("links"^).style.display = "none" : document.getElementById("home"^).style.display = "inline" : End Sub
	echo Sub openURL(url^) : Set objShell = CreateObject("Wscript.Shell"^) : objShell.Run(url^) : End Sub
	echo ^</script^>
	echo ^<style^>
	echo body {font-family: Verdana, Geneva, Tahoma, sans-serif; padding: 0; margin: 0; background: %bodybackground%; padding-top: 15px;}
	echo .buttonCON, .buttonCAN, .buttonOPT {padding: 10px; background: %buttonbackground%; color: %fontcolor%; cursor: pointer; margin: 10px; text-align: center;}
	echo .buttonCON:hover {background: green;}
	echo .buttonCAN:hover {background: red;}
	echo .buttonOPT:hover {background: rgb(0, 120, 225^);}
	echo .right {position: absolute; bottom: 0; right: 0;}
	echo .left {position: absolute; bottom: 0; left: 0;}
	echo padding-bottom: 10px; padding-left: 10px; cursor: pointer;}
	echo .next {padding-bottom: 10px; padding-left: 10px; cursor: pointer;}
	echo .back {padding-bottom: 10px; padding-right: 10px; cursor: pointer;}
	echo b, font {color: %fontcolor%;}
	echo .star {color: #ff7300;}
	echo a {font-size: 12px; color: %linkcolor%; padding: 12px; cursor: pointer;}
	echo .arrow {font-size: 12px; padding-left: 16px;}
	echo font {font-size: 10px; line-height: 0.9;}
	echo .otherline {padding: 28px;}
	echo #links {display:none}
	echo ^</style^>
	echo ^<body^>
	echo ^<span id="home"^>
	echo 	^<div class="buttonCON" onclick="CONTINUE"^>%LANG58%^<br^>WeModPatcher^</div^>
	echo 	^<div class="buttonCAN" onclick="CANCEL"^>%LANG59%^<br^>WeModPatcher^</div^>
	echo 	^<span id="OPTIONS"^>^</span^>
	echo 	^<img class="next left" onclick="LINKS" src="data:image/png;base64,%hyperlink%"/^>
	echo ^</span^>
	echo ^<span id="links"^>
	echo 	^<center^>^<b^>WeModPatcher Links:^</b^>^</center^>^<br^>
	echo ^<div style="padding: 7px;"^>^</div^>
	echo 	^<a onclick="openURL('https://cs.rin.ru/forum/viewtopic.php?f=29&t=114927')"^>^<span class="star"^>^&#9733;^</span^> ^<u^>CS.RIN.RU^</u^>^</a^>^<br^>
	echo 		^<font^>^<span class="arrow"^>^&#10551; ^</span^>Steam Underground Community^</font^>^<br^>^<br^>
	echo 	^<a onclick="openURL('https://github.com/brunolee-GIT/W3M0dP4tch32')"^>^<span class="star"^>^&#9733;^</span^> ^<u^>GitHub^</u^>^</a^>^<br^>
	echo 		^<font^>^<span class="arrow"^>^&#10551; ^</span^>Developer platform to build and^</font^>^<br^>
	echo 		^<font class="otherline"^>deliver secure software.^</font^>^<br^>^<br^>
	echo 	^<img class="back right" onclick="HOME" src="data:image/png;base64,%backhome%"/^>
	echo ^</span^>
	echo ^</body^>
	echo ^</html^>
)
goto :EOF


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::ARGUMENTS
: CMD_ARGUMENTS
if [%1] == [-csht] (goto CREATE_SHORTCUT)
if [%1] == [-dwmi] (goto DOWNLOAD_WEMOD_INSTALLER)
if [%1] == [-dwmp] (goto DOWNLOAD_WEMOD_PORTABLE)
goto CMD_END

: CREATE_SHORTCUT
::USAGE ON CMD: WeModPatcher -csht
echo.
echo  [93m[ ] Creating  a "%~nx0" shortcut...[0m
if [%~x0] == [.bat] (
	if not exist "%TITLE%.ico" (if not exist "%TOOLS%" echo.&echo  [31m[?] %TOOLS% not found[0m&goto CMD_END)
	tar -xf "%TOOLS%" "%TITLE%.ico">NUL
	set ICON='%HOME%%TITLE%.ico'
)
if [%~x0] == [.exe] set ICON='%HOME%%TITLE%.exe'
for /f "tokens=*" %%a in ('powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.SaveFileDialog;$f.InitialDirectory='%UserProfile%\Desktop';$f.FileName='WeModPatcher';$f.Filter='WeModPatcher (*.lnk)|*.lnk';$f.showHelp=$false;$f.ShowDialog()|Out-Null;$f.FileName"') do set "SHORTCUT_SAVEPATH=%%a"
if "%SHORTCUT_SAVEPATH%" == "WeModPatcher" (echo  [94m[?] Canceled...[0m & goto CMD_END)
set TARGET='%HOME%%~nx0'
set SHORTCUT='%SHORTCUT_SAVEPATH%'
set DESCRIPTION='%TITLE% v%VERSION%'
powershell -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut(%SHORTCUT%); $s.TargetPath = %TARGET%; $s.Description = %DESCRIPTION%; $s.IconLocation = %ICON%; $s.Save()"
if exist "%SHORTCUT_SAVEPATH%" (echo  [92m[X] Done![0m) else (echo  [31m[?] something went wrong...[0m)
goto CMD_END

: DOWNLOAD_WEMOD_INSTALLER
::USAGE ON CMD: WeModPatcher -dwmi
echo.
for /f "tokens=2 delims= " %%a in ('curl -s "https://api.wemod.com/client/channels/stable/releases"') do for /f "tokens=1-9 delims=-" %%1 in ("%%a") do set WEMODVER=%%3
echo  [93m[ ] Downloading WeMod %WEMODVER% Installer...[0m
for /f "tokens=*" %%a in ('powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.SaveFileDialog;$f.InitialDirectory='%CD%';$f.FileName='WeMod %WEMODVER% Installer.exe';$f.Filter='WeMod Installer (*.exe)|*.exe';$f.showHelp=$false;$f.ShowDialog()|Out-Null;$f.FileName"') do set "WMI_SAVEPATH=%%a"
if "%WMI_SAVEPATH%" == "WeMod %WEMODVER% Installer.exe" echo  [94m[?] Canceled...[0m & goto CMD_END
curl --progress-bar "https://storage-cdn.wemod.com/app/releases/stable/WeMod-%WEMODVER%.exe" -o "%WMI_SAVEPATH%"
if exist "%WMI_SAVEPATH%" (echo  [92m[X] Done![0m) else (echo  [31m[?] something went wrong...[0m)
goto CMD_END

: DOWNLOAD_WEMOD_PORTABLE
::USAGE ON CMD: WeModPatcher -dwmp
echo.
for /f "tokens=*" %%a in ('powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.SaveFileDialog;$f.InitialDirectory='%CD%';$f.FileName='WeMod Portable';$f.Filter='WeMod Portable|*.*';$f.showHelp=$false;$f.ShowDialog()|Out-Null;$f.FileName"') do set "WMP_SAVEPATH=%%a"
echo  [93m[ ] Downloading WeMod Portable...[0m
if "%WMP_SAVEPATH%" == "WeMod Portable" echo  [94m[?] Canceled...[0m & goto CMD_END
curl -s -L https://github.com/brunolee-GIT/W3M0dP4tch32/releases/download/Portable/Portable.zip -o "%TEMP%\Portable.zip"
if exist "%TEMP%\Portable.zip" (
	tar -C "%TEMP%" -xf "%TEMP%\Portable.zip" "Portable"
	robocopy "%TEMP%\Portable" "%WMP_SAVEPATH%" /E>NUL
	del "%TEMP%\Portable.zip">NUL
	rmdir /s /q "%TEMP%\Portable">NUL
) else ( echo  [31m[?] something went wrong...[0m & goto CMD_END)
if exist "%WMP_SAVEPATH%" ("%WMP_SAVEPATH%\WeMod Updater.exe"&echo  [92m[X] Done![0m) else (echo  [31m[?] something went wrong...[0m)
goto CMD_END

: CMD_END
echo.