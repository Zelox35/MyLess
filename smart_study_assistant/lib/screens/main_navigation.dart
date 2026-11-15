import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'chat/chat_screen.dart';
import 'notes/notes_screen.dart';
import 'flashcards/flashcards_screen.dart';
import 'stats/stats_screen.dart';
import 'study_plan/study_plan_screen.dart';
import 'settings/settings_screen.dart';
import '../core/theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ChatScreen(),
    NotesScreen(),
    FlashcardsScreen(),
    StatsScreen(),
  ];

  void _openStudyPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudyPlanScreen()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openStudyPlan,
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
              label: const Text('Çalışma Planı',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  index: 0,
                  currentIndex: _currentIndex,
                  icon: Icons.home_rounded,
                  label: 'Ana Sayfa',
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  index: 1,
                  currentIndex: _currentIndex,
                  icon: Icons.smart_toy_rounded,
                  label: 'AI Chat',
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  index: 2,
                  currentIndex: _currentIndex,
                  icon: Icons.description_rounded,
                  label: 'Notlar',
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  index: 3,
                  currentIndex: _currentIndex,
                  icon: Icons.style_rounded,
                  label: 'Kartlar',
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _NavItem(
                  index: 4,
                  currentIndex: _currentIndex,
                  icon: Icons.bar_chart_rounded,
                  label: 'İstatistik',
                  onTap: () => setState(() => _currentIndex = 4),
                ),
                _NavItem(
                  index: -1,
                  currentIndex: _currentIndex,
                  icon: Icons.settings_rounded,
                  label: 'Ayarlar',
                  onTap: _openSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex && index >= 0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primaryColor : AppTheme.textMutedColor,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppTheme.primaryColor : AppTheme.textMutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
