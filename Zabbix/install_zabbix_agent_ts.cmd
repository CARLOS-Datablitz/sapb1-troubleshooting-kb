@echo off
SETLOCAL ENABLEEXTENSIONS

:: ============================================================
::  CONFIGURACION - Modificar estos valores antes de ejecutar
:: ============================================================
SET ZABBIXHOSTNAME="dc.intersteel.privatcloud.biz"
SET ZabbixServer="192.168.191.250"
SET ZABBIX_MSI=zabbix_agent2-7.4.8-windows-amd64-openssl.msi
SET ZABBIX_URL=https://cdn.zabbix.com/zabbix/binaries/stable/7.4/7.4.8/%ZABBIX_MSI%
SET WORKDIR=C:\Windows\Temp
SET INSTALLFOLDER=C:\Program Files\Zabbix Agent 2
SET CONFFILE=%INSTALLFOLDER%\zabbix_agent2.conf

:: ============================================================
::  INICIO
:: ============================================================
echo.
echo [INFO] Iniciando instalacion de Zabbix Agent 2 - %DATE% %TIME%
echo [INFO] Servidor Zabbix : %ZabbixServer%
echo [INFO] Hostname        : %ZABBIXHOSTNAME%
echo.

:: ============================================================
::  PASO 1 - Descargar MSI
:: ============================================================
echo [PASO 1] Descargando instalador...
curl -s "%ZABBIX_URL%" -o "%WORKDIR%\%ZABBIX_MSI%"
IF NOT EXIST "%WORKDIR%\%ZABBIX_MSI%" (
    echo [ERROR] No se pudo descargar el instalador. Verifique conexion a internet o la URL.
    goto :ERROR
)
echo [OK] Descarga completada.

:: ============================================================
::  PASO 2 - Instalar Zabbix Agent 2
:: ============================================================
echo [PASO 2] Instalando Zabbix Agent 2...
msiexec /l*v "%WORKDIR%\zabbix_install.log" /i "%WORKDIR%\%ZABBIX_MSI%" /qn ^
    SERVER=%ZabbixServer% ^
    LISTENPORT=10050 ^
    SERVERACTIVE=%ZabbixServer% ^
    HOSTNAME=%ZABBIXHOSTNAME% ^
    ENABLEPATH=1

:: Verificar que el servicio fue instalado
sc query "Zabbix Agent 2" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] El servicio no fue instalado correctamente. Revise el log:
    echo         %WORKDIR%\zabbix_install.log
    goto :ERROR
)
echo [OK] Instalacion completada.

:: ============================================================
::  PASO 3 - Verificar archivo de configuracion
:: ============================================================
echo [PASO 3] Verificando archivo de configuracion...
IF NOT EXIST "%CONFFILE%" (
    echo [ERROR] No se encontro el archivo de configuracion: %CONFFILE%
    goto :ERROR
)
echo [OK] Archivo de configuracion encontrado.

:: ============================================================
::  PASO 4 - Agregar parametros al conf
:: ============================================================
echo [PASO 4] Configurando zabbix_agent2.conf...

:: Evitar duplicados antes de agregar
findstr /C:"AllowKey=system.run" "%CONFFILE%" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo AllowKey=system.run[*] >> "%CONFFILE%"
)

findstr /C:"Timeout=30" "%CONFFILE%" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Timeout=30 >> "%CONFFILE%"
)
echo [OK] Configuracion actualizada.

:: ============================================================
::  PASO 5 - Configurar reinicio automatico del servicio
:: ============================================================
echo [PASO 5] Configurando reinicio automatico del servicio...
SC failure "Zabbix Agent 2" reset= 0 actions= restart/0/restart/0/restart/0
IF %ERRORLEVEL% NEQ 0 (
    echo [WARN] No se pudo configurar reinicio automatico del servicio.
)
echo [OK] Reinicio automatico configurado.

:: ============================================================
::  PASO 6 - Iniciar servicio
:: ============================================================
echo [PASO 6] Iniciando servicio Zabbix Agent 2...
net stop "Zabbix Agent 2" >nul 2>&1
net start "Zabbix Agent 2"
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] El servicio no pudo iniciarse.
    goto :ERROR
)

:: Verificar estado final
sc query "Zabbix Agent 2" | findstr /I "RUNNING" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] El servicio no esta en estado RUNNING.
    goto :ERROR
)

:: ============================================================
::  LIMPIEZA
:: ============================================================
del "%WORKDIR%\%ZABBIX_MSI%" >nul 2>&1
del "%WORKDIR%\zabbix_install.log" >nul 2>&1

:: ============================================================
::  EXITO
:: ============================================================
echo.
echo ============================================================
echo  INSTALACION COMPLETADA EXITOSAMENTE
echo  Hostname : %ZABBIXHOSTNAME%
echo  Servidor : %ZabbixServer%
echo  Servicio : Zabbix Agent 2 - RUNNING
echo ============================================================
echo.
ENDLOCAL
exit /b 0

:ERROR
echo.
echo ============================================================
echo  INSTALACION FALLIDA - Revise los mensajes anteriores
echo  Log MSI : %WORKDIR%\zabbix_install.log
echo ============================================================
echo.
ENDLOCAL
exit /b 1
