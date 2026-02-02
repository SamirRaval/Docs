import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/credit_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_time_utils.dart';

/// Credit List View
class CreditListView extends GetView<CreditController> {
  const CreditListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(CreditController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits'),
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
              decoration: const InputDecoration(
                hintText: 'Search credits...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          
          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total',
                    controller.credits.length.toString(),
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Active',
                    controller.credits.where((c) => c.status == 'active').length.toString(),
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Overdue',
                    controller.credits.where((c) => c.isOverdue).length.toString(),
                    AppColors.error,
                  ),
                ),
              ],
            )),
          ),
          
          const SizedBox(height: 16),
          
          // Credit list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredCredits.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_off, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        controller.credits.isEmpty
                            ? 'No credits yet'
                            : 'No credits found',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.goToAddCredit,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Credit'),
                      ),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: controller.loadCredits,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredCredits.length,
                  itemBuilder: (context, index) {
                    final credit = controller.filteredCredits[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _showCreditActions(context, credit),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          credit.customerName ?? 'Unknown',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${credit.creditType.toUpperCase()} • ${credit.termMonths} months',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusBadge(credit.status, credit.isOverdue),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Total Amount',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          CurrencyUtils.formatCurrency(credit.totalAmount),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Remaining',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          CurrencyUtils.formatCurrency(credit.remainingAmount),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: credit.remainingAmount > 0
                                                ? AppColors.warning
                                                : AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Due Date',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          DateTimeUtils.formatDisplayDate(credit.dueDate),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: credit.isOverdue
                                                ? AppColors.error
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Progress bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Paid: ${CurrencyUtils.formatCurrency(credit.paidAmount)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${credit.progressPercentage.toStringAsFixed(0)}%',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: credit.progressPercentage / 100,
                                      backgroundColor: AppColors.border,
                                      color: credit.progressPercentage >= 100
                                          ? AppColors.success
                                          : AppColors.primary,
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
        onPressed: controller.goToAddCredit,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isOverdue) {
    Color color;
    String displayStatus = status;
    
    if (isOverdue) {
      color = AppColors.error;
      displayStatus = 'overdue';
    } else {
      switch (status) {
        case 'active':
          color = AppColors.success;
          break;
        case 'pending':
          color = AppColors.warning;
          break;
        case 'closed':
          color = AppColors.textTertiary;
          break;
        case 'rejected':
          color = AppColors.error;
          break;
        default:
          color = AppColors.textSecondary;
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayStatus.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
              'Filter Credits',
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
                  label: const Text('Pending'),
                  selected: controller.statusFilter.value == 'pending',
                  onSelected: (_) => controller.setStatusFilter('pending'),
                ),
                ChoiceChip(
                  label: const Text('Active'),
                  selected: controller.statusFilter.value == 'active',
                  onSelected: (_) => controller.setStatusFilter('active'),
                ),
                ChoiceChip(
                  label: const Text('Closed'),
                  selected: controller.statusFilter.value == 'closed',
                  onSelected: (_) => controller.setStatusFilter('closed'),
                ),
              ],
            )),
            const SizedBox(height: 16),
            const Text('Type', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: controller.typeFilter.value == 'all',
                  onSelected: (_) => controller.setTypeFilter('all'),
                ),
                ChoiceChip(
                  label: const Text('Personal'),
                  selected: controller.typeFilter.value == 'personal',
                  onSelected: (_) => controller.setTypeFilter('personal'),
                ),
                ChoiceChip(
                  label: const Text('Business'),
                  selected: controller.typeFilter.value == 'business',
                  onSelected: (_) => controller.setTypeFilter('business'),
                ),
              ],
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCreditActions(BuildContext context, credit) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (credit.status == 'pending') ...[
              ListTile(
                leading: const Icon(Icons.check_circle, color: AppColors.success),
                title: const Text('Approve Credit'),
                onTap: () {
                  Get.back();
                  controller.approveCredit(credit.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: AppColors.error),
                title: const Text('Reject Credit'),
                onTap: () {
                  Get.back();
                  controller.rejectCredit(credit.id);
                },
              ),
            ],
            if (credit.status == 'active') ...[
              ListTile(
                leading: const Icon(Icons.payment, color: AppColors.primary),
                title: const Text('Record Payment'),
                onTap: () {
                  Get.back();
                  _showPaymentDialog(context, credit);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Credit'),
              onTap: () async {
                Get.back();
                final confirm = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Delete Credit'),
                    content: const Text('Are you sure you want to delete this credit?'),
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
                if (confirm == true) {
                  controller.deleteCredit(credit.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, credit) {
    final amountController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Remaining: ${CurrencyUtils.formatCurrency(credit.remainingAmount)}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '\$ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Get.back();
                controller.recordPayment(credit.id, amount);
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }
}
