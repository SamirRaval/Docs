import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'local_database_service.dart';

/// Service for managing offline sync operations
class SyncService extends GetxService {
  final LocalDatabaseService _localDatabase;
  
  // Observables
  final RxBool isOnline = false.obs;
  final RxBool isSyncing = false.obs;
  final RxInt pendingSyncCount = 0.obs;
  final RxString lastSyncTime = ''.obs;

  // Connectivity subscription
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Sync timer
  Timer? _syncTimer;

  SyncService(this._localDatabase);

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _startPeriodicSync();
    _updatePendingSyncCount();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    super.onClose();
  }

  /// Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    // Check initial connectivity
    final result = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(result);

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (result) {
        _updateConnectivityStatus(result);
        if (isOnline.value) {
          // Trigger sync when coming online
          syncAll();
        }
      },
    );
  }

  /// Update connectivity status
  void _updateConnectivityStatus(List<ConnectivityResult> result) {
    isOnline.value = result.isNotEmpty && 
                     !result.contains(ConnectivityResult.none);
  }

  /// Start periodic sync (every 5 minutes when online)
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) {
        if (isOnline.value && !isSyncing.value) {
          syncAll();
        }
      },
    );
  }

  /// Update pending sync count
  Future<void> _updatePendingSyncCount() async {
    final items = await _localDatabase.getPendingSyncItems();
    pendingSyncCount.value = items.length;
  }

  /// Sync all pending items
  Future<void> syncAll() async {
    if (!isOnline.value || isSyncing.value) return;

    isSyncing.value = true;

    try {
      final pendingItems = await _localDatabase.getPendingSyncItems();

      for (final item in pendingItems) {
        await _syncItem(item);
      }

      lastSyncTime.value = DateTime.now().toIso8601String();
      await _localDatabase.saveSetting('lastSyncTime', lastSyncTime.value);
    } catch (e) {
      // Log error but don't throw
      print('Sync error: $e');
    } finally {
      isSyncing.value = false;
      await _updatePendingSyncCount();
    }
  }

  /// Sync a single item
  Future<void> _syncItem(Map<String, dynamic> item) async {
    try {
      // Simulate API call - in real implementation, this would call the remote API
      await Future.delayed(const Duration(milliseconds: 100));

      // For now, just mark as completed (simulate successful sync)
      // In a real app, this would:
      // 1. Send data to the server
      // 2. Update local record with server response
      // 3. Mark entity as synced

      await _localDatabase.markSyncItemCompleted(item['id']);

      // Mark the entity as synced
      await _markEntityAsSynced(
        item['entityType'],
        item['entityId'],
      );
    } catch (e) {
      await _localDatabase.updateSyncItemRetry(item['id'], e.toString());
    }
  }

  /// Mark entity as synced in local database
  Future<void> _markEntityAsSynced(String entityType, String entityId) async {
    switch (entityType) {
      case 'customer':
        final customer = await _localDatabase.getCustomerById(entityId);
        if (customer != null) {
          final updatedCustomer = customer.toJson();
          updatedCustomer['isSynced'] = true;
          await _localDatabase.saveCustomer(
            customerModelFromJson(updatedCustomer),
          );
        }
        break;
      case 'credit':
        final credit = await _localDatabase.getCreditById(entityId);
        if (credit != null) {
          final updatedCredit = credit.toJson();
          updatedCredit['isSynced'] = true;
          await _localDatabase.saveCredit(
            creditModelFromJson(updatedCredit),
          );
        }
        break;
      case 'transaction':
        final transaction = await _localDatabase.getTransactionById(entityId);
        if (transaction != null) {
          final updatedTransaction = transaction.toJson();
          updatedTransaction['isSynced'] = true;
          await _localDatabase.saveTransaction(
            transactionModelFromJson(updatedTransaction),
          );
        }
        break;
    }
  }

  /// Add entity to sync queue
  Future<void> queueForSync({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    await _localDatabase.addToSyncQueue(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
    );
    await _updatePendingSyncCount();

    // Try to sync immediately if online
    if (isOnline.value) {
      syncAll();
    }
  }

  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    return {
      'isOnline': isOnline.value,
      'isSyncing': isSyncing.value,
      'pendingCount': pendingSyncCount.value,
      'lastSyncTime': lastSyncTime.value,
    };
  }

  /// Force sync
  Future<void> forceSync() async {
    if (isOnline.value) {
      await syncAll();
    }
  }
}

// Helper functions to avoid import issues
import '../../models/customer_model.dart';
import '../../models/credit_model.dart';
import '../../models/transaction_model.dart';

/// Create CustomerModel from JSON map
CustomerModel customerModelFromJson(Map<String, dynamic> json) => 
    CustomerModel.fromJson(json);

/// Create CreditModel from JSON map
CreditModel creditModelFromJson(Map<String, dynamic> json) => 
    CreditModel.fromJson(json);

/// Create TransactionModel from JSON map
TransactionModel transactionModelFromJson(Map<String, dynamic> json) => 
    TransactionModel.fromJson(json);
