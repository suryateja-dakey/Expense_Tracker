import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/firebase_services/firebase_get_expenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../pages/add_expenses.dart';

class ThisMonthExpensesPage extends StatefulWidget {
  const ThisMonthExpensesPage({super.key});

  @override
  State<ThisMonthExpensesPage> createState() => _ThisMonthExpensesPageState();
}

class _ThisMonthExpensesPageState extends State<ThisMonthExpensesPage> {
  final controller = Get.put(ExpenseController());
  List<Map<String, dynamic>> filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    fetchAndFilterExpenses();
  }

  Future<void> fetchAndFilterExpenses() async {
    final now = DateTime.now();
    final allExpenses = await GetExpenses().fetchUserExpenses();

    final List<Map<String, dynamic>> currentMonthExpenses = [];

    for (var expense in allExpenses) {
      final mappedExpense = expense.map((key, value) {
        if (value is Timestamp) {
          return MapEntry(key, value.toDate().toIso8601String());
        }
        return MapEntry(key, value);
      });

      final expenseDate = DateTime.parse(mappedExpense['date']);
      if (expenseDate.year == now.year && expenseDate.month == now.month) {
        currentMonthExpenses.add(mappedExpense);
      }
    }

    setState(() {
      filteredExpenses = currentMonthExpenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("This Month"),
      ),
      backgroundColor: Colors.black,
      body: filteredExpenses.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 28),
                  child: Text(
                    "This\nMonth Usage",
                    style: TextStyle(
                      fontSize: 36,
                      height: 1.2,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                SizedBox(height: 160),
                Center(
                  child: Text(
                    'No expenses yet',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20, left: 28),
                  child: Text(
                    "This\nMonth Usage",
                    style: TextStyle(
                      fontSize: 36,
                      height: 1.2,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildUsageCard(expense, scale),
                      );
                    },
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
        backgroundColor: const Color(0xFF7ACB78),
        icon: const Icon(Icons.add),
        label: const Text("Add Expense"),
      ),
    );
  }

Widget _buildUsageCard(Map<String, dynamic> data, double scale) {
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
      iconPath = 'assets/expense_monthly_svgs/default.svg'; // fallback icon
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1E),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white24),
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
                style: TextStyle(
                  fontSize: 12 * scale,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "₹${data['amount'].toString()}",
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
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
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
}


// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:expense_tracker/firebase_services/firebase_get_expenses.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import '../controllers/expense_controller.dart';
// import '../pages/add_expenses.dart';

// class ThisMonthExpensesPage extends StatefulWidget {
//   const ThisMonthExpensesPage({super.key});

//   @override
//   State<ThisMonthExpensesPage> createState() => _ThisMonthExpensesPageState();
// }

// class _ThisMonthExpensesPageState extends State<ThisMonthExpensesPage> {
//   final controller = Get.put(ExpenseController());
//   List<Map<String, dynamic>> filteredExpenses = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchAndFilterExpenses();
//   }

//   Future<void> fetchAndFilterExpenses() async {
//     final now = DateTime.now();
//     final allExpenses = await GetExpenses().fetchUserExpenses();

//     final List<Map<String, dynamic>> currentMonthExpenses = [];

//     for (var expense in allExpenses) {
//       final mappedExpense = expense.map((key, value) {
//         if (value is Timestamp) {
//           return MapEntry(key, value.toDate().toIso8601String());
//         }
//         return MapEntry(key, value);
//       });

//       final expenseDate = DateTime.parse(mappedExpense['date']);
//       if (expenseDate.year == now.year && expenseDate.month == now.month) {
//         currentMonthExpenses.add(mappedExpense);
//       }
//     }

//     setState(() {
//       filteredExpenses = currentMonthExpenses;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scale = MediaQuery.of(context).textScaleFactor;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         title: const Text("This Month"),
//       ),
//       backgroundColor: Colors.black,
//       body: filteredExpenses.isEmpty
//           ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Padding(
//                   padding: EdgeInsets.only(top: 20, left: 28),
//                   child: Text(
//                     "This\nMonth Usage",
//                     style: TextStyle(
//                       fontSize: 36,
//                       height: 1.2,
//                       color: Colors.white,
//                       fontFamily: 'Inter',
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 160),
//                 Center(
//                   child: Text(
//                     'No expenses yet',
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                 ),
//               ],
//             )
//           : Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.only(top: 20, left: 28),
//                   child: Text(
//                     "This\nMonth Usage",
//                     style: TextStyle(
//                       fontSize: 36,
//                       height: 1.2,
//                       color: Colors.white,
//                       fontFamily: 'Inter',
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.only(left: 20, right: 16),
//                     itemCount: filteredExpenses.length,
//                     itemBuilder: (context, index) {
//                       final expense = filteredExpenses[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 16),
//                         child: _buildUsageCard(expense, scale),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddExpensePage()),
//           );
//         },
//         backgroundColor: const Color(0xFF7ACB78),
//         icon: const Icon(Icons.add),
//         label: const Text("Add Expense"),
//       ),
//     );
//   }
//   Color? _parseColor(dynamic colorValue) {
//   if (colorValue is Color) return colorValue;
//   if (colorValue is String) {
//     try {
//       String hexColor = colorValue.replaceAll("#", "").replaceAll("0x", "");
//       if (hexColor.length == 6) hexColor = "FF$hexColor"; // add alpha if missing
//       return Color(int.parse("0x$hexColor"));
//     } catch (_) {
//       return null;
//     }
//   }
//   return null;
// }


//   Widget _buildUsageCard(Map<String, dynamic> data, double scale) {
//     final type = data['type']?.toString();
//     final categoryData = controller.categories.firstWhere(
//       (cat) => cat['name'].toString().toLowerCase() == type?.toLowerCase(),
//       orElse: () => {'color': Colors.white},
//     );

// final cardColor = _parseColor(categoryData['color']) ?? Colors.white;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1C1C1E),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: cardColor.withOpacity(0.7), width: 1.5),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Content
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   data['title']?.toString().isNotEmpty == true
//                       ? data['title']
//                       : data['subCategory'] ?? 'Expense',
//                   style: TextStyle(
//                     fontSize: 16 * scale,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "${data['category']} • ${data['type']}",
//                   style: TextStyle(
//                     fontSize: 12 * scale,
//                     color: Colors.white70,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   "₹${data['amount'].toString()}",
//                   style: TextStyle(
//                     fontSize: 18 * scale,
//                     fontWeight: FontWeight.bold,
//                     color: cardColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
