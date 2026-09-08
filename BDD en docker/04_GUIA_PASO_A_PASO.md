# 🗄️ Guía: Crear 2 Bases de Datos en Docker
## Bases de Datos Avanzadas 2027-1

---

## **PASO 1: Crear la Red Docker** (si no existe)

```bash
docker network create oracle-network
```

---

## **PASO 2: Iniciar Oracle 19c (Linux)**

### Comando:
```bash
docker run -d \
  --name oracle-linux-19c \
  --network oracle-network \
  -p 1521:1521 \
  -e ORACLE_SID=LINUXDB \
  -e ORACLE_PDB=LINUXPDB \
  -e ORACLE_PWD=Oracle123! \
  -v oracle_linux_data:/opt/oracle/oradata \
  gvenzl/oracle-xe:latest
```

### Parámetros:
| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `--name` | oracle-linux-19c | Nombre del contenedor |
| `-p` | 1521:1521 | Puerto: host:contenedor |
| `ORACLE_SID` | LINUXDB | ID de la instancia |
| `ORACLE_PWD` | Oracle123! | Contraseña de SYS |
| `-v` | oracle_linux_data:/opt/oracle/oradata | Volumen persistente |

### Verificar:
```bash
docker logs oracle-linux-19c
```

Espera hasta ver: `"DATABASE IS READY TO USE"`

---

## **PASO 3: Iniciar Oracle 18c (Windows)**

### Comando:
```bash
docker run -d \
  --name oracle-windows-18c \
  --network oracle-network \
  -p 1522:1521 \
  -e ORACLE_SID=WINDOWSDB \
  -e ORACLE_PDB=WINDOWSPDB \
  -e ORACLE_PWD=Oracle123! \
  -v oracle_windows_data:/opt/oracle/oradata \
  gvenzl/oracle-xe:latest
```

### Parámetros:
| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `--name` | oracle-windows-18c | Nombre del contenedor |
| `-p` | 1522:1521 | Puerto diferente (1522 externo) |
| `ORACLE_SID` | WINDOWSDB | ID de la instancia |
| `ORACLE_PWD` | Oracle123! | Contraseña de SYS |

### Verificar:
```bash
docker logs oracle-windows-18c
```

---

## **PASO 4: Esperar a que se inicialicen**

Ambos contenedores tardan **2-3 minutos** en estar completamente listos.

```bash
# Verificar estado
docker ps | grep oracle
```

Cuando veas ambos contenedores con estado "Up", continúa.

---

## **PASO 5: Conectarse a Oracle Linux (OLTP)**

### Opción A: Desde terminal (SQL*Plus)
```bash
docker exec -it oracle-linux-19c sqlplus sys/Oracle123! as sysdba
```

### Opción B: Desde SQL Developer / DBeaver
```
Hostname:  localhost
Port:      1521
SID:       LINUXDB
Username:  sys
Password:  Oracle123!
Role:      SYSDBA
```

---

## **PASO 6: Inicializar BD OLTP (Linux)**

Una vez conectado a Oracle Linux:

```sql
-- Copiar el contenido del archivo 02_init_oltp_linux.sql
-- Y ejecutar en SQL*Plus

@02_init_oltp_linux.sql
```

### Resultado esperado:
```
Tablespaces creados:
TS_OLTP_DATA       ONLINE
TS_OLTP_INDEX      ONLINE
TS_OLTP_TEMP       ONLINE

Usuarios creados:
USUARIO_OLTP
ADMIN_BD

✓ Inicialización OLTP completada
```

---

## **PASO 7: Conectarse a Oracle Windows (OLAP)**

### Opción A: Desde terminal (SQL*Plus)
```bash
docker exec -it oracle-windows-18c sqlplus sys/Oracle123! as sysdba
```

### Opción B: Desde SQL Developer / DBeaver
```
Hostname:  localhost
Port:      1522
SID:       WINDOWSDB
Username:  sys
Password:  Oracle123!
Role:      SYSDBA
```

---

## **PASO 8: Inicializar BD OLAP (Windows)**

Una vez conectado a Oracle Windows:

```sql
-- Copiar el contenido del archivo 03_init_olap_windows.sql
-- Y ejecutar en SQL*Plus

@03_init_olap_windows.sql
```

### Resultado esperado:
```
Tablespaces creados:
TS_OLAP_DATA       ONLINE
TS_OLAP_INDEX      ONLINE
TS_OLAP_TEMP       ONLINE

Usuarios creados:
USUARIO_OLAP
ADMIN_OLAP

✓ Inicialización OLAP completada
```

---

## **RESUMEN: Credenciales de Acceso**

### 📊 Oracle Linux 19c (OLTP)
```
Nombre:        oracle-linux-19c
Puerto:        1521
SID:           LINUXDB
PDB:           LINUXPDB
Usuario SYS:   sys / Oracle123! (SYSDBA)
Usuario OLTP:  usuario_oltp / Pass123!
Admin BD:      admin_bd / Admin123!
```

### 💼 Oracle Windows 18c (OLAP)
```
Nombre:        oracle-windows-18c
Puerto:        1522
SID:           WINDOWSDB
PDB:           WINDOWSPDB
Usuario SYS:   sys / Oracle123! (SYSDBA)
Usuario OLAP:  usuario_olap / Pass123!
Admin OLAP:    admin_olap / AdminOlap123!
```

---

## **Comandos Útiles**

### Ver estado de contenedores:
```bash
docker ps -a | grep oracle
```

### Ver logs:
```bash
docker logs oracle-linux-19c
docker logs oracle-windows-18c
```

### Entrar al contenedor:
```bash
docker exec -it oracle-linux-19c bash
docker exec -it oracle-windows-18c bash
```

### Detener contenedores:
```bash
docker stop oracle-linux-19c oracle-windows-18c
```

### Reiniciar contenedores:
```bash
docker restart oracle-linux-19c oracle-windows-18c
```

### Eliminar todo:
```bash
docker rm oracle-linux-19c oracle-windows-18c
docker volume rm oracle_linux_data oracle_windows_data
docker network rm oracle-network
```

---

## **Verificación Final**

Desde cualquier conexión SQL, ejecuta:

```sql
-- Ver instancia actual
SELECT name FROM v$database;

-- Ver tablespaces
SELECT tablespace_name, status FROM dba_tablespaces;

-- Ver usuarios
SELECT username FROM dba_users WHERE created > SYSDATE - 1;

-- Ver PDB (si aplica)
SHOW pdbs;
```

---

## **¿Problemas?**

### "Container exits immediately"
→ Espera 1-2 minutos más, el contenedor se reinicia

### "ORA-01034: ORACLE not available"
→ La BD aún se está inicializando, revisa los logs

### "Connection refused"
→ Verifica el puerto correcto (1521 para Linux, 1522 para Windows)

### "ORA-12514: TNS:listener does not currently know of service"
→ La PDB no está montada, conecta al SID en lugar del PDB

---

**¡Listo! Ahora tienes dos BD completamente funcionales para tu proyecto.** 🎉
