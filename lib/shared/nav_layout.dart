import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/meal')) currentIndex = 1;
    if (location.startsWith('/history')) currentIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/profile');
              break;
            case 1:
              context.go('/meal');
              break;
            case 2:
              context.go('/history');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: "Refeição"),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: "Histórico"),
        ],
      ),
    );
  }
}
