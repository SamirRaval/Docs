/// Transaction entity representing a financial transaction
class TransactionEntity {
  final String id;
  final String customerId;
  final String? creditId;
  final String? customerName;
  final double amount;
  final String type; // credit, debit, payment, refund
  final String status; // pending, completed, failed, cancelled
  final String? description;
  final String? referenceNumber;
  final String paymentMethod; // cash, bank_transfer, check, card, upi
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  TransactionEntity({
    required this.id,
    required this.customerId,
    this.creditId,
    this.customerName,
    required this.amount,
    required this.type,
    this.status = 'pending',
    this.description,
    this.referenceNumber,
    this.paymentMethod = 'cash',
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  /// Check if transaction is a credit (money in)
  bool get isCredit => type == 'credit' || type == 'payment';

  /// Check if transaction is a debit (money out)
  bool get isDebit => type == 'debit' || type == 'refund';

  /// Check if transaction is completed
  bool get isCompleted => status == 'completed';

  /// Check if transaction is pending
  bool get isPending => status == 'pending';

  /// Get display amount with sign
  String get displayAmount {
    final sign = isCredit ? '+' : '-';
    return '$sign\$${amount.toStringAsFixed(2)}';
  }

  /// Get transaction type display name
  String get typeDisplayName {
    switch (type) {
      case 'credit':
        return 'Credit';
      case 'debit':
        return 'Debit';
      case 'payment':
        return 'Payment';
      case 'refund':
        return 'Refund';
      default:
        return type;
    }
  }

  /// Get payment method display name
  String get paymentMethodDisplayName {
    switch (paymentMethod) {
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'check':
        return 'Check';
      case 'card':
        return 'Card';
      case 'upi':
        return 'UPI';
      default:
        return paymentMethod;
    }
  }

  TransactionEntity copyWith({
    String? id,
    String? customerId,
    String? creditId,
    String? customerName,
    double? amount,
    String? type,
    String? status,
    String? description,
    String? referenceNumber,
    String? paymentMethod,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      creditId: creditId ?? this.creditId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
