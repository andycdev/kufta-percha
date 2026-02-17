import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kufta_percha/models/navbar.dart';
import 'package:kufta_percha/pages/calendar.dart';
import 'package:kufta_percha/pages/gallery.dart';
import 'package:kufta_percha/pages/homepage.dart';
import 'package:kufta_percha/pages/settings/settings.dart';
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavBar(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.r.dp(2.5)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              width: widget.r.wp(90),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(60),
                borderRadius: BorderRadius.circular(widget.r.dp(2.5)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(20),
                    blurRadius: 20,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(bottomNavBarItems.length, (index) {
                  final isActive = index == widget.currentIndex;
                  return Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      onTap: () => widget.onTap(index),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),

                        child: Opacity(
                          opacity: isActive ? 1 : 0.4,
                          child: Icon(
                            size: widget.r.dp(2.6),
                            bottomNavBarItems[index].icon,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
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
