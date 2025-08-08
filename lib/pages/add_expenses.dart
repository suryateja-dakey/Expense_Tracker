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
  final dynamic? expense;
  final Color? expenseColor;

  const AddExpensePage({super.key, this.expense, this.expenseColor});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _typeScrollController = ScrollController();
  final ExpenseController controller = Get.put(ExpenseController());

  DateTime? _selectedDate;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedSubSubCategory;
  String? selectedPaymentMode;
  bool _remindWeekly = false;
  bool _remindMonthly = false;
  bool isLoading=false;

  final Color darkCardColor = const Color(0xFF2D2D2D);
  final Color darkCard = const Color(0xFF1E1E1E);
  Color effectiveColor = Colors.blue; // temporary default

@override
void initState() {
  super.initState();

  effectiveColor = widget.expenseColor ??
      controller.categories[controller.focusedIndex.value]['color'] as Color;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final expense = widget.expense;

    if (expense != null) {
      final index = controller.categories.indexWhere(
        (cat) => cat['name'] == expense['type'],
      );
      if (index != -1) {
        controller.setFocusedIndex(index);
        setState(() {
          effectiveColor =
              controller.categories[index]['color'] as Color;
        });
      }

      setState(() {
        _amountController.text = expense['amount'].toString();
        _notesController.text = expense['notes'] ?? '';
        _selectedDate = DateTime.tryParse(expense['date'].toString());

        selectedSubCategory = _validateDropdownValue(
          expense['category'],
          controller.getSubCategories(expense['type']),
        );

        selectedSubSubCategory = _validateDropdownValue(
          expense['subCategory'],
          selectedSubCategory != null
              ? controller.getSubSubCategories(expense['type'], selectedSubCategory!)
              : [],
        );

        selectedPaymentMode = _validateDropdownValue(
          expense['paymentMode'],
          controller.paymentModes,
        );

        _remindWeekly = expense['remindWeekly'] ?? false;
        _remindMonthly = expense['remindMonthly'] ?? false;
      });
    }
  });
}

  String? _validateDropdownValue(String? value, List<String> list) {
    if (value == null) return null;
    return list.contains(value) ? value : null;
  }

  @override
  void dispose() {
    _typeScrollController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _scrollToSelectedType(int index) {
    double itemWidth = 120.0;
    double offset = index * itemWidth -
        (MediaQuery.of(context).size.width - itemWidth) / 2;
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

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) =>
          Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Success Icon
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded, color: effectiveColor, size: 60),
            ).animate().scale(duration: 500.ms),

            const SizedBox(height: 16),

            // ✅ Title
            const Text(
              'Expense Saved!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ).animate().slideX(begin: 0.5).fadeIn(duration: 300.ms),

            const SizedBox(height: 12),

            // ✅ Message
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Would you like to go to the home page or add another expense?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ).animate().slideX(begin: 0.5, delay: 100.ms).fadeIn(),

            const SizedBox(height: 24),

            // ✅ Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: effectiveColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      child: const Text('Go to Home'),
                    ).animate().slideX(begin: -0.3, delay: 200.ms).fadeIn(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetForm();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: effectiveColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      child: const Text('Add Another'),
                    ).animate().slideX(begin: 0.3, delay: 200.ms).fadeIn(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    ).animate().slideX(begin: 1, duration: 400.ms).fadeIn(), // ✅ slide-in from right
  );
}

