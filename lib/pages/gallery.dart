import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kufta_percha/models/pinta.dart';
import 'package:kufta_percha/models/prenda.dart';
import 'package:kufta_percha/utils/responsive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  String query = "";
  int? filtroEstrellas;
  String filtroTipo = "texto";

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    List<Prenda> obtenerPrendas(String tipo) {
      final box = Hive.box('prendasBox');
      return box.values
          .map((map) => Prenda.fromMap(Map<String, dynamic>.from(map)))
          .where((p) => p.tipo == tipo)
          .toList();
    }

    List<Prenda> obtenerTodasFiltradas() {
      final box = Hive.box('prendasBox');

      return box.values
          .map((map) => Prenda.fromMap(Map<String, dynamic>.from(map)))
          .where((p) {
            final texto = query.toLowerCase();

            final coincideTexto = filtroTipo == "texto"
                ? (p.nombre.toLowerCase().contains(texto) ||
                      p.descripcion.toLowerCase().contains(texto) ||
                      p.color.toLowerCase().contains(texto) ||
                      p.etiquetas.any((e) => e.toLowerCase().contains(texto)))
                : true; // si no está en modo texto, no filtra por texto

            final coincideEstrellas = filtroTipo == "estrellas"
                ? filtroEstrellas == null || p.estrellas == filtroEstrellas
                : true;

            return coincideTexto && coincideEstrellas;
          })
          .toList();
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          StartSliver(r: r),
          RowWithClothes(
            r: r,
            title: "Gorrito",
            list: obtenerPrendas("gorro"),
            onPrendaCreada: () => setState(() {}),
          ),
          RowWithClothes(
            r: r,
            title: "Parte de arriba",
            list: obtenerPrendas("arriba"),
            onPrendaCreada: () => setState(() {}),
          ),
          RowWithClothes(
            r: r,
            title: "Parte de abajo",
            list: obtenerPrendas("abajo"),
            onPrendaCreada: () => setState(() {}),
          ),
          RowWithClothes(
            r: r,
            title: "Tillas",
            list: obtenerPrendas("tillas"),
            onPrendaCreada: () => setState(() {}),
          ),
          SearchSliver(
            r: r,
            resultados: obtenerTodasFiltradas(),
            filtroTipo: filtroTipo,
            onFiltroTipoChanged: (tipo) => setState(() => filtroTipo = tipo),
            onSearchChanged: (texto) => setState(() => query = texto),
            onStarFilterChanged: (estrellas) =>
                setState(() => filtroEstrellas = estrellas),
          ),
        ],
      ),
    );
  }
}

class SearchSliver extends StatefulWidget {
  final Responsive r;
  final List<Prenda> resultados;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int?> onStarFilterChanged;
  final String filtroTipo;
  final ValueChanged<String> onFiltroTipoChanged;

  const SearchSliver({
    super.key,
    required this.r,
    required this.onSearchChanged,
    required this.onStarFilterChanged,
    required this.resultados,
    required this.filtroTipo,
    required this.onFiltroTipoChanged,
  });

  @override
  State<SearchSliver> createState() => _SearchSliverState();
}

