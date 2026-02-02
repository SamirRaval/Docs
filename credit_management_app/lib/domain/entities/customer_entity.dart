/// Customer entity representing a customer in the credit management system
class CustomerEntity {
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  CustomerEntity({
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
    this.creditScore = 700,
    this.creditLimit = 10000.0,
    this.currentBalance = 0.0,
    this.availableCredit = 10000.0,
    this.riskLevel = 'low',
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  /// Get full address string
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  /// Check if customer has available credit
  bool get hasAvailableCredit => availableCredit > 0;

  /// Check if customer is overdue
  bool get isOverdue => currentBalance > 0 && status == 'overdue';

  /// Get utilization percentage
  double get utilizationPercentage {
    if (creditLimit == 0) return 0;
    return (currentBalance / creditLimit) * 100;
  }

  CustomerEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? companyName,
    String? taxId,
    int? creditScore,
    double? creditLimit,
    double? currentBalance,
    double? availableCredit,
    String? riskLevel,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      companyName: companyName ?? this.companyName,
      taxId: taxId ?? this.taxId,
      creditScore: creditScore ?? this.creditScore,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      availableCredit: availableCredit ?? this.availableCredit,
      riskLevel: riskLevel ?? this.riskLevel,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
