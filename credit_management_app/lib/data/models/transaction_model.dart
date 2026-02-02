import '../../domain/entities/transaction_entity.dart';

/// Transaction data model for local storage
class TransactionModel {
  final String id;
  final String customerId;
  final String? creditId;
  final String? customerName;
  final double amount;
  final String type;
  final String status;
  final String? description;
  final String? referenceNumber;
  final String paymentMethod;
  final String transactionDate;
  final String createdAt;
  final String updatedAt;
  final bool isSynced;

  TransactionModel({
    required this.id,
    required this.customerId,
    this.creditId,
    this.customerName,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    this.referenceNumber,
    required this.paymentMethod,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });

  /// Convert from JSON Map
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      creditId: json['creditId'] as String?,
      customerName: json['customerName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      status: json['status'] as String? ?? 'pending',
      description: json['description'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      transactionDate: json['transactionDate'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'creditId': creditId,
      'customerName': customerName,
      'amount': amount,
      'type': type,
      'status': status,
      'description': description,
      'referenceNumber': referenceNumber,
      'paymentMethod': paymentMethod,
      'transactionDate': transactionDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced,
    };
  }

  /// Convert from Entity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      customerId: entity.customerId,
      creditId: entity.creditId,
      customerName: entity.customerName,
      amount: entity.amount,
      type: entity.type,
      status: entity.status,
      description: entity.description,
      referenceNumber: entity.referenceNumber,
      paymentMethod: entity.paymentMethod,
      transactionDate: entity.transactionDate.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      isSynced: entity.isSynced,
    );
  }

  /// Convert to Entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      customerId: customerId,
      creditId: creditId,
      customerName: customerName,
      amount: amount,
      type: type,
      status: status,
      description: description,
      referenceNumber: referenceNumber,
      paymentMethod: paymentMethod,
      transactionDate: DateTime.parse(transactionDate),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isSynced: isSynced,
    );
  }
}
