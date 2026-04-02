import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(user: widget.user),
    const ExploreScreen(),
    ProfileScreen(user: widget.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12121C),
          border: Border(
            top: BorderSide(color: AppColors.bgCardBorder, width: .5))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'My agents',
                active: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0)),
              _NavItem(
                icon: Icons.explore_rounded,
                label: 'Explore',
                active: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1)),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon,
          color: active ? AppColors.accent : AppColors.textMuted,
          size: 22),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          color: active ? AppColors.accent : AppColors.textMuted,
          fontSize: 10, fontWeight: FontWeight.w500)),
        if (active) ...[
          const SizedBox(height: 4),
          Container(width: 4, height: 4,
            decoration: const BoxDecoration(
              color: AppColors.accent, shape: BoxShape.circle)),
        ],
      ]),
    ));
}
