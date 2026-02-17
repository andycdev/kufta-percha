import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kufta_percha/models/pinta.dart';
import 'package:kufta_percha/models/prenda.dart';
import 'package:kufta_percha/utils/responsive.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: r.wp(5),
                right: r.wp(5),
                top: r.hp(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mi armario mor",
                    style: TextStyle(
                      fontSize: r.dp(3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClosetSliver(r: r, title: "Gorrito"),
          ClosetSliver(r: r, title: "Chaqueta"),
          ClosetSliver(r: r, title: "Parte de arriba"),
          ClosetSliver(r: r, title: "Parte de abajo"),
          ClosetSliver(r: r, title: "Tillas"),
          SliverToBoxAdapter(child: SizedBox(height: r.hp(10))),
        ],
      ),
    );
  }
}

class ClosetSliver extends StatefulWidget {
  const ClosetSliver({super.key, required this.r, required this.title});

  final Responsive r;
  final String title;

  @override
  State<ClosetSliver> createState() => _ClosetSliverState();
}

class _ClosetSliverState extends State<ClosetSliver> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  String getTipoInterno(String title) {
    switch (title) {
      case "Gorrito":
        return "gorro";
      case "Chaqueta":
        return "chaqueta";
      case "Parte de arriba":
        return "arriba";
      case "Parte de abajo":
        return "abajo";
      case "Tillas":
        return "tillas";
      default:
        return title.toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prendasBox = Hive.box('prendasBox');
    // obtener SIEMPRE la lista directamente desde Hive
    prendasBox.values
        .map((map) => Prenda.fromMap(Map<String, dynamic>.from(map)))
        .where((p) => p.tipo == getTipoInterno(widget.title))
        .toList();
    return ValueListenableBuilder(
      valueListenable: prendasBox.listenable(),
      builder: (context, Box box, _) {
        List<Prenda> listaActual = box.values
            .map((map) => Prenda.fromMap(Map<String, dynamic>.from(map)))
            .where((p) => p.tipo == getTipoInterno(widget.title))
            .toList();

        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: widget.r.hp(2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: widget.r.wp(5)),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.r.dp(2),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showPickOptions(context, widget.title);
                        },
                        child: Container(
                          width: widget.r.wp(30),
                          height: widget.r.wp(40),
                          margin: EdgeInsets.only(
                            top: widget.r.hp(1),
                            bottom: widget.r.hp(1),
                            left: widget.r.wp(5),
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(150),
                            borderRadius: BorderRadius.circular(
                              widget.r.dp(1.5),
                            ),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(80),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.add_circled,
                              size: widget.r.dp(4),
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),

                      ...List.generate(listaActual.length, (int index) {
                        final prenda = listaActual[index];
                        return GestureDetector(
                          onTap: () {
                            final box = Hive.box('prendasBox');

                            final hiveKey = box.keys.firstWhere((k) {
                              final item = Map<String, dynamic>.from(
                                box.get(k),
                              );
                              return item["id"] == prenda.id;
                            });

                            _openCreatePrendaForm(
                              prenda.imagen,
                              widget.title,
                              prendaExistente: prenda,
                              hiveKey: hiveKey,
                            );
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  "Mandarla pa'l high",
                                  style: TextStyle(fontFamily: "Fredoka"),
                                ),
                                content: const Text(
                                  "¿Seguro que las vas a borrar, mor?",
                                  style: TextStyle(fontFamily: "Fredoka"),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "No, volver",
                                      style: TextStyle(fontFamily: "Fredoka"),
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      final box = Hive.box('prendasBox');
                                      final pintaBox = Hive.box('pintasBox');
                                      final prenda = listaActual[index];

                                      bool estaUsada = false;

                                      for (var key in pintaBox.keys) {
                                        final map = Map<String, dynamic>.from(
                                          pintaBox.get(key),
                                        );
                                        final pinta = Pinta.fromMap(map);

                                        final imgPath = prenda.imagen.path;

                                        if (pinta.arriba.path == imgPath ||
                                            pinta.abajo.path == imgPath ||
                                            pinta.zapatos.path == imgPath ||
                                            pinta.chaqueta?.path == imgPath ||
                                            (pinta.gorro?.path == imgPath)) {
                                          estaUsada = true;
                                          break;
                                        }
                                      }

                                      if (estaUsada) {
                                        Navigator.pop(context);

                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            title: const Text(
                                              "No se puede borrar",
                                              style: TextStyle(
                                                fontFamily: "Fredoka",
                                              ),
                                            ),
                                            content: const Text(
                                              "Esta prenda hace parte de una pintica, mor. No se puede mandar pa'l high.",
                                              style: TextStyle(
                                                fontFamily: "Fredoka",
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text(
                                                  "Entendido",
                                                  style: TextStyle(
                                                    fontFamily: "Fredoka",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        return;
                                      }

                                      final hiveKey = box.keys.firstWhere((k) {
                                        final item = Map<String, dynamic>.from(
                                          box.get(k),
                                        );
                                        return item["id"] == prenda.id;
                                      });

                                      await box.delete(hiveKey);

                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Sí, de una mor",
                                      style: TextStyle(fontFamily: "Fredoka"),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              left: index == 0
                                  ? widget.r.wp(5)
                                  : widget.r.wp(2),
                              right: index == 6 - 1 ? widget.r.wp(5) : 0,
                            ),
                            width: widget.r.wp(30),
                            height: widget.r.wp(40),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                widget.r.dp(2),
                              ),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(80),
                                width: 1.2,
                              ),
                              image: DecorationImage(
                                image: FileImage(listaActual[index].imagen),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPickOptions(BuildContext context, String tipo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.camera_rounded),
                title: const Text(
                  "Tomar foto",
                  style: TextStyle(fontFamily: "Fredoka"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto(tipo);
                },
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: const Icon(Symbols.gallery_thumbnail_rounded),
                  title: const Text(
                    "Subir foto",
                    style: TextStyle(fontFamily: "Fredoka"),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery(tipo);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPermissionDenied() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Permiso denegado",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "No se puede acceder a la cámara, porfavor ve a los ajustes de tu dispositivo y permite el acceso a la cámara para esta app.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto(String title) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      _openCamera(title);
      return;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        _openCamera(title);
      } else {
        _showPermissionDenied();
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDenied();
    }
  }

  Future<void> _openCamera(String tipo) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080,
      maxHeight: 1920,
    );

    if (file != null) {
      final img = File(file.path);
      _openCreatePrendaForm(img, tipo);
    }
  }

  Future<void> _pickFromGallery(String tipo) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1920,
    );

    if (file != null) {
      final img = File(file.path);
      _openCreatePrendaForm(img, tipo);
    }
  }

  void _openCreatePrendaForm(
    File img,
    String tipo, {
    Prenda? prendaExistente,
    dynamic hiveKey,
  }) {
    final nombreCtrl = TextEditingController(
      text: prendaExistente?.nombre ?? "",
    );
    final descCtrl = TextEditingController(
      text: prendaExistente?.descripcion ?? "",
    );
    final colorCtrl = TextEditingController(text: prendaExistente?.color ?? "");
    final etiquetasCtrl = TextEditingController(
      text: prendaExistente?.etiquetas.join(", ") ?? "",
    );
    double estrellas = prendaExistente?.estrellas ?? 0;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: prendaExistente != null
                  ? Text("Editar la prenda")
                  : Text.rich(
                      TextSpan(
                        text: "Nueva prenda: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: tipo,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: widget.r.hp(2)),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(
                            widget.r.dp(1),
                          ),
                          child: Image.file(
                            img,
                            height: widget.r.hp(20),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      if (prendaExistente != null) ...[
                        Padding(
                          padding: EdgeInsets.only(bottom: widget.r.hp(2)),
                          child: Text(
                            "En pintas usadas: ${prendaExistente.vecesUsada}",
                          ),
                        ),
                      ],
                      _textForm(
                        widget.r,
                        "* Nombre",
                        nombreCtrl,
                        obligatorio: true,
                      ),
                      _textForm(widget.r, "Descripción", descCtrl),
                      _textForm(
                        widget.r,
                        "* Color",
                        colorCtrl,
                        obligatorio: true,
                      ),
                      _textForm(widget.r, "Etiquetas", etiquetasCtrl),

                      SizedBox(height: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Nivel de flow",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starIndex = index + 1;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    estrellas = starIndex.toDouble();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    starIndex <= estrellas
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 32,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () => Navigator.pop(context),
                ),

                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.primary,
                    ),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    if (estrellas == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Debes seleccionar el nivel de flow"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    final nombre = nombreCtrl.text.trim();
                    final desc = descCtrl.text.trim().isEmpty
                        ? ""
                        : descCtrl.text.trim();

                    final color = colorCtrl.text.trim();

                    final etiquetasTexto = etiquetasCtrl.text.trim().isEmpty
                        ? ""
                        : etiquetasCtrl.text.trim();

                    final etiquetas = etiquetasTexto
                        .split(",")
                        .map((e) => e.trim())
                        .toList();

                    // Si todo está lleno → sí crea la prenda
                    final tipoInterno = getTipoInterno(tipo);

                    if (prendaExistente != null) {
                      // EDITAR
                      final prendaActualizada = Prenda(
                        id: prendaExistente.id,
                        tipo: tipoInterno,
                        nombre: nombre,
                        descripcion: desc,
                        color: color,
                        etiquetas: etiquetas,
                        estrellas: estrellas,
                        imagen: img,
                        vecesUsada: prendaExistente.vecesUsada,
                      );

                      final box = Hive.box('prendasBox');
                      await box.put(hiveKey, prendaActualizada.toMap());
                    } else {
                      // CREAR
                      await _savePrenda(
                        img,
                        tipoInterno,
                        nombre,
                        desc,
                        color,
                        etiquetas,
                        estrellas,
                      );
                    }
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Padding _textForm(
    Responsive r,
    String title,
    TextEditingController controller, {
    bool obligatorio = false,
  }) {
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
        validator: obligatorio
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Este campo es obligatorio";
                }
                return null;
              }
            : null,
      ),
    );
  }

  Future<void> _savePrenda(
    File img,
    String tipo,
    String nombre,
    String descripcion,
    String color,
    List<String> etiquetas,
    double estrellas,
  ) async {
    final prendasBox = Hive.box('prendasBox');

    // 1. Copiamos la imagen a almacenamiento interno
    final dir = await getApplicationDocumentsDirectory();
    final prendasDir = Directory('${dir.path}/prendas');

    if (!prendasDir.existsSync()) {
      prendasDir.createSync(recursive: true);
    }

    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await img.copy('${prendasDir.path}/$uniqueName');

    // 2. Creamos la prenda con la imagen ya segura
    final prenda = Prenda(
      id: DateTime.now().millisecondsSinceEpoch, // ← id único,
      tipo: tipo,
      nombre: nombre,
      descripcion: descripcion,
      color: color,
      etiquetas: etiquetas,
      estrellas: estrellas,
      imagen: savedImage, // ← ahora sí una ruta permanente
      vecesUsada: 0,
    );

    // 3. Guardamos el map
    prendasBox.add(prenda.toMap());

    setState(() {});
  }
}
