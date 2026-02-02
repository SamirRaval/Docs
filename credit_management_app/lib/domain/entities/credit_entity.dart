/// Credit entity representing a credit account or loan
class CreditEntity {
  final String id;
  final String customerId;
  final String? customerName;
  final double principalAmount;
  final double interestRate;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final int termMonths;
  final DateTime startDate;
  final DateTime dueDate;
  final String status; // pending, approved, active, closed, overdue
  final String creditType; // personal, business, line_of_credit
  final String? purpose;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  CreditEntity({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.principalAmount,
    this.interestRate = 0.0,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.remainingAmount,
    required this.termMonths,
    required this.startDate,
    required this.dueDate,
    this.status = 'pending',
    this.creditType = 'personal',
    this.purpose,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  /// Calculate monthly payment
  double get monthlyPayment {
    if (termMonths == 0) return 0;
    return totalAmount / termMonths;
  }

  /// Get progress percentage (paid vs total)
  double get progressPercentage {
    if (totalAmount == 0) return 0;
    return (paidAmount / totalAmount) * 100;
  }

  /// Check if credit is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && remainingAmount > 0;
  }

  /// Get days until due
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Get days overdue (if applicable)
  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  /// Check if credit is active
  bool get isActive => status == 'active';

  /// Check if credit is closed
  bool get isClosed => status == 'closed';

  CreditEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    double? principalAmount,
    double? interestRate,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    int? termMonths,
    DateTime? startDate,
    DateTime? dueDate,
    String? status,
    String? creditType,
    String? purpose,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return CreditEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      principalAmount: principalAmount ?? this.principalAmount,
      interestRate: interestRate ?? this.interestRate,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      termMonths: termMonths ?? this.termMonths,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      creditType: creditType ?? this.creditType,
      purpose: purpose ?? this.purpose,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
