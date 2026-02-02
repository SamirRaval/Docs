import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/credit_controller.dart';
import '../controllers/transaction_controller.dart';

/// App binding to initialize all controllers
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Auth Controller - permanent
    Get.put<AuthController>(AuthController(), permanent: true);
    
    // Dashboard Controller
    Get.lazyPut<DashboardController>(() => DashboardController());
    
    // Customer Controller
    Get.lazyPut<CustomerController>(() => CustomerController());
    
    // Credit Controller
    Get.lazyPut<CreditController>(() => CreditController());
    
    // Transaction Controller
    Get.lazyPut<TransactionController>(() => TransactionController());
  }
}
