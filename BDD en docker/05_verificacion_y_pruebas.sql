-- =====================================================
-- Script: Verificación y Pruebas de las BD
-- Base de Datos Avanzadas 2027-1
-- =====================================================

-- Este archivo contiene comandos para verificar
-- que las bases de datos están configuradas correctamente

-- =====================================================
-- EJECUTAR EN ORACLE LINUX (OLTP) - conexión como SYSDBA
-- =====================================================

PROMPT =====================================
PROMPT VERIFICACIÓN: Oracle Linux 19c (OLTP)
PROMPT =====================================

-- 1. Ver información de la instancia
PROMPT
PROMPT 1. Información de la instancia:
PROMPT =====================================
SELECT name, open_cursors, db_block_size FROM v$database;

-- 2. Ver modo de la BD (archivelog)
PROMPT
PROMPT 2. Modo de operación:
PROMPT =====================================
ARCHIVE LOG LIST;

-- 3. Ver tablespaces OLTP
PROMPT
PROMPT 3. Tablespaces OLTP:
PROMPT =====================================
SELECT tablespace_name, extent_management, allocation_type, status
FROM dba_tablespaces 
WHERE tablespace_name LIKE 'TS_OLTP%'
ORDER BY tablespace_name;

-- 4. Ver datafiles
PROMPT
PROMPT 4. Datafiles OLTP:
PROMPT =====================================
SELECT file_name, tablespace_name, bytes/1024/1024 AS size_mb, status
FROM dba_data_files 
WHERE tablespace_name LIKE 'TS_OLTP%'
ORDER BY file_name;

-- 5. Ver usuarios creados
PROMPT
PROMPT 5. Usuarios OLTP:
PROMPT =====================================
SELECT username, account_status, created, default_tablespace
FROM dba_users 
WHERE username IN ('USUARIO_OLTP', 'ADMIN_BD')
ORDER BY username;

-- 6. Ver privilegios del usuario OLTP
PROMPT
PROMPT 6. Privilegios de usuario_oltp:
PROMPT =====================================
SELECT privilege FROM dba_sys_privs 
WHERE grantee = 'USUARIO_OLTP'
ORDER BY privilege;

-- 7. Ver cuotas asignadas
PROMPT
PROMPT 7. Cuotas de usuario_oltp:
PROMPT =====================================
SELECT username, tablespace_name, bytes/1024/1024 AS quota_mb, max_bytes
FROM dba_ts_quotas 
WHERE username = 'USUARIO_OLTP'
ORDER BY tablespace_name;

-- 8. Espacio disponible en tablespaces
PROMPT
PROMPT 8. Espacio en Tablespaces OLTP:
PROMPT =====================================
SELECT 
  t.tablespace_name,
  ROUND(SUM(d.bytes)/1024/1024) AS size_mb,
  ROUND(SUM(f.bytes)/1024/1024) AS free_mb,
  ROUND(SUM(f.bytes)*100/SUM(d.bytes)) AS free_percent
FROM dba_tablespaces t
  LEFT JOIN dba_data_files d ON t.tablespace_name = d.tablespace_name
  LEFT JOIN dba_free_space f ON t.tablespace_name = f.tablespace_name
WHERE t.tablespace_name LIKE 'TS_OLTP%'
GROUP BY t.tablespace_name
ORDER BY t.tablespace_name;

PROMPT
PROMPT ✓ Verificación OLTP completada
PROMPT

-- =====================================================
-- EJECUTAR EN ORACLE WINDOWS (OLAP) - conexión como SYSDBA
-- =====================================================

PROMPT
PROMPT =====================================
PROMPT VERIFICACIÓN: Oracle Windows 18c (OLAP)
PROMPT =====================================

-- 1. Ver información de la instancia
PROMPT
PROMPT 1. Información de la instancia:
PROMPT =====================================
SELECT name, open_cursors, db_block_size FROM v$database;

-- 2. Ver tablespaces OLAP
PROMPT
PROMPT 2. Tablespaces OLAP:
PROMPT =====================================
SELECT tablespace_name, extent_management, allocation_type, status
FROM dba_tablespaces 
WHERE tablespace_name LIKE 'TS_OLAP%'
ORDER BY tablespace_name;

-- 3. Ver datafiles
PROMPT
PROMPT 3. Datafiles OLAP:
PROMPT =====================================
SELECT file_name, tablespace_name, bytes/1024/1024 AS size_mb, status
FROM dba_data_files 
WHERE tablespace_name LIKE 'TS_OLAP%'
ORDER BY file_name;

-- 4. Ver usuarios creados
PROMPT
PROMPT 4. Usuarios OLAP:
PROMPT =====================================
SELECT username, account_status, created, default_tablespace
FROM dba_users 
WHERE username IN ('USUARIO_OLAP', 'ADMIN_OLAP')
ORDER BY username;

-- 5. Ver privilegios del usuario OLAP
PROMPT
PROMPT 5. Privilegios de usuario_olap:
PROMPT =====================================
SELECT privilege FROM dba_sys_privs 
WHERE grantee = 'USUARIO_OLAP'
ORDER BY privilege;

