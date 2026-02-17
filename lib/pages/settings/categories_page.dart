import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kufta_percha/models/categories.dart';
import 'package:kufta_percha/utils/responsive.dart';
import 'package:kufta_percha/utils/widgets.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: r.wp(5),
              right: r.wp(5),
              top: r.hp(4),
            ),
            child: Row(
              children: [
                ButtonBack(),
                SizedBox(width: r.wp(5)),
                Text(
                  "Categorias",
                  style: TextStyle(
                    fontSize: r.dp(2.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          CatPageList(r: r),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _showAddCategoryDialog(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r.dp(1.5)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: EdgeInsets.all(r.dp(1.2)),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(100),
                borderRadius: BorderRadius.circular(r.dp(1.5)),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(120),
                  width: 1,
                ),
              ),
              child: Icon(Icons.add, color: Colors.white, size: r.dp(3)),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final categoriesBox = Hive.box('categoriesBox');
    final nameController = TextEditingController();
    var errorMessage = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Nueva categoría"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(errorMessage, style: TextStyle(color: Colors.red)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final newCategory = Categories(
                        id: categoriesBox.length,
                        name: nameController.text,
                      );
                      categoriesBox.add(newCategory.toMap());
                      Navigator.pop(context);
                    } else {
                      setStateDialog(() {
                        errorMessage = "El nombre no puede estar vacío";
                      });
                      return;
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.primary,
                    ),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class CatPageList extends StatefulWidget {
  final Responsive r;
  const CatPageList({super.key, required this.r});

  @override
  State<CatPageList> createState() => _CatPageListState();
}

class _CatPageListState extends State<CatPageList>
    with TickerProviderStateMixin {
  late Box categoriesBox;

  @override
  void initState() {
    super.initState();
    categoriesBox = Hive.box('categoriesBox');
  }

  void removeCategory(Categories category) {
    final key = categoriesBox.keys.firstWhere((k) {
      final val = categoriesBox.get(k);
      if (val is Categories) return val.id == category.id;
      if (val is Map) return val['id'] == category.id;
      return false;
    }, orElse: () => null);

    if (key != null) {
      categoriesBox.delete(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: categoriesBox.listenable(),
        builder: (context, Box box, _) {
          final categories = box.values
              .map(
                (item) => Categories.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList();
          return ListView.builder(
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index < categories.length) {
                final category = categories[index];
                return CategoryItem(
                  widget: widget,
                  category: category,
                  onDelete: () => removeCategory(category),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.only(
                    left: widget.r.wp(5),
                    right: widget.r.wp(5),
                    top: widget.r.hp(2),
                    bottom: widget.r.hp(8),
                  ),
                  child: Text(
                    "Las categorias que estan acá, son las de Inicio mor",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.r.dp(1.6),
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class CategoryItem extends StatefulWidget {
  const CategoryItem({
    super.key,
    required this.widget,
    required this.category,
    required this.onDelete,
  });

  final CatPageList widget;
  final Categories category;
  final void Function() onDelete;

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _dialogShown = false;

  void _showFullDialog(String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿La vas a matar mor?"),
        content: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "Estas a punto de matar ala categoria "),
              TextSpan(
                text: nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ", ¿seguro mor?"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No, volver"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(); // <-- eliminamos la categoría
              Navigator.pop(context);
            },
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.surface,
              ),
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            child: Text(
              "Si, matar mor",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ).then((_) {
      // Reiniciar para poder volver a mostrar si se toca otra vez
      _dialogShown = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _controller.addListener(() {
      if (_controller.value >= 1.0 &&
          !_dialogShown &&
          widget.category.name != "Todas" &&
          widget.category.name != "Favoritos") {
        _dialogShown = true; // Solo una vez
        _showFullDialog(widget.category.name);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.widget.r.hp(0.6),
        horizontal: widget.widget.r.wp(5),
      ),
      child: GestureDetector(
        onTapDown: (_) {
          _controller.forward(from: 0);
        },
        onTapUp: (_) {
          _controller.stop();
          _controller.reverse();
        },
        onTapCancel: () {
          _controller.stop();
          _controller.reverse();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.widget.r.dp(1.5)),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = _controller.value;

                  return FractionallySizedBox(
                    widthFactor: progress,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        widget.widget.r.dp(1.5),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          height: widget.widget.r.hp(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(250),
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = _controller.value;

                  return Container(
                    height: widget.widget.r.hp(8),
                    padding: EdgeInsets.symmetric(
                      vertical: widget.widget.r.dp(2),
                      horizontal: widget.widget.r.wp(4),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        widget.widget.r.dp(1.5),
                      ),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.category.name,
                          style: TextStyle(
                            fontSize: widget.widget.r.dp(2),
                            color: Color.lerp(
                              Theme.of(context).colorScheme.onSurface,
                              Colors.white,
                              progress,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
