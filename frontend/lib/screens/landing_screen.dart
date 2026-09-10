import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'translate_screen.dart';
import '../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final isLoggedIn = authSnapshot.data != null;

        return ValueListenableBuilder<bool>(
          valueListenable: AppTheme.darkMode,
          builder: (context, isDark, child) {
            final screenSize = MediaQuery.of(context).size;
            final isMobile = screenSize.width < 600;
            final isTablet = screenSize.width >= 600 && screenSize.width < 1200;

            // Responsive sizes
            final logoSize = isMobile ? 120.0 : (isTablet ? 160.0 : 180.0);
            final titleFontSize = isMobile ? 32.0 : (isTablet ? 40.0 : 48.0);
            final taglineFontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
            final descriptionFontSize =
                isMobile ? 13.0 : (isTablet ? 14.0 : 15.0);
            final buttonHeight = isMobile ? 48.0 : (isTablet ? 52.0 : 56.0);
            final horizontalPadding =
                isMobile ? 24.0 : (isTablet ? 40.0 : 60.0);
            final verticalSpacing = isMobile ? 20.0 : (isTablet ? 28.0 : 36.0);

            return Scaffold(
              backgroundColor: AppTheme.landingBackground,
              body: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: verticalSpacing),
                        // Logo Badge
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            color: AppTheme.yellow,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppTheme.ink, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.ink.withValues(
                                  alpha: isDark ? 0.4 : 0.85,
                                ),
                                offset: const Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'ក',
                              style: TextStyle(
                                fontSize: logoSize * 0.48,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.onYellow,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: verticalSpacing),
                        // App Title
                        Text(
                          'Khmerify',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.ink,
                          ),
                        ),
                        SizedBox(height: verticalSpacing * 0.5),
                        // Tagline
                        Text(
                          'Khmer Typing Made Easy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: taglineFontSize,
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: verticalSpacing * 0.4),
                        // Description
                        Text(
                          'Type with speed, precision, and confidence',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: descriptionFontSize,
                            color: AppTheme.muted,
                          ),
                        ),
                        SizedBox(height: verticalSpacing * 1.5),

                        if (isLoggedIn) ...[
                          // Already logged in — go straight to app
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
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TranslateScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'CONTINUE',
                                style: TextStyle(
                                  fontSize: isMobile
                                      ? 14.0
                                      : (isTablet ? 16.0 : 18.0),
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.onYellow,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Not logged in — show Get Started & login options
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
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'GET STARTED',
                                style: TextStyle(
                                  fontSize: isMobile
                                      ? 14.0
                                      : (isTablet ? 16.0 : 18.0),
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.onYellow,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: verticalSpacing * 0.6),
                          // Already Have Account
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'I ALREADY HAVE AN ACCOUNT',
                              style: TextStyle(
                                fontSize:
                                    isMobile ? 12.0 : (isTablet ? 13.0 : 14.0),
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ink,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: verticalSpacing),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
