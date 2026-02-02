import 'package:get/get.dart';

import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/credit_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/customer_usecases.dart';
import '../../domain/usecases/credit_usecases.dart';
import '../../domain/usecases/transaction_usecases.dart';
import '../../data/datasources/local/sync_service.dart';

/// Dashboard Controller for managing dashboard state and data
class DashboardController extends GetxController {
  final CustomerUseCases _customerUseCases = Get.find<CustomerUseCases>();
  final CreditUseCases _creditUseCases = Get.find<CreditUseCases>();
  final TransactionUseCases _transactionUseCases = Get.find<TransactionUseCases>();
  late final SyncService _syncService;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // Dashboard statistics
  final RxInt totalCustomers = 0.obs;
  final RxInt totalCredits = 0.obs;
  final RxInt activeCredits = 0.obs;
  final RxInt overdueCredits = 0.obs;
  final RxDouble totalCreditAmount = 0.0.obs;
  final RxDouble totalOutstandingAmount = 0.0.obs;
  final RxDouble totalCollectedAmount = 0.0.obs;
  final RxInt pendingSyncCount = 0.obs;

  // Recent data
  final RxList<CustomerEntity> recentCustomers = <CustomerEntity>[].obs;
  final RxList<CreditEntity> recentCredits = <CreditEntity>[].obs;
  final RxList<TransactionEntity> recentTransactions = <TransactionEntity>[].obs;
  final RxList<CreditEntity> overdueList = <CreditEntity>[].obs;

  // Connectivity status
  final RxBool isOnline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSyncService();
    loadDashboardData();
  }

  void _initSyncService() {
    try {
      _syncService = Get.find<SyncService>();
      ever(_syncService.isOnline, (value) => isOnline.value = value);
      ever(_syncService.pendingSyncCount, (value) => pendingSyncCount.value = value);
      isOnline.value = _syncService.isOnline.value;
      pendingSyncCount.value = _syncService.pendingSyncCount.value;
    } catch (e) {
      // SyncService not available yet
    }
  }

  /// Load all dashboard data
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadCustomerStats(),
        _loadCreditStats(),
        _loadTransactionStats(),
        _loadRecentData(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboardData() async {
    isRefreshing.value = true;
    await loadDashboardData();
    isRefreshing.value = false;
  }

  /// Load customer statistics
  Future<void> _loadCustomerStats() async {
    final stats = await _customerUseCases.getDashboardStats();
    totalCustomers.value = stats['totalCustomers'] ?? 0;
    recentCustomers.value = List<CustomerEntity>.from(stats['recentCustomers'] ?? []);
  }

  /// Load credit statistics
  Future<void> _loadCreditStats() async {
    final stats = await _creditUseCases.getDashboardStats();
    totalCredits.value = stats['totalCredits'] ?? 0;
    totalCreditAmount.value = stats['totalAmount'] ?? 0.0;
    totalOutstandingAmount.value = stats['outstandingAmount'] ?? 0.0;
    activeCredits.value = stats['activeCount'] ?? 0;
    overdueCredits.value = stats['overdueCount'] ?? 0;
    recentCredits.value = List<CreditEntity>.from(stats['recentCredits'] ?? []);
    
    // Load overdue credits
    overdueList.value = await _creditUseCases.getOverdueCredits();
  }

  /// Load transaction statistics
  Future<void> _loadTransactionStats() async {
    final stats = await _transactionUseCases.getDashboardStats();
    totalCollectedAmount.value = stats['totalCredits'] ?? 0.0;
    recentTransactions.value = List<TransactionEntity>.from(stats['recentTransactions'] ?? []);
  }

  /// Load recent data
  Future<void> _loadRecentData() async {
    recentTransactions.value = await _transactionUseCases.getRecentTransactions(limit: 5);
  }

  /// Trigger manual sync
  Future<void> triggerSync() async {
    try {
      await _syncService.forceSync();
      Get.snackbar(
        'Sync',
        'Sync completed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Sync failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get collection rate percentage
  double get collectionRate {
    if (totalCreditAmount.value == 0) return 0;
    return (totalCollectedAmount.value / totalCreditAmount.value) * 100;
  }

  /// Navigate to customers list
  void goToCustomers() => Get.toNamed('/customers');

  /// Navigate to credits list
  void goToCredits() => Get.toNamed('/credits');

  /// Navigate to transactions list
  void goToTransactions() => Get.toNamed('/transactions');

  /// Navigate to reports
  void goToReports() => Get.toNamed('/reports');

  /// Navigate to settings
  void goToSettings() => Get.toNamed('/settings');
}
