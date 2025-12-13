import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kufta_percha/utils/responsive.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final box = Hive.box('pintasBox');

    // Todas las pintas guardadas
    final pintas = box.values.cast<Map>().toList();

    // Filtrar pintas que tengan al menos una fecha dentro del mes seleccionado
    final pintasDelMes = pintas.where((p) {
      if (p["fechas"] == null) return false;

      final fechas = (p["fechas"] as List)
          .map((ms) => DateTime.fromMillisecondsSinceEpoch(ms))
          .toList();

      return fechas.any(
        (f) => f.year == selectedDate.year && f.month == selectedDate.month,
      );
    }).toList();

    final monthNames = List.generate(
      12,
      (i) => DateFormat.MMMM().format(DateTime(2000, i + 1)),
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: r.wp(5), right: r.wp(5), top: r.wp(5), bottom: r.hp(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mor planner",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: r.dp(3)),
              ),
              GestureDetector(
                onTap: () => _showMonthPicker(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: r.hp(2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            monthNames[selectedDate.month - 1],
                            style: TextStyle(fontSize: r.dp(2)),
                          ),
                          SizedBox(width: r.wp(4)),
                          Icon(CupertinoIcons.calendar),
                        ],
                      ),
                      Text(
                        "${selectedDate.year}",
                        style: TextStyle(fontSize: r.dp(2)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: r.hp(2)),
                child: CalendarWidget(
                  year: selectedDate.year,
                  month: selectedDate.month,
                ),
              ),
              if (pintasDelMes.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: 1,
                      color: Theme.of(context).colorScheme.primary.withAlpha(120),
                    ),
                    SizedBox(height: r.hp(1)),
                    Text(
                      "Pintas para ${DateFormat.MMMM('es').format(selectedDate)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: r.dp(2),
                      ),
                    ),
                    SizedBox(height: r.hp(1)),
        
                    ...pintasDelMes.map((p) {
                      // Construimos una lista de objetos: cada entrada es UNA FECHA de UNA PINTA.
                      final fechasExpandida = <Map<String, dynamic>>[];
        
                      for (var p in pintasDelMes) {
                        final fechas =
                            (p["fechas"] as List)
                                .map(
                                  (ms) => DateTime.fromMillisecondsSinceEpoch(ms),
                                )
                                .where(
                                  (f) =>
                                      f.year == selectedDate.year &&
                                      f.month == selectedDate.month,
                                )
                                .toList()
                              ..sort((a, b) => a.compareTo(b));
        
                        for (var f in fechas) {
                          fechasExpandida.add({
                            "fecha": f,
                            "nombre": p["nombre"],
                            "descripcion": p["descripcion"],
                            "arriba": p["arriba"],
                          });
                        }
                      }
        
                      // Ordenar por fecha
                      fechasExpandida.sort(
                        (a, b) => a["fecha"].compareTo(b["fecha"]),
                      );
        
                      final formatter = DateFormat("d 'de' MMMM 'de' y", "es_ES");
        
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: fechasExpandida.map((item) {
                          final fecha = item["fecha"];
                          final nombre = item["nombre"]; 
                          final descripcion = item["descripcion"];
                          final imgTop = item["arriba"];
        
                          return Padding(
                            padding: EdgeInsets.only(bottom: r.hp(1)),
                            child: Container(
                              padding: EdgeInsets.all(r.dp(1.5)),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(r.dp(1.8)),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(20),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formatter.format(fecha),
                                          style: TextStyle(
                                            fontSize: r.dp(1.6),
                                            color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                                          ),
                                        ),
                                        Text(
                                          nombre ?? "(Sin nombre)",
                                          style: TextStyle(
                                            fontSize: r.dp(1.8),
                                            fontWeight: FontWeight.bold,
                                            height: 1
                                          ),
                                        ),
                                        SizedBox(height: r.hp(1)),
                                        Text(
                                          descripcion ?? "(Sin descripción)",
                                          style: TextStyle(
                                            fontSize: r.dp(1.8),
                                            height: 1
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: r.wp(1)),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(r.dp(1)),
                                    child: imgTop != null
                                        ? Image.file(
                                            File(
                                              imgTop,
                                            ), // <-- Aquí está lo que faltaba
                                            width: r.dp(10),
                                            height: r.dp(10),
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            Icons.image_not_supported,
                                            size: r.dp(10),
                                            color: Colors.grey,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    final monthNames = List.generate(
      12,
      (i) => DateFormat.MMMM().format(DateTime(2000, i + 1)),
    );

    final years = [2025, 2026, 2027];

    int initialMonthIndex = selectedDate.month - 1;
    int initialYearIndex = years.indexOf(selectedDate.year);

    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withAlpha(100),
                    width: 1.2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Picker de Mes
                  Expanded(
                    flex: 2,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: initialMonthIndex,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedDate = DateTime(selectedDate.year, index + 1);
                        });
                      },
                      children: monthNames
                          .map(
                            (name) => Center(
                              child: Text(
                                _capitalize(name),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: "ComicNeue",
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  // Picker de Año
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: initialYearIndex,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedDate = DateTime(
                            years[index],
                            selectedDate.month,
                          );
                        });
                      },
                      children: years
                          .map(
                            (y) => Center(
                              child: Text(
                                y.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: "ComicNeue",
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
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

  // Ayudita para poner la primera letra en mayúscula
  String _capitalize(String text) {
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
}

class CalendarWidget extends StatelessWidget {
  final int year;
  final int month;

  const CalendarWidget({super.key, required this.year, required this.month});

  @override
  Widget build(BuildContext context) {
    // Usa los parámetros que te enviaron, no el mes actual
    final int y = year;
    final int m = month;

    // Primer día del mes
    final firstDay = DateTime(y, m, 1);
    final int firstWeekday = firstDay.weekday % 7;

    // Días del mes actual
    final int daysInMonth = DateTime(y, m + 1, 0).day;

    // Días del mes anterior
    final int prevMonthDays = DateTime(y, m, 0).day;

    final int leadingDays = firstWeekday;

    final int totalCells = leadingDays + daysInMonth;
    final int trailingDays = (totalCells % 7 == 0) ? 0 : (7 - totalCells % 7);

    return Column(
      children: [
        // Encabezado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _DayLabel("S"),
            _DayLabel("D"),
            _DayLabel("L"),
            _DayLabel("M"),
            _DayLabel("M"),
            _DayLabel("J"),
            _DayLabel("V"),
          ],
        ),
        const SizedBox(height: 10),

        // Grid completo
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells + trailingDays,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            // DÍAS DEL MES ANTERIOR
            if (index < leadingDays) {
              final day = prevMonthDays - (leadingDays - index - 1);
              return _CalendarDay("$day", isGray: true, year: y, month: m - 1);
            }

            // DÍAS DEL MES ACTUAL
            if (index < leadingDays + daysInMonth) {
              final day = index - leadingDays + 1;
              return _CalendarDay("$day", isGray: false, year: y, month: m);
            }

            // DÍAS DEL MES SIGUIENTE
            final day = index - (leadingDays + daysInMonth) + 1;
            return _CalendarDay("$day", isGray: true, year: y, month: m + 1);
          },
        ),
      ],
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final String text;
  final bool isGray;
  final int year;
  final int month;

  const _CalendarDay(
    this.text, {
    required this.isGray,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final now = DateTime.now();

    final int number = int.tryParse(text) ?? 0;

    final bool isToday =
        !isGray && number == now.day && month == now.month && year == now.year;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final baseColor = Theme.of(context).colorScheme.surface;

        return Container(
          margin: EdgeInsets.all(2),
          width: size * 0.8,
          height: size * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r.dp(1)),
            color: isToday ? Theme.of(context).colorScheme.primary : baseColor,
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(76),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.white.withAlpha(204),
                      offset: Offset(-2, -2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      offset: Offset(3, 3),
                      blurRadius: 6,
                    ),
                  ],
          ),
          child: Container(
            decoration: !isToday
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(r.dp(2.2)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        baseColor.withAlpha(242),
                        baseColor.withAlpha(216),
                      ],
                    ),
                  )
                : null,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday
                      ? Theme.of(context).colorScheme.surface
                      : isGray
                      ? Theme.of(context).colorScheme.onSurface.withAlpha(140)
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String text;
  const _DayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: r.dp(2),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
