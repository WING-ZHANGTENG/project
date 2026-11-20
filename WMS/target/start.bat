@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "APP_HOME=%~dp0"
set "JVM_OPTS=-Xms512m -Xmx1024m -Dfile.encoding=UTF-8"
set "LOG_DIR=%APP_HOME%logs"
set "SQL_DIR=%APP_HOME%sql\startup"
set "SQL_DONE_DIR=%SQL_DIR%\.done"
set "LOCAL_ENV_FILE=%APP_HOME%start.local.bat"
set "CONFIG_DIR=%APP_HOME%resources"
set "APP_CONFIG_FILE=%CONFIG_DIR%\application.yml"
set "ACTIVE_PROFILE="

if exist "%APP_CONFIG_FILE%" (
    for /f "tokens=2 delims=:" %%I in ('findstr /r /c:"^[ ]*active:" "%APP_CONFIG_FILE%" 2^>nul') do (
        if not defined ACTIVE_PROFILE set "ACTIVE_PROFILE=%%I"
    )
)
set "ACTIVE_PROFILE=%ACTIVE_PROFILE: =%"
if not defined ACTIVE_PROFILE set "ACTIVE_PROFILE=xj2"
set "DB_CONFIG_FILE=%CONFIG_DIR%\application-%ACTIVE_PROFILE%.yml"

