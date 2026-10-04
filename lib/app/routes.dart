import 'package:flutter/material.dart';
import '../features/auth/auth_gate.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/expenses/models/expense.dart';
import '../features/expenses/add_expense_screen.dart';
import '../features/expenses/expenses_screen.dart';
import '../features/navigation/main_navigation_shell.dart';
import '../features/settings/settings_screen.dart';

/// Centralized application routes for Spendly.
class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainShell = '/main';
  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String addExpense = '/add-expense';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AuthGate(),
        );

      case login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case register:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );

      case mainShell:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainNavigationShell(),
        );

      case dashboard:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DashboardScreen(),
        );

      case expenses:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ExpensesScreen(),
        );

      case addExpense:
        final expense = settings.arguments is Expense ? settings.arguments as Expense : null;
        return MaterialPageRoute<void>(
          settings: settings,
          fullscreenDialog: true,
          builder: (_) => AddExpenseScreen(expense: expense),
        );

      case AppRoutes.settings:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        );

      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
