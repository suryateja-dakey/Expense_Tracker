import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/firebase_services/firebase_get_expenses.dart';
import 'package:expense_tracker/pages/expense_details.dart';
import 'package:expense_tracker/pages/add_expenses.dart';
import 'package:expense_tracker/widgets/common_app_bar.dart';
import 'package:expense_tracker/widgets/common_stats_widget.dart';
import 'package:expense_tracker/widgets/custom_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controllers/expense_controller.dart';

class ThisMonthExpensesPage extends StatefulWidget {
  const ThisMonthExpensesPage({super.key});

  @override
  State<ThisMonthExpensesPage> createState() => _ThisMonthExpensesPageState();
}

class _ThisMonthExpensesPageState extends State<ThisMonthExpensesPage> {
  final ExpenseController controller = Get.put(ExpenseController());
  List<Map<String, dynamic>> filteredExpenses = [];
  String? selectedFilter = 'All Transactions';
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchAndFilterExpenses();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchAndFilterExpenses() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, now.day);
    final allExpenses = await GetExpenses().fetchUserExpenses();

    final List<Map<String, dynamic>> filteredExpensesList = [];

    for (var expense in allExpenses) {
      final mappedExpense = expense.map((key, value) {
        if (value is Timestamp) {
          return MapEntry(key, value.toDate().toIso8601String());
        }
        return MapEntry(key, value);
      });

      final expenseDate = DateTime.parse(mappedExpense['date']);

      bool includeExpense = false;
      if (selectedFilter == 'All Transactions' &&
          expenseDate.year == now.year &&
          expenseDate.month == now.month) {
        includeExpense = true;
      } else if (selectedFilter == 'Last Month' &&
          expenseDate.year == lastMonth.year &&
          expenseDate.month == lastMonth.month) {
        includeExpense = true;
      } else if (['Essentials', 'Loans', 'Savings', 'Lifestyle'].contains(selectedFilter) &&
          expenseDate.year == now.year &&
          expenseDate.month == now.month &&
          mappedExpense['type'] == selectedFilter) {
        includeExpense = true;
      }

      if (includeExpense) {
        filteredExpensesList.add(mappedExpense);
      }
    }

    final prettyJson = const JsonEncoder.withIndent('  ').convert(filteredExpensesList);
    print(prettyJson);
    setState(() {
      filteredExpenses = filteredExpensesList;
    });
  }

  Color? _parseColor(dynamic colorValue) {
    if (colorValue is Color) return colorValue;
    if (colorValue is String) {
      try {
        String hexColor = colorValue.replaceAll("#", "").replaceAll("0x", "");
        if (hexColor.length == 6) hexColor = "FF$hexColor"; // Add alpha if missing
        return Color(int.parse("0x$hexColor"));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String _formatDateHeader(DateTime date) {
    final day = date.day;
    final suffix = (day % 10 == 1 && day != 11) ? 'st' : (day % 10 == 2 && day != 12) ? 'nd' : (day % 10 == 3 && day != 13) ? 'rd' : 'th';
    final month = DateTime(date.year, date.month).toString().split(' ')[0].substring(5, 7);
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '$day$suffix ${monthNames[int.parse(month) - 1]}';
  }

  Widget _buildDropdown() {
    final filterOptions = ['All Transactions', 'Essentials', 'Loans', 'Savings', 'Lifestyle', 'Last Month'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CustomDropdownField(
        hintText: 'Filter Expenses',
        items: filterOptions,
        selectedItem: selectedFilter,
        onChanged: (value) {
          setState(() {
            selectedFilter = value;
            final index = controller.categories.indexWhere(
              (cat) => cat['name'] == value,
            );
            if (index != -1) {
              controller.setFocusedIndex(index);
            }
          });
          fetchAndFilterExpenses();
        },
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor;

    // Group expenses by date
    final Map<DateTime, List<Map<String, dynamic>>> expensesByDate = {};
    for (var expense in filteredExpenses) {
      final date = DateTime.parse(expense['date']);
      final dateKey = DateTime(date.year, date.month, date.day);
      if (!expensesByDate.containsKey(dateKey)) {
        expensesByDate[dateKey] = [];
      }
      expensesByDate[dateKey]!.add(expense);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 28),
            child: Text(
              _currentPage == 0 ? "This\nMonth Usage" : "This\nMonth Stats",
              style: const TextStyle(
                fontSize: 36,
                height: 1.2,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),
          const SizedBox(height: 8),
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 2,
              effect: const WormEffect(
                dotColor: Colors.white30,
                activeDotColor: Colors.greenAccent,
                dotHeight: 8,
                dotWidth: 8,
                spacing: 8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdown(),
          const SizedBox(height: 16),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                // Page 1: This Month Usage
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      filteredExpenses.isEmpty
                          ?  Padding(
                              padding: EdgeInsets.only(top: 120),
                              child: Center(
                                child: SvgPicture.asset(
                  'assets/file_svgs/error_logo.svg',
                  height: 120,
                  width: 120,
                ),
                              ),
                            ).animate().fadeIn(duration: 300.ms)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: expensesByDate.entries.map((entry) {
                                final date = entry.key;
                                final expenses = entry.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20, top: 16),
                                      child: Row(
                                        children: [
                                          Text(
                                            _formatDateHeader(date),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Expanded(
                                            child: Divider(
                                              color: Colors.white70,
                                              thickness: 1,
                                              indent: 10,
                                              endIndent: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(left: 20, right: 16, top: 8),
                                      itemCount: expenses.length,
                                      itemBuilder: (context, index) {
                                        final expense = expenses[index];
                                        final type = expense['type']?.toString();
                                        final categoryData = controller.categories.firstWhere(
                                          (cat) => cat['name'].toString().toLowerCase() == type?.toLowerCase(),
                                          orElse: () => {'color': Colors.white},
                                        );
                                        final cardColor = _parseColor(categoryData['color']) ?? const Color(0xFF7ACB78);
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: GestureDetector(
                                            onTap: () {
                                              print("SELECTED EXPENSE DATA");
                                              print(expense);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ExpenseDetailsPage(expense: expense, expenseColor: cardColor),
                                                ),
                                              );
                                            },
                                            child: _buildUsageCard(expense, scale).animate().fadeIn(duration: 300.ms, delay: (100 * index).ms).slideY(begin: 0.2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ).animate().fadeIn(duration: 300.ms);
                              }).toList(),
                            ),
                    ],
                  ),
                ),
                // Page 2: This Month Stats
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const SizedBox(height: 160),
                    StatsWidget(filteredExpenses: filteredExpenses),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );
        },
        backgroundColor:Colors.greenAccent,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Add Expense", style: TextStyle(color: Colors.black)),
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildUsageCard(Map<String, dynamic> data, double scale) {
    final type = data['type']?.toString();
    final categoryData = controller.categories.firstWhere(
      (cat) => cat['name'].toString().toLowerCase() == type?.toLowerCase(),
      orElse: () => {'color': Colors.white},
    );

    final cardColor = _parseColor(categoryData['color']) ??Colors.greenAccent;

    String iconPath;
    switch (data['type']?.toString()) {
      case 'Essentials':
        iconPath = 'assets/expense_monthly_svgs/essentials.svg';
        break;
      case 'Lifestyle':
        iconPath = 'assets/expense_monthly_svgs/lifestyle.svg';
        break;
      case 'Savings':
        iconPath = 'assets/expense_monthly_svgs/savings.svg';
        break;
      case 'Loans':
        iconPath = 'assets/expense_monthly_svgs/loans.svg';
        break;
      default:
        iconPath = 'assets/expense_monthly_svgs/default.svg';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardColor.withOpacity(0.7), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']?.toString().isNotEmpty == true
                      ? data['title']
                      : data['subCategory'] ?? 'Expense',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${data['category']} • ${data['type']}",
                  style: TextStyle(fontSize: 12 * scale, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Text(
                  "₹${data['amount'].toString()}",
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(right: 26),
            child: SvgPicture.asset(
              iconPath,
              height: 36,
              width: 36,
              color: cardColor,
            ),
          ),
        ],
      ),
    );
  }
}