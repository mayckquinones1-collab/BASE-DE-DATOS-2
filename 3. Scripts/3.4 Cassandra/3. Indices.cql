-- ============================================================
-- Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
-- Motor: Apache Cassandra 5.0.9   Keyspace: farmabarrio
-- 3. Indices SAI
-- Ejecutar con: cqlsh -u <usuario> --disable-history -f "<archivo>"
-- ============================================================

USE farmabarrio;

-- SAI (Storage Attached Index) permite filtrar por columnas que no forman
-- parte de la clave primaria, sin recurrir a ALLOW FILTERING.

-- Ventas anuladas: 166 de 5000 (3.3 %). Columna muy selectiva.
CREATE CUSTOM INDEX IF NOT EXISTS ix_ventas_estado
  ON farmabarrio.ventas_periodo (estado) USING 'sai';

-- Compras de un cliente en todas las farmacias.
CREATE CUSTOM INDEX IF NOT EXISTS ix_ventas_cliente
  ON farmabarrio.ventas_periodo (cliente_id) USING 'sai';

-- Ventas por metodo de pago. Solo 4 valores distintos, por lo que
-- aporta menos que los anteriores.
CREATE CUSTOM INDEX IF NOT EXISTS ix_ventas_metodo_pago
  ON farmabarrio.ventas_periodo (metodo_pago) USING 'sai';

-- Dias con 12 o mas unidades vendidas.
CREATE CUSTOM INDEX IF NOT EXISTS ix_demanda_unidades
  ON farmabarrio.demanda_medicamento_dia (unidades) USING 'sai';

-- Cambios de precio hechos por un responsable concreto.
CREATE CUSTOM INDEX IF NOT EXISTS ix_precios_empleado
  ON farmabarrio.precios_historicos (empleado_id) USING 'sai';

-- Comprobacion: deben aparecer los cinco
SELECT table_name, index_name FROM system_schema.indexes
WHERE keyspace_name = 'farmabarrio';
