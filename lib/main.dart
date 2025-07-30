import 'package:expense_tracker/pages/authentications/login.dart';
import 'package:expense_tracker/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
//  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
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
      home:
      // Login(), 
        // HomePage(),
      FirebaseAuth.instance.currentUser!=null?HomePage(): Login(), 
    );
  }
}
