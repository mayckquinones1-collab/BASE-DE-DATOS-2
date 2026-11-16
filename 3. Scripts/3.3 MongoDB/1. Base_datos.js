// ============================================================
// Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
// Motor: MongoDB 9.0.4   Base: farmabarrio_mongo
// 1. Creacion de la base de datos
// Ejecutar con: mongosh "mongodb://localhost:27017/farmabarrio_mongo" --file "<archivo>"
// Con autenticacion activa, agregar: -u <usuario> -p --authenticationDatabase admin
// ============================================================

// MongoDB crea la base de forma implicita al insertar el primer documento.
// Esta instruccion la selecciona como base de trabajo.
use farmabarrio_mongo;

// Comprobacion
print("Base seleccionada: " + db.getName());
