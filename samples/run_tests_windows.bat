@ECHO OFF
SETLOCAL EnableDelayedExpansion

FOR /F "tokens=*" %%O IN ('vswhere.exe -nologo -version [15.0^,16.0] -property installationPath') DO SET "vs_15_path=%%O"
FOR /F "tokens=*" %%O IN ('vswhere.exe -nologo -version [16.0^,17.0] -property installationPath') DO SET "vs_16_path=%%O"

IF "!vs_15_path!" NEQ "" (
	echo Found VS2017 at !vs_15_path!
	SET msbuild_15_path=!vs_15_path!\MSBuild\15.0\Bin\amd64\MSBuild.exe"
) ELSE (
	echo VS2017 not found
)

IF "!vs_16_path!" NEQ "" (
	echo Found VS2019 at !vs_16_path!
	SET "msbuild_16_path=!vs_16_path!\MSBuild\16.0\Bin\amd64\MSBuild.exe"
) ELSE (
	echo VS2019 not found
)

SET failed=
for /F "delims=" %%D in ('dir /a:d /b') do (
	echo Run Test: %%D
	cd %%D
	
	IF "!msbuild_15_path!" NEQ "" (
		CALL :RunTests %%D vs2017 "!msbuild_15_path!
	)

	cd ..
)

IF "%failed%" EQU "" GOTO NoFailed

:FailedLoop

for /F " delims=; tokens=1,*" %%A in ("%failed%") do (
	echo Error: %%A
	set "FAILED=%%B"
)

IF "%failed%" NEQ "" GOTO FailedLoop

echo Failed
GOTO End

:NoFailed
echo Success

:End

EXIT /B %ERRORLEVEL%

:RunTests

ECHO Generate %~2
CALL generate_%~2.bat
IF ERRORLEVEL 1 (
	ECHO Generate failed
	SET "failed=%failed%Generate of %~1 failed;"
	EXIT /B %ERRORLEVEL%
)

cd build\%~2

FOR %%C in (Debug Release) do (
	FOR %%P in (x86 x64) do (
		ECHO Build %%C for %%P
		
		SET "platform=%%P"
		IF "!platform!" EQU "x86" (
			SET platform=Win32
		)
		
		"%~3" %~1.sln /m /p:Configuration=%%C /p:Platform=!platform!
		
		IF ERRORLEVEL 1 (
			ECHO Build failed
			SET "failed=%failed%%~2 build of %~1 in %%C for %%P failed;"
		)
		
		cd %%P\%%C

		"%~1_test.exe"
		IF ERRORLEVEL 1 (
			ECHO Execute failed
			SET "failed=%failed%%~2 build of %~1 in %%C for %%P return an error on execution;"
		)

		cd ..\..
	)
)

cd ../..

EXIT /B 0