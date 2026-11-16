// ============================================================
// Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
// Motor: MongoDB 9.0.4   Base: farmabarrio_mongo
// 6. Carga de datos
// Ejecutar con: mongosh "mongodb://localhost:27017/farmabarrio_mongo" --file "<archivo>"
// Con autenticacion activa, agregar: -u <usuario> -p --authenticationDatabase admin
// ============================================================

// El volumen de datos del proyecto (10376 documentos) no se genera con un script
// de insercion: se carga desde el respaldo logico incluido en la carpeta 4. Backups.
//
// Totales esperados por coleccion:
//   ventas_historicas  5000
//   resenas             500
//   auditoria_eventos   688
//   logs_marketplace   4188
//   -------------------------
//   TOTAL             10376
//
// Carga desde el respaldo (ejecutar en PowerShell, no en mongosh):
//
//   mongorestore --uri="mongodb://localhost:27017" ^
//     --dir="..\4. Backups\mongo\ciclo_final_2026-11-11" ^
//     --nsFrom="farmabarrio_mongo.*" --nsTo="farmabarrio_mongo.*" --drop
//
// Con autenticacion activa agregar:
//   --username respaldo_farma --authenticationDatabase admin -p

use farmabarrio_mongo;

// --- Verificacion del volumen cargado -----------------------
var total = 0;
db.getCollectionNames().sort().forEach(function (n) {
  var c = db[n].countDocuments();
  total += c;
  print(n + ": " + c + " documentos");
});
print("TOTAL: " + total + " documentos");
