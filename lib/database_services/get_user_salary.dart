import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GetUserSalary extends GetxController {
  // Reactive variable to store the monthly salary
  final RxDouble monthlySalary = 0.0.obs;

  // Method to fetch salary from Firestore
  Future<bool> fetchUserSalary() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'No user is logged in',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('monthlySalary')) {
        monthlySalary.value = userDoc.data()!['monthlySalary'] as double;
        return true;
      } else {
        Get.snackbar('Info', 'No salary data found for this user',
            backgroundColor: Colors.orange, colorText: Colors.white);
        monthlySalary.value = 0.0; // Default value
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch salary: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      monthlySalary.value = 0.0; // Default value on error
      return false;
    }
  }
}