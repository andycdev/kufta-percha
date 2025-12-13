import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kufta_percha/models/navbar.dart';
import 'package:kufta_percha/pages/calendar.dart';
import 'package:kufta_percha/pages/gallery.dart';
import 'package:kufta_percha/pages/homepage.dart';
import 'package:kufta_percha/pages/search.dart';
import 'package:kufta_percha/pages/settings.dart';
import 'package:kufta_percha/utils/responsive.dart';

class IndexPages extends StatefulWidget {
  const IndexPages({super.key});

  @override
  State<IndexPages> createState() => _IndexPagesState();
}

class _IndexPagesState extends State<IndexPages> {
  int currentIndex = 0;
  late PageController pageController;

  final List<Widget> pages = [
    HomePage(),
    Gallery(),
    SearchPage(),
    CalendarPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  
  @override
Widget build(BuildContext context) {
  final r = Responsive.of(context);
  return Scaffold(
    body: Stack(
      children: [
        PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() => currentIndex = index);
          },
          children: pages,
        ),

        NavBar(
          r: r,
          currentIndex: currentIndex,
          onTap: (index) {
            pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    ),
  );
}

}

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
    required this.r,
    required this.currentIndex,
    required this.onTap,
  });

  final Responsive r;
  final int currentIndex;
  final Function(int) onTap;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.r.dp(2.5)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: widget.r.wp(90),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(widget.r.dp(2.5)),
                border: Border.all(
                  color: Colors.white.withAlpha(100),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(20),
                    blurRadius: 20,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(bottomNavBarItems.length, (index) {
                  final isActive = index == widget.currentIndex;
                  return GestureDetector(
                    onTap: () => widget.onTap(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(bottom: 2),
                          height: 4,
                          width: isActive ? 20 : 0,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(widget.r.dp(2))),
                        ),
                        Opacity(
                          opacity: isActive ? 1 : 0.5,
                          child: Icon(
                            bottomNavBarItems[index].icon,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