void _saveOrUpdateExpense() async {
  print("expense button is called");
  final user = FirebaseAuth.instance.currentUser;
  setState(() {
    isLoading=true;
  });
 
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in!')),
    );
    setState(() {
       isLoading=false;
    });
    return;
  }

  if (_amountController.text.isEmpty ||
      _selectedDate == null ||
      selectedSubCategory == null ||
      selectedSubSubCategory == null || // ✅ Now mandatory
      selectedPaymentMode == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all mandatory fields.')),
    );
   setState(() {
       isLoading=false;
    });
    return;
  }

  final category = controller.categories[controller.focusedIndex.value]['name'];

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
    (widget.expense != null && widget.expense!['id'] != null)
        ? 'updatedAt'
        : 'createdAt': Timestamp.now(),
  };

  try {
    final expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses');

    if (widget.expense != null && widget.expense!['id'] != null) {
      // Edit Mode
      await expensesRef.doc(widget.expense!['id']).update(expenseData);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Expense updated successfully!')),
      // );
    } else {
      // Add Mode
      await expensesRef.add(expenseData);
    }
    setState(() {
       isLoading=false;
    });
    _showSuccessDialog();
  } catch (e) {
     setState(() {
       isLoading=false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving expense: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final subCategoryItems = controller.getSubCategories(
      controller.categories[controller.focusedIndex.value]['name'] as String,
    );

    List<String> subSubCategoryItems = selectedSubCategory != null
        ? controller.getSubSubCategories(
            controller.categories[controller.focusedIndex.value]['name']
                as String,
            selectedSubCategory!,
          )
        : [];

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Add Expense',
        heroTag: 'appBarHero',
        backgroundColor: effectiveColor,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Category Selector
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 16),
              child: Obx(() => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _typeScrollController,
                    child: Row(
                      children: List.generate(
                          controller.categories.length, (index) {
                        final category = controller.categories[index];
                        final isSelected =
                            controller.focusedIndex.value == index;
                        final color = category['color'] as Color;
                        return GestureDetector(
                          onTap: () {
                            controller.setFocusedIndex(index);
                            _scrollToSelectedType(index);
                            setState(() {
                              selectedSubCategory = null;
                              selectedSubSubCategory = null;
                              effectiveColor = color;
                            });
                          },
                          child: Container(
                            width: 120,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? color : darkCardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                category['name'].toString(),
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.black : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  )),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

            // Dropdowns
            CustomDropdownField(
              hintText: 'Select Category',
              items: subCategoryItems,
              selectedItem: selectedSubCategory,
              onChanged: (value) =>
                  setState(() => selectedSubCategory = value),
            ),
            const SizedBox(height: 16),
            if (selectedSubCategory != null)
              CustomDropdownField(
                hintText: 'Select Subcategory',
                items: subSubCategoryItems,
                selectedItem: selectedSubSubCategory,
                onChanged: (value) =>
                    setState(() => selectedSubSubCategory = value),
              ),
            const SizedBox(height: 16),
            CustomDropdownField(
              hintText: 'Payment Mode',
              items: controller.paymentModes,
              selectedItem: selectedPaymentMode,
              onChanged: (value) =>
                  setState(() => selectedPaymentMode = value),
            ),
            const SizedBox(height: 16),

            // Amount & Date
            CustomTextField(
              controller: _amountController,
              hintText: 'Enter Amount',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomDateField(selectedDate: _selectedDate, onTap: _pickDate),

            // Reminders
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1), blurRadius: 10)
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
                        color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Weekly',
                        style: TextStyle(color: Colors.white)),
                    value: _remindWeekly,
                    activeColor: effectiveColor,
                    inactiveThumbColor: effectiveColor,
                    onChanged: (val) => setState(() {
                      _remindWeekly = val;
                      if (val) _remindMonthly = false;
                    }),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Monthly',
                        style: TextStyle(color: Colors.white)),
                    value: _remindMonthly,
                    activeColor: effectiveColor,
                    inactiveThumbColor: effectiveColor,
                    onChanged: (val) => setState(() {
                      _remindMonthly = val;
                      if (val) _remindWeekly = false;
                    }),
                  ),
                ],
              ),
            ),

            // Notes
            const SizedBox(height: 12),
            CustomTextField(
              controller: _notesController,
              hintText: 'Notes (optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Submit
            PrimaryButton(
              label: widget.expenseColor!=null?'Edit Expense':'Save Expense',
              onPressed:_saveOrUpdateExpense,
              backgroundColor: effectiveColor,
              textColor: Colors.black,
              isLoading:isLoading ,
            ),
          ],
        ),
      ),
    );
  }
}
