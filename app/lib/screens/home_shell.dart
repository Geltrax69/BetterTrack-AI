import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'dashboard_screen.dart';
import 'groups_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'ai_chat_screen.dart';

/// Root scaffold holding the four primary tabs + the soft floating bottom nav.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    DashboardScreen(),
    GroupsScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    (Icons.home_rounded, 'Dashboard'),
    (Icons.groups_rounded, 'Groups'),
    (Icons.pie_chart_rounded, 'Analytics'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: FloatingActionButton(
        heroTag: 'ai_fab',
        backgroundColor: AppColors.aiAccent,
        elevation: 0,
        shape: const CircleBorder(),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AiChatScreen()),
        ),
        child: const Icon(Icons.auto_awesome_rounded,
            color: AppColors.textPrimary),
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        items: _items,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final List<(IconData, String)> items;
  final ValueChanged<int> onTap;
  const _BottomNav(
      {required this.index, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.x16, 0, AppSpacing.x16, AppSpacing.x16),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppTheme.shadow2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavItem(
              icon: items[i].$1,
              label: items[i].$2,
              selected: i == index,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.textPrimary : Colors.white;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: selected ? AppSpacing.x16 : AppSpacing.x12,
            vertical: AppSpacing.x8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: color),
            if (selected) ...[
              const SizedBox(width: AppSpacing.x8),
              Text(label, style: AppType.caption.copyWith(color: color)),
            ],
          ],
        ),
      ),
    );
  }
}
