import 'dart:math' show pi;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:graphic/graphic.dart';
import 'package:collection/collection.dart';
import '../database_services/get_user_salary.dart';

class StatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> filteredExpenses;

  const StatsWidget({
    super.key,
    required this.filteredExpenses,
  });

  Map<String, dynamic> computeStats(List<Map<String, dynamic>> expenses) {
    final totalSpending = expenses.fold<double>(
      0.0,
      (sum, expense) => sum + (expense['amount'] as num).toDouble(),
    );

    final spendingByType = <String, double>{};
    final spendingByPaymentMode = <String, double>{};
    final spendingOverTime = <String, double>{};

    for (var expense in expenses) {
      final type = expense['type'] as String;
      final paymentMode = expense['paymentMode'] as String;
      final amount = (expense['amount'] as num).toDouble();
      final date = expense['date'] is Timestamp
          ? (expense['date'] as Timestamp).toDate()
          : DateTime.parse(expense['date'].toString());

      final dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      spendingByType[type] = (spendingByType[type] ?? 0.0) + amount;
      spendingByPaymentMode[paymentMode] = (spendingByPaymentMode[paymentMode] ?? 0.0) + amount;
      spendingOverTime[dateKey] = (spendingOverTime[dateKey] ?? 0.0) + amount;
    }

    final typeData = spendingByType.entries
        .map((entry) => {'type': entry.key, 'amount': entry.value})
        .toList();
    final paymentModeData = spendingByPaymentMode.entries
        .map((entry) => {'paymentMode': entry.key, 'amount': entry.value})
        .toList();
    final lineChartData = spendingOverTime.entries
        .sortedBy((e) => e.key)
        .map((e) => {'date': e.key, 'amount': e.value})
        .toList();

    return {
      'totalSpending': totalSpending,
      'typeData': typeData,
      'paymentModeData': paymentModeData,
      'lineChartData': lineChartData,
    };
  }

  String _computeDataKey(List<Map<String, dynamic>> data) {
    // Create a unique key based on the data content to trigger rebuilds
    return data
        .map((e) => '${e['type'] ?? e['paymentMode'] ?? e['date']}:${e['amount']}')
        .join('|');
  }

  @override
  Widget build(BuildContext context) {
    final stats = computeStats(filteredExpenses);
    final categoryColors = {
      'Essentials': Colors.greenAccent,
      'Loans': Colors.blueAccent,
      'Savings': Colors.redAccent,
      'Lifestyle': Colors.yellowAccent,
    };
    final GetUserSalary salaryController = Get.put(GetUserSalary());

    // Fetch salary when the widget is built
    salaryController.fetchUserSalary().then((success) {
      if (success) {
        // print('Monthly Salary: ₹${salaryController.monthlySalary.value.toStringAsFixed(2)}');
      } else {
        print('Failed to fetch salary or no salary data available');
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Spending Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
          ).animate(effects: const [FadeEffect(), SlideEffect(begin: Offset(0, 0.1))]),
          const SizedBox(height: 20),
          StatCard(
            key: ValueKey('total_spending_${stats['totalSpending']}'),
            title: 'Total Spending',
            value: '₹${stats['totalSpending'].toStringAsFixed(2)}',
          ).animate(effects: const [FadeEffect(), SlideEffect(begin: Offset(0.1, 0))]),
          const SizedBox(height: 16),
          Obx(
            () => StatCard(
              key: ValueKey('available_salary_${salaryController.monthlySalary.value}_${stats['totalSpending']}'),
              title: 'Available Salary',
              value: salaryController.monthlySalary.value == 0.0
                  ? 'Salary not loaded'
                  : '₹${(salaryController.monthlySalary.value - stats['totalSpending']).toStringAsFixed(2)}',
              valueColor: salaryController.monthlySalary.value == 0.0
                  ? Colors.white
                  : (salaryController.monthlySalary.value - stats['totalSpending'] >= 0
                      ? Colors.greenAccent
                      : Colors.redAccent),
            ),
          ).animate(effects: const [FadeEffect(), SlideEffect(begin: Offset(0.1, 0))]),
          const SizedBox(height: 16),
          Obx(
            () => CircularBarCard(
              key: ValueKey('circular_${salaryController.monthlySalary.value}_${stats['totalSpending']}'),
              title: 'Salary Used vs Remaining',
              salary: salaryController.monthlySalary.value,
              totalSpending: stats['totalSpending'],
            ),
          ).animate(effects: const [FadeEffect(), SlideEffect(begin: Offset(0, 0.2))]),
          const SizedBox(height: 16),
          PieChartCard(
            key: ValueKey('pie_type_${_computeDataKey(stats['typeData'])}'),
            title: 'By Type (Savings, Essentials, Loans, Lifestyle)',
            data: stats['typeData'],
            variableKey: 'type',
            colorMap: categoryColors,
          ).animate(effects: const [FadeEffect(), SlideEffect(begin: Offset(0, 0.2))]),
          const SizedBox(height: 16),
          PieChartCard(
            key: ValueKey('pie_payment_${_computeDataKey(stats['paymentModeData'])}'),
            title: 'By Payment Mode',
            data: stats['paymentModeData'],
            variableKey: 'paymentMode',
          ).animate(effects: const [FadeEffect(), SlideEffect(begin: Offset(0, 0.2))]),
          const SizedBox(height: 16),
          LineChartCard(
            key: ValueKey('line_${_computeDataKey(stats['lineChartData'])}'),
            title: 'Spending Over Time',
            data: stats['lineChartData'],
          ).animate(effects: const [FadeEffect(), SlideEffect(begin: Offset(0, 0.2))]),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: valueColor ?? Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final String variableKey;
  final Map<String, Color>? colorMap;

  const PieChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.variableKey,
    this.colorMap,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure at least two colors to avoid graphic package assertion
    final colorValues = data.isEmpty
        ? [Colors.grey, Colors.grey]
        : data
            .map((e) => colorMap != null && colorMap!.containsKey(e[variableKey])
                ? colorMap![e[variableKey]]!
                : Colors.primaries[data.indexOf(e) % Colors.primaries.length])
            .toList();

    // If fewer than 2 colors, append a default color
    if (colorValues.length < 2) {
      colorValues.add(Colors.grey);
    }

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: data.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Animate(
                      effects: [
                        CustomEffect(
                          builder: (context, value, child) {
                            final animatedData = data
                                .map((e) => {
                                      variableKey: e[variableKey],
                                      'amount': (e['amount'] as num) * value,
                                    })
                                .toList();
                            return Chart(
                              data: animatedData,
                              variables: {
                                variableKey: Variable(
                                  accessor: (Map map) => map[variableKey] as String,
                                ),
                                'amount': Variable(
                                  accessor: (Map map) => map['amount'] as num,
                                  scale: LinearScale(min: 0),
                                ),
                              },
                              marks: [
                                IntervalMark(
                                  label: LabelEncode(
                                    encoder: (tuple) => Label(
                                      tuple[variableKey].toString(),
                                      LabelStyle(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  color: ColorEncode(
                                    variable: variableKey,
                                    values: colorValues,
                                  ),
                                ),
                              ],
                              coord: PolarCoord(transposed: true, dimFill: 1),
                            );
                          },
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                      ],
                      child: Container(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;

  const LineChartCard({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: data.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Animate(
                      effects: [
                        CustomEffect(
                          builder: (context, value, child) {
                            final animatedData = data
                                .map((e) => {
                                      'date': e['date'],
                                      'amount': (e['amount'] as num) * value,
                                    })
                                .toList();
                            return Chart(
                              data: animatedData,
                              variables: {
                                'date': Variable(
                                  accessor: (Map map) => map['date'] as String,
                                ),
                                'amount': Variable(
                                  accessor: (Map map) => map['amount'] as num,
                                ),
                              },
                              marks: [
                                LineMark(),
                                PointMark(),
                              ],
                              axes: [
                                Defaults.horizontalAxis,
                                Defaults.verticalAxis,
                              ],
                              selections: {
                                'tap': PointSelection(
                                  on: {GestureType.tap},
                                  dim: Dim.x,
                                ),
                              },
                              tooltip: TooltipGuide(),
                            );
                          },
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                      ],
                      child: Container(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularBarCard extends StatelessWidget {
  final String title;
  final double salary;
  final double totalSpending;

  const CircularBarCard({
    super.key,
    required this.title,
    required this.salary,
    required this.totalSpending,
  });

  @override
  Widget build(BuildContext context) {
    final remainingBalance = salary - totalSpending;
    final data = [
      {'category': 'Salary Used', 'amount': totalSpending},
      {'category': 'Remaining Salary', 'amount': remainingBalance >= 0 ? remainingBalance : 0},
    ];

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: salary == 0.0
                  ? const Center(
                      child: Text(
                        'Salary not loaded',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Animate(
                      effects: [
                        CustomEffect(
                          builder: (context, value, child) {
                            final animatedData = data
                                .map((e) => {
                                      'category': e['category'],
                                      'amount': (e['amount'] as num) * value,
                                    })
                                .toList();
                            return Chart(
                              data: animatedData,
                              variables: {
                                'category': Variable(
                                  accessor: (Map map) => map['category'] as String,
                                ),
                                'amount': Variable(
                                  accessor: (Map map) => map['amount'] as num,
                                  scale: LinearScale(min: 0),
                                ),
                              },
                              marks: [
                                IntervalMark(
                                  label: LabelEncode(
                                    encoder: (tuple) => Label(
                                      tuple['category'].toString(),
                                      LabelStyle(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  color: ColorEncode(
                                    variable: 'category',
                                    values: [
                                      Colors.greenAccent,
                                      remainingBalance >= 0 ? Colors.blueAccent : Colors.redAccent,
                                    ],
                                  ),
                                ),
                              ],
                              coord: PolarCoord(
                                transposed: true,
                                dimCount: 1,
                              ),
                              axes: [
                                Defaults.circularAxis,
                                Defaults.radialAxis,
                              ],
                              selections: {
                                'tap': PointSelection(
                                  on: {GestureType.tap},
                                  dim: Dim.x,
                                ),
                              },
                              tooltip: TooltipGuide(),
                            );
                          },
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                        ),
                      ],
                      child: Container(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 
 