import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/customer_controller.dart';
import '../../../core/constants/app_colors.dart';

/// Add/Edit Customer View
class AddCustomerView extends GetView<CustomerController> {
  const AddCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.selectedCustomer.value != null;
    final formKey = GlobalKey<FormState>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter customer name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  hintText: 'Enter email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone *',
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'Enter company name (optional)',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Address Section
              const Text(
                'Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.addressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  hintText: 'Enter street address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        hintText: 'City',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: controller.stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        hintText: 'State',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.postalCodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  hintText: 'Enter postal code',
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Credit Settings Section
              const Text(
                'Credit Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.creditLimitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Credit Limit',
                  hintText: 'Enter credit limit',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: '\$ ',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.creditScoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Credit Score',
                  hintText: 'Enter credit score (300-850)',
                  prefixIcon: Icon(Icons.score),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final score = int.tryParse(value);
                    if (score == null || score < 300 || score > 850) {
                      return 'Score must be between 300 and 850';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller.taxIdController,
                decoration: const InputDecoration(
                  labelText: 'Tax ID / PAN',
                  hintText: 'Enter tax identification number',
                  prefixIcon: Icon(Icons.badge_outlined),
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
                            if (isEditing) {
                              controller.updateCustomer();
                            } else {
                              controller.createCustomer();
                            }
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
                      : Text(isEditing ? 'Update Customer' : 'Create Customer'),
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
