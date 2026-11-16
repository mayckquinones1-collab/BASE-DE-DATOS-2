-- ============================================================
-- Proyecto FarmaBarrio - Replicacion de Cassandra
-- Clúster FarmaBarrioCluster: 3 nodos, datacenter1, RF = 3
-- ============================================================
-- Cassandra no tiene nodo primario: cualquier nodo acepta escrituras
-- y las propaga a las demas replicas. Es replicacion sin lider.
--
-- Los tres nodos se levantan con el docker-compose.yml del proyecto:
--   docker compose -p farmabarrio_cassandra up -d
--
-- Comprobar antes de seguir que los tres aparecen como UN:
--   docker exec cassandra-node1 nodetool status

-- Keyspace de laboratorio para la prueba de tolerancia a fallos.
CREATE KEYSPACE IF NOT EXISTS laboratorio_rf3
WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': '3'};

CREATE TABLE IF NOT EXISTS laboratorio_rf3.prueba (
    id      int PRIMARY KEY,
    mensaje text
);

-- Verificacion del factor de replicacion
SELECT keyspace_name, replication FROM system_schema.keyspaces
WHERE keyspace_name = 'laboratorio_rf3';
