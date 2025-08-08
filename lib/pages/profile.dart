import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/database_services/get_user_salary.dart';
import 'package:expense_tracker/firebase_services/firebase_get_expenses.dart';
import 'package:expense_tracker/widgets/common_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:math';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ExpenseController controller = Get.find<ExpenseController>();
  final GetUserSalary salaryController = Get.find<GetUserSalary>();
  List<Map<String, dynamic>> expenses = [];
  double usedSalary = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await salaryController.fetchUserSalary();

    expenses = await GetExpenses().fetchUserExpenses();
    final now = DateTime.now();
    usedSalary = expenses
        .where((expense) {
          final date = expense['date'] is Timestamp
              ? (expense['date'] as Timestamp).toDate()
              : DateTime.parse(expense['date'].toString());
          return date.year == now.year && date.month == now.month;
        })
        .fold(
          0.0,
          (sum, expense) => sum + (expense['amount'] as num).toDouble(),
        );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Not logged in';
    final nameInitial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    final double totalSalary = salaryController.monthlySalary.value;
    final double usedPercentage = totalSalary > 0
        ? (usedSalary / totalSalary).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: true,
        title: 'Profile',
        heroTag: 'appBarHero',
        backgroundColor: Colors.black,
        onPressedBack: () {
          print('Back button pressed: Navigating to HomePage');
          Get.back();
        },
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              const SizedBox(height: 20),
              Hero(
                tag: 'app-logo',
                child: SvgPicture.asset(
                  controller.appAssets[0]["logo"].toString(),
                  width: 100,
                  height: 100,
                  colorFilter: const ColorFilter.mode(
                    Colors.greenAccent,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Avatar and Email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.greenAccent.withOpacity(0.2),
                    child: Text(
                      nameInitial,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Flexible(child: _labelValue("Email", email)),
                ],
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(
                        () => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _labelValue(
                            "Total Salary",
                            salaryController.monthlySalary.value > 0
                                ? '₹${salaryController.monthlySalary.value.toStringAsFixed(2)}'
                                : 'Not Added',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _labelValue(
                          "Used Salary",
                          expenses.isEmpty && usedSalary == 0.0
                              ? 'Loading...'
                              : '₹${usedSalary.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Obx(
                      () => Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: TweenAnimationBuilder(
                              tween: Tween<double>(
                                begin: 0.0,
                                end: salaryController.monthlySalary.value > 0
                                    ? ((salaryController.monthlySalary.value - usedSalary) /
                                            salaryController.monthlySalary.value)
                                        .clamp(0.0, 1.0)
                                    : 0.0,
                              ),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeOut,
                              builder: (context, double value, child) {
                                return CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white10,
                                  color: Colors.greenAccent,
                                );
                              },
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                salaryController.monthlySalary.value > 0
                                    ? "${((1 - usedPercentage) * 100).toStringAsFixed(1)}%"
                                    : "0.0%",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Remaining\n   Salary",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.offAllNamed('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 30, 35, 29),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Text(
                'Developed by',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SURYA TEJA DAKEY',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}