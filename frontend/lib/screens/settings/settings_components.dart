import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/keyboard_service.dart';
import '../../theme/app_theme.dart';

class AccountSection extends StatelessWidget {
  final bool isMobile;
  final double sectionLabelSize;
  final double titleSize;

  const AccountSection({
    super.key,
    required this.isMobile,
    required this.sectionLabelSize,
    required this.titleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                : null,
            child: FirebaseAuth.instance.currentUser?.photoURL == null
                ? Icon(
                    Icons.person,
                    color: AppTheme.onYellow,
                    size: isMobile ? 18 : 22,
                  )
                : null,
          ),
          title: Text(
            FirebaseAuth.instance.currentUser?.displayName ?? 'Khmerify User',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.ink,
            ),
          ),
          subtitle: Text(
            FirebaseAuth.instance.currentUser?.email ?? 'Guest Account',
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
    );
  }
}

class KeyboardSection extends StatelessWidget {
  final bool isMobile;
  final double sectionLabelSize;
  final bool isKeyboardEnabled;

  const KeyboardSection({
    super.key,
    required this.isMobile,
    required this.sectionLabelSize,
    required this.isKeyboardEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'KHMERIFY KEYBOARD',
              style: TextStyle(
                fontSize: sectionLabelSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.muted,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isKeyboardEnabled
                    ? AppTheme.green.withValues(alpha: 0.2)
                    : AppTheme.muted.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isKeyboardEnabled
                          ? AppTheme.green
                          : AppTheme.muted,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isKeyboardEnabled ? 'Active' : 'Disabled',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isKeyboardEnabled
                          ? AppTheme.green
                          : AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 8 : 10),
        Text(
          'Type phonetically in any app (Telegram, Messenger, Chrome) and pick Khmer word suggestions from the candidate strip.',
          style: TextStyle(
            fontSize: isMobile ? 12.0 : 13.0,
            color: AppTheme.muted,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.ink,
                  side: BorderSide(color: AppTheme.ink, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await KeyboardService.openKeyboardSettings();
                },
                icon: const Icon(Icons.settings, size: 18),
                label: Text(
                  'Manage Keyboards',
                  style: TextStyle(
                    fontSize: isMobile ? 11.0 : 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yellow,
                  foregroundColor: AppTheme.onYellow,
                  side: BorderSide(color: AppTheme.ink, width: 1.5),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await KeyboardService.showKeyboardPicker();
                },
                icon: const Icon(Icons.keyboard, size: 18),
                label: Text(
                  'Switch Keyboard',
                  style: TextStyle(
                    fontSize: isMobile ? 11.0 : 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SupportSection extends StatelessWidget {
  final bool isMobile;
  final double sectionLabelSize;
  final double titleSize;

  const SupportSection({
    super.key,
    required this.isMobile,
    required this.sectionLabelSize,
    required this.titleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
class PreferencesSection extends StatelessWidget {
  final bool isMobile;
  final double sectionLabelSize;
  final double titleSize;
  final bool autoSaveHistory;
  final ValueChanged<bool> onAutoSaveChanged;
  final String appLanguage;
  final VoidCallback onLanguageTap;

  const PreferencesSection({
    super.key,
    required this.isMobile,
    required this.sectionLabelSize,
    required this.titleSize,
    required this.autoSaveHistory,
    required this.onAutoSaveChanged,
    required this.appLanguage,
    required this.onLanguageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            value: autoSaveHistory,
            onChanged: onAutoSaveChanged,
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
                appLanguage,
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
          onTap: onLanguageTap,
        ),
      ],
    );
  }
}
