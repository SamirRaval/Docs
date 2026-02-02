import 'dart:math';
import '../models/customer_model.dart';
import '../models/credit_model.dart';
import '../models/transaction_model.dart';

/// Service to generate and populate dummy data for the app
class DummyDataService {
  static final Random _random = Random();

  /// Generate list of dummy customers
  static List<CustomerModel> generateCustomers({int count = 15}) {
    final customers = <CustomerModel>[];
    final names = [
      'John Smith', 'Jane Doe', 'Michael Johnson', 'Sarah Williams',
      'David Brown', 'Emily Davis', 'Robert Miller', 'Jennifer Wilson',
      'William Moore', 'Elizabeth Taylor', 'James Anderson', 'Patricia Thomas',
      'Christopher Jackson', 'Linda White', 'Daniel Harris', 'Barbara Martin',
      'Matthew Garcia', 'Susan Martinez', 'Anthony Robinson', 'Jessica Clark'
    ];
    
    final companies = [
      'Tech Solutions Inc.', 'Global Trading Co.', 'Sunrise Industries',
      'Metro Services LLC', 'Prime Enterprises', 'Alpha Corp', 'Beta Systems',
      'Delta Manufacturing', 'Omega Retail', 'Sigma Consulting', null, null, null
    ];
    
    final cities = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 
                    'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'];
    final states = ['NY', 'CA', 'IL', 'TX', 'AZ', 'PA', 'TX', 'CA', 'TX', 'CA'];