if exist "%DB_CONFIG_FILE%" (
    echo Loading database config from "%DB_CONFIG_FILE%"...
    for /f "usebackq tokens=1,* delims==" %%A in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$dbPath='%DB_CONFIG_FILE%'; if (Test-Path $dbPath) { $lines=Get-Content $dbPath; $url=$null; $urlIndex=-1; for ($i=0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^\s*url\s*:\s*(jdbc:mysql://\S+)') { $url=$matches[1]; $urlIndex=$i; break } }; if ($url) { if ($url -match '^jdbc:mysql://([^:/?]+)(?::(\d+))?/([^?;]+)') { 'DB_HOST=' + $matches[1]; if ($matches[2]) { 'DB_PORT=' + $matches[2] } else { 'DB_PORT=3306' }; 'DB_NAME=' + $matches[3] }; for ($j=$urlIndex+1; $j -lt [Math]::Min($urlIndex+8,$lines.Count); $j++) { if ($lines[$j] -match '^\s*username\s*:\s*(.*)$') { 'DB_USER=' + $matches[1].Trim(); break } }; for ($j=$urlIndex+1; $j -lt [Math]::Min($urlIndex+8,$lines.Count); $j++) { if ($lines[$j] -match '^\s*password\s*:\s*(.*)$') { 'DB_PASS=' + $matches[1].Trim(); break } } } }"`) do (
        if /i "%%A"=="DB_HOST" set "DB_HOST=%%B"
        if /i "%%A"=="DB_PORT" set "DB_PORT=%%B"
        if /i "%%A"=="DB_NAME" set "DB_NAME=%%B"
        if /i "%%A"=="DB_USER" set "DB_USER=%%B"
        if /i "%%A"=="DB_PASS" set "DB_PASS=%%B"
    )
) else (
    echo WARN: Database config file not found: "%DB_CONFIG_FILE%"
)

if exist "%LOCAL_ENV_FILE%" call "%LOCAL_ENV_FILE%"

if not defined MYSQL_CMD (
    for /f "delims=" %%I in ('where mysql 2^>nul') do (
        if not defined MYSQL_CMD set "MYSQL_CMD=%%I"
    )
)

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo Starting application...
echo Info: Application logs are saved to "%LOG_DIR%" and retained for 3 days.
echo -------------------------------------------------------------------

if not defined DB_HOST (
    echo ERROR: DB_HOST not found. Please check "%DB_CONFIG_FILE%" or set DB_* in "%LOCAL_ENV_FILE%".
    pause
    exit /b 1
)
if not defined DB_PORT set "DB_PORT=3306"
if not defined DB_NAME (
    echo ERROR: DB_NAME not found. Please check "%DB_CONFIG_FILE%" or set DB_* in "%LOCAL_ENV_FILE%".
    pause
    exit /b 1
)
if not defined DB_USER (
    echo ERROR: DB_USER not found. Please check "%DB_CONFIG_FILE%" or set DB_* in "%LOCAL_ENV_FILE%".
    pause
    exit /b 1
)
if not defined DB_PASS set "DB_PASS="

"%MYSQL_CMD%" --version >nul 2>nul
if errorlevel 1 (
    echo ERROR: mysql client not found.
    echo Please add mysql.exe to PATH, or create "%LOCAL_ENV_FILE%" and set MYSQL_CMD there.
    echo You can copy start.local.example.bat to start.local.bat and adjust it once per server.
    pause
    exit /b 1
)

if not exist "%SQL_DIR%" mkdir "%SQL_DIR%"
if not exist "%SQL_DONE_DIR%" mkdir "%SQL_DONE_DIR%"

echo Checking database connection...
set "MYSQL_PWD=%DB_PASS%"
"%MYSQL_CMD%" --protocol=TCP --connect-timeout=10 --default-character-set=utf8mb4 --host="%DB_HOST%" --port="%DB_PORT%" --user="%DB_USER%" --database="%DB_NAME%" --execute="SELECT 1;" >nul
set "DB_CHECK_CODE=%ERRORLEVEL%"
set "MYSQL_PWD="
if not "%DB_CHECK_CODE%"=="0" (
    echo ERROR: Database connection check failed. No startup SQL was executed.
    echo Please verify DB_HOST, DB_PORT, DB_NAME, DB_USER and DB_PASS in "%LOCAL_ENV_FILE%" or "%DB_CONFIG_FILE%".
    pause
    exit /b %DB_CHECK_CODE%
)
echo Database connection check succeeded.

echo Running startup SQL scripts from "%SQL_DIR%"...
set "HAS_SQL=0"

for /f "delims=" %%F in ('dir /b /a-d "%SQL_DIR%\*.sql" 2^>nul') do (
    call :RUN_STARTUP_SQL "%%F"
    if errorlevel 1 goto :STARTUP_SQL_FAILED
)

if "%HAS_SQL%"=="0" (
    echo No startup SQL files found. Skip database patch step.
)

echo -------------------------------------------------------------------

java %JVM_OPTS% -DLOG_PATH="%LOG_DIR%" -Dloader.path=resources/ -cp wms-admin.jar org.springframework.boot.loader.PropertiesLauncher

echo.
echo -------------------------------------------------------------------
echo Application exited.

pause
exit /b 0

:RUN_STARTUP_SQL
set "HAS_SQL=1"
set "SCRIPT_NAME=%~1"
set "SCRIPT_FILE=%SQL_DIR%\%~1"
set "MARK_FILE=%SQL_DONE_DIR%\%~n1.done"

if exist "%MARK_FILE%" (
    echo Skip applied startup SQL: %SCRIPT_NAME%
    exit /b 0
)

echo Running startup SQL: %SCRIPT_NAME%
set "MYSQL_PWD=%DB_PASS%"
"%MYSQL_CMD%" --protocol=TCP --connect-timeout=10 --default-character-set=utf8mb4 --host="%DB_HOST%" --port="%DB_PORT%" --user="%DB_USER%" --database="%DB_NAME%" < "%SCRIPT_FILE%"
set "EXIT_CODE=%ERRORLEVEL%"
set "MYSQL_PWD="

if not "%EXIT_CODE%"=="0" (
    echo ERROR: Startup SQL execution failed for %SCRIPT_NAME%. Application not started.
    exit /b %EXIT_CODE%
)

> "%MARK_FILE%" echo Applied at %date% %time%
echo Startup SQL completed: %SCRIPT_NAME%
exit /b 0

:STARTUP_SQL_FAILED
set "STARTUP_EXIT_CODE=%ERRORLEVEL%"
pause
exit /b %STARTUP_EXIT_CODE%
