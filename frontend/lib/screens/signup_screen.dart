import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'translate_screen.dart';
import '../theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TranslateScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        default:
          message = 'Sign up failed: ${e.message}';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (context.mounted) setState(() => _isLoading = false);
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Create Account',
                    style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.w900, color: AppTheme.ink),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Join Khmerify and start translating today.',
                    style: TextStyle(fontSize: subtitleFontSize, color: AppTheme.muted),
                  ),
                  SizedBox(height: verticalSpacing * 1.5),

                  // Full Name
                  Text('FULL NAME', style: TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w600, color: AppTheme.ink)),
                  SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: AppTheme.ink),
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Email
                  Text('EMAIL', style: TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w600, color: AppTheme.ink)),
                  SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: AppTheme.ink),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Password
                  Text('PASSWORD', style: TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w600, color: AppTheme.ink)),
                  SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    style: TextStyle(color: AppTheme.ink),
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'At least 6 characters',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.muted),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Confirm Password
                  Text('CONFIRM PASSWORD', style: TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w600, color: AppTheme.ink)),
                  SizedBox(height: 6),
                  TextField(
                    controller: _confirmPasswordController,
                    style: TextStyle(color: AppTheme.ink),
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      hintText: 'Re-enter your password',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppTheme.muted),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 1.5),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.yellow,
                        foregroundColor: AppTheme.onYellow,
                        elevation: 0,
                        side: BorderSide(color: AppTheme.ink, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _handleSignUp,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.onYellow),
                            )
                          : Text(
                              'CREATE ACCOUNT',
                              style: TextStyle(
                                fontSize: isMobile ? 14.0 : (isTablet ? 16.0 : 18.0),
                                fontWeight: FontWeight.w900,
                                color: AppTheme.onYellow,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Already have account
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(fontSize: isMobile ? 12.0 : (isTablet ? 13.0 : 14.0), color: AppTheme.muted),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(
                              fontSize: isMobile ? 12.0 : (isTablet ? 13.0 : 14.0),
                              color: AppTheme.ink,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
