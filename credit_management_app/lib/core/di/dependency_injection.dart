import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/local/local_database_service.dart';
import '../../data/datasources/local/sync_service.dart';
import '../../data/datasources/local/dummy_data_service.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/credit_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/credit_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/customer_usecases.dart';
import '../../domain/usecases/credit_usecases.dart';
import '../../domain/usecases/transaction_usecases.dart';

/// Dependency Injection configuration
class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    // Initialize Hive boxes
    await _initializeHiveBoxes();

    // Register services
    _registerServices();

    // Register repositories
    _registerRepositories();

    // Register use cases
    _registerUseCases();

    // Load dummy data on first launch
    await _loadDummyDataIfNeeded();
  }

  static Future<void> _initializeHiveBoxes() async {
    await Hive.openBox('customers');
    await Hive.openBox('credits');
    await Hive.openBox('transactions');
    await Hive.openBox('sync_queue');
    await Hive.openBox('settings');
    await Hive.openBox('user');
  }

  static void _registerServices() {
    // Local Database Service
    Get.lazyPut<LocalDatabaseService>(
      () => LocalDatabaseService(),
      fenix: true,
    );

    // Sync Service
    Get.lazyPut<SyncService>(
      () => SyncService(Get.find<LocalDatabaseService>()),
      fenix: true,
    );
  }

  static void _registerRepositories() {
    // Customer Repository
    Get.lazyPut<CustomerRepository>(
      () => CustomerRepositoryImpl(Get.find<LocalDatabaseService>()),
      fenix: true,
    );

    // Credit Repository
    Get.lazyPut<CreditRepository>(
      () => CreditRepositoryImpl(Get.find<LocalDatabaseService>()),
      fenix: true,
    );

    // Transaction Repository
    Get.lazyPut<TransactionRepository>(
      () => TransactionRepositoryImpl(Get.find<LocalDatabaseService>()),
      fenix: true,
    );
  }

  static void _registerUseCases() {
    // Customer Use Cases
    Get.lazyPut<CustomerUseCases>(
      () => CustomerUseCases(Get.find<CustomerRepository>()),
      fenix: true,
    );

    // Credit Use Cases
    Get.lazyPut<CreditUseCases>(
      () => CreditUseCases(Get.find<CreditRepository>()),
      fenix: true,
    );

    // Transaction Use Cases
    Get.lazyPut<TransactionUseCases>(
      () => TransactionUseCases(Get.find<TransactionRepository>()),
      fenix: true,
    );
  }

  /// Load dummy data if this is first launch
  static Future<void> _loadDummyDataIfNeeded() async {
    final settingsBox = Hive.box('settings');
    final hasLoadedDummyData = settingsBox.get('hasLoadedDummyData', defaultValue: false);

    if (!hasLoadedDummyData) {
      final localDb = Get.find<LocalDatabaseService>();

      // Generate dummy data
      final customers = DummyDataService.generateCustomers(count: 15);
      final credits = DummyDataService.generateCredits(customers, maxPerCustomer: 2);
      final transactions = DummyDataService.generateTransactions(customers, credits, count: 40);

      // Save customers
      for (final customer in customers) {
        await localDb.saveCustomer(customer);
      }

      // Save credits
      for (final credit in credits) {
        await localDb.saveCredit(credit);
      }

      // Save transactions
      for (final transaction in transactions) {
        await localDb.saveTransaction(transaction);
      }

      // Mark as loaded
      await settingsBox.put('hasLoadedDummyData', true);
    }
  }
}
