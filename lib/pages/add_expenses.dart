import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:expense_tracker/widgets/common_app_bar.dart';
import 'package:expense_tracker/controllers/expense_controller.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ExpenseController expenseController = Get.put(ExpenseController());
  DateTime _selectedDate = DateTime.now();
  String? selectedCategory;
  String? selectedPaymentMode;
  final ScrollController _typeScrollController = ScrollController();

  final List<String> categories = [
    'Rent',
    'Groceries',
    'Fuel',
    'Electricity',
    'Dining Out',
  ];

  final List<String> paymentModes = [
    'Cash',
    'UPI',
    'Credit Card',
    'Debit Card',
  ];

  final darkCardColor = const Color(0xFF2D2D2D);
  final Color darkCard = const Color(0xFF1E1E1E);
  final Color darkField = const Color(0xFF2A2A2A);
  final Color accentGreen = const Color(0xFF7ACB78);

  @override
  void dispose() {
    _typeScrollController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _scrollToSelectedType(int index) {
    // Calculate the position to center the selected item
    double itemWidth = 120.0; // Adjusted for text and padding
    double offset = index * itemWidth - (MediaQuery.of(context).size.width - itemWidth) / 2;
    _typeScrollController.animateTo(
      offset.clamp(0.0, _typeScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic, // Smooth easing curve
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Add Expense',
        heroTag: 'appBarHero',
        backgroundColor: Color(0xFF7ACB78),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Horizontal Scrollable Expense Types
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 16),
              child: Obx(() => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _typeScrollController,
                    physics: const BouncingScrollPhysics(), // Smooth scroll behavior
                    child: Row(
                      children: List.generate(expenseController.categories.length, (index) {
                        bool isSelected = expenseController.focusedIndex.value == index;
                        return GestureDetector(
                          onTap: () {
                            expenseController.setFocusedIndex(index);
                            _scrollToSelectedType(index);
                          },
                          child: Container(
                            width: 120, // Fixed width for consistent spacing
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? expenseController.categories[index]['color'] as Color
                                  : darkCardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                expenseController.categories[index]['name'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  )),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

            // Category Dropdown
            CustomDropdown<String>(
              hintText: 'Select Category',
              items: categories,
              initialItem: selectedCategory,
              onChanged: (value) => setState(() => selectedCategory = value),
              decoration: CustomDropdownDecoration(
                closedFillColor: darkField,
                expandedFillColor: darkField,
                closedBorder: Border.all(color: Colors.grey.shade700),
              ),
              listItemBuilder: (context, item, isSelected, onTap) {
                return ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? accentGreen : Colors.white,
                    ),
                  ),
                  onTap: onTap,
                );
              },
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Payment Mode Dropdown
            CustomDropdown<String>(
              hintText: 'Payment Mode',
              items: paymentModes,
              initialItem: selectedPaymentMode,
              onChanged: (value) => setState(() => selectedPaymentMode = value),
              decoration: CustomDropdownDecoration(
                closedFillColor: darkField,
                expandedFillColor: darkField,
                closedBorder: Border.all(color: Colors.grey.shade700),
              ),
              listItemBuilder: (context, item, isSelected, onTap) {
                return ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? accentGreen : Colors.white,
                    ),
                  ),
                  onTap: onTap,
                );
              },
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Date Picker Field
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: darkCardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Amount Field
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.currency_rupee, color: Colors.white),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: darkCardColor,
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Notes Field
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: darkCardColor,
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),

            // Preview Card
            Obx(() => Card(
                  color: darkCardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPreviewRow('Type',
                            expenseController.categories[expenseController.focusedIndex.value]['name'] as String),
                        _buildPreviewRow('Date', DateFormat('dd MMM yyyy').format(_selectedDate)),
                        _buildPreviewRow('Amount', _amountController.text),
                        _buildPreviewRow('Category', selectedCategory),
                        _buildPreviewRow('Payment', selectedPaymentMode),
                        _buildPreviewRow('Notes', _notesController.text),
                      ],
                    ),
                  ),
                )).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _submitExpense,
              icon: const Icon(Icons.check),
              label: const Text('Save Expense'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label:", style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : '-',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark(),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitExpense() {
    print("Type: ${expenseController.categories[expenseController.focusedIndex.value]['name']}");
    print("Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}");
    print("Amount: ${_amountController.text}");
    print("Category: $selectedCategory");
    print("Payment Mode: $selectedPaymentMode");
    print("Notes: ${_notesController.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense saved!')),
    );
  }
}