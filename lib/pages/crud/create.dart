import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:kufta_percha/models/categories.dart';
import 'package:kufta_percha/models/pinta.dart';
import 'package:kufta_percha/models/prenda.dart';
import 'package:kufta_percha/utils/notificaction.dart';
import 'package:kufta_percha/utils/responsive.dart';
import 'dart:io';

class Create extends StatelessWidget {
  final Pinta? existingPinta;
  final int? index;
  const Create({super.key, this.existingPinta, this.index});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: r.hp(1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.wp(2)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.chevron_back, size: r.dp(3)),
                      SizedBox(width: r.wp(2)),
                      Text(
                        existingPinta != null
                            ? "¿Qué le vamos a cambiar?"
                            : "Piensela pues..",
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                          fontSize: r.dp(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ImgBuilder(existingPinta: existingPinta, index: index, r: r),
            ],
          ),
        ),
      ),
    );
  }
}

class ImgBuilder extends StatefulWidget {
  final Pinta? existingPinta;
  final int? index;
  final Responsive r;
  const ImgBuilder({
    super.key,
    this.existingPinta,
    this.index,
    required this.r,
  });

  @override
  State<ImgBuilder> createState() => _ImgBuilderState();
}

class _ImgBuilderState extends State<ImgBuilder> {
  final Map<String, File?> _images = {};
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  List<DateTime> _fechasSeleccionadas = [];

