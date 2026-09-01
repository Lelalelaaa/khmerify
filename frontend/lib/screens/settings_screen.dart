import 'package:flutter/material.dart';
import 'landing_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool showAppBar;
  
  const SettingsScreen({super.key, this.showAppBar = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _autoSaveHistory = true;
  String _appLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    // Responsive sizes
    final appBarTitleSize = isMobile ? 18.0 : (screenSize.width >= 1200 ? 24.0 : 20.0);
    final sectionLabelSize = isMobile ? 10.0 : (screenSize.width >= 1200 ? 12.0 : 11.0);
    final titleSize = isMobile ? 13.0 : (screenSize.width >= 1200 ? 15.0 : 14.0);
    const buttonHeight = 50.0;
    final horizontalPadding = isMobile ? 14.0 : (screenSize.width >= 1200 ? 28.0 : 20.0);
    
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: const Color(0xFF003DA5),
        elevation: 0,
        title: Text(
          'Khmerify',
          style: TextStyle(
            fontSize: appBarTitleSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: isMobile ? 18 : 20,
                child: const Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCOUNT',
                    style: TextStyle(
                      fontSize: sectionLabelSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: isMobile ? 22 : 26,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: isMobile ? 18 : 22,
                      ),
                    ),
                    title: Text(
                      'Example',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'user@example.com',
                      style: TextStyle(fontSize: isMobile ? 11.0 : 12.0),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: isMobile ? 14 : 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // TODO: Navigate to edit profile
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement Edit Profile
                    },
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: const Color(0xFF003DA5),
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 12.0 : 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Preferences Section
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PREFERENCES',
                    style: TextStyle(
                      fontSize: sectionLabelSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : 12),
                  // Dark Mode
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: titleSize),
                    ),
                    trailing: Switch(
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() {
                          _darkMode = value;
                        });
                      },
                      activeColor: const Color(0xFF003DA5),
                    ),
                  ),
                  // Auto-save History
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Auto-save History',
                      style: TextStyle(fontSize: titleSize),
                    ),
                    trailing: Switch(
                      value: _autoSaveHistory,
                      onChanged: (value) {
                        setState(() {
                          _autoSaveHistory = value;
                        });
                      },
                      activeColor: const Color(0xFF003DA5),
                    ),
                  ),
                  // App Language
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'App Language',
                      style: TextStyle(fontSize: titleSize),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _appLanguage,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isMobile ? 11.0 : 12.0,
                          ),
                        ),
                        SizedBox(width: isMobile ? 6 : 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: isMobile ? 14 : 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            // Support Section
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUPPORT',
                    style: TextStyle(
                      fontSize: sectionLabelSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Help & Support',
                      style: TextStyle(fontSize: titleSize),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: isMobile ? 14 : 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            // Logout Section
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _showLogoutDialog();
                  },
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: isMobile ? 14.0 : 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Text(
                'Khmerify Version 2.4.0',
                style: TextStyle(
                  fontSize: isMobile ? 10.0 : 12.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                setState(() {
                  _appLanguage = 'English';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Khmer'),
              onTap: () {
                setState(() {
                  _appLanguage = 'Khmer';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LandingScreen(),
                ),
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
