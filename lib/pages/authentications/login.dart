import 'dart:io';

import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/firebase_services/firebase_core_calls.dart';
import 'package:expense_tracker/pages/authentications/signup.dart';
import 'package:expense_tracker/pages/home_page.dart';
import 'package:expense_tracker/widgets/custom_svg_text_button.dart';
import 'package:expense_tracker/widgets/custom_text_button.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final repo = Repository();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final ExpenseController controller = Get.put(ExpenseController());

  final _formKey = GlobalKey<FormState>();
  bool _isLoadingGoogle = false;
  bool _isLoadingSignin = false;
  bool _isLoadingApple = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo and App Name
              Padding(
                padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      controller.appAssets[0]["logo"].toString(),
                      width: 30,
                      height: 30,
                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      controller.appAssets[0]["name"].toString(),
                      style: TextStyle(
                        fontSize: 22,
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
                     const SizedBox(width: 10),
                  ],
                ),
              ),
                const SizedBox(height: 22),
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Let’s fix your \nmoney mess!",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500 ,
                        color: Colors.white,
                        fontSize: 20
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Top half of SVG
                    ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 0.5, // Shows only the top half
                        child: SvgPicture.asset(
                          controller.appAssets[0]["logo"].toString(),
                          width: 120,
                          height: 120,
                          colorFilter: ColorFilter.mode(Colors.greenAccent, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                   
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: password,
                      obscureText: true,
                      hintText: "Password",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter password";
                        }
                        if (value.length < 6) return "Password too short";
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPressed: _handleLogin,
                        label: "Login",
                        isLoading: _isLoadingSignin,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Signup()),
                            );
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(color: theme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: BlackSvgButton(
                            label: "Google",
                            svgAsset: "assets/file_svgs/logo_google.svg",
                            isLoading: _isLoadingGoogle,
                            onPressed: () async {
                              setState(() => _isLoadingGoogle = true);
                              final success = await signInWithGoogle();
                              setState(() => _isLoadingGoogle = false);

                              if (success) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => HomePage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Google Sign-In failed"),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BlackSvgButton(
                            label: "Apple",
                            svgAsset: "assets/file_svgs/logo_apple.svg",
                            isLoading: _isLoadingApple,
                            onPressed: () async {
                              setState(() => _isLoadingApple = true);
                              if (!Platform.isIOS && !Platform.isMacOS) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Apple Sign-In support only apple devices"),
                                  ),
                                );
                                setState(() => _isLoadingApple = false);
                              } else {
                                final success = await signInWithApple();
                                setState(() => _isLoadingApple = false);

                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => HomePage()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Apple Sign-In failed"),
                                    ),
                                  );
                                }
                              }
                            },
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
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoadingSignin = true);

    final res = await repo.signIn(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    setState(() => _isLoadingSignin = false);

    if (res.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message ?? "Login failed")));
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account == null) {
        print('⚠️ Google sign-in aborted by user');
        return false;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS) {
        print('❌ Apple Sign-In is only supported on iOS/macOS');
        return false;
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      print('❌ Apple Sign-In Error: $e');
      return false;
    }
  }
}