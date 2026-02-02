import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/transaction_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_time_utils.dart';

/// Transaction List View
class TransactionListView extends GetView<TransactionController> {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(TransactionController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
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
                hintText: 'Search transactions...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          
          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() {
              double totalIn = 0;
              double totalOut = 0;
              
              for (final t in controller.transactions) {
                if (t.isCompleted) {
                  if (t.isCredit) {
                    totalIn += t.amount;
                  } else {
                    totalOut += t.amount;
                  }
                }
              }
              
              return Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Money In',
                      CurrencyUtils.formatCompactCurrency(totalIn),
                      AppColors.success,
                      Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Money Out',
                      CurrencyUtils.formatCompactCurrency(totalOut),
                      AppColors.error,
                      Icons.arrow_upward,
                    ),
                  ),
                ],
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Transaction list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredTransactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        controller.transactions.isEmpty
                            ? 'No transactions yet'
                            : 'No transactions found',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.goToAddTransaction,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Transaction'),
                      ),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: controller.loadTransactions,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.filteredTransactions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
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
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${transaction.typeDisplayName} • ${transaction.paymentMethodDisplayName}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              DateTimeUtils.formatDisplayDate(transaction.transactionDate),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              transaction.displayAmount,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: transaction.isCredit ? AppColors.success : AppColors.error,
                              ),
                            ),
                            _buildStatusChip(transaction.status),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () => _showTransactionDetails(context, transaction),
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
        onPressed: controller.goToAddTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'cancelled':
      case 'failed':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
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
              'Filter Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
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
                  label: const Text('Payment'),
                  selected: controller.typeFilter.value == 'payment',
                  onSelected: (_) => controller.setTypeFilter('payment'),
                ),
                ChoiceChip(
                  label: const Text('Credit'),
                  selected: controller.typeFilter.value == 'credit',
                  onSelected: (_) => controller.setTypeFilter('credit'),
                ),
                ChoiceChip(
                  label: const Text('Debit'),
                  selected: controller.typeFilter.value == 'debit',
                  onSelected: (_) => controller.setTypeFilter('debit'),
                ),
                ChoiceChip(
                  label: const Text('Refund'),
                  selected: controller.typeFilter.value == 'refund',
                  onSelected: (_) => controller.setTypeFilter('refund'),
                ),
              ],
            )),
            const SizedBox(height: 16),
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
                  label: const Text('Completed'),
                  selected: controller.statusFilter.value == 'completed',
                  onSelected: (_) => controller.setStatusFilter('completed'),
                ),
                ChoiceChip(
                  label: const Text('Pending'),
                  selected: controller.statusFilter.value == 'pending',
                  onSelected: (_) => controller.setStatusFilter('pending'),
                ),
              ],
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, transaction) {
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
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: transaction.isCredit
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  radius: 24,
                  child: Icon(
                    transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: transaction.isCredit ? AppColors.success : AppColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.customerName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        transaction.typeDisplayName,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  transaction.displayAmount,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: transaction.isCredit ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow('Reference', transaction.referenceNumber ?? 'N/A'),
            _buildDetailRow('Payment Method', transaction.paymentMethodDisplayName),
            _buildDetailRow('Status', transaction.status.toUpperCase()),
            _buildDetailRow('Date', DateTimeUtils.formatDisplayDateTime(transaction.transactionDate)),
            if (transaction.description != null && transaction.description!.isNotEmpty)
              _buildDetailRow('Description', transaction.description!),
            _buildDetailRow('Synced', transaction.isSynced ? 'Yes' : 'No'),
            const SizedBox(height: 16),
            if (transaction.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                    controller.cancelTransaction(transaction.id);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Cancel Transaction'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
