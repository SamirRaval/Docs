import '../../domain/entities/customer_entity.dart';

/// Customer data model for local storage
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? companyName;
  final String? taxId;
  final int creditScore;
  final double creditLimit;
  final double currentBalance;
  final double availableCredit;
  final String riskLevel;
  final String status;
  final String createdAt;
  final String updatedAt;
  final bool isSynced;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.companyName,
    this.taxId,
    required this.creditScore,
    required this.creditLimit,
    required this.currentBalance,
    required this.availableCredit,
    required this.riskLevel,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });

  /// Convert from JSON Map
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      companyName: json['companyName'] as String?,
      taxId: json['taxId'] as String?,
      creditScore: json['creditScore'] as int? ?? 700,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 10000.0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      availableCredit: (json['availableCredit'] as num?)?.toDouble() ?? 10000.0,
      riskLevel: json['riskLevel'] as String? ?? 'low',
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'companyName': companyName,
      'taxId': taxId,
      'creditScore': creditScore,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'availableCredit': availableCredit,
      'riskLevel': riskLevel,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced,
    };
  }

  /// Convert from Entity
  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      postalCode: entity.postalCode,
      companyName: entity.companyName,
      taxId: entity.taxId,
      creditScore: entity.creditScore,
      creditLimit: entity.creditLimit,
      currentBalance: entity.currentBalance,
      availableCredit: entity.availableCredit,
      riskLevel: entity.riskLevel,
      status: entity.status,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      isSynced: entity.isSynced,
    );
  }

  /// Convert to Entity
  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      companyName: companyName,
      taxId: taxId,
      creditScore: creditScore,
      creditLimit: creditLimit,
      currentBalance: currentBalance,
      availableCredit: availableCredit,
      riskLevel: riskLevel,
      status: status,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isSynced: isSynced,
    );
  }
}
