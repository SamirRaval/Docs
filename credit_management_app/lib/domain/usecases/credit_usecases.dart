import '../entities/credit_entity.dart';
import '../repositories/credit_repository.dart';

/// Use cases for credit operations
class CreditUseCases {
  final CreditRepository _repository;

  CreditUseCases(this._repository);

  /// Get all credits
  Future<List<CreditEntity>> getAllCredits() {
    return _repository.getAllCredits();
  }

  /// Get credit by ID
  Future<CreditEntity?> getCreditById(String id) {
    return _repository.getCreditById(id);
  }

  /// Get credits by customer ID
  Future<List<CreditEntity>> getCreditsByCustomerId(String customerId) {
    return _repository.getCreditsByCustomerId(customerId);
  }

  /// Get credits by status
  Future<List<CreditEntity>> getCreditsByStatus(String status) {
    return _repository.getCreditsByStatus(status);
  }

  /// Get active credits
  Future<List<CreditEntity>> getActiveCredits() {
    return _repository.getActiveCredits();
  }

  /// Get overdue credits
  Future<List<CreditEntity>> getOverdueCredits() {
    return _repository.getOverdueCredits();
  }

  /// Create a new credit
  Future<CreditEntity> createCredit({
    required String customerId,
    String? customerName,
    required double principalAmount,
    double interestRate = 0.0,
    required int termMonths,
    required DateTime startDate,
    String creditType = 'personal',
    String? purpose,
    String? notes,
  }) {
    final now = DateTime.now();
    
    // Calculate total amount with interest
    final totalInterest = principalAmount * (interestRate / 100) * (termMonths / 12);
    final totalAmount = principalAmount + totalInterest;
    
    // Calculate due date
    final dueDate = startDate.add(Duration(days: termMonths * 30));

    final credit = CreditEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customerId,
      customerName: customerName,
      principalAmount: principalAmount,
      interestRate: interestRate,
      totalAmount: totalAmount,
      paidAmount: 0.0,
      remainingAmount: totalAmount,
      termMonths: termMonths,
      startDate: startDate,
      dueDate: dueDate,
      status: 'pending',
      creditType: creditType,
      purpose: purpose,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
    return _repository.createCredit(credit);
  }

  /// Approve a credit
  Future<CreditEntity> approveCredit(String creditId) async {
    final credit = await _repository.getCreditById(creditId);
    if (credit == null) throw Exception('Credit not found');

    final updatedCredit = credit.copyWith(
      status: 'active',
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    return _repository.updateCredit(updatedCredit);
  }

  /// Reject a credit
  Future<CreditEntity> rejectCredit(String creditId, {String? reason}) async {
    final credit = await _repository.getCreditById(creditId);
    if (credit == null) throw Exception('Credit not found');

    final updatedCredit = credit.copyWith(
      status: 'rejected',
      notes: reason ?? credit.notes,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    return _repository.updateCredit(updatedCredit);
  }

  /// Record a payment against credit
  Future<CreditEntity> recordPayment(String creditId, double amount) async {
    final credit = await _repository.getCreditById(creditId);
    if (credit == null) throw Exception('Credit not found');

    final newPaidAmount = credit.paidAmount + amount;
    final newRemainingAmount = credit.totalAmount - newPaidAmount;
    
    String newStatus = credit.status;
    if (newRemainingAmount <= 0) {
      newStatus = 'closed';
    }

    final updatedCredit = credit.copyWith(
      paidAmount: newPaidAmount,
      remainingAmount: newRemainingAmount > 0 ? newRemainingAmount : 0,
      status: newStatus,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    return _repository.updateCredit(updatedCredit);
  }

  /// Close a credit
  Future<CreditEntity> closeCredit(String creditId) async {
    final credit = await _repository.getCreditById(creditId);
    if (credit == null) throw Exception('Credit not found');

    final updatedCredit = credit.copyWith(
      status: 'closed',
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    return _repository.updateCredit(updatedCredit);
  }

  /// Delete a credit
  Future<bool> deleteCredit(String id) {
    return _repository.deleteCredit(id);
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final totalCount = await _repository.getTotalCreditsCount();
    final totalAmount = await _repository.getTotalCreditAmount();
    final outstandingAmount = await _repository.getTotalOutstandingAmount();
    final activeCredits = await _repository.getActiveCredits();
    final overdueCredits = await _repository.getOverdueCredits();
    final recentCredits = await _repository.getRecentCredits();

    return {
      'totalCredits': totalCount,
      'totalAmount': totalAmount,
      'outstandingAmount': outstandingAmount,
      'activeCount': activeCredits.length,
      'overdueCount': overdueCredits.length,
      'recentCredits': recentCredits,
    };
  }

  /// Get credits due within specified days
  Future<List<CreditEntity>> getCreditsDueWithinDays(int days) {
    return _repository.getCreditsDueWithinDays(days);
  }

  /// Get unsynced credits for sync
  Future<List<CreditEntity>> getUnsyncedCredits() {
    return _repository.getUnsyncedCredits();
  }

  /// Mark credit as synced
  Future<void> markCreditAsSynced(String id) {
    return _repository.markCreditAsSynced(id);
  }
}
