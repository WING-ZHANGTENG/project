@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem ============================================================
rem WMS startup script
rem Supports passwords containing special chars such as ! @ # $ ^
rem ============================================================

set "APP_HOME=%~dp0"
set "JVM_OPTS=-Xms512m -Xmx1024m -Dfile.encoding=UTF-8"
set "LOG_DIR=%APP_HOME%logs"
set "SQL_DIR=%APP_HOME%sql\startup"
set "SQL_DONE_DIR=%SQL_DIR%\.done"
set "LOCAL_ENV_FILE=%APP_HOME%start.local.bat"
set "CONFIG_DIR=%APP_HOME%resources"
set "APP_CONFIG_FILE=%CONFIG_DIR%\application.yml"
set "ACTIVE_PROFILE="


rem ============================================================
rem 1. Read active Spring profile
rem ============================================================

if exist "%APP_CONFIG_FILE%" (
    for /f "tokens=2 delims=:" %%I in ('findstr /r /c:"^[ ]*active:" "%APP_CONFIG_FILE%" 2^>nul') do (
        if not defined ACTIVE_PROFILE set "ACTIVE_PROFILE=%%I"
    )
)

set "ACTIVE_PROFILE=%ACTIVE_PROFILE: =%"

if not defined ACTIVE_PROFILE (
    set "ACTIVE_PROFILE=xj2"
)

set "DB_CONFIG_FILE=%CONFIG_DIR%\application-%ACTIVE_PROFILE%.yml"


rem ============================================================
rem 2. Read database config from application-{profile}.yml
rem ============================================================

if exist "%DB_CONFIG_FILE%" (

    echo Loading database config from "%DB_CONFIG_FILE%"...

    for /f "usebackq tokens=1,* delims==" %%A in (`
        powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$dbPath='%DB_CONFIG_FILE%'; ^
        if (Test-Path $dbPath) { ^
            $lines=Get-Content $dbPath; ^
            $url=$null; ^
            $urlIndex=-1; ^
            for ($i=0; $i -lt $lines.Count; $i++) { ^
                if ($lines[$i] -match '^\s*url\s*:\s*(jdbc:mysql://\S+)') { ^
                    $url=$matches[1]; ^
                    $urlIndex=$i; ^
                    break ^
                } ^
            }; ^
            if ($url) { ^
                if ($url -match '^jdbc:mysql://([^:/?]+)(?::(\d+))?/([^?;]+)') { ^
                    'DB_HOST=' + $matches[1]; ^
                    if ($matches[2]) { ^
                        'DB_PORT=' + $matches[2] ^
                    } else { ^
                        'DB_PORT=3306' ^
                    }; ^
                    'DB_NAME=' + $matches[3] ^
                }; ^
                for ($j=$urlIndex+1; $j -lt [Math]::Min($urlIndex+8,$lines.Count); $j++) { ^
                    if ($lines[$j] -match '^\s*username\s*:\s*(.*)$') { ^
                        'DB_USER=' + $matches[1].Trim(); ^
                        break ^
                    } ^
                }; ^
                for ($j=$urlIndex+1; $j -lt [Math]::Min($urlIndex+8,$lines.Count); $j++) { ^
                    if ($lines[$j] -match '^\s*password\s*:\s*(.*)$') { ^
                        'DB_PASS=' + $matches[1].Trim(); ^
                        break ^
                    } ^
                } ^
            } ^
        }"
    `) do (

        if /i "%%A"=="DB_HOST" set "DB_HOST=%%B"
        if /i "%%A"=="DB_PORT" set "DB_PORT=%%B"
        if /i "%%A"=="DB_NAME" set "DB_NAME=%%B"
        if /i "%%A"=="DB_USER" set "DB_USER=%%B"
        if /i "%%A"=="DB_PASS" set "DB_PASS=%%B"
    )

) else (

    echo WARN: Database config file not found: "%DB_CONFIG_FILE%"
)


rem ============================================================
rem 3. Load server-specific overrides
rem
rem IMPORTANT:
rem DelayedExpansion is disabled, so ! in DB_PASS is preserved.
rem ============================================================

if exist "%LOCAL_ENV_FILE%" (
    call "%LOCAL_ENV_FILE%"
)


rem ============================================================
rem 4. Locate mysql.exe
rem ============================================================

if not defined MYSQL_CMD (

    for /f "delims=" %%I in ('where mysql 2^>nul') do (
        if not defined MYSQL_CMD set "MYSQL_CMD=%%I"
    )
)


rem ============================================================
rem 5. Create log directory
rem ============================================================

if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
)


