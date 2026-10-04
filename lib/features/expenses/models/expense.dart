import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain model representing an expense in Spendly.
class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  /// Creates an [Expense] from a Firestore [DocumentSnapshot].
  factory Expense.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Expense.fromMap(data, doc.id);
  }

  /// Creates an [Expense] from a raw map and document ID.
  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      title: map['title'] as String? ?? 'Untitled',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? 'Other',
      date: _parseDateTime(map['date']),
      note: map['note'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// Converts the [Expense] to a Map suitable for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'amount': amount,
      'category': category.trim(),
      'date': Timestamp.fromDate(date),
      'note': note?.trim().isEmpty == true ? null : note?.trim(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Safely converts Firestore [Timestamp], [DateTime], or [String] to [DateTime].
  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Creates a copy of this [Expense] with modified fields.
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.category == category &&
        other.date == date &&
        other.note == note &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      amount,
      category,
      date,
      note,
      createdAt,
    );
  }
}
