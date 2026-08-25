@echo off
rem Copy this file to start.local.bat and adjust the values for each server.
rem start.bat will load start.local.bat automatically if it exists.
rem Database connection is loaded from resources/application-{active}.yml by default.

rem Set MYSQL_CMD only when mysql.exe is not available in PATH.
rem set "MYSQL_CMD=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

rem Optional overrides, normally not needed:
rem set "DB_HOST=localhost"
rem set "DB_PORT=3306"
rem set "DB_NAME=deer_wms_xj"
rem set "DB_USER=root"
rem set "DB_PASS=root"