class _SearchSliverState extends State<SearchSliver> {
  final TextEditingController searchCtrl = TextEditingController();
  int? filtroEstrellas;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.r.wp(5),
          right: widget.r.wp(5),
          top: widget.r.hp(5),
          bottom: widget.r.hp(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              thickness: 1,
              color: Theme.of(context).colorScheme.primary.withAlpha(200),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: widget.r.hp(1.2)),
              child: Text(
                "¿Qué se te perdio mor?",
                style: TextStyle(fontSize: widget.r.dp(2.2)),
              ),
            ),
            Container(
              width: widget.r.wp(100),
              height: widget.r.dp(5.2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.r.dp(3)),
                border: Border.all(color: Colors.white70, width: 1.2),
                color: Theme.of(context).colorScheme.primary.withAlpha(60),
              ),
              child: Row(
                children: [
                  SizedBox(width: widget.r.dp(2)),
                  Icon(CupertinoIcons.search, size: widget.r.dp(3)),
                  SizedBox(width: widget.r.dp(2)),
                  Expanded(
                    child: widget.filtroTipo == "texto"
                        ? TextField(
                            controller: searchCtrl,
                            onChanged: (txt) =>
                                widget.onSearchChanged(txt.toLowerCase()),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Buscar por texto",
                              hintStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(150),
                              ),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              _openFiltroEstrellas();
                            },
                            child: Row(
                              children: [
                                Text(
                                  filtroEstrellas == null
                                      ? "Filtrar por estrellas"
                                      : "$filtroEstrellas estrellas",
                                  style: TextStyle(
                                    fontSize: widget.r.dp(1.8),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  GestureDetector(
                    onTap: () => _openTipoFiltro(),
                    child: Icon(
                      CupertinoIcons.slider_horizontal_3,
                      size: widget.r.dp(3),
                    ),
                  ),

                  SizedBox(width: widget.r.dp(2)),
                ],
              ),
            ),

            if (widget.filtroTipo == "texto" && searchCtrl.text.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: widget.r.dp(1.5)),
                child: Text(
                  "Filtrado por: \"${searchCtrl.text}\"",
                  style: TextStyle(
                    fontSize: widget.r.dp(1.8),
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(220),
                  ),
                ),
              ),

            if (widget.filtroTipo == "estrellas" && filtroEstrellas != null)
              Padding(
                padding: EdgeInsets.only(top: widget.r.dp(1.5)),
                child: Text(
                  "Filtrado por: $filtroEstrellas estrellas",
                  style: TextStyle(
                    fontSize: widget.r.dp(1.8),
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(220),
                  ),
                ),
              ),

            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: widget.r.wp(100),
                  height: widget.r.hp(50),
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.r.dp(2)),
                    border: Border.all(
                      width: 1.2,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(200),
                    ),
                    color: Theme.of(context).colorScheme.primary.withAlpha(100),
                  ),
                  child: widget.resultados.isEmpty
                      ? Center(
                          child: Text(
                            "Nada por aquí mor…",
                            style: TextStyle(fontSize: widget.r.dp(2)),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(widget.r.dp(1)),
                          itemCount: widget.resultados.length,
                          itemBuilder: (_, i) {
                            final p = widget.resultados[i];
                            return GestureDetector(
                              onTap: () {
                                infoCloth(context, p, widget.r);
                              },
                              onLongPress: () {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (_) => CupertinoAlertDialog(
                                    title: Text(
                                      "Mandarla pa'l high",
                                      style: TextStyle(fontFamily: "ComicNeue"),
                                    ),
                                    content: Text(
                                      "¿Seguro que las vas a borrar, mor?",
                                      style: TextStyle(fontFamily: "ComicNeue"),
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        onPressed: () =>
                                            Navigator.pop(context), // Cancelar
                                        child: Text(
                                          "No, volver",
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                          ),
                                        ),
                                      ),
                                      CupertinoDialogAction(
                                        onPressed: () async {
                                          Navigator.pop(context);

                                          final box = Hive.box("prendasBox");
                                          final key = box.keys.firstWhere((k) {
                                            final item = Prenda.fromMap(
                                              Map<String, dynamic>.from(
                                                box.get(k),
                                              ),
                                            );
                                            return item.id == p.id;
                                          }, orElse: () => null);

                                          if (key != null) {
                                            box.delete(key);
                                            setState(() {});
                                          }
                                        },

                                        isDestructiveAction: true,
                                        child: Text(
                                          "Sí, de una mor",
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  bottom: widget.r.dp(1.5),
                                ),
                                padding: EdgeInsets.all(widget.r.dp(1.2)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    widget.r.dp(2),
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surface.withAlpha(180),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        widget.r.dp(1.5),
                                      ),
                                      child: Image.file(
                                        File(p.imagen.path),
                                        width: widget.r.dp(12),
                                        height: widget.r.dp(12),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: widget.r.dp(2)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.nombre,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: widget.r.dp(2),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            p.descripcion,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: widget.r.dp(1.6),
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: List.generate(
                                              5,
                                              (s) => Icon(
                                                s < p.estrellas
                                                    ? CupertinoIcons.star_fill
                                                    : CupertinoIcons.star,
                                                size: widget.r.dp(1.6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTipoFiltro() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            "Filtrar por",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                widget.onFiltroTipoChanged("texto");
                Navigator.pop(context);
              },
              child: Text("Nombre"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                widget.onFiltroTipoChanged("texto");
                Navigator.pop(context);
              },
              child: Text("Descripción"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                widget.onFiltroTipoChanged("texto");
                Navigator.pop(context);
              },
              child: Text("Etiquetas"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                widget.onFiltroTipoChanged("texto");
                Navigator.pop(context);
              },
              child: Text("Color"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                widget.onFiltroTipoChanged("estrellas");
                Navigator.pop(context);
              },
              child: Text("Estrellas"),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
        );
      },
    );
  }

  void _openFiltroEstrellas() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            "Filtrar por estrellas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          message: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final activo = filtroEstrellas == i;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    filtroEstrellas = i == 0 ? null : i;
                    widget.onStarFilterChanged(filtroEstrellas);
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activo
                        ? Theme.of(context).colorScheme.primary
                        : CupertinoColors.systemGrey4,
                  ),
                  child: Text(
                    i == 0 ? "X" : i.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: activo ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
        );
      },
    );
  }
}

