import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/local/sync_service.dart';

/// Settings View
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sync Section
          const Text(
            'Sync & Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildSyncStatusTile(),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Sync Now'),
                  subtitle: const Text('Manually sync all pending changes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    try {
                      final syncService = Get.find<SyncService>();
                      await syncService.forceSync();
                      Get.snackbar(
                        'Success',
                        'Sync completed',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Info',
                        'Sync service not available',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Appearance Section
          const Text(
            'Appearance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Theme'),
                  subtitle: const Text('System default'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: const Text('English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Language settings will be available in future updates',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive important alerts'),
                  value: true,
                  onChanged: (value) {
                    Get.snackbar(
                      'Info',
                      'Notifications settings coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.email),
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive email updates'),
                  value: false,
                  onChanged: (value) {
                    Get.snackbar(
                      'Info',
                      'Email notifications coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Logout
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                final confirm = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  Get.find<AuthController>().logout();
                }
              },
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSyncStatusTile() {
    try {
      final syncService = Get.find<SyncService>();
      return Obx(() => ListTile(
        leading: Icon(
          syncService.isOnline.value ? Icons.cloud_done : Icons.cloud_off,
          color: syncService.isOnline.value ? AppColors.success : AppColors.error,
        ),
        title: Text(syncService.isOnline.value ? 'Online' : 'Offline'),
        subtitle: Text(
          'Pending sync: ${syncService.pendingSyncCount.value} items',
        ),
      ));
    } catch (e) {
      return const ListTile(
        leading: Icon(Icons.cloud_off, color: AppColors.textTertiary),
        title: Text('Status Unknown'),
        subtitle: Text('Sync service not available'),
      );
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System Default'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.system);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.light);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              onTap: () {
                Get.changeThemeMode(ThemeMode.dark);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
