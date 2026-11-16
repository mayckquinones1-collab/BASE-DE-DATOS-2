// ============================================================
// Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
// Motor: MongoDB 9.0.4   Base: farmabarrio_mongo
// 5. Usuarios y roles
// Ejecutar con: mongosh "mongodb://localhost:27017/farmabarrio_mongo" --file "<archivo>"
// Con autenticacion activa, agregar: -u <usuario> -p --authenticationDatabase admin
// ============================================================

// IMPORTANTE: ninguna contrasena figura en este script.
// passwordPrompt() hace que mongosh la pida por teclado al ejecutarse.
// Los usuarios se crean en la base 'admin', que es donde MongoDB guarda las credenciales.

use admin;

// 1) Administrador del servidor. Rol root: control total sobre todas las bases.
db.createUser({
  user: "admin_farma",
  pwd: passwordPrompt(),
  roles: [ { role: "root", db: "admin" } ]
});

// 2) Cuenta de respaldo. Roles backup y restore: leer todo y escribir al restaurar.
db.createUser({
  user: "respaldo_farma",
  pwd: passwordPrompt(),
  roles: [ { role: "backup", db: "admin" }, { role: "restore", db: "admin" } ]
});

// 3) Cuenta de consulta. Solo lectura sobre farmabarrio_mongo.
db.createUser({
  user: "consulta_farma",
  pwd: passwordPrompt(),
  roles: [ { role: "read", db: "farmabarrio_mongo" } ]
});

// 4) Cuenta de operacion. Lectura y escritura sobre farmabarrio_mongo.
db.createUser({
  user: "operacion_farma",
  pwd: passwordPrompt(),
  roles: [ { role: "readWrite", db: "farmabarrio_mongo" } ]
});

// --- Verificacion -------------------------------------------
db.getUsers().users.forEach(function (u) {
  print(u.user + "  ->  " + u.roles.map(function (r) { return r.role + "@" + r.db; }).join(", "));
});

// Para activar la autenticacion hay que arrancar mongod con --auth
// (o security.authorization: enabled en mongod.cfg) y reiniciar el servicio.