    for (int i = 0; i < count; i++) {
      final nameIndex = i % names.length;
      final cityIndex = _random.nextInt(cities.length);
      final creditScore = 550 + _random.nextInt(300); // 550-850
      final creditLimit = (5000 + _random.nextInt(45000)).toDouble();
      final balance = _random.nextDouble() * creditLimit * 0.8;
      
      String riskLevel;
      if (creditScore >= 750) {
        riskLevel = 'low';
      } else if (creditScore >= 650) {
        riskLevel = 'medium';
      } else {
        riskLevel = 'high';
      }
      
      String status;
      if (_random.nextDouble() < 0.1) {
        status = 'overdue';
      } else if (_random.nextDouble() < 0.05) {
        status = 'inactive';
      } else {
        status = 'active';
      }

      final createdDate = DateTime.now().subtract(
        Duration(days: _random.nextInt(365)),
      );

      customers.add(CustomerModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_$i',
        name: names[nameIndex],
        email: '${names[nameIndex].toLowerCase().replaceAll(' ', '.')}@email.com',
        phone: '+1${_random.nextInt(900) + 100}${_random.nextInt(900) + 100}${_random.nextInt(9000) + 1000}',
        address: '${_random.nextInt(9999) + 1} ${['Main', 'Oak', 'Pine', 'Maple', 'Cedar'][_random.nextInt(5)]} Street',
        city: cities[cityIndex],
        state: states[cityIndex],
        country: 'USA',
        postalCode: '${_random.nextInt(90000) + 10000}',
        companyName: companies[_random.nextInt(companies.length)],
        taxId: _random.nextBool() ? 'TAX${_random.nextInt(900000) + 100000}' : null,
        creditScore: creditScore,
        creditLimit: creditLimit,
        currentBalance: balance,
        availableCredit: creditLimit - balance,
        riskLevel: riskLevel,
        status: status,
        createdAt: createdDate.toIso8601String(),
        updatedAt: createdDate.add(Duration(days: _random.nextInt(30))).toIso8601String(),
        isSynced: _random.nextBool(),
      ));
    }

    return customers;
  }

  /// Generate dummy credits for a list of customers
  static List<CreditModel> generateCredits(List<CustomerModel> customers, {int maxPerCustomer = 3}) {
    final credits = <CreditModel>[];
    final purposes = [
      'Working Capital', 'Equipment Purchase', 'Inventory', 'Expansion',
      'Emergency Funds', 'Renovation', 'Marketing', 'Debt Consolidation'
    ];
    final types = ['personal', 'business', 'line_of_credit'];
    final statuses = ['pending', 'active', 'active', 'active', 'closed', 'rejected'];

    for (final customer in customers) {
      final creditCount = _random.nextInt(maxPerCustomer) + 1;
      
      for (int i = 0; i < creditCount; i++) {
        final principal = (1000 + _random.nextInt(49000)).toDouble();
        final rate = _random.nextDouble() * 15; // 0-15% interest
        final termMonths = [3, 6, 12, 18, 24, 36][_random.nextInt(6)];
        final interest = principal * (rate / 100) * (termMonths / 12);
        final total = principal + interest;
        final paidPercent = _random.nextDouble();
        final paid = total * paidPercent;
        
        final startDate = DateTime.now().subtract(
          Duration(days: _random.nextInt(180) + 30),
        );
        final dueDate = startDate.add(Duration(days: termMonths * 30));
        
        String status = statuses[_random.nextInt(statuses.length)];
        if (paidPercent >= 0.99) status = 'closed';
        if (DateTime.now().isAfter(dueDate) && status == 'active') {
          status = 'active'; // Will show as overdue based on date
        }

        credits.add(CreditModel(
          id: '${DateTime.now().millisecondsSinceEpoch}_credit_${credits.length}',
          customerId: customer.id,
          customerName: customer.name,
          principalAmount: principal,
          interestRate: rate,
          totalAmount: total,
          paidAmount: status == 'closed' ? total : paid,
          remainingAmount: status == 'closed' ? 0 : total - paid,
          termMonths: termMonths,
          startDate: startDate.toIso8601String(),
          dueDate: dueDate.toIso8601String(),
          status: status,
          creditType: types[_random.nextInt(types.length)],
          purpose: purposes[_random.nextInt(purposes.length)],
          notes: _random.nextBool() ? 'Regular customer with good payment history' : null,
          createdAt: startDate.toIso8601String(),
          updatedAt: DateTime.now().subtract(Duration(days: _random.nextInt(7))).toIso8601String(),
          isSynced: _random.nextBool(),
        ));
      }
    }

    return credits;
  }

  /// Generate dummy transactions for credits
  static List<TransactionModel> generateTransactions(
    List<CustomerModel> customers,
    List<CreditModel> credits, {
    int count = 50,
  }) {
    final transactions = <TransactionModel>[];
    final paymentMethods = ['cash', 'bank_transfer', 'card', 'check', 'upi'];
    final types = ['payment', 'credit', 'debit', 'refund'];
    final descriptions = [
      'Monthly payment', 'Partial payment', 'Full settlement',
      'Interest payment', 'Late fee', 'Processing fee refund',
      'Credit disbursement', 'Balance adjustment'
    ];

    for (int i = 0; i < count; i++) {
      final customer = customers[_random.nextInt(customers.length)];
      final customerCredits = credits.where((c) => c.customerId == customer.id).toList();
      final credit = customerCredits.isNotEmpty 
          ? customerCredits[_random.nextInt(customerCredits.length)] 
          : null;
      
      final type = types[_random.nextInt(types.length)];
      final amount = (100 + _random.nextInt(4900)).toDouble();
      final txnDate = DateTime.now().subtract(
        Duration(days: _random.nextInt(90)),
      );

      transactions.add(TransactionModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_txn_$i',
        customerId: customer.id,
        creditId: credit?.id,
        customerName: customer.name,
        amount: amount,
        type: type,
        status: _random.nextDouble() < 0.95 ? 'completed' : 'pending',
        description: descriptions[_random.nextInt(descriptions.length)],
        referenceNumber: 'TXN${DateTime.now().year}${(i + 1).toString().padLeft(6, '0')}',
        paymentMethod: paymentMethods[_random.nextInt(paymentMethods.length)],
        transactionDate: txnDate.toIso8601String(),
        createdAt: txnDate.toIso8601String(),
        updatedAt: txnDate.add(const Duration(minutes: 5)).toIso8601String(),
        isSynced: _random.nextBool(),
      ));
    }

    // Sort by date descending
    transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    
    return transactions;
  }
}
