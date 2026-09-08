import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _controller = TextEditingController();
  String _output = "";
  bool _loading = false;
  int _selectedTab = 0;

  /// Fuzzy suggestions from the backend for the last typed input.
  List<String> _suggestions = [];

  Future<void> _handleTranslate() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to translate')),
      );
      return;
    }

    final input = _controller.text.trim();

    setState(() {
      _loading = true;
      _suggestions = [];
    });

    try {
      final converted = await ApiService.convert(input);
      setState(() {
        _output = converted;
      });

      // Fetch fuzzy suggestions in background (single-word only)
      final words = input.toLowerCase().split(' ');
      if (words.length == 1) {
        final suggestions = await ApiService.getSuggestions(words[0]);
        if (mounted) {
          setState(() {
            _suggestions = suggestions
                .where((s) => s != words[0])
                .toList();
          });
        }
      }
    } catch (e) {
      setState(() {
        _output = "Error: could not reach the server";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: could not reach the server')),
        );
      }
    } finally {
      setState(() {
        _loading = false;
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
        final appBarTitleSize = isMobile
            ? 18.0
            : (screenSize.width >= 1200 ? 24.0 : 20.0);

        return Scaffold(
          backgroundColor: AppTheme.paper,
          appBar: AppBar(
            backgroundColor: AppTheme.paper,
            elevation: 0,
            title: Text(
              'Khmerify',
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
          ),
          body: _selectedTab == 0 ? _buildTranslateTab() : _buildOtherTabs(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.translate),
                label: 'Translate',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTranslateTab() {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1200;

    // Responsive sizes
    final labelFontSize = isMobile ? 11.0 : (isTablet ? 12.0 : 13.0);
    final outputFontSize = isMobile ? 20.0 : (isTablet ? 24.0 : 28.0);
    final buttonHeight = isMobile ? 48.0 : (isTablet ? 52.0 : 56.0);
    final horizontalPadding = isMobile ? 14.0 : (isTablet ? 20.0 : 28.0);
    final verticalSpacing = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: verticalSpacing),
            Text(
              'ROMANIZED KHMER',
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.muted,
              ),
            ),
            SizedBox(height: verticalSpacing * 0.6),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type romanized khmer here (e.g., suosdey)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isMobile ? 10 : 12,
                ),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            SizedBox(height: verticalSpacing),
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
                onPressed: _loading ? null : _handleTranslate,
                child: Text(
                  _loading ? 'Translating...' : 'Translate',
                  style: TextStyle(
                    fontSize: isMobile ? 14.0 : (isTablet ? 16.0 : 18.0),
                    fontWeight: FontWeight.w900,
                    color: AppTheme.onYellow,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: verticalSpacing * 1.5),
            if (_output.isNotEmpty) ...[
              Text(
                'KHMER SCRIPT',
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                ),
              ),
              SizedBox(height: verticalSpacing * 0.6),
              // ── Output card ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(horizontalPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: AppTheme.ink, width: 2),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ink.withValues(
                        alpha: AppTheme.darkMode.value ? 0.35 : 0.85,
                      ),
                      offset: const Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _output,
                      style: TextStyle(
                        fontSize: outputFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.content_copy, color: AppTheme.ink),
                            iconSize: isMobile ? 20 : 24,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.share, color: AppTheme.ink),
                            iconSize: isMobile ? 20 : 24,
                            onPressed: () {
                              // TODO: Implement share functionality
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.favorite_border,
                              color: AppTheme.ink,
                            ),
                            iconSize: isMobile ? 20 : 24,
                            onPressed: () {
                              // TODO: Implement save/favorite
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ── "Did you mean?" banner (shown only when suggestions exist) ─
              if (_suggestions.isNotEmpty) ...[
                SizedBox(height: verticalSpacing),
                _didYouMeanBanner(
                  isMobile: isMobile,
                  isTablet: isTablet,
                  horizontalPadding: horizontalPadding,
                  verticalSpacing: verticalSpacing,
                ),
              ],
            ] else if (!_loading)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: verticalSpacing * 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.translate,
                        size: isMobile ? 56 : 64,
                        color: AppTheme.muted.withValues(alpha: 0.35),
                      ),
                      SizedBox(height: verticalSpacing),
                      Text(
                        'Translation will appear here',
                        style: TextStyle(
                          fontSize: isMobile ? 14.0 : (isTablet ? 15.0 : 16.0),
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _didYouMeanBanner({
    required bool isMobile,
    required bool isTablet,
    required double horizontalPadding,
    required double verticalSpacing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: AppTheme.yellow.withValues(
          alpha: AppTheme.darkMode.value ? 0.18 : 0.15,
        ),
        border: Border.all(color: AppTheme.ink, width: 2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(
              alpha: AppTheme.darkMode.value ? 0.35 : 0.85,
            ),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppTheme.ink,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: verticalSpacing * 0.5),
              Expanded(
                child: Text(
                  'Did you mean to type:',
                  style: TextStyle(
                    fontSize: isMobile ? 12.0 : (isTablet ? 13.0 : 14.0),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: verticalSpacing * 0.8),
          ..._suggestions.map((suggestion) {
            return Padding(
              padding: EdgeInsets.only(bottom: verticalSpacing * 0.5),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.ink,
                        side: BorderSide(color: AppTheme.ink, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 8 : 10,
                          horizontal: 12,
                        ),
                      ),
                      onPressed: () async {
                        _controller.text = suggestion;
                        setState(() => _suggestions = []);
                        await _handleTranslate();
                      },
                      child: Text(
                        '"$suggestion"',
                        style: TextStyle(
                          fontSize: isMobile ? 12.0 : 13.0,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: verticalSpacing * 0.5),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.muted,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 10,
                        horizontal: 8,
                      ),
                    ),
                    onPressed: () async {
                      await ApiService.rejectSuggestion(suggestion);
                      setState(() {
                        _suggestions.remove(suggestion);
                      });
                    },
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: isMobile ? 11.0 : 12.0,
                        color: AppTheme.muted,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOtherTabs() {
    if (_selectedTab == 1) {
      return const HistoryScreen(showAppBar: false);
    } else if (_selectedTab == 2) {
      return const SettingsScreen(showAppBar: false);
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
