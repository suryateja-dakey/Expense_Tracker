import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/firebase_services/firebase_core_calls.dart';
import 'package:expense_tracker/pages/authentications/login.dart';
import 'package:expense_tracker/pages/home_page.dart';
import 'package:expense_tracker/widgets/custom_text_button.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final repo = Repository();

  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Logo and App Name (fixed at top)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.03,
                bottom: screenHeight * 0.02,
                left: screenWidth * 0.1,
                right: screenWidth * 0.1,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    Get.find<ExpenseController>().appAssets[0]["logo"].toString(),
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Get.find<ExpenseController>().appAssets[0]["name"].toString(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.7),
                          blurRadius: 5,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Centered Form with Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.01), // Top padding for centering
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Sign up and sort \nyour savings!",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Top half of SVG
                        ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor: 0.5,
                            child: SvgPicture.asset(
                              Get.find<ExpenseController>().appAssets[0]["logo"].toString(),
                              width: screenWidth * 0.3,
                              height: screenWidth * 0.3,
                              colorFilter: ColorFilter.mode(Colors.greenAccent, BlendMode.srcIn),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        CustomTextField(
                          controller: fullName,
                          hintText: "Full Name",
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Enter your name";
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        CustomTextField(
                          controller: email,
                          hintText: "Email",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Enter email";
                            if (!value.contains("@")) return "Enter valid email";
                            return null;
                          },
                        ),
                       
                        SizedBox(height: screenHeight * 0.02),
                        CustomTextField(
                          controller: password,
                          obscureText: true,
                          hintText: "Password",
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Enter password";
                            if (value.length < 6) return "Password too short";
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        SizedBox(
                          width: screenWidth * 0.8,
                          child: PrimaryButton(
                            onPressed: _handleSignup,
                            label: "Register",
                            isLoading: _isLoading,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const Login()),
                                );
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = await repo.signUp(
      fullName: fullName.text.trim(),
      email: email.text.trim(),
      password: password.text.trim(),
    );

    setState(() => _isLoading = false);

    if (res.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message ?? "Signup failed")));
    }
  }
}