import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import 'home/home_screen.dart';
import 'documents/documents_screen.dart';
import 'knowledge/knowledge_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DocumentsScreen(),
    const KnowledgeScreen(),
  ];

  void _onNavTap(int index) {
    // If switching to documents tab, trigger a refresh
    if (index == 1 && _currentIndex != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Force a rebuild of the documents screen
        setState(() {
          _currentIndex = index;
        });
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _screens[0], // Home
          _currentIndex == 1
              ? DocumentsScreen(
                  key: ValueKey(
                    'docs_${DateTime.now().millisecondsSinceEpoch}',
                  ),
                )
              : _screens[1], // Documents - recreate when selected
          _screens[2], // Knowledge
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
