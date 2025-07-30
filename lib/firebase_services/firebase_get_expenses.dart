import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetExpenses {
  // Singleton (optional)
  static final GetExpenses _instance = GetExpenses._internal();
  factory GetExpenses() => _instance;
  GetExpenses._internal();

  /// Fetch all expenses for the current user
  Future<List<Map<String, dynamic>>> fetchUserExpenses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .get();

      final expenses = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Optional: Include Firestore document ID
        return data;
      }).toList();

      return expenses;
    } catch (e) {
      print('Error fetching expenses: $e');
      return [];
    }
  }
}
