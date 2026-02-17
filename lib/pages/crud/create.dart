import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:kufta_percha/models/categories.dart';
import 'package:kufta_percha/models/pinta.dart';
import 'package:kufta_percha/models/prenda.dart';
import 'package:kufta_percha/utils/responsive.dart';
import 'dart:io';

import 'package:material_symbols_icons/symbols.dart';

class Create extends StatefulWidget {
  final Pinta? existingPinta;
  final int? index;
  const Create({super.key, this.index, this.existingPinta});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final Map<String, File?> images = {};

  @override
  void initState() {
    super.initState();

    if (widget.existingPinta != null) {
      final p = widget.existingPinta!;

      images["arriba"] = p.arriba;
      images["abajo"] = p.abajo;
      images["tillas"] = p.zapatos;

      if (p.gorro != null) images["gorro"] = p.gorro!;
      if (p.chaqueta != null) images["chaqueta"] = p.chaqueta!;
    }
  }

  void _updateImage(String tipo, File? file) {
    setState(() {
      images[tipo] = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          StartSliverCreate(r: r, existingPinta: widget.existingPinta),
          RowWithClothesSliver(
            r: r,
            images: images,
            onImageSelected: _updateImage,
          ),
          SliverBoxWithPinta(images: images, r: r),
          AboutSliver(
            r: r,
            images: images,
            index: widget.index,
            existingPinta: widget.existingPinta,
          ),
        ],
      ),
    );
  }
}

class StartSliverCreate extends StatelessWidget {
  final Pinta? existingPinta;
  const StartSliverCreate({
    super.key,
    required this.r,
    required this.existingPinta,
  });

