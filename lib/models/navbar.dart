import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class NavBarItem {
  final IconData icon;
  NavBarItem({required this.icon});
}

List<NavBarItem> bottomNavBarItems = [
  NavBarItem(icon: Icons.home_rounded),
  NavBarItem(icon: Symbols.dresser_rounded),
  NavBarItem(icon: Icons.event_rounded),
  NavBarItem(icon: Icons.settings_rounded),
];
