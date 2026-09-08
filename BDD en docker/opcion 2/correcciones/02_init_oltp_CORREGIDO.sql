-- =====================================================
-- Inicializar esquema OLTP
-- Imagen: gvenzl/oracle-xe (Oracle XE 21c)
-- Contenedor: oracle-oltp  |  Puerto 1521
-- Bases de Datos Avanzadas 2027-1
-- =====================================================
--
-- Ejecutar con:
--   docker exec -i oracle-oltp sqlplus sys/Oracle123@localhost:1521/XEPDB1 as sysdba < 02_init_oltp_CORREGIDO.sql
--
-- O bien copiar y pegar dentro de SQL*Plus.
-- =====================================================

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 50

-- =====================================================
-- 0. CONFIRMAR EN QUÉ CONTENEDOR ESTAMOS
-- =====================================================
-- En Oracle 21c XE la arquitectura es multitenant:
--   CDB$ROOT  = contenedor raíz (no se crean objetos de usuario aquí)
--   XEPDB1    = base pluggable donde SÍ van nuestros esquemas
--
-- Si conectaste con el servicio XEPDB1, ya estás en la PDB.

SHOW CON_NAME

PROMPT
PROMPT Si arriba NO dice XEPDB1, ejecuta: ALTER SESSION SET CONTAINER = XEPDB1;
PROMPT

-- Descomenta la siguiente línea si conectaste al CDB por error:
-- ALTER SESSION SET CONTAINER = XEPDB1;

-- =====================================================
-- 1. VER DÓNDE VIVEN LOS DATAFILES
-- =====================================================
-- Esto confirma la ruta real antes de crear tablespaces.
-- En esta imagen normalmente es /opt/oracle/oradata/XE/XEPDB1/

PROMPT
PROMPT Ruta actual de los datafiles:
PROMPT ======================================
SELECT name FROM v$datafile ORDER BY file#;

-- =====================================================
-- 2. CREAR TABLESPACES
-- =====================================================
-- Separar datos de índices permite después medir y ajustar
-- el rendimiento de cada uno por separado (tema 5 del temario).

CREATE TABLESPACE ts_oltp_data
  DATAFILE '/opt/oracle/oradata/XE/XEPDB1/ts_oltp_data_01.dbf'
  SIZE 200M
  AUTOEXTEND ON NEXT 50M MAXSIZE 2G
  SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE ts_oltp_index
  DATAFILE '/opt/oracle/oradata/XE/XEPDB1/ts_oltp_index_01.dbf'
  SIZE 100M
  AUTOEXTEND ON NEXT 25M MAXSIZE 1G
  SEGMENT SPACE MANAGEMENT AUTO;

-- =====================================================
-- 3. CREAR USUARIO DE APLICACIÓN
-- =====================================================

CREATE USER usuario_oltp IDENTIFIED BY Pass123
  DEFAULT TABLESPACE ts_oltp_data
  QUOTA UNLIMITED ON ts_oltp_data
  QUOTA UNLIMITED ON ts_oltp_index;

GRANT CONNECT, RESOURCE TO usuario_oltp;
GRANT CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE TO usuario_oltp;
GRANT CREATE TRIGGER, CREATE SYNONYM TO usuario_oltp;

-- =====================================================
-- 4. CREAR USUARIO ADMINISTRADOR
-- =====================================================

CREATE USER admin_bd IDENTIFIED BY Admin123
  DEFAULT TABLESPACE ts_oltp_data
  QUOTA UNLIMITED ON ts_oltp_data;

GRANT DBA TO admin_bd;

-- =====================================================
-- 5. VERIFICAR
-- =====================================================

PROMPT
PROMPT Tablespaces creados:
PROMPT ======================================
SELECT tablespace_name, status, contents
FROM   dba_tablespaces
WHERE  tablespace_name LIKE 'TS_OLTP%'
ORDER  BY tablespace_name;

PROMPT
PROMPT Usuarios creados:
PROMPT ======================================
SELECT username, account_status, default_tablespace
FROM   dba_users
WHERE  username IN ('USUARIO_OLTP','ADMIN_BD')
ORDER  BY username;

PROMPT
PROMPT Espacio asignado:
PROMPT ======================================
SELECT tablespace_name,
       ROUND(bytes/1024/1024) AS mb_actual,
       ROUND(maxbytes/1024/1024) AS mb_maximo,
       autoextensible
FROM   dba_data_files
WHERE  tablespace_name LIKE 'TS_OLTP%'
ORDER  BY tablespace_name;

PROMPT
PROMPT ======================================
PROMPT Inicializacion OLTP completada
PROMPT ======================================

-- =====================================================
-- 6. PRUEBA RÁPIDA (opcional)
-- =====================================================
-- Desconéctate y vuelve a entrar como usuario_oltp:
--   docker exec -it oracle-oltp sqlplus usuario_oltp/Pass123@localhost:1521/XEPDB1
--
-- Luego:
--   CREATE TABLE prueba (id NUMBER PRIMARY KEY, texto VARCHAR2(100));
--   INSERT INTO prueba VALUES (1, 'Funciona');
--   COMMIT;
--   SELECT * FROM prueba;
