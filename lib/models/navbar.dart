import 'package:flutter/cupertino.dart';

class NavBarItem {
  final IconData icon;
  NavBarItem({required this.icon});
}

List<NavBarItem> bottomNavBarItems = [
  NavBarItem(icon: CupertinoIcons.house_alt),
  NavBarItem(icon: CupertinoIcons.scribble),
  NavBarItem(icon: CupertinoIcons.search),
  NavBarItem(icon: CupertinoIcons.calendar),
  NavBarItem(icon: CupertinoIcons.settings),
];
