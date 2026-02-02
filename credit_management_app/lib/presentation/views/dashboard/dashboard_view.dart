import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../widgets/stat_card.dart';
import '../widgets/sync_status_widget.dart';

/// Dashboard View - Main home screen
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(DashboardController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          const SyncStatusWidget(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshDashboardData(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                controller.goToSettings();
              } else if (value == 'logout') {
                Get.find<AuthController>().logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: () => controller.refreshDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Grid
                _buildStatsGrid(),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                _buildQuickActions(),
                
                const SizedBox(height: 24),
                
                // Recent Activity
                _buildRecentActivity(),
                
                const SizedBox(height: 24),
                
                // Overdue Credits
                if (controller.overdueList.isNotEmpty)
                  _buildOverdueSection(),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            Obx(() => StatCard(
              title: 'Total Customers',
              value: controller.totalCustomers.value.toString(),
              icon: Icons.people,
              color: AppColors.primary,
              onTap: () => controller.goToCustomers(),
            )),
            Obx(() => StatCard(
              title: 'Active Credits',
              value: controller.activeCredits.value.toString(),
              icon: Icons.credit_card,
              color: AppColors.secondary,
              onTap: () => controller.goToCredits(),
            )),
            Obx(() => StatCard(
              title: 'Outstanding',
              value: CurrencyUtils.formatCompactCurrency(controller.totalOutstandingAmount.value),
              icon: Icons.account_balance,
              color: AppColors.warning,
              onTap: () => controller.goToCredits(),
            )),
            Obx(() => StatCard(
              title: 'Overdue',
              value: controller.overdueCredits.value.toString(),
              icon: Icons.warning_amber,
              color: AppColors.error,
              onTap: () => controller.goToCredits(),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.person_add,
                label: 'Add Customer',
                color: AppColors.primary,
                onTap: () => Get.toNamed('/customers/add'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_card,
                label: 'New Credit',
                color: AppColors.secondary,
                onTap: () => Get.toNamed('/credits/add'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.payment,
                label: 'Record Payment',
                color: AppColors.accent,
                onTap: () => Get.toNamed('/transactions/add'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => controller.goToTransactions(),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.recentTransactions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: AppColors.textTertiary),
                    SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentTransactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = controller.recentTransactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.isCredit
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    child: Icon(
                      transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: transaction.isCredit ? AppColors.success : AppColors.error,
                    ),
                  ),
                  title: Text(
                    transaction.customerName ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    transaction.typeDisplayName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    transaction.displayAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: transaction.isCredit ? AppColors.success : AppColors.error,
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOverdueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.error),
            SizedBox(width: 8),
            Text(
              'Overdue Credits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.overdueList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final credit = controller.overdueList[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFEE2E2),
                  child: Icon(Icons.warning, color: AppColors.error),
                ),
                title: Text(
                  credit.customerName ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${credit.daysOverdue} days overdue',
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
                trailing: Text(
                  CurrencyUtils.formatCurrency(credit.remainingAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              );
            },
          ),
        )),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            controller.goToCustomers();
            break;
          case 2:
            controller.goToCredits();
            break;
          case 3:
            controller.goToTransactions();
            break;
          case 4:
            controller.goToReports();
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Customers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card),
          label: 'Credits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Reports',
        ),
      ],
    );
  }
}
