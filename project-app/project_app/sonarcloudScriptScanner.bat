@echo off

:: Paso 1: Ejecutar los tests de Flutter con cobertura
call flutter test --coverage

:: Comprobar si el comando anterior tuvo éxito
if %ERRORLEVEL% neq 0 (
    echo "Error: Los tests no se ejecutaron correctamente."
    exit /b %ERRORLEVEL%
)

:: Paso 2: Ejecutar SonarScanner y pasar el archivo de cobertura
call sonar-scanner.bat ^
-D"sonar.projectKey=fps1001_TFGII_FPisot" ^
-D"sonar.organization=fps" ^
-D"sonar.sources=." ^
-D"sonar.host.url=https://sonarcloud.io" ^
-D"sonar.tests=./test" ^
-D"sonar.dart.coverage.reportPaths=./coverage/lcov.info"

:: Comprobar si el análisis con SonarCloud tuvo éxito
if %ERRORLEVEL% neq 0 (
    echo "Error: El análisis de SonarCloud falló."
    exit /b %ERRORLEVEL%
)

echo "Proceso completado con éxito."