  @override
  void initState() {
    super.initState();

    if (widget.existingPinta != null) {
      final p = widget.existingPinta!;
      _nombreController.text = p.nombre;
      _descripcionController.text = p.descripcion ?? "";
      _categoriaController.text = p.categoria ?? "";
      _fechasSeleccionadas = p.fechas ?? [];

      _images["Lo de arriba"] = p.arriba;
      _images["Lo de abajo"] = p.abajo;
      _images["Las tillas"] = p.zapatos;
      if (p.gorro != null) _images["Gorrita"] = p.gorro!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.hp(2), horizontal: r.wp(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPic(r, context, "Gorrita"),
          _buildPic(r, context, "Lo de arriba"),
          _buildPic(r, context, "Lo de abajo"),
          _buildPic(r, context, "Las tillas"),
          Padding(
            padding: EdgeInsets.symmetric(vertical: r.hp(1)),
            child: Divider(
              thickness: 1,
              color: Theme.of(context).colorScheme.primary.withAlpha(120),
            ),
          ),
          Container(
            width: r.wp(100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r.dp(2)),
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
            ),
            child: Column(
              children: [
                // GORRO (opcional)
                if (_images["Gorrita"] != null)
                  Padding(
                    padding: EdgeInsets.only(top: r.dp(1)),
                    child: Image.file(
                      _images["Gorrita"]!,
                      height: r.hp(10),
                      fit: BoxFit.contain,
                    ),
                  ),

                // ARRIBA
                if (_images["Lo de arriba"] != null)
                  Padding(
                    padding: EdgeInsets.only(top: r.dp(1)),
                    child: Image.file(
                      _images["Lo de arriba"]!,
                      height: r.hp(12),
                      fit: BoxFit.contain,
                    ),
                  ),

                // ABAJO
                if (_images["Lo de abajo"] != null)
                  Padding(
                    padding: EdgeInsets.only(top: r.dp(1)),
                    child: Image.file(
                      _images["Lo de abajo"]!,
                      height: r.hp(12),
                      fit: BoxFit.contain,
                    ),
                  ),

                // ZAPATOS
                if (_images["Las tillas"] != null)
                  Padding(
                    padding: EdgeInsets.only(top: r.dp(1)),
                    child: Image.file(
                      _images["Las tillas"]!,
                      height: r.hp(10),
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: r.hp(3)),
            child: Divider(
              thickness: 1,
              color: Theme.of(context).colorScheme.primary.withAlpha(120),
            ),
          ),
          _buildForm(r, "Nombre de la pinta", _nombreController),
          _buildForm(
            r,
            "¿Algo que decir de la percha?",
            _descripcionController,
          ),
          _buildForm(r, "¿Pa' dónde es la vuelta?", _categoriaController),

          Padding(
            padding: EdgeInsets.symmetric(vertical: r.hp(2)),
            child: Text(
              "¿Para cuando lo vamos a usar mor? (Opcional)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: r.dp(2)),
            ),
          ),
          GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Container(
              width: r.wp(100),
              padding: EdgeInsets.all(r.dp(1)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(r.dp(2)),
                color: Theme.of(context).colorScheme.primary.withAlpha(200),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Agregar la fecha",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: r.dp(1.6),
                    ),
                  ),
                  SizedBox(width: r.wp(2)),
                  Icon(
                    CupertinoIcons.calendar,
                    size: r.dp(3),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (_fechasSeleccionadas.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: r.hp(1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (() {
                  final fechasOrdenadas = [..._fechasSeleccionadas]
                    ..sort((a, b) => a.compareTo(b));

                  return fechasOrdenadas.map((f) {
                    final fechaFormateada = DateFormat(
                      "d 'de' MMMM 'de' y",
                      "es_ES",
                    ).format(f);

                    return Padding(
                      padding: EdgeInsets.only(bottom: r.hp(0.5)),
                      child: Container(
                        padding: EdgeInsets.all(r.dp(1)),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(r.dp(1.5)),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fechaFormateada,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: r.dp(1.7),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _fechasSeleccionadas.remove(f);
                                });
                              },
                              child: Icon(
                                CupertinoIcons.trash,
                                size: r.dp(2.5),
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList();
                })(),
              ),
            ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: r.hp(1)),
            child: Divider(
              thickness: 1,
              color: Theme.of(context).colorScheme.primary.withAlpha(120),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _guardarPinta,
              child: Container(
                padding: EdgeInsets.all(r.dp(1)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r.dp(2)),
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: Text(
                  widget.index != null ? "Editar la pinta" : "Subir la pinta",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: r.dp(1.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    // Filtramos las categorías quitando "Todas"
    final filtered = categories
        .where((c) => c.name != "Todas" && c.name != "Favoritos")
        .toList();

    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(100),
                border: Border(
                  top: BorderSide(color: Colors.white.withAlpha(100)),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: filtered.indexWhere(
                          (c) => c.name == _categoriaController.text,
                        ),
                      ),
                      selectionOverlay: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(150),
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          _categoriaController.text = filtered[index].name;
                        });
                      },
                      children: filtered
                          .map(
                            (c) => Center(
                              child: Text(
                                c.name,
                                style: TextStyle(
                                  fontSize: widget.r.dp(1.9),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  CupertinoButton(
                    child: Text(
                      "Cerrar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDatePicker(BuildContext context) {
    final now = DateTime.now();

    // Fecha mínima: hoy (pero si hoy es 2024, arranca en 2025)
    final minimo = now.year < 2025
        ? DateTime(2025, now.month, now.day)
        : DateTime(now.year, now.month, now.day);

    // Máximo permitido: fin del 2027
    final fin = DateTime(2027, 12, 31);

    DateTime tempDate = minimo;

    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 350,
              padding: const EdgeInsets.only(top: 10),
              color: Theme.of(context).colorScheme.primary.withAlpha(100),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: Brightness
                            .dark, // Fuerza que los textos sí usen el estilo
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        minimumDate: minimo,
                        maximumDate: fin,
                        initialDateTime: minimo,
                        onDateTimeChanged: (DateTime newDate) {
                          tempDate = newDate;
                        },
                      ),
                    ),
                  ),

                  CupertinoButton(
                    child: const Text(
                      "Pintarla pa' esa fecha",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "ComicNeue",
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _fechasSeleccionadas.add(tempDate);
                      });
                      Navigator.pop(context);
                    },
                  ),

                  CupertinoButton(
                    child: const Text(
                      "Volver",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "ComicNeue",
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Padding _buildForm(
    Responsive r,
    String title,
    TextEditingController? controller,
  ) {
    final isCategoryField = title == "¿Pa' dónde es la vuelta?";

    if (isCategoryField) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => _showCategoryPicker(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: title,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.dp(2)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r.dp(2)),
          ),
        ),
        maxLines: 1,
      ),
    );
  }

  Padding _buildPic(Responsive r, BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.hp(2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: r.dp(2)),
          ),
          GestureDetector(
            onTap: () async {
              _abrirGaleriaKufta(context, title);
            },
            child: Container(
              height: r.hp(16),
              width: r.wp(100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(r.dp(2)),
                border: Border.all(color: Colors.white60, width: 1.5),
                color: Theme.of(context).colorScheme.primary.withAlpha(100),
              ),
              child: _images[title] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(r.dp(2)),
                      child: Image.file(
                        _images[title]!,
                        fit: BoxFit.cover,
                        width: r.wp(100),
                        height: r.hp(16),
                      ),
                    )
                  : Icon(
                      CupertinoIcons.camera_circle_fill,
                      size: r.dp(6),
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirGaleriaKufta(BuildContext context, String tipo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _GaleriaKuftaModal(
          tipo: _mapTituloATipo(tipo), // convierte "Gorrita" -> "gorro"
          onPrendaSeleccionada: (File imagen) {
            setState(() {
              _images[tipo] = imagen;
            });
          },
        );
      },
    );
  }

  String _mapTituloATipo(String titulo) {
    switch (titulo) {
      case "Gorrita":
        return "gorro";
      case "Lo de arriba":
        return "arriba";
      case "Lo de abajo":
        return "abajo";
      case "Las tillas":
        return "tillas";
      default:
        return titulo.toLowerCase();
    }
  }

  void _incrementarUso(File imagen) {
    final box = Hive.box('prendasBox');
    final path = imagen.path;

    for (var key in box.keys) {
      final map = Map<String, dynamic>.from(box.get(key));

      final prenda = Prenda.fromMap(map);

      if (prenda.imagen.path == path) {
        prenda.vecesUsada = (prenda.vecesUsada) + 1;
        box.put(key, prenda.toMap());
        break;
      }
    }
  }

  void _guardarPinta() async {
    // Validar imágenes obligatorias
    if (_images['Lo de arriba'] == null ||
        _images['Lo de abajo'] == null ||
        _images['Las tillas'] == null) {
      _mostrarError("Debes completar arriba, abajo y zapatos");
      return;
    }

    // Validar campos obligatorios
    if (_nombreController.text.trim().isEmpty ||
        _categoriaController.text.trim().isEmpty) {
      _mostrarError(
        "Debes completar el nombre de la pinta y hacia dónde es la vuelta",
      );
      return;
    }

    final arribaFile = _images['Lo de arriba']!;
    final abajoFile = _images['Lo de abajo']!;
    final zapatosFile = _images['Las tillas']!;
    final gorroFile = _images['Gorrita'];

    final pinta = Pinta(
      arriba: arribaFile,
      abajo: abajoFile,
      zapatos: zapatosFile,
      gorro: gorroFile,
      nombre: _nombreController.text,
      descripcion: _descripcionController.text.isEmpty
          ? null
          : _descripcionController.text,
      categoria: _categoriaController.text.isEmpty
          ? null
          : _categoriaController.text,
      fechas: _fechasSeleccionadas,
    );

    final box = await Hive.openBox('pintasBox');

    if (widget.index != null) {
      // EDITAR
      await box.putAt(widget.index!, pinta.toMap());
    } else {
      // CREAR
      await box.add(pinta.toMap());
    }
    _incrementarUso(arribaFile);
    _incrementarUso(abajoFile);
    _incrementarUso(zapatosFile);
    if (gorroFile != null) _incrementarUso(gorroFile);

    // Tu código actual de notificaciones programadas
    await mostrarNotificacionSoloUnaVez();
    if (pinta.fechas != null) {
      for (final f in pinta.fechas!) {
        await programarNotificacionPinta(pinta, f);
      }
    }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(
          widget.index != null ? "Actualizado" : "¡Listo!",
          style: TextStyle(fontFamily: "ComicNeue"),
        ),
        content: Text(
          widget.index != null
              ? "La pinta ha sido actualizada"
              : "La pinta ha sido guardada",
          style: TextStyle(fontFamily: "ComicNeue"),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Ok", style: TextStyle(fontFamily: "ComicNeue")),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String mensaje) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Error", style: TextStyle(fontFamily: "ComicNeue")),
        content: Text(mensaje, style: TextStyle(fontFamily: "ComicNeue")),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text("Ok"),
          ),
        ],
      ),
    );
  }
}

class _GaleriaKuftaModal extends StatelessWidget {
  final String tipo;
  final Function(File) onPrendaSeleccionada;

  const _GaleriaKuftaModal({
    required this.tipo,
    required this.onPrendaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    List<Prenda> obtenerPrendasPorTipo(String tipo) {
      final box = Hive.box('prendasBox');
      return box.values
          .map((map) => Prenda.fromMap(Map<String, dynamic>.from(map)))
          .where((p) => p.tipo == tipo && p.imagen.existsSync())
          .toList();
    }

    final prendas = obtenerPrendasPorTipo(tipo);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(100),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Galería Kufta",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: GridView.builder(
                      controller: controller,
                      itemCount: prendas.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemBuilder: (_, index) {
                        final prenda = prendas[index];
                        return GestureDetector(
                          onTap: () {
                            onPrendaSeleccionada(prenda.imagen);
                            Navigator.pop(context);
                          },

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(prenda.imagen, fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
