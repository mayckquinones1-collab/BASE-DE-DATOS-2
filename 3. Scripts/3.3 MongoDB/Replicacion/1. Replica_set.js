// ============================================================
// Proyecto FarmaBarrio - Replicacion asincronica de MongoDB
// Replica set rs0: 1 nodo primario y 2 secundarios en Docker
// ============================================================
// Cada nodo escucha en el puerto 27017 dentro de su contenedor.
// En el equipo anfitrion se publican como 27018, 27019 y 27020.
//
// Ejecutar desde PowerShell contra el primer nodo:
//   docker exec mongo_rs1 mongosh --quiet --file /ruta/1._Replica_set.js

// 1) Iniciar el conjunto de replicas
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo-rs1:27017" },
    { _id: 1, host: "mongo-rs2:27017" },
    { _id: 2, host: "mongo-rs3:27017" }
  ]
});

// 2) Esperar a que se elija el primario y mostrar los roles
sleep(15000);
print(rs.status().members.map(function (m) { return m.name + " " + m.stateStr; }).join(", "));

// Resultado esperado:
//   mongo-rs1:27017 PRIMARY, mongo-rs2:27017 SECONDARY, mongo-rs3:27017 SECONDARY