class StartSliver extends StatelessWidget {
  const StartSliver({super.key, required this.r});

  final Responsive r;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          left: r.wp(5),
          right: r.wp(5),
          top: r.hp(2),
          bottom: r.hp(1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tomemos las pic mor",
              style: TextStyle(fontSize: r.dp(3), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class RowWithClothes extends StatefulWidget {
  const RowWithClothes({
    super.key,
    required this.r,
    required this.list,
    required this.title,
    required this.onPrendaCreada,
  });

  final String title;
  final Responsive r;
  final List<Prenda> list;
  final Function() onPrendaCreada;

  @override
  State<RowWithClothes> createState() => _RowWithClothesState();
}

class _RowWithClothesState extends State<RowWithClothes> {
  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    String getTipoInterno(String title) {
      switch (title) {
        case "Gorrito":
          return "gorro";
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

    final prendasBox = Hive.box('prendasBox');

    // obtener SIEMPRE la lista directamente desde Hive
    List<Prenda> listaActual = prendasBox.values
        .map((map) => Prenda.fromMap(Map<String, dynamic>.from(map)))
        .where((p) => p.tipo == getTipoInterno(widget.title))
        .toList();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.r.wp(5.5),
              vertical: widget.r.hp(1),
            ),
            child: Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: widget.r.dp(2.2),
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _showPickOptions(context, getTipoInterno(widget.title));
                  },

                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        width: widget.r.wp(30),
                        height: widget.r.wp(40),
                        margin: EdgeInsets.only(
                          left: widget.r.wp(5),
                          right: widget.r.wp(2),
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(150),
                          borderRadius: BorderRadius.circular(widget.r.dp(1.5)),
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
                  ),
                ),
                ...List.generate(listaActual.length, (int index) {
                  final prenda = listaActual[index];
                  return GestureDetector(
                    onTap: () {
                      infoCloth(context, prenda, widget.r);
                    },
                    onLongPress: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: Text(
                            "Mandarla pa'l high",
                            style: TextStyle(fontFamily: "ComicNeue"),
                          ),
                          content: Text(
                            "¿Seguro que las vas a borrar, mor?",
                            style: TextStyle(fontFamily: "ComicNeue"),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () =>
                                  Navigator.pop(context), // Cancelar
                              child: Text(
                                "No, volver",
                                style: TextStyle(fontFamily: "ComicNeue"),
                              ),
                            ),
                            CupertinoDialogAction(
                              onPressed: () async {
                                final box = Hive.box('prendasBox');
                                final pintaBox = Hive.box(
                                  'pintasBox',
                                ); // ← Asegúrate de abrirlo en main.dart
                                final prenda = listaActual[index];

                                // Verificar si la prenda está usada en una pinta
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
                                      (pinta.gorro?.path == imgPath)) {
                                    estaUsada = true;
                                    break;
                                  }
                                }

                                if (estaUsada) {
                                  Navigator.pop(
                                    context,
                                  ); // cerrar el diálogo anterior

                                  showCupertinoDialog(
                                    context: context,
                                    builder: (_) => CupertinoAlertDialog(
                                      title: Text(
                                        "No se puede borrar",
                                        style: TextStyle(
                                          fontFamily: "ComicNeue",
                                        ),
                                      ),
                                      content: Text(
                                        "Esta prenda hace parte de una pintica, mor. No se puede mandar pa'l high.",
                                        style: TextStyle(
                                          fontFamily: "ComicNeue",
                                        ),
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: Text(
                                            "Entendido",
                                            style: TextStyle(
                                              fontFamily: "ComicNeue",
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );

                                  return;
                                }

                                // Si no está usada → borrar normal
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

                              isDestructiveAction: true,
                              child: Text(
                                "Sí, de una mor",
                                style: TextStyle(fontFamily: "ComicNeue"),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left: index == 0 ? widget.r.wp(5) : widget.r.wp(2),
                        right: index == listaActual.length - 1
                            ? widget.r.wp(5)
                            : 0,
                      ),
                      width: widget.r.wp(30),
                      height: widget.r.wp(40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.r.dp(2)),
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
    );
  }

  void _showPickOptions(BuildContext context, String tipo) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          title: Text(tipo),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _takePhoto(tipo);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.camera),
                  SizedBox(width: 10),
                  Text("Tomar foto", style: TextStyle(fontFamily: "ComicNeue")),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickFromGallery(tipo);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.photo),
                  SizedBox(width: 10),
                  Text("Subir foto", style: TextStyle(fontFamily: "ComicNeue")),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
        );
      },
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

  void _showPermissionDenied() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(
          "Permiso denegado",
          style: TextStyle(fontFamily: "ComicNeue"),
        ),
        content: Text(
          "No se puede acceder a la cámara",
          style: TextStyle(fontFamily: "ComicNeue"),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text("Ok", style: TextStyle(fontFamily: "ComicNeue")),
          ),
        ],
      ),
    );
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

