import 'package:flutter/material.dart';
import '../data/catalog.dart';

/// Lightweight models shared by the mock data and the live API client.
/// `fromJson` factories parse the FastAPI payloads (see backend schemas.py).

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

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

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        category: resolveCategory(j['category'] as String?),
        amount: _toDouble(j['amount']),
        payer: j['payer'] as String? ?? '',
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        settled: j['settled'] as bool? ?? false,
      );
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

  double get progress => limit <= 0 ? 0 : (spent / limit).clamp(0, 1);
  bool get overBudget => spent > limit;

  factory Budget.fromJson(Map<String, dynamic> j) => Budget(
        name: j['name'] as String? ?? 'Budget',
        spent: _toDouble(j['spent']),
        limit: _toDouble(j['limit']),
        color: budgetColor(j['name'] as String? ?? ''),
      );
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

  factory Group.fromJson(Map<String, dynamic> j) {
    final id = j['id'] as String? ?? '';
    return Group(
      id: id,
      name: j['name'] as String? ?? 'Group',
      memberCount: (j['member_count'] as num?)?.toInt() ?? 0,
      currency: j['currency'] as String? ?? '₹',
      outstanding: _toDouble(j['outstanding']),
      lastActivity: j['last_activity'] as String? ?? '',
      tint: tintForId(id),
    );
  }
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

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
        type: activityTypeFromString(j['type'] as String?),
        title: j['title'] as String? ?? '',
        subtitle: j['subtitle'] as String? ?? '',
        time: j['time'] as String? ?? '',
      );
}

/// Dashboard balance summary (GET /api/summary).
class Summary {
  final double owed;
  final double owing;
  final double net;
  const Summary({required this.owed, required this.owing, required this.net});

  factory Summary.fromJson(Map<String, dynamic> j) => Summary(
        owed: _toDouble(j['owed']),
        owing: _toDouble(j['owing']),
        net: _toDouble(j['net']),
      );
}

enum ChatRole { user, ai, system }

class ChatMessage {
  final ChatRole role;
  final String text;
  final String? time;
  const ChatMessage(this.role, this.text, {this.time});
}
