@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo COMPILING PRJ301 VENDING MACHINE APPLICATION (VendDB)
echo ========================================================

if not exist "build\web\WEB-INF\classes" (
    mkdir "build\web\WEB-INF\classes"
)

rem Lay danh sach tat ca cac file .java
dir /s /b "src\java\*.java" > "sources.txt"

javac -encoding UTF-8 -cp "web\WEB-INF\lib\sqljdbc4.jar;C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\servlet-api.jar;C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\jsp-api.jar" -d "build\web\WEB-INF\classes" @sources.txt

if %ERRORLEVEL% EQU 0 (
    echo [OK] COMPILE SUCCESSFUL!
    del /q "sources.txt" 2>nul
) else (
    echo [ERROR] COMPILATION FAILED!
    del /q "sources.txt" 2>nul
    exit /b 1
)
