// ignore_for_file: use_key_in_widget_constructors, avoid_print

import 'package:expense_tracker/firebase_services/firebase_core_calls.dart';
import 'package:expense_tracker/firebase_services/firebase_get_expenses.dart';
import 'package:expense_tracker/pages/add_expenses.dart';
import 'package:expense_tracker/pages/authentications/login.dart';
import 'package:expense_tracker/pages/monthly_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../widgets/custom_styled_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.put(ExpenseController());
  final ScrollController _scrollController = ScrollController();
  static const double cardWidth = 186.0;
  static const double cardSpacing = 35.0;
  bool _isAnimating = false;
  dynamic expenses;
  final repo = Repository();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getExpenseData();
  }

  Future<dynamic> getExpenseData() async {
    expenses = await GetExpenses().fetchUserExpenses();
    dynamic totalLoans;
    for (int i = 0; i < controller.categories.length; i++) {
      totalLoans = calculateTotalAmount(
        expenses: expenses,
        types: [controller.categories[i]['name'].toString()],
      );
      controller.categories[i]['amount'] = totalLoans;
      print('Total spent on ${controller.categories[i]['name']}: ₹$totalLoans');
    }
    setState(() {});
    return expenses;
  }

  double calculateTotalAmount({
    required List<Map<String, dynamic>> expenses,
    List<String>? types,
    List<String>? categories,
  }) {
    return expenses
        .where((expense) {
          final matchesType = types == null || types.contains(expense['type']);
          final matchesCategory =
              categories == null || categories.contains(expense['category']);
          return matchesType && matchesCategory;
        })
        .fold(0.0, (sum, expense) => sum + (expense['amount'] ?? 0));
  }

  void _onScroll() {
    if (_isAnimating) return;

    final totalCardWidth = cardWidth + cardSpacing;
    final offset = _scrollController.offset;
    final index = ((offset + totalCardWidth / 2) / totalCardWidth).floor();

    if (index >= 0 &&
        index < controller.categories.length &&
        index != controller.focusedIndex.value) {
      controller.setFocusedIndex(index);
    }
  }

  void _animateToIndex(int index, double screenWidth) async {
    final totalCardWidth = cardWidth + cardSpacing;
    final targetOffset =
        (index * totalCardWidth - (screenWidth - cardWidth) / 2) + 15;

    if (_scrollController.hasClients) {
      _isAnimating = true;
      await _scrollController.animateTo(
        targetOffset.clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _isAnimating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top-right Menu
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: Align(
                  alignment: Alignment.topRight,
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.dehaze_outlined,
                      color: Color(0xFF7ACB78),
                      size: 24,
                    ),
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Color(0xFF7ACB78),
                        width: 2,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'settings') {
                        print('Navigate to Settings');
                      } else if (value == 'logout') {
                        print('Logging out...');
                        repo.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Login()),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'settings', child: Text('Settings')),
                      PopupMenuItem(value: 'logout', child: Text('Logout')),
                    ],
                  ),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.only(top: 20, left: 28),
                child: Text(
                  "Expenses\nCategories",
                  style: TextStyle(
                    fontSize: 36,
                    height: 1.2,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),

              // Category Names (horizontal)
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 20),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 25),
                    itemBuilder: (context, index) {
                      return Obx(() {
                        final isFocused =
                            controller.focusedIndex.value == index;
                        return GestureDetector(
                          onTap: () {
                            controller.setFocusedIndex(index);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _animateToIndex(index, screenWidth);
                            });
                          },
                          child: Text(
                            controller.categories[index]['name'].toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isFocused
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isFocused
                                  ? Colors.greenAccent
                                  : Colors.white,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Horizontal Scroll Cards
              SizedBox(
                height: 464,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: (screenWidth - cardWidth) / 2,
                  ),
                  child: Obx(() {
                    final cards = controller.categories.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final category = entry.value;
                      final isFocused = controller.focusedIndex.value == index;

                      return Padding(
                        padding: const EdgeInsets.only(right: cardSpacing),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 1.0,
                            end: isFocused ? 1.05 : 0.95,
                          ),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              alignment: Alignment.center,
                              child: Opacity(
                                opacity: isFocused ? 1.0 : 0.6,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ThisMonthExpensesPage(),
                                      ),
                                    );
                                  },
                                  child: CustomStyledCard(
                                    categoryName: category['name'].toString(),
                                    imagePath: category['image'].toString(),
                                    amountUsed: category['amount'].toString(),
                                    cardColors: category['color'] as Color,
                                    addExpenseOnTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AddExpensePage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList();

                    return Row(children: cards);
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
