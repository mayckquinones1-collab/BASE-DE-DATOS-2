-- ============================================================
-- Proyecto FarmaBarrio - Prueba de tolerancia a fallos
-- ============================================================
-- Demuestra que el clúster sigue aceptando escrituras con un nodo
-- apagado, y que ese nodo recibe el dato al volver.
--
-- Los pasos marcados [PowerShell] se ejecutan fuera de cqlsh.

-- 1) Con los tres nodos arriba, insertar la primera fila.
INSERT INTO laboratorio_rf3.prueba (id, mensaje) VALUES (1, 'con los tres nodos arriba');

-- 2) [PowerShell] Apagar el segundo nodo:
--      docker stop cassandra-node2
--      docker exec cassandra-node1 nodetool status
--    Esperado: cassandra-node2 aparece como DN (Down/Normal).

-- 3) Con un nodo caido, insertar la segunda fila con consistencia ONE.
--    Basta con que responda una replica, asi que la escritura se acepta.
CONSISTENCY ONE;
INSERT INTO laboratorio_rf3.prueba (id, mensaje) VALUES (2, 'con node2 apagado');
SELECT * FROM laboratorio_rf3.prueba;
-- Esperado: 2 filas.

-- 4) [PowerShell] Volver a encender el nodo y esperar a que se reincorpore:
--      docker start cassandra-node2
--      Start-Sleep -Seconds 90
--      docker exec cassandra-node1 nodetool status
--    Esperado: los tres nodos como UN.

-- 5) Consultar desde el nodo que estuvo apagado.
--    [PowerShell] docker exec -it cassandra-node2 cqlsh -u farma_consulta
SELECT * FROM laboratorio_rf3.prueba;
-- Esperado: las mismas 2 filas. El nodo recibio el dato que se escribio
-- mientras estaba apagado, lo que confirma la propagacion entre replicas.
