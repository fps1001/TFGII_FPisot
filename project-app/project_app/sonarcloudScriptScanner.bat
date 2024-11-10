@echo off

rem Paso 1: Ejecutar SonarScanner y pasarle el archivo de cobertura
call flutter test --coverage

rem Comprobar si el archivo de cobertura existe
if not exist "coverage\lcov.info" (
    echo "Error: El archivo de cobertura no se generó correctamente."
    exit /b 1
)

call sonar-scanner.bat ^
  -D"sonar.projectKey=fps1001_TFGII_FPisot" ^
  -D"sonar.organization=fps" ^
  -D"sonar.sources=lib" ^
  -D"sonar.tests=test" ^
  -D"sonar.host.url=https://sonarcloud.io" ^
  -D"sonar.test.inclusions=test/**/*.dart" ^
  -D"sonar.coverage.exclusions=lib/generated_plugin_registrant.dart" ^
  -D"sonar.dart.coverage.reportPaths=coverage/lcov.info"

rem Comprobar si el análisis con SonarCloud tuvo éxito
if %ERRORLEVEL% neq 0 (
    echo "Error: El análisis de SonarCloud falló."
    exit /b %ERRORLEVEL%
)

echo "Proceso completado con éxito."
