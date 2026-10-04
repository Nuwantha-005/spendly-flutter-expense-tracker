import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../expenses/presentation/expenses_screen.dart';
import '../../settings/presentation/settings_screen.dart';

/// Main shell managing bottom navigation for the 4 core sections:
/// 1. Dashboard
/// 2. Expenses
/// 3. Add Expense (Prominent central action)
/// 4. Settings
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pages = <Widget>[
      DashboardScreen(
        onNavigateToExpenses: () {
          setState(() {
            _activeIndex = 1;
          });
        },
      ),
      const ExpensesScreen(),
      const SettingsScreen(),
    ];

    // Map nav bar index (0: Dashboard, 1: Expenses, 2: Settings) to page index (0, 1, 2)
    final pageIndex = _activeIndex >= 2 ? 2 : _activeIndex;

    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline,
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm,
              vertical: AppDimensions.spacingXs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: _activeIndex == 0,
                  onTap: () {
                    setState(() {
                      _activeIndex = 0;
                    });
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Expenses',
                  isSelected: _activeIndex == 1,
                  onTap: () {
                    setState(() {
                      _activeIndex = 1;
                    });
                  },
                ),
                _buildProminentAddAction(
                  context: context,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.addExpense);
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: _activeIndex == 2,
                  onTap: () {
                    setState(() {
                      _activeIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required dynamic activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: AppDimensions.iconMd,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProminentAddAction({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              color: theme.colorScheme.onPrimary,
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Add',
            style: AppTextStyles.labelSmall.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
