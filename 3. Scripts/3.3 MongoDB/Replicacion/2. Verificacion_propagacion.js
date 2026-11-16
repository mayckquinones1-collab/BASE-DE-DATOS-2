// ============================================================
// Proyecto FarmaBarrio - Verificacion de la replicacion
// ============================================================
// Comprueba que lo escrito en el primario llega a un secundario
// mediante el oplog, de forma asincronica.

// --- En el PRIMARIO: conteos de la base replicada ------------
db.getSiblingDB("farmabarrio_mongo").getCollectionNames().sort().forEach(function (n) {
  var d = db.getSiblingDB("farmabarrio_mongo")[n];
  print(n + " docs=" + d.countDocuments() + " indices=" + d.getIndexes().length);
});
// Esperado: ventas_historicas 5000/5, resenas 500/2,
//           auditoria_eventos 688/3, logs_marketplace 4188/3  (total 10376)

// --- En el PRIMARIO: insertar un documento de prueba ---------
db.getSiblingDB("farmabarrio_mongo").prueba_replicacion.insertOne({
  mensaje: "prueba de propagacion",
  fecha: new Date()
});

// --- En el SECUNDARIO: leer el documento ---------------------
// Ejecutar contra mongo_rs2. setReadPref permite leer de un secundario.
db.getMongo().setReadPref("secondary");
printjson(db.getSiblingDB("farmabarrio_mongo").prueba_replicacion.find({}, { _id: 0 }).toArray());

// Si el documento aparece, la replicacion funciona.
