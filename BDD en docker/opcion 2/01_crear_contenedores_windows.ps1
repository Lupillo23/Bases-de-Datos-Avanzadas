# =====================================================
# SCRIPT PowerShell: Crear dos instancias Oracle en Docker
# Base de Datos Avanzadas 2027-1 - WINDOWS
# =====================================================

# Ejecutar como Administrador

Write-Host "===============================================" -ForegroundColor Green
Write-Host "Creando Base de Datos en Docker (Windows)" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# 1. Crear red personalizada para conectar los contenedores
Write-Host ""
Write-Host "1. Creando red Docker..." -ForegroundColor Yellow
docker network create oracle-network 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Red creada exitosamente" -ForegroundColor Green
} else {
    Write-Host "   ℹ La red ya existe o hubo un error" -ForegroundColor Cyan
}

# 2. Crear volumen para Oracle Linux
Write-Host ""
Write-Host "2. Creando volumen para Oracle 19c (Linux)..." -ForegroundColor Yellow
docker volume create oracle_linux_data
Write-Host "   ✓ Volumen creado" -ForegroundColor Green

# 3. Crear volumen para Oracle Windows
Write-Host ""
Write-Host "3. Creando volumen para Oracle 18c (Windows)..." -ForegroundColor Yellow
docker volume create oracle_windows_data
Write-Host "   ✓ Volumen creado" -ForegroundColor Green

# 4. Iniciar Oracle 19c en Linux
Write-Host ""
Write-Host "4. Iniciando Oracle 19c (Linux)..." -ForegroundColor Yellow
Write-Host "   - Nombre: oracle-linux-19c" -ForegroundColor Cyan
Write-Host "   - Puerto: 1521" -ForegroundColor Cyan
Write-Host "   - SID: LINUXDB" -ForegroundColor Cyan
Write-Host "   - Contraseña: Oracle123!" -ForegroundColor Cyan

docker run -d `
  --name oracle-linux-19c `
  --network oracle-network `
  -p 1521:1521 `
  -e ORACLE_SID=LINUXDB `
  -e ORACLE_PDB=LINUXPDB `
  -e ORACLE_PWD=Oracle123! `
  -v oracle_linux_data:/opt/oracle/oradata `
  gvenzl/oracle-xe:latest

Write-Host "   ✓ Contenedor iniciado" -ForegroundColor Green

# 5. Iniciar Oracle 18c en Windows (usando Docker)
Write-Host ""
Write-Host "5. Iniciando Oracle 18c (Windows)..." -ForegroundColor Yellow
Write-Host "   - Nombre: oracle-windows-18c" -ForegroundColor Cyan
Write-Host "   - Puerto: 1522" -ForegroundColor Cyan
Write-Host "   - SID: WINDOWSDB" -ForegroundColor Cyan
Write-Host "   - Contraseña: Oracle123!" -ForegroundColor Cyan

docker run -d `
  --name oracle-windows-18c `
  --network oracle-network `
  -p 1522:1521 `
  -e ORACLE_SID=WINDOWSDB `
  -e ORACLE_PDB=WINDOWSPDB `
  -e ORACLE_PWD=Oracle123! `
  -v oracle_windows_data:/opt/oracle/oradata `
  gvenzl/oracle-xe:latest

Write-Host "   ✓ Contenedor iniciado" -ForegroundColor Green

# 6. Mostrar estado
Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "Estado de los contenedores:" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
docker ps -a | Select-String oracle

Write-Host ""
Write-Host "===============================================" -ForegroundColor Yellow
Write-Host "Esperando a que las BD se inicialicen..." -ForegroundColor Yellow
Write-Host "Esto puede tomar 2-3 minutos..." -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Yellow

Start-Sleep -Seconds 30

Write-Host ""
Write-Host "Verificando logs de inicialización..." -ForegroundColor Cyan
Write-Host ""
Write-Host "--- Oracle Linux 19c ---" -ForegroundColor Cyan
docker logs --tail 20 oracle-linux-19c
Write-Host ""
Write-Host "--- Oracle Windows 18c ---" -ForegroundColor Cyan
docker logs --tail 20 oracle-windows-18c

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "✓ Setup completado" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "PRÓXIMOS PASOS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Espera 2-3 minutos adicionales a que inicialicen completamente" -ForegroundColor White
Write-Host ""
Write-Host "2. Para conectarse a Oracle Linux (19c):" -ForegroundColor White
Write-Host "   docker exec -it oracle-linux-19c sqlplus sys/Oracle123! as sysdba" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Para conectarse a Oracle Windows (18c):" -ForegroundColor White
Write-Host "   docker exec -it oracle-windows-18c sqlplus sys/Oracle123! as sysdba" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. O usar SQL Developer / DBeaver con:" -ForegroundColor White
Write-Host "   Linux:   localhost:1521/LINUXDB" -ForegroundColor Cyan
Write-Host "   Windows: localhost:1522/WINDOWSDB" -ForegroundColor Cyan
Write-Host ""
