import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:expense_tracker/controllers/connectivity_controller.dart';
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/pages/authentications/login.dart';
import 'package:expense_tracker/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    Get.put(ConnectivityController());
  runApp(ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.greenAccent,
        cardColor: Colors.grey[900],
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ExpenseController controller = Get.put(ExpenseController());

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 2)); // Splash screen delay
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if user is new by checking Firestore document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists && mounted) {
        // Show bottom sheet for new user
        // _showSalaryBottomSheet(user.uid);
         Get.offAll(() => HomePage());
      } else {
        Get.offAll(() => HomePage());
      }
    } else {
      Get.offAll(() => Login());
    }
  }

  void _showSalaryBottomSheet(String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SalaryInputBottomSheet(userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'app-logo',
              child: SvgPicture.asset(
                controller.appAssets[0]["logo"].toString(),
                width: screenWidth * 0.3, // 30% of screen width
                height: screenWidth * 0.3,
                colorFilter: ColorFilter.mode(Colors.greenAccent, BlendMode.srcIn),
              ).animate(
                // onPlay: (controller) => controller.repeat(), // Uncomment for loop (optional)
              ).fadeIn(duration: 1000.ms).scale(
                    begin: Offset(0.8, 0.8),
                    end: Offset(1.0, 1.0),
                    duration: 1000.ms,
                  ),
            ),
            SizedBox(height: screenHeight * 0.03), // Dynamic spacing
            Text(
              controller.appAssets[0]["name"].toString(),
              style: TextStyle(
                fontSize: screenWidth * 0.08, // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.greenAccent.withOpacity(0.7),
                    blurRadius: 10,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ).animate(
              // onPlay: (controller) => controller.repeat(), // Uncomment for loop (optional)
            ).fadeIn(duration: 1000.ms).slideY(
                  begin: 0.2,
                  end: 0.0,
                  duration: 1000.ms,
                ),
            SizedBox(height: screenHeight * 0.02), // Dynamic spacing
            Text(
              "Your Expenses are under control!",
              style: TextStyle(
                fontSize: screenWidth * 0.04, // Responsive font size
                fontWeight: FontWeight.w500,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.greenAccent.withOpacity(0.7),
                    blurRadius: 10,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ).animate(
              // onPlay: (controller) => controller.repeat(), // Uncomment for loop (optional)
            ).fadeIn(duration: 1000.ms).slideY(
                  begin: 0.2,
                  end: 0.0,
                  duration: 1000.ms,
                ),
          ],
        ),
      ),
    );
  }
}

class SalaryInputBottomSheet extends StatefulWidget {
  final String userId;

  const SalaryInputBottomSheet({required this.userId});

  @override
  _SalaryInputBottomSheetState createState() => _SalaryInputBottomSheetState();
}

class _SalaryInputBottomSheetState extends State<SalaryInputBottomSheet> {
  final TextEditingController _salaryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _saveSalary() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .set({
          'monthlySalary': double.parse(_salaryController.text),
          'createdAt': FieldValue.serverTimestamp(),
        });
        Get.offAll(() => HomePage());
      } catch (e) {
        Get.snackbar('Error', 'Failed to save salary: $e',
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome! Enter Your Monthly Salary',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Monthly Salary',
                labelStyle: TextStyle(color: Colors.greenAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your salary';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator(color: Colors.greenAccent)
                : ElevatedButton(
                    onPressed: _saveSalary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }
}