  void _openCreatePrendaForm(File img, String tipo) {
    final nombreCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    final etiquetasCtrl = TextEditingController();
    double estrellas = 0;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text("Nueva prenda ($tipo)"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.file(img, height: 150, fit: BoxFit.cover),

                    TextField(
                      controller: nombreCtrl,
                      decoration: InputDecoration(labelText: "Nombre"),
                    ),

                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(labelText: "Descripción"),
                    ),

                    TextField(
                      controller: colorCtrl,
                      decoration: InputDecoration(labelText: "Color"),
                    ),

                    TextField(
                      controller: etiquetasCtrl,
                      decoration: InputDecoration(
                        labelText: "Etiquetas (separadas por coma)",
                      ),
                    ),

                    SizedBox(height: 10),

                    Text("Estrellas"),
                    Slider(
                      value: estrellas,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: estrellas.toString(),
                      onChanged: (v) => setState(() => estrellas = v),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () => Navigator.pop(context),
                ),

                ElevatedButton(
                  child: Text("Guardar"),
                  onPressed: () {
                    final nombre = nombreCtrl.text.trim();
                    final desc = descCtrl.text.trim();
                    final color = colorCtrl.text.trim();
                    final etiquetas = etiquetasCtrl.text.trim();

                    // VALIDACIÓN
                    if (nombre.isEmpty ||
                        desc.isEmpty ||
                        color.isEmpty ||
                        etiquetas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Todos los campos son obligatorios"),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return; // ❌ No continúa
                    }

                    // Si todo está lleno → sí crea la prenda
                    _savePrenda(
                      img,
                      tipo,
                      nombre,
                      desc,
                      color,
                      etiquetas.split(",").map((e) => e.trim()).toList(),
                      estrellas,
                    );

                    Navigator.pop(context);

                    Future.delayed(Duration(milliseconds: 100), () {
                      widget.onPrendaCreada();
                    });
                  },
                ),
              ],
            );
          },
        );
      },
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

void infoCloth(BuildContext context, Prenda p, Responsive r) {
  showCupertinoDialog(
    context: context,
    builder: (_) {
      return CupertinoAlertDialog(
        title: Text(p.nombre),
        content: Column(
          children: [
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(r.dp(2)),
              child: Image.file(
                File(p.imagen.path),
                height: r.dp(30),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Text("Descripción:\n${p.descripcion}"),
            SizedBox(height: 8),
            Text("Color: ${p.color}"),
            SizedBox(height: 8),
            Text("Etiquetas: ${p.etiquetas.join(', ')}"),
            SizedBox(height: 8),
            Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(
    5,
    (i) => Icon(
      i < p.estrellas ? CupertinoIcons.star_fill : CupertinoIcons.star,
      size: r.dp(2.2),
    ),
  ),
),
            SizedBox(height: 8),
            Text("En pintas: ${p.vecesUsada}"),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text("Cerrar"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}
