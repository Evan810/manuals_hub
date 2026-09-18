import 'package:flutter/material.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';

import 'app/models.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomePage(),
          PackagesPage(),
          ToolsPage(),
          AccountPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.primaryBlue,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? AppColors.primaryBlue
              : Theme.of(context).colorScheme.onSurfaceVariant;
          return TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          );
        }),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.home_rounded, color: Colors.white),
            label: '主页',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline_rounded, color: Colors.grey),
            selectedIcon: Icon(Icons.lightbulb_rounded, color: Colors.white),
            label: '锦囊妙计',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.grid_view_rounded, color: Colors.white),
            label: '工具',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: Colors.grey),
            selectedIcon: Icon(Icons.person_rounded, color: Colors.white),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
