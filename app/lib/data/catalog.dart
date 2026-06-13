import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

/// Maps API string values onto the typed UI catalog (icons/colors). Keeps the
/// backend payloads simple (plain strings) while the app stays strongly typed.

const _categories = <String, ExpenseCategory>{
  'food': ExpenseCategory('Food', Icons.restaurant_rounded, AppColors.food),
  'travel': ExpenseCategory('Travel', Icons.flight_rounded, AppColors.travel),
  'entertainment':
      ExpenseCategory('Entertainment', Icons.movie_rounded, AppColors.entertainment),
  'shopping':
      ExpenseCategory('Shopping', Icons.shopping_bag_rounded, AppColors.shopping),
};

const _other =
    ExpenseCategory('Other', Icons.receipt_long_rounded, AppColors.primary);

ExpenseCategory resolveCategory(String? key) {
  if (key == null) return _other;
  final k = key.toLowerCase();
  if (_categories.containsKey(k)) return _categories[k]!;
  // tolerate synonyms coming from OCR / AI
  if (k.startsWith('fun')) return _categories['entertainment']!;
  if (k.startsWith('shop')) return _categories['shopping']!;
  return _other;
}

const _tints = [
  AppColors.travel,
  AppColors.food,
  AppColors.entertainment,
  AppColors.shopping,
  AppColors.aiAccent,
];

/// Deterministic tint for a group, derived from its id so it stays stable.
Color tintForId(String id) =>
    _tints[id.codeUnits.fold<int>(0, (a, b) => a + b) % _tints.length];

Color budgetColor(String name) => resolveCategory(name).color;

ActivityType activityTypeFromString(String? t) {
  switch (t) {
    case 'settlement':
      return ActivityType.settlement;
    case 'budget_alert':
      return ActivityType.budgetAlert;
    default:
      return ActivityType.expenseAdded;
  }
}
