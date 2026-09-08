-- =====================================================
-- Inicializar esquema OLAP
-- Imagen: gvenzl/oracle-xe (Oracle XE 21c)
-- Contenedor: oracle-olap  |  Puerto 1522
-- Bases de Datos Avanzadas 2027-1
-- =====================================================
--
-- Ejecutar con:
--   docker exec -i oracle-olap sqlplus sys/Oracle123@localhost:1521/XEPDB1 as sysdba < 03_init_olap_CORREGIDO.sql
--
-- Nota: dentro del contenedor el puerto sigue siendo 1521.
-- El 1522 es solo el puerto que expone hacia tu Windows.
-- =====================================================

SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 50

SHOW CON_NAME

PROMPT
PROMPT Si arriba NO dice XEPDB1, ejecuta: ALTER SESSION SET CONTAINER = XEPDB1;
PROMPT

-- =====================================================
-- 1. CREAR TABLESPACES
-- =====================================================
-- Una BD OLAP hace lecturas grandes y pocas escrituras,
-- por eso conviene darle extents mas grandes que a la OLTP.

CREATE TABLESPACE ts_olap_data
  DATAFILE '/opt/oracle/oradata/XE/XEPDB1/ts_olap_data_01.dbf'
  SIZE 200M
  AUTOEXTEND ON NEXT 50M MAXSIZE 2G
  SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE ts_olap_index
  DATAFILE '/opt/oracle/oradata/XE/XEPDB1/ts_olap_index_01.dbf'
  SIZE 100M
  AUTOEXTEND ON NEXT 25M MAXSIZE 1G
  SEGMENT SPACE MANAGEMENT AUTO;

-- =====================================================
-- 2. CREAR USUARIO DE APLICACIÓN
-- =====================================================

CREATE USER usuario_olap IDENTIFIED BY Pass123
  DEFAULT TABLESPACE ts_olap_data
  QUOTA UNLIMITED ON ts_olap_data
  QUOTA UNLIMITED ON ts_olap_index;

GRANT CONNECT, RESOURCE TO usuario_olap;
GRANT CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE TO usuario_olap;
GRANT CREATE TRIGGER, CREATE SYNONYM TO usuario_olap;

-- Para vistas materializadas (tipicas en OLAP):
GRANT CREATE MATERIALIZED VIEW TO usuario_olap;

-- =====================================================
-- 3. CREAR USUARIO ADMINISTRADOR
-- =====================================================

CREATE USER admin_olap IDENTIFIED BY AdminOlap123
  DEFAULT TABLESPACE ts_olap_data
  QUOTA UNLIMITED ON ts_olap_data;

GRANT DBA TO admin_olap;

-- =====================================================
-- 4. VERIFICAR
-- =====================================================

PROMPT
PROMPT Tablespaces creados:
PROMPT ======================================
SELECT tablespace_name, status, contents
FROM   dba_tablespaces
WHERE  tablespace_name LIKE 'TS_OLAP%'
ORDER  BY tablespace_name;

PROMPT
PROMPT Usuarios creados:
PROMPT ======================================
SELECT username, account_status, default_tablespace
FROM   dba_users
WHERE  username IN ('USUARIO_OLAP','ADMIN_OLAP')
ORDER  BY username;

PROMPT
PROMPT Espacio asignado:
PROMPT ======================================
SELECT tablespace_name,
       ROUND(bytes/1024/1024) AS mb_actual,
       ROUND(maxbytes/1024/1024) AS mb_maximo,
       autoextensible
FROM   dba_data_files
WHERE  tablespace_name LIKE 'TS_OLAP%'
ORDER  BY tablespace_name;

PROMPT
PROMPT ======================================
PROMPT Inicializacion OLAP completada
PROMPT ======================================

-- =====================================================
-- 5. PRUEBA RÁPIDA (opcional)
-- =====================================================
--   docker exec -it oracle-olap sqlplus usuario_olap/Pass123@localhost:1521/XEPDB1
--
--   CREATE TABLE ventas_hist (
--     id_venta   NUMBER PRIMARY KEY,
--     region     VARCHAR2(50),
--     monto      NUMBER(12,2),
--     fecha      DATE
--   );
--   INSERT INTO ventas_hist VALUES (1,'Centro',1500.50,SYSDATE);
--   INSERT INTO ventas_hist VALUES (2,'Norte',2300.75,SYSDATE);
--   COMMIT;
--   SELECT region, SUM(monto) FROM ventas_hist GROUP BY region;
