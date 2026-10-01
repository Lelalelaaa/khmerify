import 'package:flutter/material.dart';

import 'landing_screen.dart';
import '../services/auth_service.dart';
import '../services/keyboard_service.dart';
import '../theme/app_theme.dart';
import 'settings/settings_components.dart';

class SettingsScreen extends StatefulWidget {
  final bool showAppBar;

  const SettingsScreen({super.key, this.showAppBar = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _autoSaveHistory = true;
  String _appLanguage = 'English';
  bool _isKeyboardEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkKeyboardStatus();
    }
  }

  Future<void> _checkKeyboardStatus() async {
    final enabled = await KeyboardService.isKeyboardEnabled();
    if (mounted) {
      setState(() {
        _isKeyboardEnabled = enabled;
      });
    }
  }

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
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: AccountSection(
                    isMobile: isMobile,
                    sectionLabelSize: sectionLabelSize,
                    titleSize: titleSize,
                  ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: PreferencesSection(
                    isMobile: isMobile,
                    sectionLabelSize: sectionLabelSize,
                    titleSize: titleSize,
                    autoSaveHistory: _autoSaveHistory,
                    onAutoSaveChanged: (value) {
                      setState(() {
                        _autoSaveHistory = value;
                      });
                    },
                    appLanguage: _appLanguage,
                    onLanguageTap: _showLanguageDialog,
                  ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: KeyboardSection(
                    isMobile: isMobile,
                    sectionLabelSize: sectionLabelSize,
                    isKeyboardEnabled: _isKeyboardEnabled,
                  ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: SupportSection(
                    isMobile: isMobile,
                    sectionLabelSize: sectionLabelSize,
                    titleSize: titleSize,
                  ),
                ),
                const Divider(),
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
                    'Khmerify Version 1.0.0',
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
            onPressed: () async {
              // Actually log out of Firebase
              await AuthService.signOut();
              
              if (!context.mounted) return;
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
