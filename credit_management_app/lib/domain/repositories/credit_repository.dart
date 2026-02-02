import '../entities/credit_entity.dart';

/// Abstract repository interface for credit operations
abstract class CreditRepository {
  /// Get all credits
  Future<List<CreditEntity>> getAllCredits();

  /// Get credit by ID
  Future<CreditEntity?> getCreditById(String id);

  /// Get credits by customer ID
  Future<List<CreditEntity>> getCreditsByCustomerId(String customerId);

  /// Get credits by status
  Future<List<CreditEntity>> getCreditsByStatus(String status);

  /// Get active credits
  Future<List<CreditEntity>> getActiveCredits();

  /// Get overdue credits
  Future<List<CreditEntity>> getOverdueCredits();

  /// Create a new credit
  Future<CreditEntity> createCredit(CreditEntity credit);

  /// Update an existing credit
  Future<CreditEntity> updateCredit(CreditEntity credit);

  /// Delete a credit
  Future<bool> deleteCredit(String id);

  /// Get total credits count
  Future<int> getTotalCreditsCount();

  /// Get total credit amount
  Future<double> getTotalCreditAmount();

  /// Get total outstanding amount
  Future<double> getTotalOutstandingAmount();

  /// Get credits by type
  Future<List<CreditEntity>> getCreditsByType(String creditType);

  /// Get credits due within days
  Future<List<CreditEntity>> getCreditsDueWithinDays(int days);

  /// Record payment against credit
  Future<CreditEntity> recordPayment(String creditId, double amount);

  /// Get recent credits
  Future<List<CreditEntity>> getRecentCredits({int limit = 5});

  /// Get unsynced credits
  Future<List<CreditEntity>> getUnsyncedCredits();

  /// Mark credit as synced
  Future<void> markCreditAsSynced(String id);
}
