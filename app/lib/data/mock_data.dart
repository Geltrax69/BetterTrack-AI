import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

/// Static sample content so every screen renders meaningfully without a backend.
class MockData {
  MockData._();

  static const categories = <String, ExpenseCategory>{
    'food': ExpenseCategory('Food', Icons.restaurant_rounded, AppColors.food),
    'travel':
        ExpenseCategory('Travel', Icons.flight_rounded, AppColors.travel),
    'fun': ExpenseCategory(
        'Entertainment', Icons.movie_rounded, AppColors.entertainment),
    'shop': ExpenseCategory(
        'Shopping', Icons.shopping_bag_rounded, AppColors.shopping),
  };

  static const double totalOwed = 12450; // people owe you
  static const double totalOwing = 4300; // you owe people
  static double get netPosition => totalOwed - totalOwing;

  static final budgets = <Budget>[
    Budget(
        name: 'Food', spent: 8200, limit: 10000, color: AppColors.food),
    Budget(
        name: 'Travel', spent: 14500, limit: 12000, color: AppColors.travel),
    Budget(
        name: 'Entertainment',
        spent: 2100,
        limit: 5000,
        color: AppColors.entertainment),
    Budget(
        name: 'Shopping', spent: 3400, limit: 6000, color: AppColors.shopping),
  ];

  static final activity = <Activity>[
    Activity(
      type: ActivityType.expenseAdded,
      title: 'Dinner at Olive',
      subtitle: 'Sam paid ₹2,400 · Goa Trip',
      time: '2h',
    ),
    Activity(
      type: ActivityType.settlement,
      title: 'Settlement completed',
      subtitle: 'Riya settled ₹1,200 with you',
      time: '5h',
    ),
    Activity(
      type: ActivityType.budgetAlert,
      title: 'Travel budget exceeded',
      subtitle: '₹14,500 of ₹12,000 used',
      time: '1d',
    ),
  ];

  static final groups = <Group>[
    Group(
      id: 'g1',
      name: 'Goa Trip',
      memberCount: 5,
      currency: '₹',
      outstanding: 6200,
      lastActivity: 'Dinner at Olive · 2h ago',
      tint: AppColors.travel,
    ),
    Group(
      id: 'g2',
      name: 'Flat 402',
      memberCount: 3,
      currency: '₹',
      outstanding: -1800,
      lastActivity: 'Electricity bill · 1d ago',
      tint: AppColors.food,
    ),
    Group(
      id: 'g3',
      name: 'Office Lunch',
      memberCount: 8,
      currency: '₹',
      outstanding: 0,
      lastActivity: 'All settled up 🎉 · 3d ago',
      tint: AppColors.entertainment,
    ),
  ];

  static final expenses = <Expense>[
    Expense(
      id: 'e1',
      name: 'Dinner at Olive',
      category: categories['food']!,
      amount: 2400,
      payer: 'Sam',
      date: DateTime(2026, 6, 13),
    ),
    Expense(
      id: 'e2',
      name: 'Cab to airport',
      category: categories['travel']!,
      amount: 850,
      payer: 'You',
      date: DateTime(2026, 6, 12),
    ),
    Expense(
      id: 'e3',
      name: 'Movie night',
      category: categories['fun']!,
      amount: 1200,
      payer: 'Riya',
      date: DateTime(2026, 6, 11),
      settled: true,
    ),
    Expense(
      id: 'e4',
      name: 'Groceries',
      category: categories['shop']!,
      amount: 3400,
      payer: 'You',
      date: DateTime(2026, 6, 10),
    ),
  ];

  static final chat = <ChatMessage>[
    ChatMessage(ChatRole.system, 'Goa Trip group created'),
    ChatMessage(ChatRole.user, 'Add ₹2400 dinner split between everyone',
        time: '9:32'),
    ChatMessage(
      ChatRole.ai,
      'Done! Added “Dinner at Olive” — ₹2,400 split 5 ways (₹480 each). '
      'Sam paid. Want me to remind everyone?',
      time: '9:32',
    ),
    ChatMessage(ChatRole.system, 'Expense added · ₹2,400'),
    ChatMessage(ChatRole.user, 'How much do I owe Sam overall?', time: '9:35'),
    ChatMessage(
      ChatRole.ai,
      'You owe Sam ₹1,180 across 3 expenses. Tap “Settle up” to clear it.',
      time: '9:35',
    ),
  ];

  // Last 6 months total spend for the analytics line/bar chart.
  static const monthlySpend = <double>[8200, 9400, 7600, 11200, 9800, 12450];
  static const months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  // Category split for the pie chart.
  static const categorySplit = <String, double>{
    'Food': 8200,
    'Travel': 14500,
    'Entertainment': 2100,
    'Shopping': 3400,
  };
}
