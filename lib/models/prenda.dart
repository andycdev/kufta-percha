  import 'dart:io';

  class Prenda {
    int id;
    File imagen;              // Ruta física en el dispositivo
    String nombre;
    String descripcion;
    String color;
    List<String> etiquetas;
    double estrellas;         // 0.0 a 5.0
    int vecesUsada;           // cuántas pintas la han usado
    String tipo;              // gorro / arriba / abajo / tillas

    Prenda({
      required this.id,
      required this.imagen,
      required this.nombre,
      required this.descripcion,
      required this.color, 
      required this.etiquetas,
      required this.estrellas,
      required this.vecesUsada,
      required this.tipo,
    });

    Map<String, dynamic> toMap() {
      return {
        "id": id,
        "imagen": imagen.path,
        "nombre": nombre,
        "descripcion": descripcion,
        "color": color,
        "etiquetas": etiquetas,
        "estrellas": estrellas,
        "vecesUsada": vecesUsada,
        "tipo": tipo,
      };
    }

    factory Prenda.fromMap(Map<String, dynamic> map) {
      return Prenda(
        id: map['id'],
        imagen: File(map["imagen"]),
        nombre: map["nombre"],
        descripcion: map["descripcion"],
        color: map["color"],
        etiquetas: List<String>.from(map["etiquetas"]),
        estrellas: map["estrellas"],
        vecesUsada: map["vecesUsada"],
        tipo: map["tipo"],
      );
    }
  }



