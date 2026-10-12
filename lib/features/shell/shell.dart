import 'package:flutter/material.dart';
import '../ai_lab/ai_lab_screen.dart';
import '../books/books_screen.dart';
import '../home/home_screen.dart';
import '../learning/learning_screen.dart';
import '../tests/tests_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _i = 0;
  void _go(int i) => setState(() => _i = i);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _i == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(0);
      },
      child: Scaffold(
        body: IndexedStack(index: _i, children: [
          HomeScreen(onGo: _go),
          const BooksScreen(),
          const AiLabScreen(),
          const TestsScreen(),
          const LearningScreen(),
        ]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: _go,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Books'),
            NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome_rounded), label: 'AI Lab'),
            NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz_rounded), label: 'Tests'),
            NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school_rounded), label: 'My Learning'),
          ],
        ),
      ),
    );
  }
}
