import 'package:flutter/material.dart';

/// Lightweight in-memory models. Mirror the future backend schema closely so
/// swapping mock data for the FastAPI client later is a small change.

enum ActivityType { expenseAdded, settlement, budgetAlert }

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;
  const ExpenseCategory(this.name, this.icon, this.color);
}

class Expense {
  final String id;
  final String name;
  final ExpenseCategory category;
  final double amount;
  final String payer;
  final DateTime date;
  final bool settled;

  const Expense({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.payer,
    required this.date,
    this.settled = false,
  });
}

class Budget {
  final String name;
  final double spent;
  final double limit;
  final Color color;
  const Budget({
    required this.name,
    required this.spent,
    required this.limit,
    required this.color,
  });

  double get progress => (spent / limit).clamp(0, 1);
  bool get overBudget => spent > limit;
}

class Group {
  final String id;
  final String name;
  final int memberCount;
  final String currency;
  final double outstanding; // +ve you are owed, -ve you owe
  final String lastActivity;
  final Color tint;

  const Group({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.currency,
    required this.outstanding,
    required this.lastActivity,
    required this.tint,
  });
}

class Activity {
  final ActivityType type;
  final String title;
  final String subtitle;
  final String time;
  const Activity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

enum ChatRole { user, ai, system }

class ChatMessage {
  final ChatRole role;
  final String text;
  final String? time;
  const ChatMessage(this.role, this.text, {this.time});
}