echo Starting application...
echo Info: Logging to console and saving to "%LOG_DIR%" (tomLog keeps 3 days).
echo -------------------------------------------------------------------


rem ============================================================
rem 6. Validate database configuration
rem ============================================================

if not defined DB_HOST (
    echo ERROR: DB_HOST not found.
    echo Please check "%DB_CONFIG_FILE%"
    echo or set DB_* in "%LOCAL_ENV_FILE%".
    pause
    exit /b 1
)

if not defined DB_PORT (
    set "DB_PORT=3306"
)

if not defined DB_NAME (
    echo ERROR: DB_NAME not found.
    echo Please check "%DB_CONFIG_FILE%"
    echo or set DB_* in "%LOCAL_ENV_FILE%".
    pause
    exit /b 1
)

if not defined DB_USER (
    echo ERROR: DB_USER not found.
    echo Please check "%DB_CONFIG_FILE%"
    echo or set DB_* in "%LOCAL_ENV_FILE%".
    pause
    exit /b 1
)

if not defined DB_PASS (
    set "DB_PASS="
)


rem ============================================================
rem 7. Check mysql client
rem ============================================================

"%MYSQL_CMD%" --version >nul 2>nul

if errorlevel 1 (

    echo ERROR: mysql client not found.
    echo.
    echo Please add mysql.exe to PATH,
    echo or configure MYSQL_CMD in:
    echo "%LOCAL_ENV_FILE%"
    echo.
    echo Example:
    echo set "MYSQL_CMD=C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe"

    pause
    exit /b 1
)


rem ============================================================
rem 8. Prepare startup SQL folders
rem ============================================================

if not exist "%SQL_DIR%" (
    mkdir "%SQL_DIR%"
)

if not exist "%SQL_DONE_DIR%" (
    mkdir "%SQL_DONE_DIR%"
)


echo Running startup SQL scripts from "%SQL_DIR%"...

set "HAS_SQL=0"


rem ============================================================
rem 9. Execute startup SQL
rem
rem Do NOT enable DelayedExpansion here.
rem Each SQL file is handled by :RUN_SQL.
rem This avoids ! in DB_PASS being interpreted by CMD.
rem ============================================================

for /f "delims=" %%F in ('dir /b /a-d "%SQL_DIR%\*.sql" 2^>nul') do (
    call :RUN_SQL "%%F"

    if errorlevel 1 (
        pause
        exit /b 1
    )
)


if "%HAS_SQL%"=="0" (
    echo No startup SQL files found. Skip database patch step.
)


echo -------------------------------------------------------------------


rem ============================================================
rem 10. Start Spring Boot application
rem ============================================================

cd /d "%APP_HOME%"

java %JVM_OPTS% ^
    -Dloader.path=resources/ ^
    -cp wms-admin.jar ^
    org.springframework.boot.loader.PropertiesLauncher


echo.
echo -------------------------------------------------------------------
echo Application exited.

pause
exit /b 0



rem ============================================================
rem SQL execution subroutine
rem ============================================================

:RUN_SQL

set "HAS_SQL=1"

set "SQL_FILE_NAME=%~1"
set "SCRIPT_FILE=%SQL_DIR%\%SQL_FILE_NAME%"
set "MARK_FILE=%SQL_DONE_DIR%\%~n1.done"


if exist "%MARK_FILE%" (

    echo Skip applied startup SQL: %SQL_FILE_NAME%
    exit /b 0
)


echo Running startup SQL: %SQL_FILE_NAME%


rem ------------------------------------------------------------
rem MYSQL_PWD avoids putting the password directly in command line.
rem Delayed expansion is disabled, therefore passwords containing
rem ! and @ are preserved correctly.
rem ------------------------------------------------------------

set "MYSQL_PWD=%DB_PASS%"


"%MYSQL_CMD%" ^
    --default-character-set=utf8mb4 ^
    -h"%DB_HOST%" ^
    -P"%DB_PORT%" ^
    -u"%DB_USER%" ^
    "%DB_NAME%" < "%SCRIPT_FILE%"


set "SQL_EXIT_CODE=%ERRORLEVEL%"


rem Clear password immediately after mysql execution
set "MYSQL_PWD="


if not "%SQL_EXIT_CODE%"=="0" (

    echo.
    echo ERROR: Startup SQL execution failed for %SQL_FILE_NAME%.
    echo Application not started.
    echo MySQL exit code: %SQL_EXIT_CODE%
    echo.

    exit /b %SQL_EXIT_CODE%
)


> "%MARK_FILE%" echo Applied at %date% %time%

echo Startup SQL completed: %SQL_FILE_NAME%
echo.

exit /b 0