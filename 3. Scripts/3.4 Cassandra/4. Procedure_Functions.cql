-- ============================================================
-- Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
-- Motor: Apache Cassandra 5.0.9   Keyspace: farmabarrio
-- 4. Funciones y agregado definidos por el usuario
-- Ejecutar con: cqlsh -u <usuario> --disable-history -f "<archivo>"
-- ============================================================

USE farmabarrio;

-- Cassandra permite funciones definidas por el usuario (UDF) en Java.
-- Requieren enable_user_defined_functions: true en cassandra.yaml.

-- ------------------------------------------------------------
-- fn_total_con_igv: calcula el total de una venta con IGV del 18 %.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION farmabarrio.fn_total_con_igv(subtotal decimal)
    RETURNS NULL ON NULL INPUT
    RETURNS decimal
    LANGUAGE java
    AS $$return subtotal.multiply(new java.math.BigDecimal("1.18")).setScale(2, java.math.RoundingMode.HALF_UP);$$;

-- ------------------------------------------------------------
-- fn_total_sin_igv: del total con IGV devuelve el subtotal.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION farmabarrio.fn_total_sin_igv(total decimal)
    RETURNS NULL ON NULL INPUT
    RETURNS decimal
    LANGUAGE java
    AS $$return total.divide(new java.math.BigDecimal("1.18"), 2, java.math.RoundingMode.HALF_UP);$$;

-- ------------------------------------------------------------
-- fn_clasificar_demanda: ALTA (8 o mas), MEDIA (4 a 7), BAJA (3 o menos).
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION farmabarrio.fn_clasificar_demanda(unidades int)
    RETURNS NULL ON NULL INPUT
    RETURNS text
    LANGUAGE java
    AS $$if (unidades >= 8) { return "ALTA"; } else if (unidades >= 4) { return "MEDIA"; } else { return "BAJA"; }$$;

-- ------------------------------------------------------------
-- fn_margen_pct: margen de ganancia en porcentaje.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION farmabarrio.fn_margen_pct(precio_venta decimal, precio_compra decimal)
    RETURNS NULL ON NULL INPUT
    RETURNS decimal
    LANGUAGE java
    AS $$return precio_venta.subtract(precio_compra).multiply(new java.math.BigDecimal("100")).divide(precio_venta, 2, java.math.RoundingMode.HALF_UP);$$;

-- ------------------------------------------------------------
-- uda_rango_variacion: agregado que calcula la variacion porcentual
-- entre el precio minimo y el maximo. Se apoya en dos funciones
-- auxiliares: una acumula el estado fila por fila y la otra calcula
-- el resultado final.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION farmabarrio.uda_rango_estado(estado tuple<int, double, double>, valor decimal)
    CALLED ON NULL INPUT
    RETURNS tuple<int, double, double>
    LANGUAGE java
    AS $$if (valor == null) { return estado; } double v = valor.doubleValue(); int n = estado.getInt(0); if (n == 0) { estado.setDouble(1, v); estado.setDouble(2, v); } else { if (v < estado.getDouble(1)) { estado.setDouble(1, v); } if (v > estado.getDouble(2)) { estado.setDouble(2, v); } } estado.setInt(0, n + 1); return estado;$$;

CREATE OR REPLACE FUNCTION farmabarrio.uda_rango_final(estado tuple<int, double, double>)
    CALLED ON NULL INPUT
    RETURNS double
    LANGUAGE java
    AS $$if (estado.getInt(0) == 0) { return null; } double mn = estado.getDouble(1); double mx = estado.getDouble(2); if (mn == 0) { return null; } double r = (mx - mn) / mn * 100.0; return Math.round(r * 100.0) / 100.0;$$;

CREATE OR REPLACE AGGREGATE farmabarrio.uda_rango_variacion(decimal)
    SFUNC uda_rango_estado
    STYPE tuple<int, double, double>
    FINALFUNC uda_rango_final
    INITCOND (0, 0.0, 0.0);

-- Comprobacion
SELECT function_name, argument_types FROM system_schema.functions WHERE keyspace_name = 'farmabarrio';
SELECT aggregate_name FROM system_schema.aggregates WHERE keyspace_name = 'farmabarrio';
