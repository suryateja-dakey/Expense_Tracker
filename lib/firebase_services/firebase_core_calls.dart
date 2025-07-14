import 'package:expense_tracker/firebase_services/firebase_handler.dart';
import 'package:expense_tracker/firebase_services/firebase_service.dart';
 import 'package:firebase_auth/firebase_auth.dart';
 

class AuthResult {
  final bool success;
  final String? message;
  const AuthResult({required this.success, this.message});
}

class Repository extends FirebaseHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
   final FirebaseServices _services = FirebaseServices();

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential usr = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (usr.user != null) {
        return AuthResult(success: true);
      } else {
        return AuthResult(success: false, message: "User not found");
      }
    } on FirebaseException catch (e) {
      final message = getErrorMessage(e);
      return AuthResult(success: false, message: message);
    }
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential usr = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (usr.user != null) {
        await usr.user?.updateDisplayName(fullName);
        await usr.user?.reload();
        return AuthResult(success: true);
      } else {
        return AuthResult(success: false, message: "Failed to create user");
      }
    } on FirebaseException catch (e) {
      final message = getErrorMessage(e);
      return AuthResult(success: false, message: message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
