-- =====================================================
-- Script: Inicializar BD OLTP en Oracle Linux 19c
-- Base de Datos Avanzadas 2027-1
-- =====================================================

-- Conectarse como SYSDBA
-- sqlplus sys/Oracle123! as sysdba @02_init_oltp_linux.sql

SET ECHO ON
SET FEEDBACK ON

-- =====================================================
-- 1. CREAR TABLESPACES
-- =====================================================

CREATE TABLESPACE ts_oltp_data
  DATAFILE '/opt/oracle/oradata/linuxdb/ts_oltp_data_01.dbf' 
  SIZE 500M
  AUTOEXTEND ON
  NEXT 50M
  MAXSIZE UNLIMITED
  SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE ts_oltp_index
  DATAFILE '/opt/oracle/oradata/linuxdb/ts_oltp_index_01.dbf' 
  SIZE 200M
  AUTOEXTEND ON
  NEXT 25M
  MAXSIZE UNLIMITED
  SEGMENT SPACE MANAGEMENT AUTO;

CREATE TEMPORARY TABLESPACE ts_oltp_temp
  TEMPFILE '/opt/oracle/oradata/linuxdb/ts_oltp_temp_01.dbf' 
  SIZE 100M
  AUTOEXTEND ON
  NEXT 10M
  MAXSIZE UNLIMITED;

-- =====================================================
-- 2. CREAR USUARIO OLTP
-- =====================================================

CREATE USER usuario_oltp IDENTIFIED BY Pass123!
  DEFAULT TABLESPACE ts_oltp_data
  TEMPORARY TABLESPACE ts_oltp_temp
  QUOTA UNLIMITED ON ts_oltp_data
  QUOTA UNLIMITED ON ts_oltp_index;

-- Otorgar privilegios
GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE PROCEDURE TO usuario_oltp;
GRANT CREATE TABLE TO usuario_oltp;
GRANT CREATE SEQUENCE TO usuario_oltp;
GRANT CREATE TRIGGER TO usuario_oltp;
GRANT CREATE SYNONYM TO usuario_oltp;

-- =====================================================
-- 3. CREAR USUARIO ADMINISTRADOR
-- =====================================================

CREATE USER admin_bd IDENTIFIED BY Admin123!
  DEFAULT TABLESPACE ts_oltp_data
  TEMPORARY TABLESPACE ts_oltp_temp
  QUOTA UNLIMITED ON ts_oltp_data
  QUOTA UNLIMITED ON ts_oltp_index;

GRANT DBA TO admin_bd;

-- =====================================================
-- 4. VERIFICAR CREACIÓN
-- =====================================================

PROMPT ======================================
PROMPT Tablespaces creados:
PROMPT ======================================
SELECT tablespace_name, status FROM dba_tablespaces WHERE tablespace_name LIKE 'TS_OLTP%';

PROMPT
PROMPT ======================================
PROMPT Usuarios creados:
PROMPT ======================================
SELECT username FROM dba_users WHERE username IN ('USUARIO_OLTP', 'ADMIN_BD');

PROMPT
PROMPT ======================================
PROMPT ✓ Inicialización OLTP completada
PROMPT ======================================

EXIT;
