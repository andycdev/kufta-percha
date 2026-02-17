import 'package:flutter/material.dart';
import 'package:kufta_percha/utils/responsive.dart';

// Widget reutilizable para las rutas
Route createRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 600),
    reverseTransitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.linearToEaseOut));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

// Boton reutilizable para volver atrás
class ButtonBack extends StatelessWidget {
  const ButtonBack({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return IconButton(
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
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.dp(2))),
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(Icons.arrow_back, size: r.dp(3)),
    );
  }
}
