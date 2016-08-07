@echo off

SET OLDDIR=%cd%
SET BRANCH = ""

CLS

ECHO.
ECHO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ECHO.
ECHO               IIS WEBSITE CONFIGURATION
ECHO.
ECHO   Please specify the branch you wish to setup on IIS:
ECHO.
ECHO      1) EXIT
ECHO      ------------------------------------------------------------
ECHO      2) Main
ECHO      3) Dev-Team
ECHO      ------------------------------------------------------------
ECHO      4) Cleanup (remove all websites from IIS)
ECHO.
ECHO   Warning: You will recieve errors if you have not previously setup the websites on IIS.
ECHO   Don't worry about the errors, everything will setup as it should.
ECHO.
ECHO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ECHO.

CHOICE /N /C 123456789 /M "Enter Branch Number:"

REM Exit Script
IF %ERRORLEVEL% EQU 1 (
	ECHO.
	ECHO Exiting...
	ECHO.
	GOTO END
)

REM Setup websites for MAIN code branch
IF %ERRORLEVEL% EQU 2 (
	ECHO.
	ECHO Main
	ECHO.
	SET BRANCH=Main
	GOTO SETUP
)

REM Setup websites for Dev-Team code branch
IF %ERRORLEVEL% EQU 3 (
	ECHO.
	ECHO Dev-Team
	ECHO.
	SET BRANCH=Dev-Team
	GOTO SETUP
)

REM Remove ALL websites from IIS
IF %ERRORLEVEL% EQU 9 (
	ECHO.
	ECHO CLEANUP
	ECHO.
	GOTO CLEANUP
)

:SETUP
cd %windir%\system32\inetsrv
appcmd delete site "asp.example.local"
appcmd delete site "mvc.example.local"

REM Websites

ECHO "Adding ASP Website"
appcmd add site /name:"asp.example.local" /bindings:"http/*:80:asp.example.local" /physicalPath:"C:\TFS\%BRANCH%\AspWebApplication"

ECHO "Adding MVC Website"
appcmd add site /name:"mvc.example.local" /bindings:"http/*:80:mvc.example.local" /physicalPath:"C:\TFS\%BRANCH%\MvcWebApplication"

ECHO.

REM Global Themes Directory
ECHO "Adding Global Themes to ASP Website"
appcmd add vdir /app.name:"asp.example.local/" /path:"/aspnet_client" /physicalPath:"C:\inetpub\wwwroot\aspnet_client"
ECHO.

REM Nested Web Applications
ECHO "Adding Nested Web Application to ASP Website"
appcmd add app /site.name:"asp.example.local" /path:"/asp.example.local/NestedWebApp" /physicalPath:"C:\TFS\%BRANCH%\NestedAspWebApplication"
ECHO.

REM Virtual Directory
ECHO "Adding Virtual Directory to MVC Website"
appcmd add vdir /app.name:"mvc.example.local/" /path:/Web.UI /physicalPath:"C:\TFS\%BRANCH%\MvcVirtualDirectory"
ECHO.

REM Set Application Pools
ECHO "Setting Application Pools"
appcmd set app "asp.example.local/" /applicationPool:"ASP.NET v2.0"
appcmd set app "mvc.example.local/" /applicationPool:"ASP.NET v4.0"
ECHO.

ECHO.
ECHO setup completed!
ECHO.
cd %OLDDIR%
GOTO END

:CLEANUP
cd %windir%\system32\inetsrv
appcmd delete site "asp.example.local"
appcmd delete site "mvc.example.local"
ECHO.
ECHO cleanup completed!
ECHO.
cd %OLDDIR%
GOTO END

:END
ECHO Bye Mun!
ECHO.
PAUSE
