# ============================================================
# Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
# Motor: MongoDB   Respaldo logico y prueba de restauracion
# Ejecutar en PowerShell 5.1
# ============================================================
# Con la autenticacion activa, todos los comandos requieren la cuenta de
# respaldo: --username respaldo_farma --authenticationDatabase admin -p
# La clave se escribe en el prompt; nunca va en el script.

$destino = "F:\backup_mongo\ciclo_final_2026-11-11"

# 1. Respaldo completo de la base de trabajo
mongodump --uri="mongodb://localhost:27017/farmabarrio_mongo" --out="$destino"

# 2. Verificacion de los archivos generados
dir "$destino\farmabarrio_mongo"

# 3. Restauracion sobre una base de prueba, nunca sobre la de trabajo
mongorestore --uri="mongodb://localhost:27017" --dir="$destino" `
  --nsFrom="farmabarrio_mongo.*" --nsTo="farmabarrio_mongo_prueba.*" --drop

# 4. Simulacion de perdida: se borra la base de prueba
mongosh "mongodb://localhost:27017/farmabarrio_mongo_prueba" --quiet --eval "print('ANTES DEL BORRADO:', db.getCollectionNames().join(', '))"
mongosh "mongodb://localhost:27017/farmabarrio_mongo_prueba" --quiet --eval "db.dropDatabase()"
mongosh "mongodb://localhost:27017/farmabarrio_mongo_prueba" --quiet --eval "print('DESPUES DEL BORRADO: colecciones =', db.getCollectionNames().length)"
mongosh "mongodb://localhost:27017" --quiet --eval "db.adminCommand({listDatabases: 1}).databases.forEach(d => print(d.name))"

# 5. Recuperacion: mismo comando del paso 3
mongorestore --uri="mongodb://localhost:27017" --dir="$destino" `
  --nsFrom="farmabarrio_mongo.*" --nsTo="farmabarrio_mongo_prueba.*" --drop

# 6. Verificacion de conteos e indices en ambas bases
# Resultado esperado e identico en las dos:
#   ventas_historicas 5000 / 5 indices   resenas 500 / 2
#   auditoria_eventos  688 / 3 indices   logs_marketplace 4188 / 3
mongosh "mongodb://localhost:27017/farmabarrio_mongo_prueba" --quiet --eval "db.getCollectionNames().forEach(n => print(n, db[n].countDocuments(), db[n].getIndexes().length))"
mongosh "mongodb://localhost:27017/farmabarrio_mongo" --quiet --eval "db.getCollectionNames().forEach(n => print(n, db[n].countDocuments(), db[n].getIndexes().length))"
