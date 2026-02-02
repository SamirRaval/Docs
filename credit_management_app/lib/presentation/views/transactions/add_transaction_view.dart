import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/transaction_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';

/// Add Transaction View
class AddTransactionView extends GetView<TransactionController> {
  const AddTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Selection
              const Text(
                'Customer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedCustomer.value?.id,
                decoration: const InputDecoration(
                  labelText: 'Select Customer *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: controller.customers.map((customer) {
                  return DropdownMenuItem(
                    value: customer.id,
                    child: Text(customer.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedCustomer.value = controller.customers
                        .firstWhere((c) => c.id == value);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a customer';
                  }
                  return null;
                },
              )),
              
              const SizedBox(height: 32),
              
              // Transaction Details
              const Text(
                'Transaction Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Transaction Type
              const Text('Transaction Type', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Payment'),
                    selected: controller.transactionType.value == 'payment',
                    onSelected: (_) => controller.transactionType.value = 'payment',
                    selectedColor: AppColors.success.withOpacity(0.2),
                  ),
                  ChoiceChip(
                    label: const Text('Credit'),
                    selected: controller.transactionType.value == 'credit',
                    onSelected: (_) => controller.transactionType.value = 'credit',
                    selectedColor: AppColors.primary.withOpacity(0.2),
                  ),
                  ChoiceChip(
                    label: const Text('Debit'),
                    selected: controller.transactionType.value == 'debit',
                    onSelected: (_) => controller.transactionType.value = 'debit',
                    selectedColor: AppColors.warning.withOpacity(0.2),
                  ),
                  ChoiceChip(
                    label: const Text('Refund'),
                    selected: controller.transactionType.value == 'refund',
                    onSelected: (_) => controller.transactionType.value = 'refund',
                    selectedColor: AppColors.error.withOpacity(0.2),
                  ),
                ],
              )),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: '\$ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Payment Method
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.money, size: 18),
                    label: const Text('Cash'),
                    selected: controller.paymentMethod.value == 'cash',
                    onSelected: (_) => controller.paymentMethod.value = 'cash',
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.account_balance, size: 18),
                    label: const Text('Bank Transfer'),
                    selected: controller.paymentMethod.value == 'bank_transfer',
                    onSelected: (_) => controller.paymentMethod.value = 'bank_transfer',
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.credit_card, size: 18),
                    label: const Text('Card'),
                    selected: controller.paymentMethod.value == 'card',
                    onSelected: (_) => controller.paymentMethod.value = 'card',
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.receipt, size: 18),
                    label: const Text('Check'),
                    selected: controller.paymentMethod.value == 'check',
                    onSelected: (_) => controller.paymentMethod.value = 'check',
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.qr_code, size: 18),
                    label: const Text('UPI'),
                    selected: controller.paymentMethod.value == 'upi',
                    onSelected: (_) => controller.paymentMethod.value = 'upi',
                  ),
                ],
              )),
              const SizedBox(height: 16),
              
              // Transaction Date
              Obx(() => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Transaction Date'),
                subtitle: Text(
                  DateTimeUtils.formatDisplayDate(controller.transactionDate.value),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.transactionDate.value,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    controller.transactionDate.value = date;
                  }
                },
              )),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference Number',
                  hintText: 'Enter reference number (optional)',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description (optional)',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            controller.createTransaction();
                          }
                        },
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Add Transaction'),
                ),
              )),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
