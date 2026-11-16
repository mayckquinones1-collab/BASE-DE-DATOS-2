// ============================================================
// Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
// Motor: MongoDB 9.0.4   Base: farmabarrio_mongo
// 3. Indices
// Ejecutar con: mongosh "mongodb://localhost:27017/farmabarrio_mongo" --file "<archivo>"
// Con autenticacion activa, agregar: -u <usuario> -p --authenticationDatabase admin
// ============================================================

use farmabarrio_mongo;

// --- Indices unicos sobre los identificadores de negocio -----
// Impiden que dos documentos compartan el mismo identificador.

db.ventas_historicas.createIndex({ venta_id: 1 }, { name: "ux_venta_id", unique: true });
db.resenas.createIndex({ resena_id: 1 }, { name: "ux_resena_id", unique: true });
db.auditoria_eventos.createIndex({ evento_id: 1 }, { name: "ux_evento_id", unique: true });
db.logs_marketplace.createIndex({ log_id: 1 }, { name: "ux_log_id", unique: true });

// --- Indices de consulta ------------------------------------

// Compuesto: igualdad por farmacia + rango y orden por fecha.
db.ventas_historicas.createIndex({ farmacia_id: 1, fecha_venta: -1 }, { name: "ix_ventas_farmacia_fecha" });

// Multikey: indexa cada elemento del arreglo items por separado.
db.ventas_historicas.createIndex({ "items.medicamento_id": 1 }, { name: "ix_ventas_items_medicamento" });

// Parcial: solo indexa las ventas anuladas (166 de 5000).
db.ventas_historicas.createIndex(
  { fecha_venta: 1 },
  { name: "ix_ventas_anuladas_fecha", partialFilterExpression: { estado: "ANULADA" } }
);

// Compuesto sobre campo anidado: historial de un empleado ya ordenado.
db.auditoria_eventos.createIndex({ "usuario.empleado_id": 1, fecha_evento: -1 }, { name: "ix_auditoria_empleado_fecha" });

// Simple: recorrido de una sesion del marketplace.
db.logs_marketplace.createIndex({ sesion_id: 1 }, { name: "ix_logs_sesion" });

// --- Verificacion -------------------------------------------
// Totales esperados (incluyen el indice _id_ automatico):
//   ventas_historicas 5 | resenas 2 | auditoria_eventos 3 | logs_marketplace 3
db.getCollectionNames().sort().forEach(function (n) {
  print(n + ": " + db[n].getIndexes().map(function (i) { return i.name; }).join(", "));
});
