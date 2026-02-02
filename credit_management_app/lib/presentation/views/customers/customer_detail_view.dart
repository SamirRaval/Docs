import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/customer_controller.dart';
import '../../controllers/credit_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_time_utils.dart';

/// Customer Detail View
class CustomerDetailView extends GetView<CustomerController> {
  const CustomerDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (controller.selectedCustomer.value != null) {
                controller.populateFormForEdit(controller.selectedCustomer.value!);
                Get.toNamed('/customers/add');
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Delete Customer'),
                    content: const Text('Are you sure you want to delete this customer?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true && controller.selectedCustomer.value != null) {
                  await controller.deleteCustomer(controller.selectedCustomer.value!.id);
                  Get.back();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final customer = controller.selectedCustomer.value;
        if (customer == null) {
          return const Center(child: Text('Customer not found'));
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: _getRiskColor(customer.riskLevel).withOpacity(0.1),
                        child: Text(
                          customer.initials,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _getRiskColor(customer.riskLevel),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (customer.companyName != null && customer.companyName!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            customer.companyName!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatusBadge(customer.status),
                          const SizedBox(width: 8),
                          _buildRiskBadge(customer.riskLevel),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Credit Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Credit Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryItem(
                              'Credit Limit',
                              CurrencyUtils.formatCurrency(customer.creditLimit),
                              AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              'Current Balance',
                              CurrencyUtils.formatCurrency(customer.currentBalance),
                              AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryItem(
                              'Available Credit',
                              CurrencyUtils.formatCurrency(customer.availableCredit),
                              AppColors.success,
                            ),
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              'Credit Score',
                              customer.creditScore.toString(),
                              AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Utilization bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Credit Utilization'),
                              Text('${customer.utilizationPercentage.toStringAsFixed(1)}%'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: customer.utilizationPercentage / 100,
                              backgroundColor: AppColors.border,
                              color: customer.utilizationPercentage > 80
                                  ? AppColors.error
                                  : customer.utilizationPercentage > 50
                                      ? AppColors.warning
                                      : AppColors.success,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contact Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.email, customer.email),
                      _buildInfoRow(Icons.phone, customer.phone),
                      if (customer.fullAddress.isNotEmpty)
                        _buildInfoRow(Icons.location_on, customer.fullAddress),
                      if (customer.taxId != null && customer.taxId!.isNotEmpty)
                        _buildInfoRow(Icons.badge, 'Tax ID: ${customer.taxId}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Metadata
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Info',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Created: ${DateTimeUtils.formatDisplayDate(customer.createdAt)}',
                      ),
                      _buildInfoRow(
                        Icons.update,
                        'Updated: ${DateTimeUtils.getRelativeTime(customer.updatedAt)}',
                      ),
                      _buildInfoRow(
                        customer.isSynced ? Icons.cloud_done : Icons.cloud_off,
                        customer.isSynced ? 'Synced' : 'Pending sync',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to credits for this customer
                        Get.find<CreditController>().setSearchQuery(customer.name);
                        Get.toNamed('/credits');
                      },
                      icon: const Icon(Icons.credit_card),
                      label: const Text('View Credits'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to add transaction for this customer
                        Get.find<TransactionController>().selectedCustomer.value = customer;
                        Get.toNamed('/transactions/add');
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Add Payment'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusBadge(String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRiskColor(risk).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${risk.toUpperCase()} RISK',
        style: TextStyle(
          color: _getRiskColor(risk),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
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
}
