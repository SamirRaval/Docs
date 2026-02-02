import '../../domain/entities/credit_entity.dart';
import '../../domain/repositories/credit_repository.dart';
import '../datasources/local/local_database_service.dart';
import '../models/credit_model.dart';

/// Implementation of CreditRepository using local database
class CreditRepositoryImpl implements CreditRepository {
  final LocalDatabaseService _localDatabase;

  CreditRepositoryImpl(this._localDatabase);

  @override
  Future<List<CreditEntity>> getAllCredits() async {
    final models = await _localDatabase.getAllCredits();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CreditEntity?> getCreditById(String id) async {
    final model = await _localDatabase.getCreditById(id);
    return model?.toEntity();
  }

  @override
  Future<List<CreditEntity>> getCreditsByCustomerId(String customerId) async {
    final models = await _localDatabase.getCreditsByCustomerId(customerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CreditEntity>> getCreditsByStatus(String status) async {
    final models = await _localDatabase.getCreditsByStatus(status);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CreditEntity>> getActiveCredits() async {
    return getCreditsByStatus('active');
  }

  @override
  Future<List<CreditEntity>> getOverdueCredits() async {
    final credits = await getAllCredits();
    return credits.where((c) => c.isOverdue).toList();
  }

  @override
  Future<CreditEntity> createCredit(CreditEntity credit) async {
    final model = CreditModel.fromEntity(credit);
    final savedModel = await _localDatabase.saveCredit(model);
    
    // Add to sync queue
    await _localDatabase.addToSyncQueue(
      entityType: 'credit',
      entityId: credit.id,
      operation: 'create',
      data: model.toJson(),
    );
    
    return savedModel.toEntity();
  }

  @override
  Future<CreditEntity> updateCredit(CreditEntity credit) async {
    final model = CreditModel.fromEntity(credit);
    final savedModel = await _localDatabase.saveCredit(model);
    
    // Add to sync queue
    await _localDatabase.addToSyncQueue(
      entityType: 'credit',
      entityId: credit.id,
      operation: 'update',
      data: model.toJson(),
    );
    
    return savedModel.toEntity();
  }

  @override
  Future<bool> deleteCredit(String id) async {
    final result = await _localDatabase.deleteCredit(id);
    
    if (result) {
      // Add to sync queue
      await _localDatabase.addToSyncQueue(
        entityType: 'credit',
        entityId: id,
        operation: 'delete',
        data: {'id': id},
      );
    }
    
    return result;
  }

  @override
  Future<int> getTotalCreditsCount() async {
    final credits = await _localDatabase.getAllCredits();
    return credits.length;
  }

  @override
  Future<double> getTotalCreditAmount() async {
    final credits = await getAllCredits();
    return credits.fold(0.0, (sum, c) => sum + c.totalAmount);
  }

  @override
  Future<double> getTotalOutstandingAmount() async {
    final credits = await getAllCredits();
    return credits.fold(0.0, (sum, c) => sum + c.remainingAmount);
  }

  @override
  Future<List<CreditEntity>> getCreditsByType(String creditType) async {
    final credits = await getAllCredits();
    return credits.where((c) => c.creditType == creditType).toList();
  }

  @override
  Future<List<CreditEntity>> getCreditsDueWithinDays(int days) async {
    final credits = await getAllCredits();
    final now = DateTime.now();
    final targetDate = now.add(Duration(days: days));
    
    return credits.where((c) {
      return c.dueDate.isAfter(now) && c.dueDate.isBefore(targetDate);
    }).toList();
  }

  @override
  Future<CreditEntity> recordPayment(String creditId, double amount) async {
    final credit = await getCreditById(creditId);
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

    return updateCredit(updatedCredit);
  }

  @override
  Future<List<CreditEntity>> getRecentCredits({int limit = 5}) async {
    final credits = await getAllCredits();
    return credits.take(limit).toList();
  }

  @override
  Future<List<CreditEntity>> getUnsyncedCredits() async {
    final models = await _localDatabase.getUnsyncedCredits();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markCreditAsSynced(String id) async {
    final credit = await getCreditById(id);
    if (credit != null) {
      final updatedCredit = credit.copyWith(isSynced: true);
      final model = CreditModel.fromEntity(updatedCredit);
      await _localDatabase.saveCredit(model);
    }
  }
}
