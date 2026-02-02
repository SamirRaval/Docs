import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/customer_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';

/// Customer List View
class CustomerListView extends GetView<CustomerController> {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(CustomerController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.setSearchQuery('');
                        },
                      )
                    : const SizedBox.shrink()),
              ),
            ),
          ),
          
          // Customer list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredCustomers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        controller.customers.isEmpty
                            ? 'No customers yet'
                            : 'No customers found',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.goToAddCustomer,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Customer'),
                      ),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: controller.loadCustomers,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = controller.filteredCustomers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRiskColor(customer.riskLevel).withOpacity(0.1),
                          child: Text(
                            customer.initials,
                            style: TextStyle(
                              color: _getRiskColor(customer.riskLevel),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer.email, style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildStatusChip(customer.status),
                                const SizedBox(width: 8),
                                _buildRiskChip(customer.riskLevel),
                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyUtils.formatCurrency(customer.currentBalance),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Balance',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => controller.selectCustomer(customer),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToAddCustomer,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = AppColors.success;
        break;
      case 'overdue':
        color = AppColors.error;
        break;
      case 'inactive':
        color = AppColors.textTertiary;
        break;
      default:
        color = AppColors.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRiskChip(String risk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getRiskColor(risk).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${risk.toUpperCase()} RISK',
        style: TextStyle(
          color: _getRiskColor(risk),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'low':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'high':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Customers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: controller.statusFilter.value == 'all',
                  onSelected: (_) => controller.setStatusFilter('all'),
                ),
                ChoiceChip(
                  label: const Text('Active'),
                  selected: controller.statusFilter.value == 'active',
                  onSelected: (_) => controller.setStatusFilter('active'),
                ),
                ChoiceChip(
                  label: const Text('Overdue'),
                  selected: controller.statusFilter.value == 'overdue',
                  onSelected: (_) => controller.setStatusFilter('overdue'),
                ),
                ChoiceChip(
                  label: const Text('Inactive'),
                  selected: controller.statusFilter.value == 'inactive',
                  onSelected: (_) => controller.setStatusFilter('inactive'),
                ),
              ],
            )),
            const SizedBox(height: 16),
            const Text('Risk Level', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: controller.riskFilter.value == 'all',
                  onSelected: (_) => controller.setRiskFilter('all'),
                ),
                ChoiceChip(
                  label: const Text('Low'),
                  selected: controller.riskFilter.value == 'low',
                  onSelected: (_) => controller.setRiskFilter('low'),
                ),
                ChoiceChip(
                  label: const Text('Medium'),
                  selected: controller.riskFilter.value == 'medium',
                  onSelected: (_) => controller.setRiskFilter('medium'),
                ),
                ChoiceChip(
                  label: const Text('High'),
                  selected: controller.riskFilter.value == 'high',
                  onSelected: (_) => controller.setRiskFilter('high'),
                ),
              ],
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
