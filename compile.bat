@echo off
setlocal
if not exist "build\web\WEB-INF\classes" mkdir "build\web\WEB-INF\classes"
dir /s /b "src\java\*.java" > sources.txt
javac -encoding UTF-8 -cp "C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\servlet-api.jar;web\WEB-INF\lib\sqljdbc4.jar;build\web\WEB-INF\classes" -d "build\web\WEB-INF\classes" @sources.txt
if %errorlevel% equ 0 (
    echo [OK] COMPILE SUCCESSFUL!
) else (
    echo [ERROR] COMPILE FAILED!
)
del sources.txt
