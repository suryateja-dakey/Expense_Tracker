import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ExpenseController extends GetxController {
  var focusedIndex = 0.obs;

  final categories = [
    {
      'name': 'Essentials',
      'amount': '3640',
      'image': 'assets/expense_category_items/essentials_animation.json',
      'color': const Color(0xFF7ACB78)
    },
    {
      'name': 'Lifestyle',
      'amount': '6520',
      'image': 'assets/expense_category_items/lifestyle.json',
      'color': const Color(0xFFD7CCC8)
    },
    {
      'name': 'Savings',
      'amount': '1200',
      'image': 'assets/expense_category_items/savings.json',
      'color': const Color(0xFF556B2F)
    },
    {
      'name': 'Loans',
      'amount': '8000',
      'image': 'assets/expense_category_items/loan.json',
      'color': const Color(0xFF11D9B2)
    },
  ];

  void setFocusedIndex(int index) {
    focusedIndex.value = index;
  }
}
