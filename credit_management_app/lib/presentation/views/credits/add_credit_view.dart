import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/credit_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';

/// Add Credit View
class AddCreditView extends GetView<CreditController> {
  const AddCreditView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Credit'),
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
              
              // Credit Details
              const Text(
                'Credit Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Credit Type
              Obx(() => DropdownButtonFormField<String>(
                value: controller.creditType.value,
                decoration: const InputDecoration(
                  labelText: 'Credit Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'personal', child: Text('Personal Loan')),
                  DropdownMenuItem(value: 'business', child: Text('Business Loan')),
                  DropdownMenuItem(value: 'line_of_credit', child: Text('Line of Credit')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.creditType.value = value;
                  }
                },
              )),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.principalAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Principal Amount *',
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
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.interestRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Interest Rate (%)',
                        hintText: '0',
                        suffixText: '%',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: controller.termMonthsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Term (Months) *',
                        hintText: '12',
                        suffixText: 'months',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final months = int.tryParse(value);
                        if (months == null || months <= 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Start Date
              Obx(() => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Start Date'),
                subtitle: Text(
                  DateTimeUtils.formatDisplayDate(controller.startDate.value),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.startDate.value,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    controller.startDate.value = date;
                  }
                },
              )),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  hintText: 'Enter purpose of credit',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Additional notes (optional)',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Calculated Amount Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Credit Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Principal Amount:'),
                        Obx(() {
                          final amount = double.tryParse(controller.principalAmountController.text) ?? 0;
                          return Text('\$${amount.toStringAsFixed(2)}');
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimated Interest:'),
                        Obx(() {
                          final principal = double.tryParse(controller.principalAmountController.text) ?? 0;
                          final rate = double.tryParse(controller.interestRateController.text) ?? 0;
                          final months = int.tryParse(controller.termMonthsController.text) ?? 12;
                          final interest = principal * (rate / 100) * (months / 12);
                          return Text('\$${interest.toStringAsFixed(2)}');
                        }),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Obx(() {
                          final principal = double.tryParse(controller.principalAmountController.text) ?? 0;
                          final rate = double.tryParse(controller.interestRateController.text) ?? 0;
                          final months = int.tryParse(controller.termMonthsController.text) ?? 12;
                          final interest = principal * (rate / 100) * (months / 12);
                          final total = principal + interest;
                          return Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
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
                            controller.createCredit();
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
                      : const Text('Create Credit'),
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