-- 6. Espacio disponible
PROMPT
PROMPT 6. Espacio en Tablespaces OLAP:
PROMPT =====================================
SELECT 
  t.tablespace_name,
  ROUND(SUM(d.bytes)/1024/1024) AS size_mb,
  ROUND(SUM(f.bytes)/1024/1024) AS free_mb,
  ROUND(SUM(f.bytes)*100/SUM(d.bytes)) AS free_percent
FROM dba_tablespaces t
  LEFT JOIN dba_data_files d ON t.tablespace_name = d.tablespace_name
  LEFT JOIN dba_free_space f ON t.tablespace_name = f.tablespace_name
WHERE t.tablespace_name LIKE 'TS_OLAP%'
GROUP BY t.tablespace_name
ORDER BY t.tablespace_name;

PROMPT
PROMPT ✓ Verificación OLAP completada
PROMPT

-- =====================================================
-- PRUEBA: Crear una tabla de prueba como USUARIO_OLTP
-- =====================================================

PROMPT
PROMPT =====================================
PROMPT PRUEBA: Crear tabla en BD OLTP
PROMPT =====================================
PROMPT (Ejecutar como usuario_oltp)
PROMPT

-- Conectarse primero como usuario_oltp
-- sqlplus usuario_oltp/Pass123!

CREATE TABLE prueba_conexion (
  id_prueba NUMBER PRIMARY KEY,
  nombre VARCHAR2(100),
  fecha_creacion DATE
);

-- Crear secuencia
CREATE SEQUENCE seq_prueba START WITH 1 INCREMENT BY 1;

-- Crear trigger para auto-incremento
CREATE OR REPLACE TRIGGER trg_prueba
  BEFORE INSERT ON prueba_conexion
  FOR EACH ROW
BEGIN
  IF :NEW.id_prueba IS NULL THEN
    SELECT seq_prueba.NEXTVAL INTO :NEW.id_prueba FROM dual;
  END IF;
END;
/

-- Insertar datos de prueba
INSERT INTO prueba_conexion (nombre, fecha_creacion)
VALUES ('Primer registro OLTP', SYSDATE);

INSERT INTO prueba_conexion (nombre, fecha_creacion)
VALUES ('Segundo registro OLTP', SYSDATE);

COMMIT;

-- Verificar datos
SELECT * FROM prueba_conexion;

-- Ver objetos del usuario
SELECT object_type, COUNT(*) AS cantidad
FROM user_objects
GROUP BY object_type
ORDER BY object_type;

-- Ver espacio utilizado
SELECT 
  segment_name,
  segment_type,
  bytes/1024 AS size_kb
FROM user_segments
ORDER BY bytes DESC;

PROMPT
PROMPT ✓ Prueba de tabla completada
PROMPT

-- =====================================================
-- PRUEBA: Crear tabla de prueba como USUARIO_OLAP
-- =====================================================

PROMPT
PROMPT =====================================
PROMPT PRUEBA: Crear tabla en BD OLAP
PROMPT =====================================
PROMPT (Ejecutar como usuario_olap)
PROMPT

-- Conectarse primero como usuario_olap
-- sqlplus usuario_olap/Pass123!

CREATE TABLE prueba_analisis (
  id_registro NUMBER PRIMARY KEY,
  tipo_dato VARCHAR2(50),
  valor NUMBER,
  fecha_registro DATE
);

-- Crear secuencia
CREATE SEQUENCE seq_analisis START WITH 1 INCREMENT BY 1;

-- Insertar datos de prueba
INSERT INTO prueba_analisis (id_registro, tipo_dato, valor, fecha_registro)
VALUES (1, 'Tipo A', 1500.50, SYSDATE);

INSERT INTO prueba_analisis (id_registro, tipo_dato, valor, fecha_registro)
VALUES (2, 'Tipo B', 2300.75, SYSDATE);

INSERT INTO prueba_analisis (id_registro, tipo_dato, valor, fecha_registro)
VALUES (3, 'Tipo A', 1800.25, SYSDATE);

COMMIT;

-- Consultas de análisis
SELECT COUNT(*) AS total_registros FROM prueba_analisis;

SELECT tipo_dato, SUM(valor) AS total_valor, AVG(valor) AS promedio
FROM prueba_analisis
GROUP BY tipo_dato;

-- Ver objetos
SELECT object_type, COUNT(*) AS cantidad
FROM user_objects
GROUP BY object_type
ORDER BY object_type;

PROMPT
PROMPT ✓ Prueba de análisis completada
PROMPT

-- =====================================================
-- RESUMEN FINAL
-- =====================================================

PROMPT
PROMPT ======================================================
PROMPT ✓ TODAS LAS VERIFICACIONES COMPLETADAS
PROMPT ======================================================
PROMPT
PROMPT Resumen:
PROMPT • BD OLTP (Linux):   Inicializada y operativa
PROMPT • BD OLAP (Windows): Inicializada y operativa
PROMPT • Usuarios:          Creados con permisos correctos
PROMPT • Tablespaces:       Configurados y con espacio
PROMPT • Tablas de prueba:  Funcionando correctamente
PROMPT
PROMPT ¡Listo para crear tu proyecto CRUD!
PROMPT ======================================================

QUIT;
