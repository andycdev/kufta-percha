import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kufta_percha/models/pinta.dart';
import 'package:kufta_percha/pages/crud/create.dart';
import 'package:kufta_percha/pages/homepage.dart';
import 'package:kufta_percha/utils/responsive.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Pinta> _allPintas = [];
  List<Pinta> _filtered = [];

  @override
  void initState() {
    super.initState();
    // Abrir el box y cargar pintas
    final box = Hive.box('pintasBox');
    _allPintas = box.values
        .map((raw) => Pinta.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList();
    _filtered = List.from(_allPintas);

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.from(_allPintas);
      } else {
        _filtered = _allPintas.where((p) {
          final nombre = p.nombre.toLowerCase();
          final cat = (p.categoria ?? "").toLowerCase();
          return nombre.contains(q) || cat.contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: r.wp(5),
            right: r.wp(5),
            top: r.hp(2),
            bottom: r.hp(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mor, ¿qué vamos a buscar?",
                style: TextStyle(
                  fontSize: r.dp(3),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: r.hp(2)),
                child: Container(
                  width: r.wp(100),
                  height: r.dp(5.2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r.dp(3)),
                    border: Border.all(color: Colors.white70, width: 1.2),
                    color: Theme.of(context).colorScheme.primary.withAlpha(60),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: r.dp(2)),
                      Icon(CupertinoIcons.search, size: r.dp(3)),
                      SizedBox(width: r.dp(2)),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Buscar",
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150)),
                          ),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ..._filtered.map((pinta) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: r.dp(1)),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(createRoute(Create(existingPinta: pinta)));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: r.dp(1),
                        horizontal: r.dp(2),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(r.dp(2)),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pinta.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: r.dp(1.8),
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              if (pinta.descripcion != null)
                                Text(
                                  pinta.descripcion!,
                                  style: TextStyle(
                                    fontSize: r.dp(1.7),
                                    color: Theme.of(context).colorScheme.surface.withAlpha(200),
                                  ),
                                ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                pinta.arriba,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
