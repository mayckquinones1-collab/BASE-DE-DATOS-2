-- ============================================================
-- Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
-- Motor: Apache Cassandra 5.0.9   Keyspace: farmabarrio
-- 2. Tablas
-- Ejecutar con: cqlsh -u <usuario> --disable-history -f "<archivo>"
-- ============================================================

USE farmabarrio;

-- ------------------------------------------------------------
-- ventas_periodo
-- Pregunta de negocio: ventas de una farmacia en un periodo,
-- de la mas reciente a la mas antigua.
-- Clave de particion compuesta (farmacia_id, anio_mes): reparte las
-- filas por sucursal y mes. Clustering por fecha descendente.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS farmabarrio.ventas_periodo (
    farmacia_id     int,
    anio_mes        text,
    fecha_venta     timestamp,
    venta_id        int,
    cliente_id      int,
    codigo_venta    text,
    empleado_id     int,
    estado          text,
    farmacia_nombre text,
    igv             decimal,
    metodo_pago     text,
    num_items       int,
    subtotal        decimal,
    total           decimal,
    unidades        int,
    PRIMARY KEY ((farmacia_id, anio_mes), fecha_venta, venta_id)
) WITH CLUSTERING ORDER BY (fecha_venta DESC, venta_id ASC)
  AND comment = 'Ventas por farmacia y mes (copia de PostgreSQL via MongoDB)';

-- ------------------------------------------------------------
-- demanda_medicamento_dia
-- Pregunta de negocio: demanda diaria de un medicamento y en que
-- farmacia se vendio. Clave de particion por medicamento.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS farmabarrio.demanda_medicamento_dia (
    medicamento_id     int,
    fecha              date,
    farmacia_id        int,
    farmacia_nombre    text,
    ingresos           decimal,
    medicamento_nombre text,
    num_ventas         int,
    unidades           int,
    PRIMARY KEY (medicamento_id, fecha, farmacia_id)
) WITH CLUSTERING ORDER BY (fecha DESC, farmacia_id ASC)
  AND comment = 'Demanda diaria por medicamento y farmacia (ventas COMPLETADAS)';

-- ------------------------------------------------------------
-- precios_historicos
-- Pregunta de negocio: como cambio el precio de un medicamento a lo
-- largo del tiempo y quien hizo cada cambio.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS farmabarrio.precios_historicos (
    medicamento_id         int,
    vigente_desde          timestamp,
    cambio_id              int,
    categoria              text,
    codigo                 text,
    empleado_id            int,
    medicamento_nombre     text,
    motivo                 text,
    origen                 text,
    precio_compra_anterior decimal,
    precio_compra_nuevo    decimal,
    precio_venta_anterior  decimal,
    precio_venta_nuevo     decimal,
    usuario_nombre         text,
    usuario_tipo           text,
    variacion_pct          decimal,
    PRIMARY KEY (medicamento_id, vigente_desde, cambio_id)
) WITH CLUSTERING ORDER BY (vigente_desde DESC, cambio_id ASC)
  AND comment = 'Historial de precios de venta y compra por medicamento';

-- Comprobacion
DESCRIBE TABLES;
