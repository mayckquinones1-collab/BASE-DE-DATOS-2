-- ============================================================
-- Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
-- Motor: Apache Cassandra 5.0.9   Keyspace: farmabarrio
-- 1. Creacion del keyspace
-- Ejecutar con: cqlsh -u <usuario> --disable-history -f "<archivo>"
-- ============================================================

-- NetworkTopologyStrategy con factor de replicacion 3 sobre datacenter1:
-- cada fila se guarda en los tres nodos del clúster, de modo que el sistema
-- sigue disponible aunque caiga uno.

CREATE KEYSPACE IF NOT EXISTS farmabarrio
WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': '3'}
AND durable_writes = true;

USE farmabarrio;

-- Comprobacion
DESCRIBE KEYSPACES;
