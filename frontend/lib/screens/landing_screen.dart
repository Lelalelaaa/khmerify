import 'package:flutter/material.dart';
import 'login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1200;
    
    // Responsive sizes
    final logoSize = isMobile ? 120.0 : (isTablet ? 160.0 : 180.0);
    final titleFontSize = isMobile ? 32.0 : (isTablet ? 40.0 : 48.0);
    final taglineFontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
    final descriptionFontSize = isMobile ? 13.0 : (isTablet ? 14.0 : 15.0);
    final buttonHeight = isMobile ? 48.0 : (isTablet ? 52.0 : 56.0);
    final horizontalPadding = isMobile ? 24.0 : (isTablet ? 40.0 : 60.0);
    final verticalSpacing = isMobile ? 20.0 : (isTablet ? 28.0 : 36.0);
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: verticalSpacing),
                // Logo
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF003DA5),
                        Color(0xFF0052CC),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF003DA5).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background decorative circle
                      Container(
                        width: logoSize * 0.85,
                        height: logoSize * 0.85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      // Main content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: logoSize * 0.6,
                            height: logoSize * 0.6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'ក',
                                style: TextStyle(
                                  fontSize: logoSize * 0.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: verticalSpacing),
                // App Title
                Text(
                  'Khmerify',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF003DA5),
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.5),
                // Tagline
                Text(
                  'Khmer Typing Made Easy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: taglineFontSize,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.4),
                // Description
                Text(
                  'Type with speed, precision, and confidence',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: verticalSpacing * 1.5),
                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003DA5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                        fontSize: isMobile ? 14.0 : (isTablet ? 16.0 : 18.0),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                      fontSize: isMobile ? 12.0 : (isTablet ? 13.0 : 14.0),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF003DA5),
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
