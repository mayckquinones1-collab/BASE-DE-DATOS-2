# ============================================================
# Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
# Motor: Apache Cassandra   Respaldo y prueba de restauracion
# Ejecutar en PowerShell 5.1
# ============================================================
# Estrategia mixta: snapshot de nodo (copia fisica) + exportacion
# logica a CSV. Con RF=3 en un clúster de 3 nodos, el snapshot de un
# solo nodo contiene todos los datos.
#
# Con la autenticacion activa, cqlsh requiere -u farma_respaldo para
# exportar y -u farma_admin para restaurar. La clave se escribe en el
# prompt; nunca va en el script. nodetool y docker cp no cambian.

$fecha   = "final_2026-11-12"
$etiqueta = "final_2026_11_12"
$destino = "F:\backup_cassandra\$fecha"

New-Item -ItemType Directory -Force $destino | Out-Null

# OJO: si la carpeta 'exportado' ya existe de una corrida anterior,
# renombrarla a mano antes de continuar, o docker cp la anidara dentro.

# 1. Limpiar el snapshot anterior con la misma etiqueta
docker exec cassandra-node1 nodetool clearsnapshot -t $etiqueta farmabarrio

# 2. Guardar el esquema y crear el snapshot
docker exec cassandra-node1 cqlsh -e "DESCRIBE KEYSPACE farmabarrio" | Out-File -Encoding utf8 "$destino\esquema_farmabarrio.cql"
docker exec cassandra-node1 nodetool snapshot -t $etiqueta farmabarrio

# 3. Exportacion logica de las tres tablas a CSV
docker exec cassandra-node1 mkdir -p /tmp/backup_$etiqueta
docker exec -it cassandra-node1 cqlsh --request-timeout=120 -e "COPY farmabarrio.ventas_periodo TO '/tmp/backup_$etiqueta/ventas_periodo.csv' WITH HEADER = true;"
docker exec -it cassandra-node1 cqlsh --request-timeout=120 -e "COPY farmabarrio.demanda_medicamento_dia TO '/tmp/backup_$etiqueta/demanda_medicamento_dia.csv' WITH HEADER = true;"
docker exec -it cassandra-node1 cqlsh --request-timeout=120 -e "COPY farmabarrio.precios_historicos TO '/tmp/backup_$etiqueta/precios_historicos.csv' WITH HEADER = true;"

# 4. Empaquetar el snapshot y copiar todo al equipo anfitrion
docker exec cassandra-node1 sh -c "cd /var/lib/cassandra/data/farmabarrio && tar czf /tmp/backup_$etiqueta/snapshot_$etiqueta.tgz */snapshots/$etiqueta"
docker cp cassandra-node1:/tmp/backup_$etiqueta "$destino\exportado"
dir "$destino\exportado"

# 5. Simulacion de perdida sobre el keyspace de prueba
docker exec cassandra-node1 cqlsh --request-timeout=120 -e "DROP KEYSPACE farmabarrio_prueba;"
docker exec cassandra-node1 cqlsh -e "DESCRIBE KEYSPACES;"

# 6. Recrear el esquema en el keyspace de prueba
(Get-Content "$destino\esquema_farmabarrio.cql") -replace 'farmabarrio', 'farmabarrio_prueba' | Out-File -Encoding utf8 "$destino\esquema_prueba.cql"
docker cp "$destino\esquema_prueba.cql" cassandra-node1:/tmp/esquema_prueba.cql
docker exec cassandra-node1 cqlsh --request-timeout=120 -f /tmp/esquema_prueba.cql

# 7. Recuperacion desde los CSV
docker exec -it cassandra-node1 cqlsh --request-timeout=120 -e "COPY farmabarrio_prueba.ventas_periodo FROM '/tmp/backup_$etiqueta/ventas_periodo.csv' WITH HEADER = true AND NUMPROCESSES = 3;"
docker exec -it cassandra-node1 cqlsh --request-timeout=120 -e "COPY farmabarrio_prueba.demanda_medicamento_dia FROM '/tmp/backup_$etiqueta/demanda_medicamento_dia.csv' WITH HEADER = true AND NUMPROCESSES = 3;"
docker exec -it cassandra-node1 cqlsh --request-timeout=120 -e "COPY farmabarrio_prueba.precios_historicos FROM '/tmp/backup_$etiqueta/precios_historicos.csv' WITH HEADER = true AND NUMPROCESSES = 3;"

# 8. Verificacion por particion con consistencia ALL
# Esperado: 285 y 285 | 159 y 159 | 4 y 4
docker exec cassandra-node1 cqlsh --request-timeout=120 -e "CONSISTENCY ALL; SELECT COUNT(*) FROM farmabarrio.ventas_periodo WHERE farmacia_id = 8 AND anio_mes = '2024-06'; SELECT COUNT(*) FROM farmabarrio_prueba.ventas_periodo WHERE farmacia_id = 8 AND anio_mes = '2024-06';"
docker exec cassandra-node1 cqlsh --request-timeout=120 -e "CONSISTENCY ALL; SELECT COUNT(*) FROM farmabarrio.demanda_medicamento_dia WHERE medicamento_id = 10; SELECT COUNT(*) FROM farmabarrio_prueba.demanda_medicamento_dia WHERE medicamento_id = 10;"
docker exec cassandra-node1 cqlsh --request-timeout=120 -e "CONSISTENCY ALL; SELECT COUNT(*) FROM farmabarrio.precios_historicos WHERE medicamento_id = 17; SELECT COUNT(*) FROM farmabarrio_prueba.precios_historicos WHERE medicamento_id = 17;"
