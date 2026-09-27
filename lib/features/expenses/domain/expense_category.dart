import 'package:flutter/material.dart';

/// Predefined expense category for Spendly.
class ExpenseCategory {
  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;

  static const List<ExpenseCategory> categories = [
    ExpenseCategory(
      name: 'Food',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFF97316), // Orange
    ),
    ExpenseCategory(
      name: 'Transport',
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF3B82F6), // Blue
    ),
    ExpenseCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFEC4899), // Pink
    ),
    ExpenseCategory(
      name: 'Bills',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFEAB308), // Amber
    ),
    ExpenseCategory(
      name: 'Entertainment',
      icon: Icons.movie_creation_rounded,
      color: Color(0xFF8B5CF6), // Purple
    ),
    ExpenseCategory(
      name: 'Health',
      icon: Icons.medical_services_rounded,
      color: Color(0xFF10B981), // Emerald
    ),
    ExpenseCategory(
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF06B6D4), // Cyan
    ),
    ExpenseCategory(
      name: 'Travel',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF6366F1), // Indigo
    ),
    ExpenseCategory(
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF64748B), // Slate
    ),
  ];

  static ExpenseCategory fromName(String name) {
    return categories.firstWhere(
      (c) => c.name.toLowerCase() == name.trim().toLowerCase(),
      orElse: () => const ExpenseCategory(
        name: 'Other',
        icon: Icons.more_horiz_rounded,
        color: Color(0xFF64748B),
      ),
    );
  }
}
