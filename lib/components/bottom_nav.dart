import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70, // Reduced height for modern look
          child: Theme(
            data: Theme.of(context).copyWith(
              navigationBarTheme: NavigationBarThemeData(
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    );
                  }
                  return GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  );
                }),
              ),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              height: 70,
              indicatorColor: const Color(0xFF3B82F6).withOpacity(0.1),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    color: currentIndex == 0
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF6B7280),
                    size: 24,
                  ),
                  selectedIcon: Icon(
                    Icons.home,
                    color: const Color(0xFF3B82F6),
                    size: 24,
                  ),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.folder_outlined,
                    color: currentIndex == 1
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF6B7280),
                    size: 24,
                  ),
                  selectedIcon: Icon(
                    Icons.folder,
                    color: const Color(0xFF3B82F6),
                    size: 24,
                  ),
                  label: 'Documents',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.lightbulb_outlined,
                    color: currentIndex == 2
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF6B7280),
                    size: 24,
                  ),
                  selectedIcon: Icon(
                    Icons.lightbulb,
                    color: const Color(0xFF3B82F6),
                    size: 24,
                  ),
                  label: 'Knowledge',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
