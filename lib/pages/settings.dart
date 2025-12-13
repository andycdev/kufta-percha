import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:kufta_percha/utils/responsive.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: r.hp(10)),
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: EdgeInsets.only(
                  top: r.hp(5),
                  bottom: r.hp(2),
                  left: r.wp(5),
                  right: r.wp(5),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        height: r.dp(12),
                        width: r.dp(12),
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
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : null,
                            colorBlendMode:
                                BlendMode.srcIn, // o BlendMode.srcIn
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Kufta Percha",
                            style: TextStyle(
                              fontSize: r.dp(2.2),
                              color: Colors.grey.withAlpha(210),
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          Text(
                            "Versión 1.0.0",
                            style: TextStyle(
                              fontSize: r.dp(1.6),
                              color: Colors.grey.withAlpha(210),
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // SECTION: APLICACIÓN
              SettingsSection(
                title: "Cuenta",
                items: [
                  SettingsItem(
                    icon: CupertinoIcons.square_arrow_right,
                    text: "Chao mor",
                    onTap: () => _salirApp(context),
                  ),
                ],
              ),
              SettingsSection(
                title: "Personalización",
                items: [
                  SettingsItem(
                    icon: CupertinoIcons.paintbrush,
                    text: "Trajecito de la App",
                    onTap: () => _mostrarCambiarColor(context),
                  ),
                  SettingsItem(
                    icon: CupertinoIcons.brightness,
                    text: "¿Muy brillante?",
                    onTap: () => _mostrarCambiarTema(context),
                  ),
                ],
              ),
              SettingsSection(
                title: "Información",
                items: [
                  SettingsItem(
                    icon: CupertinoIcons.lock_shield,
                    text: "Cuidamos tu Info",
                    onTap: () => _mostrarInfoApp(context),
                  ),
                  SettingsItem(
                    icon: CupertinoIcons.doc_text,
                    text: "Acuerditos",
                    onTap: () => _mostrarAcuerdito(context),
                  ),
                  SettingsItem(
                    icon: CupertinoIcons.chat_bubble_2,
                    text: "Te Ayudamos Mor",
                    onTap: () => _mostrarAyudaMor(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _salirApp(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("¿Te vas mor?", style: TextStyle(fontFamily: "ComicNeue")),
        content: Text(
          "Cerramos la app ya mismo.",
          style: TextStyle(fontFamily: "ComicNeue"),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text("Cancelar", style: TextStyle(fontFamily: "ComicNeue")),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text("Chao mor", style: TextStyle(fontFamily: "ComicNeue")),
            onPressed: () {
              Navigator.pop(context); // cierra el diálogo
              Future.delayed(Duration(milliseconds: 200), () {
                // acá se cierra la app
                SystemNavigator.pop();
              });
            },
          ),
        ],
      ),
    );
  }

  void _mostrarCambiarColor(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          title: Text(
            "Trajecito de la App",
            style: TextStyle(fontFamily: "ComicNeue"),
          ),
          message: Text(
            "Escoge el color que te cuadre, mor.",
            style: TextStyle(fontFamily: "ComicNeue"),
          ),
          actions: [
            _colorOption(context, Color(0xff057a7b), "Principal"),
            _colorOption(context, Color(0xff9a0525), "Rojo carmesí"),
            _colorOption(context, const Color(0xFF0A4FB7), "Azul rey"),
            _colorOption(context, const Color(0xFFC10ECD), "Fucsia"),
            _colorOption(context, const Color(0xFFDB9C08), "Mostaza"),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text("Volver", style: TextStyle(fontFamily: "ComicNeue")),
          ),
        );
      },
    );
  }

  CupertinoActionSheetAction _colorOption(
    BuildContext context,
    Color color,
    String name,
  ) {
    return CupertinoActionSheetAction(
      onPressed: () {
        Hive.box('settingsBox').put('primaryColor', color.value);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 10),
          Text(name, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _mostrarCambiarTema(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(
          "Cambiemos la vuelta",
          style: TextStyle(fontFamily: "ComicNeue"),
        ),
        message: Text(
          "Escoge cómo quieres ver el mundo, mor.",
          style: TextStyle(fontFamily: "ComicNeue"),
        ),
        actions: [
          _temaAction(
            context,
            "Del cel",
            0,
            CupertinoIcons.device_phone_portrait,
          ),
          _temaAction(context, "Claro", 1, CupertinoIcons.sun_max),
          _temaAction(context, "Oscuro", 2, CupertinoIcons.moon),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text("Volver", style: TextStyle(fontFamily: "ComicNeue")),
        ),
      ),
    );
  }

  CupertinoActionSheetAction _temaAction(
    BuildContext context,
    String label,
    int mode,
    IconData icon,
  ) {
    return CupertinoActionSheetAction(
      onPressed: () {
        Hive.box('settingsBox').put('themeMode', mode);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _mostrarInfoApp(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
            "Cuidamos tu Info",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "ComicNeue",
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: "ComicNeue",
                ),
                children: const [
                  TextSpan(
                    text: "Privacidad Mor\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "Aquí vamos al grano, morcito. Todo lo que guardas en la app vive únicamente en tu dispositivo. No sube a servidores, nubes, ni lugares raros.\n\n",
                  ),
                  TextSpan(
                    text: "Tus Datos Son Tuyos\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "No vendemos, no prestamos y no usamos tu info para publicidad. Tampoco rastreamos tu actividad ni hacemos perfiles secretos.\n\n",
                  ),
                  TextSpan(
                    text: "Permisos\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "La app solo usa permisos para tomar fotos, elegir imágenes y guardar tus pinticas. Nada más.\n\n",
                  ),
                  TextSpan(
                    text: "Control Total\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "Puedes borrar todo cuando quieras. Si desinstalas la app, tu info se va contigo y no queda ninguna copia por fuera.",
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Listo mor",
                style: TextStyle(fontFamily: "ComicNeue"),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarAcuerdito(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
            "Acuerdito",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "ComicNeue",
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: "ComicNeue",
                ),
                children: const [
                  TextSpan(
                    text: "Términos y Condiciones\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "Bienvenide a Kufta Percha, mor. Al usar la app aceptas estas reglas básicas para que todo fluya rico y sin enredos.\n\n",
                  ),
                  TextSpan(
                    text: "Uso de la App\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "La app es para que crees, guardes y organices tus pinticas. No es para usos ilegales, raros o que dañen la experiencia de otros usuarios. Sé buena vibra.\n\n",
                  ),
                  TextSpan(
                    text: "Contenido Guardado\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "Todo lo que subes y tomas vive en tu dispositivo. Eres responsable del contenido que guardas y compartes desde tu celular.\n\n",
                  ),
                  TextSpan(
                    text: "Propiedad Intelectual\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "La marca, diseño, iconos y todo lo oficial de Kufta Software son propiedad de su creador. No se pueden copiar, vender ni modificar sin permiso.\n\n",
                  ),
                  TextSpan(
                    text: "Limitación de Responsabilidad\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "Hacemos lo posible para que todo funcione siempre fino. Pero la app se usa tal cual es. No somos responsables por daños, pérdidas o enredos causados por mal uso o fallas del dispositivo.\n\n",
                  ),
                  TextSpan(
                    text: "Cambios al Acuerdito\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "A veces actualizamos estos términos para mejorar la app. Si algo cambia, lo avisaremos en una próxima versión.\n\n",
                  ),
                  TextSpan(
                    text: "Al Usarla, Aceptas\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "Si continúas usando Kufta Percha, aceptas completico este acuerdito. Y si no, siempre puedes desinstalar la app sin resentimientos, mor.",
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Todo claro",
                style: TextStyle(fontFamily: "ComicNeue"),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarAyudaMor(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
            "Te Ayudamos Mor",
            style: TextStyle(
              fontWeight: FontWeight.bold,

              fontFamily: "ComicNeue",
            ),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "Si necesitas una mano, un consejo técnico, o algo no anda como debe, "
              "puedes escribirme directamente al correo:\n\n"
              "tech.andresb@gmail.com\n\n"
              "Siempre que pueda, te echo la mano, mor.",
              style: TextStyle(
                fontSize: 15,
                height: 1.3,
                fontFamily: "ComicNeue",
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                "Listo mor",
                style: TextStyle(fontFamily: "ComicNeue"),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;

  const SettingsSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.hp(1), horizontal: r.wp(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: r.hp(1)),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: r.dp(2)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r.dp(2)),
              color: Theme.of(context).colorScheme.primary.withAlpha(40),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i != items.length - 1)
                    Divider(
                      thickness: 1,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(r.dp(2)),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(r.dp(1.4)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon),
            SizedBox(width: r.wp(2)),
            Text(text),
            Spacer(),
            Icon(CupertinoIcons.chevron_right, size: r.dp(2)),
          ],
        ),
      ),
    );
  }
}
