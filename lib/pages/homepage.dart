import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kufta_percha/models/categories.dart';
import 'package:kufta_percha/models/pinta.dart';
import 'package:kufta_percha/models/prenda.dart';
import 'package:kufta_percha/pages/crud/create.dart';
import 'package:kufta_percha/utils/responsive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return CustomScrollView(
      slivers: [
        StartSliver(r: r),
        ScrollCategoriesSliver(
          r: r,
          onCategoryChanged: (i) {
            setState(() => selectedCategory = i);
          },
        ),
        ClothesSliver(r: r, selectedCategory: selectedCategory),
      ],
    );
  }
}

class StartSliver extends StatelessWidget {
  const StartSliver({super.key, required this.r});

  final Responsive r;

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Buenos días";
    } else if (hour >= 12 && hour < 18) {
      return "Buenas tardes";
    } else {
      return "Buenas noches";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: r.hp(2), horizontal: r.wp(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quiubo mor",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: r.dp(3),
                        height: 1.2,
                      ),
                    ),
                    Text(
                      getGreeting(),
                      style: TextStyle(
                        fontSize: r.dp(2),
                        letterSpacing: 0,
                        height: 1.2,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(170),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: r.dp(6),
                  width: r.dp(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors
                              .white // tema oscuro → blanco
                        : Theme.of(context).colorScheme.primary,
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/img/kufta_icon_reverted.png",
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : null,
                      colorBlendMode: BlendMode.srcIn, // o BlendMode.srcIn
                      fit: BoxFit.contain,
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
}

class ScrollCategoriesSliver extends StatefulWidget {
  const ScrollCategoriesSliver({
    super.key,
    required this.r,
    required this.onCategoryChanged,
  });

  final Responsive r;
  final ValueChanged<int> onCategoryChanged;

  @override
  State<ScrollCategoriesSliver> createState() => _ScrollCategoriesSliverState();
}

class _ScrollCategoriesSliverState extends State<ScrollCategoriesSliver> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final catNames = categories.map((c) => c.name).toList();
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: widget.r.hp(1)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(catNames.length, (int index) {
              final bool isActive = index == selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);
                  widget.onCategoryChanged(index); // <── ENVÍA EL ÍNDICE
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  margin: EdgeInsets.only(
                    left: index == 0 ? widget.r.wp(5) : widget.r.wp(2),
                    right: index == categories.length - 1 ? widget.r.wp(5) : 0,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.r.wp(4),
                    vertical: widget.r.hp(0.5),
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(widget.r.dp(2.5)),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(80),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    catNames[index],
                    style: TextStyle(
                      fontSize: widget.r.dp(1.8),
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ClothesSliver extends StatefulWidget {
  const ClothesSliver({
    super.key,
    required this.r,
    required this.selectedCategory,
  });

  final Responsive r;
  final int selectedCategory;

  @override
  State<ClothesSliver> createState() => _ClothesSliverState();
}

class _ClothesSliverState extends State<ClothesSliver> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: widget.r.hp(0.5),
              horizontal: widget.r.wp(5),
            ),

            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(createRoute(Create()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Crear mi pinta",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: widget.r.wp(2)),
                  Icon(CupertinoIcons.collections),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: widget.r.wp(5),
              right: widget.r.wp(5),
              top: widget.r.hp(2),
              bottom: widget.r.hp(10),
            ),
            child: ValueListenableBuilder(
              valueListenable: Hive.box('pintasBox').listenable(),
              builder: (context, box, _) {
                final raw = box.values.toList();

                final pintas = raw.map((map) {
                  final pintaMap = Map<String, dynamic>.from(map);
                  return Pinta.fromMap(pintaMap);
                }).toList();

                List<Pinta> filtered = pintas;

                final cat = widget.selectedCategory;

                // Categoría 1 = Favoritos
                if (cat == 1) {
                  filtered = pintas.where((p) => p.favorito).toList();
                }
                // Categorías normales
                else if (cat > 1) {
                  final selectedName = categories[cat].name;
                  filtered = pintas
                      .where((p) => p.categoria == selectedName)
                      .toList();
                }

                if (pintas.isEmpty) {
                  return Container(
                    height: widget.r.hp(30),
                    alignment: Alignment.center,
                    child: Text(
                      "Créese una pintica mor, aquí no hay na'",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.r.dp(2),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,

                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final pinta = filtered[index];

                    return GestureDetector(
                      onLongPress: () => _confirmDelete(context, index),
                      onTap: () => Navigator.of(context).push(
                        createRoute(Create(existingPinta: pinta, index: index)),
                      ),

                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        width: widget.r.wp(50),
                        height: widget.r.wp(50),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(80),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(widget.r.dp(2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.file(
                                pinta.arriba,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: widget.r.dp(1),
                                vertical: widget.r.dp(1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      pinta.nombre,
                                      style: TextStyle(
                                        fontSize: widget.r.dp(1.7),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: widget.r.dp(0.1)),
                                  GestureDetector(
                                    onTap: () async {
                                      final box = Hive.box('pintasBox');

                                      pinta.favorito =
                                          !pinta.favorito; // toggle

                                      await box.putAt(
                                        index,
                                        pinta.toMap(),
                                      ); // guardar cambio
                                      setState(() {});
                                    },
                                    child: Icon(
                                      pinta.favorito
                                          ? CupertinoIcons.heart_fill
                                          : CupertinoIcons.heart,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _decrementarUso(File imagen) {
    final box = Hive.box('prendasBox');
    final path = imagen.path;

    for (var key in box.keys) {
      final map = Map<String, dynamic>.from(box.get(key));
      final prenda = Prenda.fromMap(map);

      if (prenda.imagen.path == path) {
        final valor = prenda.vecesUsada;
        prenda.vecesUsada = valor > 0 ? valor - 1 : 0;
        box.put(key, prenda.toMap());
        break;
      }
    }
  }

  void _confirmDelete(BuildContext context, int index) {
    showCupertinoDialog(
      barrierColor: Colors.black.withAlpha(150),
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(
          "Eliminar pinta",
          style: TextStyle(fontFamily: "ComicNeue"),
        ),
        content: Text(
          "¿Estás seguro que quieres eliminar esta pinta?",
          style: TextStyle(fontFamily: "ComicNeue"),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text("No", style: TextStyle(fontFamily: "ComicNeue")),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              final box = Hive.box('pintasBox');

              // 1. Recuperar la pinta ANTES de borrarla
              final pintaMap = Map<String, dynamic>.from(box.getAt(index));
              final pinta = Pinta.fromMap(pintaMap);

              // 2. Restar usos a las prendas
              _decrementarUso(pinta.arriba);
              _decrementarUso(pinta.abajo);
              _decrementarUso(pinta.zapatos);
              if (pinta.gorro != null) _decrementarUso(pinta.gorro!);

              // 3. Ahora sí borramos la pinta
              await box.deleteAt(index);

              Navigator.pop(context);
              setState(() {});
            },

            isDestructiveAction: true,
            child: Text("Sí", style: TextStyle(fontFamily: "ComicNeue")),
          ),
        ],
      ),
    );
  }
}

Route createRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 600),
    reverseTransitionDuration: Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
