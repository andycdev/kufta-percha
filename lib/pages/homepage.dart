import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kufta_percha/models/categories.dart';
import 'package:kufta_percha/models/pinta.dart';
import 'package:kufta_percha/models/prenda.dart';
import 'package:kufta_percha/pages/crud/create.dart';
import 'package:kufta_percha/utils/responsive.dart';
import 'package:kufta_percha/utils/widgets.dart';
import 'package:lottie/lottie.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String selectedCategoryName;
  bool isSearching = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    selectedCategoryName = "Todas";
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return CustomScrollView(
      slivers: [
        StartSliver(
          r: r,
          onSearchChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
        ScrollCategoriesSliver(
          r: r,
          selectedCategory: selectedCategoryName, // 👈 ESTO FALTABA
          onChanged: (name) {
            setState(() {
              selectedCategoryName = name;
            });
          },
        ),

        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: r.hp(2),
              horizontal: r.wp(5),
            ),
            width: r.wp(100),
            height: 1,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
              borderRadius: BorderRadius.circular(r.dp(1)),
            ),
          ),
        ),

        ClothesSliver(
          r: r,
          selectedCategory: selectedCategoryName,
          searchQuery: searchQuery,
        ),
      ],
    );
  }
}

class StartSliver extends StatefulWidget {
  const StartSliver({
    super.key,
    required this.r,
    required this.onSearchChanged,
  });

  final Responsive r;
  final Function(String) onSearchChanged;

  @override
  State<StartSliver> createState() => _StartSliverState();
}

class _StartSliverState extends State<StartSliver>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> widthAnimation;
  late Animation<double> opacityAnimation;

  final TextEditingController controller = TextEditingController();

  bool showTextField = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    widthAnimation = Tween<double>(
      begin: 48,
      end: widget.r.wp(90),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          showTextField = true;
        });
      }
    });
  }

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
  void dispose() {
    _controller.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: widget.r.hp(6),
          bottom: widget.r.hp(2),
          left: widget.r.wp(5),
          right: widget.r.wp(5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FadeTransition(
                opacity: opacityAnimation,
                child: _buildHeaderContent(context),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: widthAnimation.value,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(60),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: showTextField
                      ? _buildTextField(context)
                      : _buildSearchIcon(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            onChanged: widget.onSearchChanged,
            decoration: const InputDecoration(
              hintText: "Buscar pinta...",
              border: InputBorder.none,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            controller.clear();
            widget.onSearchChanged("");
            setState(() {
              showTextField = false;
            });
            _controller.reverse();
          },
        ),
      ],
    );
  }

  Widget _buildSearchIcon() {
    return IconButton(
      icon: const Icon(CupertinoIcons.search),
      onPressed: () {
        _controller.forward();
      },
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quiubo mor",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: widget.r.dp(3),
              ),
            ),
            Text(
              getGreeting(),
              style: TextStyle(
                fontSize: widget.r.dp(2),
                color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(createRoute(Create()));
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class ScrollCategoriesSliver extends StatefulWidget {
  final Responsive r;
  final String selectedCategory;
  final Function(String) onChanged;
  const ScrollCategoriesSliver({
    super.key,
    required this.r,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  State<ScrollCategoriesSliver> createState() => _ScrollCategoriesSliverState();
}

class _ScrollCategoriesSliverState extends State<ScrollCategoriesSliver> {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('categoriesBox');

    final categoriesName = box.values
        .map((c) => Categories.fromMap(Map<String, dynamic>.from(c)).name)
        .toList();

    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categoriesName.length, (int index) {
            final raw = box.getAt(index);
            final category = Categories.fromMap(Map<String, dynamic>.from(raw));
            final isActive = category.name == widget.selectedCategory;
            return GestureDetector(
              onTap: () => widget.onChanged(category.name),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.fastEaseInToSlowEaseOut,
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withAlpha(60),
                  borderRadius: BorderRadius.circular(widget.r.dp(2.5)),
                ),
                margin: EdgeInsets.only(
                  left: index == 0 ? widget.r.wp(5) : widget.r.wp(2),
                  right: index == categoriesName.length - 1
                      ? widget.r.wp(5)
                      : 0,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.r.wp(4),
                  vertical: widget.r.hp(0.5),
                ),
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }),
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
    required this.searchQuery,
  });

  final Responsive r;
  final String selectedCategory;
  final String searchQuery;

  @override
  State<ClothesSliver> createState() => _ClothesSliverState();
}

class _ClothesSliverState extends State<ClothesSliver> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.r.wp(5)),
        child: ValueListenableBuilder(
          valueListenable: Hive.box('pintasBox').listenable(),
          builder: (context, box, _) {
            final raw = box.values.toList();

            final pintas = raw.map((map) {
              final pintaMap = Map<String, dynamic>.from(map);
              return Pinta.fromMap(pintaMap);
            }).toList();

            final selected = widget.selectedCategory;

            List<Pinta> filtered = pintas;

            if (selected == "Favoritos") {
              filtered = pintas.where((p) => p.favorito).toList();
            } else if (selected != "Todas") {
              filtered = pintas.where((p) => p.categoria == selected).toList();
            }

            if (filtered.isEmpty) {
              return Container(
                height: widget.r.hp(50),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Lottie.asset(
                      "assets/gifts/Loader_cat.json",
                      fit: BoxFit.contain,
                      width: widget.r.wp(80),
                    ),
                    Text(
                      "Créese una pintica mor\naquí no hay na'",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.r.dp(2),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (widget.searchQuery.isNotEmpty) {
              filtered = filtered.where((p) {
                return p.nombre.toLowerCase().contains(
                  widget.searchQuery.toLowerCase(),
                );
              }).toList();
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

                                  pinta.favorito = !pinta.favorito; // toggle

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
                                  color: Theme.of(context).colorScheme.primary,
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Eliminar pinta",
            style: TextStyle(fontFamily: "Fredoka"),
          ),
          content: const Text(
            "¿Estás seguro que quieres eliminar esta pinta?",
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
              onPressed: () async {
                final box = Hive.box('pintasBox');

                // 1. Recuperar antes de borrar
                final pintaMap = Map<String, dynamic>.from(box.getAt(index));
                final pinta = Pinta.fromMap(pintaMap);

                // 2. Restar usos
                _decrementarUso(pinta.arriba);
                _decrementarUso(pinta.abajo);
                _decrementarUso(pinta.zapatos);
                if (pinta.gorro != null) {
                  _decrementarUso(pinta.gorro!);
                }

                // 3. Borrar
                await box.deleteAt(index);

                if (context.mounted) {
                  Navigator.pop(context);
                }

                setState(() {});
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text("Sí, de una"),
            ),
          ],
        );
      },
    );
  }
}
