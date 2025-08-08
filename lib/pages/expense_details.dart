import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/pages/add_expenses.dart';
import 'package:expense_tracker/widgets/common_app_bar.dart';
import 'package:expense_tracker/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ExpenseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> expense;
  Color? expenseColor;

  ExpenseDetailsPage({super.key, required this.expense, this.expenseColor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpenseController());
    // Use expenseColor if provided, otherwise fallback to a default or controller-derived color
    final Color effectiveColor = expenseColor ?? (controller.categories[controller.focusedIndex.value]['color'] as Color? ?? const Color(0xFF7ACB78));

    final DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final String formattedDate = expense['date'] != null
        ? dateFormat.format(DateTime.parse(expense['date']))
        : 'N/A';
    final String formattedCreatedAt = expense['createdAt'] != null
        ? dateFormat.format(DateTime.parse(expense['createdAt'].toString()))
        : 'N/A';

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Expense Details',
        heroTag: 'appBarHero',
        backgroundColor: effectiveColor,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTopCards(expense, effectiveColor),
            const SizedBox(height: 24),
            _buildDoubleTileRow(
              _buildTile(Icons.sell_rounded, 'Subcategory', expense['subCategory'] ?? 'N/A', effectiveColor),
              _buildTile(Icons.account_balance_wallet_outlined, 'Payment Mode', expense['paymentMode'] ?? 'N/A', effectiveColor),
            ),
            _buildDoubleTileRow(
              _buildTile(Icons.compare_arrows_outlined, 'Type', expense['type'] ?? 'N/A', effectiveColor),
              _buildTile(Icons.notes_outlined, 'Notes', (expense['notes']?.isNotEmpty ?? false) ? expense['notes'] : 'No notes added', effectiveColor),
            ),
            _buildDoubleTileRow(
              _buildTile(Icons.date_range_outlined, 'Expense Date', formattedDate, effectiveColor),
              _buildTile(Icons.schedule_outlined, 'Created At', formattedCreatedAt, effectiveColor),
            ),
            _buildDoubleTileRow(
              _buildTile(Icons.alarm_on_outlined, 'Remind Weekly', expense['remindWeekly'] == true ? 'Yes' : 'No', effectiveColor),
              _buildTile(Icons.repeat_outlined, 'Remind Monthly', expense['remindMonthly'] == true ? 'Yes' : 'No', effectiveColor),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
                  label: 'Edit Expense',
                  onPressed: (){
                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddExpensePage(expense: expense, expenseColor: effectiveColor),
                                      ),
                                    );
                  },
                  backgroundColor: effectiveColor,
                  textColor: Colors.black,
                ),
           
          ],
        ),
      ),
    );
  }

  Widget _buildTopCards(Map<String, dynamic> expense, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.9), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.currency_rupee, color: Colors.white, size: 28),
                const SizedBox(height: 10),
                const Text(
                  'Amount',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    '₹${expense['amount']?.toString() ?? '0'}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.category_outlined, size: 28, color: color),
                const SizedBox(height: 10),
                const Text('Category',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    expense['category'] ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    )),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  softWrap: true,
                  maxLines: null,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1);
  }

  Widget _buildDoubleTileRow(Widget leftTile, Widget rightTile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: leftTile),
          const SizedBox(width: 16),
          Expanded(child: rightTile),
        ],
      ),
    );
  }
}