import 'package:expense_tracker/pages/add_expenses.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../widgets/custom_styled_card.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key}) {
    _scrollController.addListener(_onScroll);
  }

  final controller = Get.put(ExpenseController());
  final ScrollController _scrollController = ScrollController();

  static const double cardWidth = 186.0;
  static const double cardSpacing = 35.0;

  bool _isAnimating = false;

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
              const Padding(
                padding: EdgeInsets.only(top: 20, right: 20),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.dehaze_outlined,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
              ),
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
                                        builder: (_) => AddExpensePage(),
                                      ),
                                    );
                                  },
                                  child: CustomStyledCard(
                                    categoryName: category['name'].toString(),
                                    imagePath: category['image'].toString(),
                                    amountUsed: category['amount'].toString(),
                                    cardColors: category['color'] as Color,
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
