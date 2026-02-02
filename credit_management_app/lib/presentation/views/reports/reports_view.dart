import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';

/// Reports View for analytics and charts
class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  final DashboardController _dashboardController = Get.find<DashboardController>();
  final TransactionController _transactionController = Get.put(TransactionController());
  
  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    await _dashboardController.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReportData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Section
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildOverviewCards(),
              
              const SizedBox(height: 24),
              
              // Credit Summary
              const Text(
                'Credit Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildCreditSummary(),
              
              const SizedBox(height: 24),
              
              // Transaction Summary
              const Text(
                'Transaction Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTransactionSummary(),
              
              const SizedBox(height: 24),
              
              // Customer Risk Distribution
              const Text(
                'Risk Distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildRiskDistribution(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Obx(() => GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          'Total Customers',
          _dashboardController.totalCustomers.value.toString(),
          Icons.people,
          AppColors.primary,
        ),
        _buildStatCard(
          'Active Credits',
          _dashboardController.activeCredits.value.toString(),
          Icons.credit_card,
          AppColors.success,
        ),
        _buildStatCard(
          'Outstanding',
          CurrencyUtils.formatCompactCurrency(_dashboardController.totalOutstandingAmount.value),
          Icons.account_balance_wallet,
          AppColors.warning,
        ),
        _buildStatCard(
          'Collection Rate',
          '${_dashboardController.collectionRate.toStringAsFixed(1)}%',
          Icons.trending_up,
          AppColors.secondary,
        ),
      ],
    ));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
          children: [
            _buildSummaryRow(
              'Total Credit Amount',
              CurrencyUtils.formatCurrency(_dashboardController.totalCreditAmount.value),
            ),
            const Divider(),
            _buildSummaryRow(
              'Outstanding Amount',
              CurrencyUtils.formatCurrency(_dashboardController.totalOutstandingAmount.value),
              valueColor: AppColors.warning,
            ),
            const Divider(),
            _buildSummaryRow(
              'Collected Amount',
              CurrencyUtils.formatCurrency(_dashboardController.totalCollectedAmount.value),
              valueColor: AppColors.success,
            ),
            const Divider(),
            _buildSummaryRow(
              'Active Credits',
              _dashboardController.activeCredits.value.toString(),
            ),
            const Divider(),
            _buildSummaryRow(
              'Overdue Credits',
              _dashboardController.overdueCredits.value.toString(),
              valueColor: AppColors.error,
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          double totalIn = 0;
          double totalOut = 0;
          
          for (final t in _transactionController.transactions) {
            if (t.isCompleted) {
              if (t.isCredit) {
                totalIn += t.amount;
              } else {
                totalOut += t.amount;
              }
            }
          }
          
          return Column(
            children: [
              _buildSummaryRow(
                'Total Transactions',
                _transactionController.transactions.length.toString(),
              ),
              const Divider(),
              _buildSummaryRow(
                'Money In (Credits/Payments)',
                CurrencyUtils.formatCurrency(totalIn),
                valueColor: AppColors.success,
              ),
              const Divider(),
              _buildSummaryRow(
                'Money Out (Debits/Refunds)',
                CurrencyUtils.formatCurrency(totalOut),
                valueColor: AppColors.error,
              ),
              const Divider(),
              _buildSummaryRow(
                'Net Amount',
                CurrencyUtils.formatCurrency(totalIn - totalOut),
                valueColor: totalIn - totalOut >= 0 ? AppColors.success : AppColors.error,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRiskDistribution() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRiskRow('Low Risk', 'Good credit score', AppColors.success, 0.6),
            const SizedBox(height: 16),
            _buildRiskRow('Medium Risk', 'Moderate credit score', AppColors.warning, 0.25),
            const SizedBox(height: 16),
            _buildRiskRow('High Risk', 'Low credit score', AppColors.error, 0.15),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskRow(String label, String subtitle, Color color, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.border,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
