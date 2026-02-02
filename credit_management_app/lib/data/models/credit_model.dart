import '../../domain/entities/credit_entity.dart';

/// Credit data model for local storage
class CreditModel {
  final String id;
  final String customerId;
  final String? customerName;
  final double principalAmount;
  final double interestRate;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final int termMonths;
  final String startDate;
  final String dueDate;
  final String status;
  final String creditType;
  final String? purpose;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final bool isSynced;

  CreditModel({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.principalAmount,
    required this.interestRate,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.termMonths,
    required this.startDate,
    required this.dueDate,
    required this.status,
    required this.creditType,
    this.purpose,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });

  /// Convert from JSON Map
  factory CreditModel.fromJson(Map<String, dynamic> json) {
    return CreditModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String?,
      principalAmount: (json['principalAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      termMonths: json['termMonths'] as int,
      startDate: json['startDate'] as String,
      dueDate: json['dueDate'] as String,
      status: json['status'] as String? ?? 'pending',
      creditType: json['creditType'] as String? ?? 'personal',
      purpose: json['purpose'] as String?,
      notes: json['notes'] as String?,
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
      'customerName': customerName,
      'principalAmount': principalAmount,
      'interestRate': interestRate,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'termMonths': termMonths,
      'startDate': startDate,
      'dueDate': dueDate,
      'status': status,
      'creditType': creditType,
      'purpose': purpose,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced,
    };
  }

  /// Convert from Entity
  factory CreditModel.fromEntity(CreditEntity entity) {
    return CreditModel(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName,
      principalAmount: entity.principalAmount,
      interestRate: entity.interestRate,
      totalAmount: entity.totalAmount,
      paidAmount: entity.paidAmount,
      remainingAmount: entity.remainingAmount,
      termMonths: entity.termMonths,
      startDate: entity.startDate.toIso8601String(),
      dueDate: entity.dueDate.toIso8601String(),
      status: entity.status,
      creditType: entity.creditType,
      purpose: entity.purpose,
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      isSynced: entity.isSynced,
    );
  }

  /// Convert to Entity
  CreditEntity toEntity() {
    return CreditEntity(
      id: id,
      customerId: customerId,
      customerName: customerName,
      principalAmount: principalAmount,
      interestRate: interestRate,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      termMonths: termMonths,
      startDate: DateTime.parse(startDate),
      dueDate: DateTime.parse(dueDate),
      status: status,
      creditType: creditType,
      purpose: purpose,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isSynced: isSynced,
    );
  }
}
