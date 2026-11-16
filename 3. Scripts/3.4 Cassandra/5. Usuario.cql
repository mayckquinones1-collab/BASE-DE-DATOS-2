-- ============================================================
-- Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
-- Motor: Apache Cassandra 5.0.9   Keyspace: farmabarrio
-- 5. Roles y usuarios
-- Ejecutar con: cqlsh -u <usuario> --disable-history -f "<archivo>"
-- ============================================================

-- IMPORTANTE: las contrasenas estan reemplazadas por el marcador <CLAVE>.
-- Sustituir antes de ejecutar y no guardar el archivo con la clave real.
--
-- Requiere que el clúster tenga activados en cassandra.yaml:
--   authenticator: PasswordAuthenticator
--   authorizer: CassandraAuthorizer
-- y que system_auth tenga factor de replicacion 3, con nodetool repair system_auth.

-- --- Roles sin acceso directo (LOGIN = false) ----------------
-- Agrupan permisos; los usuarios los heredan.

CREATE ROLE IF NOT EXISTS rol_lectura WITH LOGIN = false;
GRANT SELECT ON KEYSPACE farmabarrio TO rol_lectura;

CREATE ROLE IF NOT EXISTS rol_escritura WITH LOGIN = false;
GRANT SELECT ON KEYSPACE farmabarrio TO rol_escritura;
GRANT MODIFY ON KEYSPACE farmabarrio TO rol_escritura;

CREATE ROLE IF NOT EXISTS rol_respaldo WITH LOGIN = false;
GRANT SELECT ON KEYSPACE farmabarrio TO rol_respaldo;

-- --- Usuarios con acceso (LOGIN = true) ----------------------

-- Administrador del clúster. SUPERUSER no se otorga con un rol:
-- es un atributo del propio usuario.
CREATE ROLE IF NOT EXISTS farma_admin
  WITH PASSWORD = '<CLAVE>' AND LOGIN = true AND SUPERUSER = true;

CREATE ROLE IF NOT EXISTS farma_consulta  WITH PASSWORD = '<CLAVE>' AND LOGIN = true;
GRANT rol_lectura TO farma_consulta;

CREATE ROLE IF NOT EXISTS farma_operacion WITH PASSWORD = '<CLAVE>' AND LOGIN = true;
GRANT rol_escritura TO farma_operacion;

CREATE ROLE IF NOT EXISTS farma_respaldo  WITH PASSWORD = '<CLAVE>' AND LOGIN = true;
GRANT rol_respaldo TO farma_respaldo;

-- --- Comprobacion (requiere farma_admin) ---------------------
LIST ROLES;
LIST ROLES OF farma_consulta;
