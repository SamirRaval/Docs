import 'package:get/get.dart';

/// Auth Controller for managing authentication state
class AuthController extends GetxController {
  // Authentication state
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    // For demo purposes, always show login screen
    // In real app, check stored auth token
    isLoggedIn.value = false;
  }

  /// Login with email and password (Demo login)
  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Demo validation - accept any non-empty credentials
      if (email.isNotEmpty && password.isNotEmpty) {
        isLoggedIn.value = true;
        userName.value = email.split('@').first;
        userEmail.value = email;
        
        // Navigate to dashboard
        Get.offAllNamed('/dashboard');
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Please enter valid credentials',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    isLoading.value = true;
    
    try {
      // Clear auth state
      isLoggedIn.value = false;
      userName.value = '';
      userEmail.value = '';
      
      // Navigate to login
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  /// Demo login for quick access
  Future<void> demoLogin() async {
    await login('demo@creditmanagement.com', 'demo123');
  }
}
