import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'dart:developer' as developer;

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
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the new credential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      developer.log('Error signing in with Google: $e', name: 'AuthService');
      return null;
    }
  }

  // Simple function to trigger Facebook Login
  static Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the native Facebook login prompt, requesting only public profile to avoid email scope errors
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );
      
      if (result.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        // Sign in to Firebase with the new credential
        return await FirebaseAuth.instance.signInWithCredential(credential);
      }
      return null; // The user canceled the login
    } catch (e) {
      developer.log('Error signing in with Facebook: $e', name: 'AuthService');
      return null;
    }
  }

  // Simple function to trigger Twitter Login
  static Future<UserCredential?> signInWithTwitter() async {
    try {
      TwitterAuthProvider twitterProvider = TwitterAuthProvider();
      // Firebase handles the Twitter OAuth flow securely for us
      return await FirebaseAuth.instance.signInWithProvider(twitterProvider);
    } catch (e) {
      developer.log('Error signing in with Twitter: $e', name: 'AuthService');
      return null;
    }
  }

  // Simple function to log out
  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();
  }
}
