import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'translate_screen.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TranslateScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = 'Login failed. Please check your credentials.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.darkMode,
      builder: (context, isDark, child) {
        final screenSize = MediaQuery.of(context).size;
        final isMobile = screenSize.width < 600;
        final isTablet = screenSize.width >= 600 && screenSize.width < 1200;

        // Responsive sizes
        final titleFontSize = isMobile ? 24.0 : (isTablet ? 28.0 : 32.0);
        final subtitleFontSize = isMobile ? 12.0 : (isTablet ? 13.0 : 14.0);
        final labelFontSize = isMobile ? 11.0 : (isTablet ? 12.0 : 13.0);
        final buttonHeight = isMobile ? 48.0 : (isTablet ? 52.0 : 56.0);
        final horizontalPadding = isMobile ? 20.0 : (isTablet ? 40.0 : 60.0);
        final verticalSpacing = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

        return Scaffold(
          backgroundColor: AppTheme.paper,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.ink),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: verticalSpacing),
                // Welcome Back Text
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.5),
                Text(
                  'Please enter your details to sign in.',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: AppTheme.muted,
                  ),
                ),
                SizedBox(height: verticalSpacing * 1.5),
                // Email Field
                Text(
                  'EMAIL',
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.4),
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: AppTheme.ink),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isMobile ? 12 : 14,
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing),
                // Password Field
                Text(
                  'PASSWORD',
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.4),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: AppTheme.ink),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isMobile ? 12 : 14,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.muted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.6),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: isMobile ? 11.0 : (isTablet ? 12.0 : 13.0),
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing),
                // Log In Button
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.yellow,
                      foregroundColor: AppTheme.onYellow,
                      elevation: 0,
                      side: BorderSide(color: AppTheme.ink, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleEmailLogin,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.onYellow,
                            ),
                          )
                        : Text(
                            'LOG IN',
                            style: TextStyle(
                              fontSize:
                                  isMobile ? 14.0 : (isTablet ? 16.0 : 18.0),
                              fontWeight: FontWeight.w900,
                              color: AppTheme.onYellow,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: verticalSpacing),
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppTheme.ink.withValues(alpha: 0.25),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(
                          fontSize: isMobile ? 10.0 : (isTablet ? 11.0 : 12.0),
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppTheme.ink.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: verticalSpacing),
                // Social Login Buttons — Google, Facebook, Twitter only (no Apple)
                Row(
                  children: [
                    // Google
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor: AppTheme.ink,
                          padding: EdgeInsets.symmetric(
                            vertical: buttonHeight * 0.35,
                          ),
                          side: BorderSide(color: AppTheme.ink, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                final user =
                                    await AuthService.signInWithGoogle();
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  if (user != null) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TranslateScreen(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Google sign-in failed. Please try again.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: Text(
                          'G',
                          style: TextStyle(
                            fontSize:
                                isMobile ? 16.0 : (isTablet ? 18.0 : 20.0),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: verticalSpacing * 0.4),
                    // Facebook
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor: AppTheme.ink,
                          padding: EdgeInsets.symmetric(
                            vertical: buttonHeight * 0.35,
                          ),
                          side: BorderSide(color: AppTheme.ink, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                final user =
                                    await AuthService.signInWithFacebook();
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  if (user != null) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TranslateScreen(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Facebook sign-in failed. Please try again.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: Icon(
                          Icons.facebook,
                          size: isMobile ? 22.0 : (isTablet ? 24.0 : 26.0),
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                    SizedBox(width: verticalSpacing * 0.4),
                    // Twitter / X
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor: AppTheme.ink,
                          padding: EdgeInsets.symmetric(
                            vertical: buttonHeight * 0.35,
                          ),
                          side: BorderSide(color: AppTheme.ink, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                final user =
                                    await AuthService.signInWithTwitter();
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  if (user != null) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TranslateScreen(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Twitter sign-in failed. Please try again.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: Text(
                          '𝕏',
                          style: TextStyle(
                            fontSize:
                                isMobile ? 18.0 : (isTablet ? 20.0 : 22.0),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: verticalSpacing),
                // Sign Up Link
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        fontSize: isMobile ? 12.0 : (isTablet ? 13.0 : 14.0),
                        color: AppTheme.muted,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            fontSize:
                                isMobile ? 12.0 : (isTablet ? 13.0 : 14.0),
                            color: AppTheme.ink,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: null, // TODO: Implement sign up
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.6),
                // View as Guest
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const TranslateScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'VIEW AS GUEST',
                      style: TextStyle(
                        fontSize: isMobile ? 12.0 : (isTablet ? 13.0 : 14.0),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