  final Responsive r;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: r.hp(4),
          bottom: r.hp(2),
          left: r.wp(5),
          right: r.wp(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 225, 225, 225)
                      : Theme.of(context).colorScheme.primary.withAlpha(200),
                ),
                foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.dp(2)),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back, size: r.dp(3)),
            ),
            SizedBox(width: r.wp(5)),
            Text(
              existingPinta != null ? "¿Qué cambiamos?" : "Piensela pues..",
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
                fontSize: r.dp(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RowWithClothesSliver extends StatefulWidget {
  const RowWithClothesSliver({
    super.key,
    required this.r,
    required this.images,
    required this.onImageSelected,
  });
  final Responsive r;
  final Map<String, File?> images;
  final Function(String, File?) onImageSelected;

  @override
  State<RowWithClothesSliver> createState() => _RowWithClothesSliverState();
}

class _RowWithClothesSliverState extends State<RowWithClothesSliver> {
  String _mapTituloATipo(String title) {
    switch (title) {
      case "Gorrito":
        return "gorro";
      case "Chaqueta":
        return "chaqueta";
      case "Arriba":
        return "arriba";
      case "Abajo":
        return "abajo";
      case "Tillas":
        return "tillas";
      default:
        return title.toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummyClothes = [
      {
        "name": "Gorrito",
        "tipoInterno": "gorro",
        "img": null,
        "icon": Symbols.child_hat_rounded,
      },
      {
        "name": "Chaqueta",
        "tipoInterno": "chaqueta",
        "img": null,
        "icon": Symbols.checkroom_rounded,
      },
      {
        "name": "Arriba",
        "tipoInterno": "arriba",
        "img": null,
        "icon": Symbols.apparel_rounded,
      },
      {
        "name": "Abajo",
        "tipoInterno": "abajo",
        "img": null,
        "icon": Symbols.styler_rounded,
      },
      {
        "name": "Tillas",
        "tipoInterno": "tillas",
        "img": null,
        "icon": Symbols.steps_rounded,
      },
    ];

    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(dummyClothes.length, (int index) {
            final item = dummyClothes[index];
            final imagen = widget.images[item['tipoInterno']];

            return GestureDetector(
              onTap: () {
                _abrirGaleriaKufta(context, dummyClothes[index]['tipoInterno']);
              },
              child: Container(
                width: widget.r.wp(50),
                height: widget.r.hp(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.r.dp(2)),
                  color: Theme.of(context).colorScheme.primary.withAlpha(50),
                  border: BoxBorder.all(color: Colors.white60, width: 1.5),
                ),
                margin: EdgeInsets.only(
                  left: index == 0 ? widget.r.wp(5) : widget.r.wp(4),
                  right: index == dummyClothes.length - 1 ? widget.r.wp(5) : 0,
                ),
                child: imagen != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(widget.r.dp(2)),
                        child: Image.file(
                          imagen,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              dummyClothes[index]['icon'],
                              size: widget.r.dp(10),
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(150),
                            ),
                            Text(
                              dummyClothes[index]['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(150),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<List<Prenda>> _obtenerPrendasAsync(String tipo) async {
    final box = Hive.box('prendasBox');

    return box.values
        .map((map) => Prenda.fromMap(Map<String, dynamic>.from(map)))
        .where((p) => p.tipo == tipo)
        .toList();
  }

  void _abrirGaleriaKufta(BuildContext context, String tipoVisual) {
    final tipo = _mapTituloATipo(tipoVisual);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FutureBuilder<List<Prenda>>(
          future: _obtenerPrendasAsync(tipo),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final prendas = snapshot.data!;

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
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(100),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
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
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (widget.images[tipo] != null &&
                              (tipo == "gorro" || tipo == "chaqueta"))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.withAlpha(
                                    200,
                                  ),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    widget.onImageSelected(tipo, null);
                                  });
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                label: const Text(
                                  "Quitar prenda",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

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
                                    setState(() {
                                      widget.onImageSelected(
                                        tipo,
                                        prenda.imagen,
                                      );
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      prenda.imagen,
                                      fit: BoxFit.cover,
                                    ),
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
          },
        );
      },
    );
  }
}

class SliverBoxWithPinta extends StatefulWidget {
  final Map<String, File?> images;
  final Responsive r;

  const SliverBoxWithPinta({super.key, required this.images, required this.r});

  @override
  State<SliverBoxWithPinta> createState() => _SliverBoxWithPintaState();
}

class _SliverBoxWithPintaState extends State<SliverBoxWithPinta>
    with TickerProviderStateMixin {
  bool expanded = false;

  void toggle() {
    setState(() {
      expanded = !expanded;
    });
  }

  Widget _buildCloth(String key) {
    final file = widget.images[key];
    if (file == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(widget.r.dp(1)),
        child: Image.file(file, width: widget.r.wp(30), fit: BoxFit.contain),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.r.wp(5),
          vertical: widget.r.hp(2),
        ),
        child: Container(
          width: widget.r.wp(100),
          padding: EdgeInsets.symmetric(
            vertical: widget.r.hp(1.5),
            horizontal: widget.r.wp(4),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).colorScheme.primary.withAlpha(80),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔘 HEADER (siempre arriba, nunca animado)
              GestureDetector(
                onTap: toggle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ver pinta",
                      style: TextStyle(
                        fontSize: widget.r.dp(2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),

              /// 🔥 SOLO esta parte se anima
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter, // 🔥 clave
                child: expanded
                    ? Column(
                        children: [
                          SizedBox(height: widget.r.hp(2)),
                          _buildCloth('gorro'),
                          _buildCloth('chaqueta'),
                          _buildCloth('arriba'),
                          _buildCloth('abajo'),
                          _buildCloth('tillas'),
                        ],
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutSliver extends StatefulWidget {
  const AboutSliver({
    super.key,
    required this.r,
    required this.images,
    this.index,
    this.existingPinta,
  });
  final Responsive r;
  final Map<String, File?> images;
  final int? index;
  final Pinta? existingPinta;

  @override
  State<AboutSliver> createState() => _AboutSliverState();
}

class _AboutSliverState extends State<AboutSliver> {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: widget.r.hp(1),
          right: widget.r.wp(5),
          left: widget.r.wp(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textForm(widget.r, "* Nombre de la pinta", _nombreController),
            _textForm(
              widget.r,
              "* Algo que decir de la pinta",
              _descripcionController,
            ),
            _textForm(
              widget.r,
              "* ¿Pa' dónde es la vuelta?",
              _categoriaController,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: widget.r.hp(1)),
              child: ElevatedButton(
                onPressed: () => _showDatePicker(context),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: widget.r.dp(2.4),
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black87
                          : Colors.white70,
                    ),
                    SizedBox(width: widget.r.wp(2)),
                    Text("Planear la fecha"),
                  ],
                ),
              ),
            ),

            if (_fechasSeleccionadas.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: widget.r.hp(1)),
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
                        padding: EdgeInsets.only(bottom: widget.r.hp(0.5)),
                        child: Container(
                          padding: EdgeInsets.all(widget.r.dp(1)),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(
                              widget.r.dp(1.5),
                            ),
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: widget.r.dp(1.7),
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
                                  size: widget.r.dp(2.5),
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

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _guardarPinta();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    child: Text(
                      widget.index != null
                          ? "Editar la pinta"
                          : "Subir la pinta",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding _textForm(
    Responsive r,
    String title,
    TextEditingController controller,
  ) {
    if (title.contains("¿Pa' dónde es la vuelta?")) {
      return Padding(
        padding: EdgeInsets.only(bottom: r.hp(2)),
        child: GestureDetector(
          onTap: () => _showCategoryPicker(context, r),
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
      padding: EdgeInsets.only(bottom: r.hp(2)),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r.dp(2)),
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, Responsive r) {
    final box = Hive.box('categoriesBox');

    final filtered = box.values
        .map((c) => Categories.fromMap(Map<String, dynamic>.from(c)))
        .where((c) => c.name != "Todas" && c.name != "Favoritos")
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 12),

              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    final isSelected =
                        _categoriaController.text == category.name;

                    final isLast = index == filtered.length - 1;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: r.wp(5)),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                _categoriaController.text = category.name;
                              });
                              Navigator.pop(context);
                            },
                          ),

                          /// 🔹 Línea separadora (excepto el último)
                          if (!isLast)
                            Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withAlpha(120),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
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
    final fin = DateTime(2030, 12, 31);

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
                      data: CupertinoThemeData(brightness: Brightness.dark),
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
                        fontFamily: "Fredoka",
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
                        fontFamily: "Fredoka",
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
    if (widget.images['arriba'] == null ||
        widget.images['abajo'] == null ||
        widget.images['tillas'] == null) {
      _mostrarError("Debes completar arriba, abajo y zapatos");
      return;
    }

    // Validar campos obligatorios
    if (_nombreController.text.trim().isEmpty ||
        _categoriaController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty) {
      _mostrarError("Debes completar todos los campos obligatorios (*)");
      return;
    }

    final arribaFile = widget.images['arriba']!;
    final abajoFile = widget.images['abajo']!;
    final zapatosFile = widget.images['tillas']!;
    final chaquetaFile = widget.images['chaqueta'];
    final gorroFile = widget.images['gorro'];

    final pinta = Pinta(
      arriba: arribaFile,
      abajo: abajoFile,
      zapatos: zapatosFile,
      gorro: gorroFile,
      chaqueta: chaquetaFile,
      nombre: _nombreController.text,
      descripcion: _descripcionController.text.isEmpty
          ? null
          : _descripcionController.text,
      categoria: _categoriaController.text.isEmpty
          ? null
          : _categoriaController.text,
      fechas: _fechasSeleccionadas,
    );

    Pinta? pintaAnterior;

    if (widget.index != null) {
      final boxTemp = Hive.box('pintasBox');
      final oldMap = Map<String, dynamic>.from(boxTemp.getAt(widget.index!));
      pintaAnterior = Pinta.fromMap(oldMap);
    }

    final box = await Hive.openBox('pintasBox');

    if (widget.index != null) {
      // EDITAR
      await box.putAt(widget.index!, pinta.toMap());
    } else {
      // CREAR
      await box.add(pinta.toMap());
    }

    if (widget.index != null && pintaAnterior != null) {
      _manejarUso(arribaFile, pintaAnterior.arriba);
      _manejarUso(abajoFile, pintaAnterior.abajo);
      _manejarUso(zapatosFile, pintaAnterior.zapatos);
      if (widget.index != null) {
        // Si antes había gorro y ahora no
        if (pintaAnterior.gorro != null && gorroFile == null) {
          _decrementarUso(pintaAnterior.gorro!);
        }

        if (pintaAnterior.chaqueta != null && chaquetaFile == null) {
          _decrementarUso(pintaAnterior.chaqueta!);
        }
      }
    } else {
      // Crear nueva pinta
      _incrementarUso(arribaFile);
      _incrementarUso(abajoFile);
      _incrementarUso(zapatosFile);
      if (gorroFile != null) _incrementarUso(gorroFile);
      if (chaquetaFile != null) _incrementarUso(chaquetaFile);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.index != null ? "Actualizado" : "¡Listo!"),
        content: Text(
          widget.index != null
              ? "La pinta ha sido actualizada"
              : "La pinta ha sido guardada",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // cerrar dialog
              Navigator.pop(context); // volver atrás
            },
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  void _manejarUso(File nueva, File? anterior) {
    // Si antes no había
    if (anterior == null) {
      _incrementarUso(nueva);
      return;
    }

    // Si cambió la prenda
    if (nueva.path != anterior.path) {
      _decrementarUso(anterior);
      _incrementarUso(nueva);
    }
  }

  void _decrementarUso(File imagen) {
    final box = Hive.box('prendasBox');
    final path = imagen.path;

    for (var key in box.keys) {
      final map = Map<String, dynamic>.from(box.get(key));
      final prenda = Prenda.fromMap(map);

      if (prenda.imagen.path == path) {
        prenda.vecesUsada = prenda.vecesUsada > 0 ? prenda.vecesUsada - 1 : 0;
        box.put(key, prenda.toMap());
        break;
      }
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Error"),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }
}
