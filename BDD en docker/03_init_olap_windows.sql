-- =====================================================
-- Script: Inicializar BD OLAP en Oracle Windows 18c
-- Base de Datos Avanzadas 2027-1
-- =====================================================

-- Conectarse como SYSDBA
-- sqlplus sys/Oracle123! @03_init_olap_windows.sql

SET ECHO ON
SET FEEDBACK ON

-- =====================================================
-- 1. CREAR TABLESPACES
-- =====================================================

CREATE TABLESPACE ts_olap_data
  DATAFILE 'C:\oracle\oradata\windowsdb\ts_olap_data_01.dbf' 
  SIZE 500M
  AUTOEXTEND ON
  NEXT 50M
  MAXSIZE UNLIMITED
  SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE ts_olap_index
  DATAFILE 'C:\oracle\oradata\windowsdb\ts_olap_index_01.dbf' 
  SIZE 200M
  AUTOEXTEND ON
  NEXT 25M
  MAXSIZE UNLIMITED
  SEGMENT SPACE MANAGEMENT AUTO;

CREATE TEMPORARY TABLESPACE ts_olap_temp
  TEMPFILE 'C:\oracle\oradata\windowsdb\ts_olap_temp_01.dbf' 
  SIZE 100M
  AUTOEXTEND ON
  NEXT 10M
  MAXSIZE UNLIMITED;

-- =====================================================
-- 2. CREAR USUARIO OLAP
-- =====================================================

CREATE USER usuario_olap IDENTIFIED BY Pass123!
  DEFAULT TABLESPACE ts_olap_data
  TEMPORARY TABLESPACE ts_olap_temp
  QUOTA UNLIMITED ON ts_olap_data
  QUOTA UNLIMITED ON ts_olap_index;

-- Otorgar privilegios
GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE PROCEDURE TO usuario_olap;
GRANT CREATE TABLE TO usuario_olap;
GRANT CREATE SEQUENCE TO usuario_olap;
GRANT CREATE TRIGGER TO usuario_olap;
GRANT CREATE SYNONYM TO usuario_olap;

-- =====================================================
-- 3. CREAR USUARIO ADMINISTRADOR
-- =====================================================

CREATE USER admin_olap IDENTIFIED BY AdminOlap123!
  DEFAULT TABLESPACE ts_olap_data
  TEMPORARY TABLESPACE ts_olap_temp
  QUOTA UNLIMITED ON ts_olap_data
  QUOTA UNLIMITED ON ts_olap_index;

GRANT DBA TO admin_olap;

-- =====================================================
-- 4. VERIFICAR CREACIÓN
-- =====================================================

PROMPT ======================================
PROMPT Tablespaces creados:
PROMPT ======================================
SELECT tablespace_name, status FROM dba_tablespaces WHERE tablespace_name LIKE 'TS_OLAP%';

PROMPT
PROMPT ======================================
PROMPT Usuarios creados:
PROMPT ======================================
SELECT username FROM dba_users WHERE username IN ('USUARIO_OLAP', 'ADMIN_OLAP');

PROMPT
PROMPT ======================================
PROMPT ✓ Inicialización OLAP completada
PROMPT ======================================

EXIT;
