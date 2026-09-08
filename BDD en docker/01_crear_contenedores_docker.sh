#!/bin/bash

# =====================================================
# SCRIPT: Crear dos instancias Oracle en Docker
# Base de Datos Avanzadas 2027-1
# =====================================================

echo "==============================================="
echo "Creando Base de Datos en Docker"
echo "==============================================="

# 1. Crear red personalizada para conectar los contenedores
echo ""
echo "1. Creando red Docker..."
docker network create oracle-network 2>/dev/null || echo "   La red ya existe"

# 2. Crear volumen para Oracle Linux
echo ""
echo "2. Creando volumen para Oracle 19c (Linux)..."
docker volume create oracle_linux_data

# 3. Crear volumen para Oracle Windows
echo ""
echo "3. Creando volumen para Oracle 18c (Windows)..."
docker volume create oracle_windows_data

# 4. Iniciar Oracle 19c en Linux
echo ""
echo "4. Iniciando Oracle 19c (Linux)..."
echo "   - Puerto: 1521"
echo "   - SID: LINUXDB"
echo "   - Usuario: sys"
echo "   - Contraseña: Oracle123!"

docker run -d \
  --name oracle-linux-19c \
  --network oracle-network \
  -p 1521:1521 \
  -e ORACLE_SID=LINUXDB \
  -e ORACLE_PDB=LINUXPDB \
  -e ORACLE_PWD=Oracle123! \
  -v oracle_linux_data:/opt/oracle/oradata \
  gvenzl/oracle-xe:latest

# 5. Iniciar Oracle 18c en Windows (usando Docker)
echo ""
echo "5. Iniciando Oracle 18c (Windows)..."
echo "   - Puerto: 1522"
echo "   - SID: WINDOWSDB"
echo "   - Usuario: sys"
echo "   - Contraseña: Oracle123!"

docker run -d \
  --name oracle-windows-18c \
  --network oracle-network \
  -p 1522:1521 \
  -e ORACLE_SID=WINDOWSDB \
  -e ORACLE_PDB=WINDOWSPDB \
  -e ORACLE_PWD=Oracle123! \
  -v oracle_windows_data:/opt/oracle/oradata \
  gvenzl/oracle-xe:latest

# 6. Mostrar estado
echo ""
echo "==============================================="
echo "Estado de los contenedores:"
echo "==============================================="
docker ps -a | grep oracle

echo ""
echo "==============================================="
echo "Esperando a que las BD se inicialicen..."
echo "Esto puede tomar 2-3 minutos..."
echo "==============================================="
sleep 30

echo ""
echo "Verificando logs de inicialización..."
echo ""
echo "--- Oracle Linux 19c ---"
docker logs --tail 20 oracle-linux-19c
echo ""
echo "--- Oracle Windows 18c ---"
docker logs --tail 20 oracle-windows-18c

echo ""
echo "==============================================="
echo "✓ Setup completado"
echo "==============================================="
echo ""
echo "PRÓXIMOS PASOS:"
echo ""
echo "1. Espera 2-3 minutos adicionales a que inicialicen completamente"
echo ""
echo "2. Para conectarse a Oracle Linux (19c):"
echo "   docker exec -it oracle-linux-19c sqlplus sys/Oracle123! as sysdba"
echo ""
echo "3. Para conectarse a Oracle Windows (18c):"
echo "   docker exec -it oracle-windows-18c sqlplus sys/Oracle123! as sysdba"
echo ""
echo "4. O usar SQL Developer / DBeaver con:"
echo "   Linux:   localhost:1521/LINUXDB"
echo "   Windows: localhost:1522/WINDOWSDB"
echo ""
