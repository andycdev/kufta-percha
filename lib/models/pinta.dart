import 'dart:io';
class Pinta {
  final File arriba;
  final File abajo;
  final File zapatos;
  final String nombre;

  final File? chaqueta;
  final File? gorro;
  final String? descripcion;
  final String? categoria;

  // AHORA: varias fechas opcionales
  final List<DateTime>? fechas;
  bool favorito;

  Pinta({
    required this.arriba,
    required this.abajo,
    required this.zapatos,
    required this.nombre,
    this.chaqueta,
    this.gorro,
    this.descripcion,
    this.categoria,
    this.fechas,
    this.favorito = false,
  });

  Map<String, dynamic> toMap() => {
    'arriba': arriba.path,
    'abajo': abajo.path,
    'zapatos': zapatos.path,
    'nombre': nombre,
    'chaqueta': chaqueta?.path,
    'gorro': gorro?.path,
    'descripcion': descripcion,
    'categoria': categoria,

    // Convertir lista → list<int> (timestamps)
    'fechas': fechas?.map((f) => f.millisecondsSinceEpoch).toList(),
    'favorito': favorito ? 1 : 0,
  };

  factory Pinta.fromMap(Map<String, dynamic> map) => Pinta(
    arriba: File(map['arriba']),
    abajo: File(map['abajo']),
    zapatos: File(map['zapatos']),
    nombre: map['nombre'],
    chaqueta: map['chaqueta'] != null ? File(map['chaqueta']) : null,
    gorro: map['gorro'] != null ? File(map['gorro']) : null,
    descripcion: map['descripcion'],
    categoria: map['categoria'],

    // Convertir list<int> → list<DateTime>
    fechas: map['fechas'] != null
        ? (map['fechas'] as List)
              .map((ts) => DateTime.fromMillisecondsSinceEpoch(ts))
              .toList()
        : null,
    favorito: map['favorito'] == 1,
  );
}


