import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Simple function to trigger Google Login
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // The user canceled the login
      }

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the new credential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Simple function to log out
  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}
