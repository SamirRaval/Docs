import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/bindings/app_binding.dart';
import 'presentation/views/auth/login_view.dart';
import 'presentation/views/dashboard/dashboard_view.dart';
import 'presentation/views/customers/customer_list_view.dart';
import 'presentation/views/customers/customer_detail_view.dart';
import 'presentation/views/customers/add_customer_view.dart';
import 'presentation/views/credits/credit_list_view.dart';
import 'presentation/views/credits/add_credit_view.dart';
import 'presentation/views/transactions/transaction_list_view.dart';
import 'presentation/views/transactions/add_transaction_view.dart';
import 'presentation/views/settings/settings_view.dart';
import 'presentation/views/reports/reports_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize dependencies
  await DependencyInjection.init();
  
  runApp(const CreditManagementApp());
}

class CreditManagementApp extends StatelessWidget {
  const CreditManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Credit Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: AppBinding(),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginView(),
        ),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardView(),
        ),
        GetPage(
          name: '/customers',
          page: () => const CustomerListView(),
        ),
        GetPage(
          name: '/customers/detail',
          page: () => const CustomerDetailView(),
        ),
        GetPage(
          name: '/customers/add',
          page: () => const AddCustomerView(),
        ),
        GetPage(
          name: '/credits',
          page: () => const CreditListView(),
        ),
        GetPage(
          name: '/credits/add',
          page: () => const AddCreditView(),
        ),
        GetPage(
          name: '/transactions',
          page: () => const TransactionListView(),
        ),
        GetPage(
          name: '/transactions/add',
          page: () => const AddTransactionView(),
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsView(),
        ),
        GetPage(
          name: '/reports',
          page: () => const ReportsView(),
        ),
      ],
    );
  }
}
