import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/firebase_services/firebase_get_expenses.dart';
import 'package:expense_tracker/pages/home_page.dart';
import 'package:expense_tracker/widgets/common_app_bar.dart';
import 'package:expense_tracker/widgets/common_date_field.dart';
import 'package:expense_tracker/widgets/custom_dropdown_field.dart';
import 'package:expense_tracker/widgets/custom_text_button.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:expense_tracker/controllers/expense_controller.dart';



class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ExpenseController controller = Get.put(ExpenseController());
  DateTime? _selectedDate;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedSubSubCategory;
  String? selectedPaymentMode;
  bool _remindWeekly = false;
  bool _remindMonthly = false;
  final ScrollController _typeScrollController = ScrollController();

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
    double itemWidth = 120.0;
    double offset = index * itemWidth - (MediaQuery.of(context).size.width - itemWidth) / 2;
    _typeScrollController.animateTo(
      offset.clamp(0.0, _typeScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _resetForm() {
    _amountController.clear();
    _notesController.clear();
    setState(() {
      _selectedDate = null;
      selectedCategory = null;
      selectedSubCategory = null;
      selectedSubSubCategory = null;
      selectedPaymentMode = null;
      _remindWeekly = false;
      _remindMonthly = false;
    });
  }

 void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Expense Saved!',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
      content: const Text(
        'Would you like to go to the home page or add another expense?',
        style: TextStyle(color: Colors.white70),
      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) =>  HomePage()),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: controller.categories[controller.focusedIndex.value]['color'] as Color,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Go to Home'),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.3),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  _resetForm(); // Reset form for adding another expense
                },
                style: TextButton.styleFrom(
                  backgroundColor: controller.categories[controller.focusedIndex.value]['color'] as Color,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Add Another'),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: 0.3),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Add Expense',
        heroTag: 'appBarHero',
        backgroundColor:
            controller.categories[controller.focusedIndex.value]['color']
                as Color,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Root Category Selector
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 16),
              child: Obx(
                () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _typeScrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(controller.categories.length, (index) {
                      bool isSelected = controller.focusedIndex.value == index;
                      return GestureDetector(
                        onTap: () {
                          controller.setFocusedIndex(index);
                          _scrollToSelectedType(index);
                          setState(() {
                            selectedSubCategory = null;
                            selectedSubSubCategory = null;
                          });
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? controller.categories[index]['color'] as Color
                                : darkCardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              controller.categories[index]['name'] as String,
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
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

            // SubCategory Dropdown
            CustomDropdownField(
              hintText: 'Select Category',
              items: controller.getSubCategories(
                controller.categories[controller.focusedIndex.value]['name'] as String,
              ),
              selectedItem: selectedSubCategory,
              onChanged: (value) => setState(() {
                selectedSubCategory = value;
                selectedSubSubCategory = null;
              }),
            ),

            const SizedBox(height: 16),

            // Sub-SubCategory Dropdown
            if (selectedSubCategory != null)
              CustomDropdownField(
                hintText: 'Select Subcategory',
                items: controller.getSubSubCategories(
                  controller.categories[controller.focusedIndex.value]['name'] as String,
                  selectedSubCategory!,
                ),
                selectedItem: selectedSubSubCategory,
                onChanged: (value) => setState(() {
                  selectedSubSubCategory = value;
                }),
              ),

            const SizedBox(height: 16),

            // Payment Mode Dropdown
            CustomDropdownField(
              hintText: 'Payment Mode',
              items: controller.paymentModes,
              selectedItem: selectedPaymentMode,
              onChanged: (value) => setState(() => selectedPaymentMode = value),
            ),

            const SizedBox(height: 16),

            // Amount Field
            CustomTextField(
              controller: _amountController,
              hintText: 'Enter Amount',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Date Picker
            CustomDateField(selectedDate: _selectedDate, onTap: _pickDate),

            const SizedBox(height: 12),

            // Reminders
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set Reminders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Weekly', style: TextStyle(color: Colors.white)),
                        value: _remindWeekly,
                        inactiveThumbColor: controller.categories[controller.focusedIndex.value]['color'] as Color,
                        activeColor: controller.categories[controller.focusedIndex.value]['color'] as Color,
                        onChanged: (bool value) {
                          setState(() {
                            _remindWeekly = value;
                            if (value) _remindMonthly = false;
                          });
                        },
                      )),
                  Obx(() => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Monthly', style: TextStyle(color: Colors.white)),
                        value: _remindMonthly,
                        inactiveThumbColor: controller.categories[controller.focusedIndex.value]['color'] as Color,
                        activeColor: controller.categories[controller.focusedIndex.value]['color'] as Color,
                        onChanged: (bool value) {
                          setState(() {
                            _remindMonthly = value;
                            if (value) _remindWeekly = false;
                          });
                        },
                      )),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Notes Field
            CustomTextField(
              controller: _notesController,
              hintText: 'Notes (optional)',
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Submit Button
            Obx(() => PrimaryButton(
                  label: 'Save Expense',
                  onPressed: _submitExpense,
                  backgroundColor: controller.categories[controller.focusedIndex.value]['color'] as Color,
                  textColor: Colors.black,
                )),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitExpense() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date!')),
      );
      return;
    }

    final category = controller.categories[controller.focusedIndex.value]['name'];
    final color = controller.categories[controller.focusedIndex.value]['color'] as Color;

    final expenseData = {
      'type': category,
      'date': Timestamp.fromDate(_selectedDate!),
      'amount': double.tryParse(_amountController.text) ?? 0,
      'category': selectedSubCategory,
      'subCategory': selectedSubSubCategory,
      'paymentMode': selectedPaymentMode,
      'notes': _notesController.text,
      'remindWeekly': _remindWeekly,
      'remindMonthly': _remindMonthly,
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add(expenseData);

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving expense: $e')),
      );
    }
  }
}