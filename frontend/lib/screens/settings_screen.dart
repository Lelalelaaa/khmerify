import 'package:flutter/material.dart';

import 'landing_screen.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final bool showAppBar;

  const SettingsScreen({super.key, this.showAppBar = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSaveHistory = true;
  String _appLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.darkMode,
      builder: (context, isDark, child) {
        final screenSize = MediaQuery.of(context).size;
        final isMobile = screenSize.width < 600;

        // Responsive sizes
        final appBarTitleSize = isMobile
            ? 18.0
            : (screenSize.width >= 1200 ? 24.0 : 20.0);
        final sectionLabelSize = isMobile
            ? 10.0
            : (screenSize.width >= 1200 ? 12.0 : 11.0);
        final titleSize = isMobile
            ? 13.0
            : (screenSize.width >= 1200 ? 15.0 : 14.0);
        const buttonHeight = 50.0;
        final horizontalPadding = isMobile
            ? 14.0
            : (screenSize.width >= 1200 ? 28.0 : 20.0);

        return Scaffold(
          backgroundColor: AppTheme.paper,
          appBar: widget.showAppBar
              ? AppBar(
                  backgroundColor: AppTheme.paper,
                  elevation: 0,
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: appBarTitleSize,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      child: Center(
                        child: CircleAvatar(
                          backgroundColor: AppTheme.yellow,
                          radius: isMobile ? 18 : 20,
                          child: Icon(Icons.person, color: AppTheme.onYellow),
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isMobile ? 18 : 26,
                    horizontalPadding,
                    8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Make it yours.',
                        style: TextStyle(
                          fontSize: isMobile ? 28 : 36,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tune your Khmerify experience.',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 15,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
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
                          color: AppTheme.muted,
                        ),
                      ),
                      SizedBox(height: isMobile ? 10 : 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.yellow,
                          radius: isMobile ? 22 : 26,
                          child: Icon(
                            Icons.person,
                            color: AppTheme.onYellow,
                            size: isMobile ? 18 : 22,
                          ),
                        ),
                        title: Text(
                          'Example',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ink,
                          ),
                        ),
                        subtitle: Text(
                          'user@example.com',
                          style: TextStyle(
                            fontSize: isMobile ? 11.0 : 12.0,
                            color: AppTheme.muted,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: isMobile ? 14 : 16,
                          color: AppTheme.ink,
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
                            color: AppTheme.ink,
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
                          color: AppTheme.muted,
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
                        trailing: ValueListenableBuilder<bool>(
                          valueListenable: AppTheme.darkMode,
                          builder: (context, isDark, child) {
                            return Switch(
                              value: isDark,
                              onChanged: AppTheme.setDarkMode,
                              activeThumbColor: AppTheme.green,
                            );
                          },
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
                          activeThumbColor: AppTheme.green,
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
                                color: AppTheme.muted,
                                fontSize: isMobile ? 11.0 : 12.0,
                              ),
                            ),
                            SizedBox(width: isMobile ? 6 : 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: isMobile ? 14 : 16,
                              color: AppTheme.muted,
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
                          color: AppTheme.muted,
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
                          color: AppTheme.muted,
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
                        backgroundColor: AppTheme.pink,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: AppTheme.ink, width: 2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                      color: AppTheme.muted,
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
            child: Text('Cancel', style: TextStyle(color: AppTheme.muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LandingScreen()),
              );
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                color: AppTheme.pink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
