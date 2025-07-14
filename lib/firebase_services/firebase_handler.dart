 import 'package:firebase_auth/firebase_auth.dart';

class FirebaseHelper{

  String getErrorMessage(FirebaseException e){
    switch(e.code){
      case 'invalid-credential': return "Invalid email or password";
      case 'invalid-email' : return "invalid email format";
      case 'email-already-in-use': return "Email already registered by another user";
      case 'weak-password' : return "Your password is too weak";
      default: return "Unexpected error: ${e.message}";
    }
  }
 }