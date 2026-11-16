-- ============================================================
-- Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
-- Motor: Apache Cassandra 5.0.9   Keyspace: farmabarrio
-- 6. Carga de datos
-- Ejecutar con: cqlsh -u <usuario> --disable-history -f "<archivo>"
-- ============================================================

-- El volumen del proyecto no se genera con sentencias INSERT: se carga
-- desde los CSV del respaldo incluido en la carpeta 4. Backups.
--
-- Totales esperados:
--   ventas_periodo           5000 filas (20 particiones)
--   demanda_medicamento_dia  6354 filas
--   precios_historicos        501 filas
--
-- Los archivos deben estar dentro del contenedor. Copiarlos antes con:
--   docker cp <ruta_local>\ventas_periodo.csv cassandra-node1:/tmp/

USE farmabarrio;

COPY farmabarrio.ventas_periodo FROM '/tmp/ventas_periodo.csv'
  WITH HEADER = true AND NUMPROCESSES = 3;

COPY farmabarrio.demanda_medicamento_dia FROM '/tmp/demanda_medicamento_dia.csv'
  WITH HEADER = true AND NUMPROCESSES = 3;

COPY farmabarrio.precios_historicos FROM '/tmp/precios_historicos.csv'
  WITH HEADER = true AND NUMPROCESSES = 3;

-- --- Verificacion por particion ------------------------------
-- No se usa COUNT(*) sobre toda la tabla porque recorre el clúster entero.
CONSISTENCY ALL;
SELECT COUNT(*) FROM farmabarrio.ventas_periodo WHERE farmacia_id = 8 AND anio_mes = '2024-06';   -- esperado 285
SELECT COUNT(*) FROM farmabarrio.demanda_medicamento_dia WHERE medicamento_id = 10;               -- esperado 159
SELECT COUNT(*) FROM farmabarrio.precios_historicos WHERE medicamento_id = 17;                    -- esperado 4
