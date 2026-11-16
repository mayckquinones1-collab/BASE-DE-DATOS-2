// ============================================================
// Proyecto FarmaBarrio - Base de Datos II - UTP - Ciclo 2026-2
// Motor: MongoDB 9.0.4   Base: farmabarrio_mongo
// 2. Creacion de las colecciones con sus validadores $jsonSchema
// Ejecutar con: mongosh "mongodb://localhost:27017/farmabarrio_mongo" --file "<archivo>"
// Con autenticacion activa, agregar: -u <usuario> -p --authenticationDatabase admin
// ============================================================

use farmabarrio_mongo;

// Las cuatro colecciones se crean con un validador $jsonSchema en nivel 'strict'
// y accion 'error': MongoDB rechaza cualquier documento que no cumpla el esquema.

// ------------------------------------------------------------
// Coleccion: ventas_historicas
// ------------------------------------------------------------
db.createCollection("ventas_historicas", {
  validator: {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "venta_id",
        "codigo_venta",
        "farmacia_id",
        "cliente_id",
        "fecha_venta",
        "estado",
        "totales",
        "items"
      ],
      "properties": {
        "venta_id": {
          "bsonType": "number"
        },
        "codigo_venta": {
          "bsonType": "string"
        },
        "farmacia_id": {
          "bsonType": "number"
        },
        "farmacia_nombre": {
          "bsonType": "string"
        },
        "cliente_id": {
          "bsonType": "number"
        },
        "empleado_id": {
          "bsonType": "number"
        },
        "fecha_venta": {
          "bsonType": "date"
        },
        "metodo_pago": {
          "bsonType": "string",
          "enum": [
            "EFECTIVO",
            "TARJETA",
            "YAPE",
            "PLIN"
          ]
        },
        "estado": {
          "bsonType": "string",
          "enum": [
            "COMPLETADA",
            "ANULADA",
            "PENDIENTE"
          ]
        },
        "totales": {
          "bsonType": "object",
          "required": [
            "subtotal",
            "igv",
            "total"
          ],
          "properties": {
            "subtotal": {
              "bsonType": "number",
              "minimum": 0
            },
            "igv": {
              "bsonType": "number",
              "minimum": 0
            },
            "total": {
              "bsonType": "number",
              "minimum": 0
            }
          }
        },
        "items": {
          "bsonType": "array",
          "minItems": 1,
          "items": {
            "bsonType": "object",
            "required": [
              "medicamento_id",
              "nombre",
              "cantidad",
              "precio_unitario"
            ],
            "properties": {
              "medicamento_id": {
                "bsonType": "number"
              },
              "nombre": {
                "bsonType": "string"
              },
              "cantidad": {
                "bsonType": "number",
                "minimum": 1
              },
              "precio_unitario": {
                "bsonType": "number",
                "minimum": 0
              },
              "descuento": {
                "bsonType": "number",
                "minimum": 0
              },
              "subtotal": {
                "bsonType": "number",
                "minimum": 0
              }
            }
          }
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// ------------------------------------------------------------
// Coleccion: resenas
// ------------------------------------------------------------
db.createCollection("resenas", {
  validator: {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "resena_id",
        "venta_id",
        "cliente",
        "farmacia",
        "medicamento",
        "calificacion",
        "comentario",
        "compra_verificada",
        "votos_util",
        "fecha_resena"
      ],
      "properties": {
        "resena_id": {
          "bsonType": "number"
        },
        "venta_id": {
          "bsonType": "number"
        },
        "cliente": {
          "bsonType": "object",
          "required": [
            "cliente_id",
            "nombre"
          ],
          "properties": {
            "cliente_id": {
              "bsonType": "number"
            },
            "nombre": {
              "bsonType": "string"
            }
          }
        },
        "farmacia": {
          "bsonType": "object",
          "required": [
            "farmacia_id",
            "nombre"
          ],
          "properties": {
            "farmacia_id": {
              "bsonType": "number"
            },
            "nombre": {
              "bsonType": "string"
            }
          }
        },
        "medicamento": {
          "bsonType": "object",
          "required": [
            "medicamento_id",
            "nombre"
          ],
          "properties": {
            "medicamento_id": {
              "bsonType": "number"
            },
            "nombre": {
              "bsonType": "string"
            }
          }
        },
        "calificacion": {
          "bsonType": "number",
          "minimum": 1,
          "maximum": 5
        },
        "comentario": {
          "bsonType": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "compra_verificada": {
          "bsonType": "bool"
        },
        "votos_util": {
          "bsonType": "number",
          "minimum": 0
        },
        "fecha_resena": {
          "bsonType": "date"
        },
        "origen": {
          "bsonType": "string",
          "enum": [
            "real",
            "derivado",
            "simulado"
          ]
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// ------------------------------------------------------------
// Coleccion: auditoria_eventos
// ------------------------------------------------------------
db.createCollection("auditoria_eventos", {
  validator: {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "evento_id",
        "fecha_evento",
        "tipo_evento",
        "accion",
        "entidad",
        "usuario",
        "detalle",
        "origen_motor",
        "origen"
      ],
      "properties": {
        "evento_id": {
          "bsonType": "number"
        },
        "fecha_evento": {
          "bsonType": "date"
        },
        "tipo_evento": {
          "bsonType": "string",
          "enum": [
            "VENTA_ANULADA",
            "MOVIMIENTO_INVENTARIO",
            "PRECIO_ACTUALIZADO"
          ]
        },
        "accion": {
          "bsonType": "string",
          "enum": [
            "INSERTAR",
            "ACTUALIZAR",
            "ANULAR"
          ]
        },
        "entidad": {
          "bsonType": "object",
          "required": [
            "tabla",
            "id"
          ],
          "properties": {
            "tabla": {
              "bsonType": "string"
            },
            "id": {
              "bsonType": "number"
            },
            "codigo": {
              "bsonType": "string"
            }
          }
        },
        "usuario": {
          "bsonType": "object",
          "required": [
            "tipo",
            "nombre"
          ],
          "properties": {
            "tipo": {
              "bsonType": "string",
              "enum": [
                "empleado",
                "sistema"
              ]
            },
            "empleado_id": {
              "bsonType": "number"
            },
            "nombre": {
              "bsonType": "string"
            },
            "cargo": {
              "bsonType": "string"
            }
          }
        },
        "farmacia": {
          "bsonType": "object",
          "required": [
            "farmacia_id",
            "nombre"
          ],
          "properties": {
            "farmacia_id": {
              "bsonType": "number"
            },
            "nombre": {
              "bsonType": "string"
            }
          }
        },
        "detalle": {
          "bsonType": "object"
        },
        "origen_motor": {
          "bsonType": "string",
          "enum": [
            "postgresql",
            "oracle"
          ]
        },
        "origen": {
          "bsonType": "string",
          "enum": [
            "real",
            "derivado",
            "simulado"
          ]
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// ------------------------------------------------------------
// Coleccion: logs_marketplace
// ------------------------------------------------------------
db.createCollection("logs_marketplace", {
  validator: {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "log_id",
        "fecha_log",
        "nivel",
        "evento",
        "sesion_id",
        "cliente_id",
        "dispositivo",
        "origen",
        "expira_en"
      ],
      "properties": {
        "log_id": {
          "bsonType": "number"
        },
        "fecha_log": {
          "bsonType": "date"
        },
        "nivel": {
          "bsonType": "string",
          "enum": [
            "INFO",
            "WARN",
            "ERROR"
          ]
        },
        "evento": {
          "bsonType": "string",
          "enum": [
            "BUSQUEDA",
            "VER_MEDICAMENTO",
            "AGREGAR_CARRITO",
            "PEDIDO_CREADO",
            "PEDIDO_FALLIDO",
            "ERROR_APP"
          ]
        },
        "sesion_id": {
          "bsonType": "string"
        },
        "cliente_id": {
          "bsonType": [
            "number",
            "null"
          ]
        },
        "dispositivo": {
          "bsonType": "string",
          "enum": [
            "ANDROID",
            "IOS",
            "WEB"
          ]
        },
        "farmacia_id": {
          "bsonType": "number"
        },
        "medicamento_id": {
          "bsonType": "number"
        },
        "venta_id": {
          "bsonType": "number"
        },
        "detalle": {
          "bsonType": "object"
        },
        "latencia_ms": {
          "bsonType": "number",
          "minimum": 0
        },
        "origen": {
          "bsonType": "string",
          "enum": [
            "real",
            "derivado",
            "simulado"
          ]
        },
        "expira_en": {
          "bsonType": "date"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

print("Colecciones creadas: " + db.getCollectionNames().sort().join(", "));
