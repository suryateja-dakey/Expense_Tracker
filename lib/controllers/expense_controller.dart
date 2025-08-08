import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ExpenseController extends GetxController {
  var focusedIndex = 0.obs;

  final appAssets =[{
    'name':'Spendex',
    'logo':'assets/file_svgs/app_logo.svg'
  }];

  final categories = [
    {
      'name': 'Essentials',
      'image': 'assets/expense_category_items/essentials_animation.json',
      'amount':"0.0",
      'color':Colors. greenAccent,
      
    },
    {
      'name': 'Lifestyle',
      'image': 'assets/expense_category_items/lifestyle.json',
       'amount':"0.0",
      'color': const Color(0xFFD7CCC8),
    },
    {
      'name': 'Savings',
      'image': 'assets/expense_category_items/savings.json',
       'amount':"0.0",
      'color': const Color.fromARGB(255, 145, 168, 104),
    },
    {
      'name': 'Loans',
      'image': 'assets/expense_category_items/loan.json',
       'amount':"0.0",
      'color': const Color.fromARGB(255, 131, 195, 182),
    },
    
  ];

  // Structure: Category -> Subcategory -> Sub-subcategory List
  final Map<String, Map<String, List<String>>> categoryHierarchy = {
    'Essentials': {
      'Housing': ['Rent', 'Mortgage', 'Property Tax', 'Maintenance'],
      'Utilities': ['Electricity', 'Water', 'Gas', 'Internet', 'Phone Bill'],
      'Groceries': ['Food', 'Household Supplies'],
      'Transportation': ['Fuel', 'Public Transport', 'Car Payments', 'Insurance'],
      'Healthcare': ['Insurance', 'Doctor Visits', 'Medicines'],
    },
    'Lifestyle': {
      'Entertainment': ['Streaming', 'Movies', 'Concerts', 'Subscriptions'],
      'Shopping': ['Clothes', 'Gadgets', 'Accessories'],
      'Dining Out': ['Restaurants', 'Cafés', 'Takeout'],
      'Fitness & Hobbies': ['Gym', 'Sports', 'Hobbies', 'Gaming'],
    },
    'Savings': {
      'Emergency Fund': ['Savings for Unexpected Expenses'],
      'Investments': ['Stocks', 'Mutual Funds', 'Crypto', 'Real Estate'],
      'Education': ['Courses', 'Books', 'Certifications'],
    },
    'Loans': {
      'Loans': ['Credit Card Bills', 'Personal Loans', 'Car Loans'],
      'EMIs': ['Monthly Installment Payments'],
    },
  };

  final List<String> paymentModes = [
    'Cash',
    'UPI',
    'Credit Card',
    'Debit Card',
    'Net Banking',
    'Wallet',
  ];

  void setFocusedIndex(int index) {
    focusedIndex.value = index;
  }

  /// Get Subcategories for a given main category
  List<String> getSubCategories(String categoryName) {
    return categoryHierarchy[categoryName]?.keys.toList() ?? [];
  }

  /// Get Sub-subcategories for a given main and sub category
  List<String> getSubSubCategories(String categoryName, String subCategoryName) {
    return categoryHierarchy[categoryName]?[subCategoryName] ?? [];
  }
}
