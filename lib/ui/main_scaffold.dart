// lib/ui/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:pokey_music/ui/mini_player.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Function(int)? onTabSelected;

  const MainScaffold({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTabSelected,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: "Música",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: "Favoritos",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Ajustes",
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 90,
          child: Material(elevation: 8, child: MiniPlayer()),
        ),
      ],
    );
  }
}
