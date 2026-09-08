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
  List<WordResult> _results = [];
  bool _loading = false;
  int _selectedTab = 0;

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
      _results = [];
    });

    try {
      final results = await ApiService.convert(input);
      if (mounted) {
        setState(() {
          _results = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: could not reach the server')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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
            if (_results.isNotEmpty) ...[
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _results
                          .map(
                            (result) => _buildWordSegment(
                              result,
                              outputFontSize: outputFontSize,
                            ),
                          )
                          .toList(),
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

  Widget _buildWordSegment(
    WordResult result, {
    required double outputFontSize,
  }) {
    final label = result.found && result.candidates.isNotEmpty
        ? result.candidates.first.khmer
        : result.suggestion == null
        ? result.patternFallback ?? result.input
        : result.input;
    final canChooseAlternate = result.found && result.candidates.length > 1;

    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: outputFontSize,
          fontWeight: FontWeight.w700,
          color: AppTheme.ink,
        ),
      ),
      onPressed: () => _handleWordResult(result),
      avatar: canChooseAlternate
          ? Icon(Icons.more_horiz, color: AppTheme.ink)
          : null,
      backgroundColor: result.found
          ? Theme.of(context).cardColor
          : AppTheme.yellow.withValues(alpha: 0.2),
      side: BorderSide(color: AppTheme.ink, width: 1.5),
    );
  }

  Future<void> _handleWordResult(WordResult result) async {
    if (result.found && result.candidates.length > 1) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Alternate translations for ${result.input}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: result.candidates
                .map(
                  (candidate) => ListTile(
                    title: Text(candidate.khmer),
                    subtitle: candidate.gloss?.isEmpty ?? true
                        ? null
                        : Text(candidate.gloss!),
                  ),
                )
                .toList(),
          ),
        ),
      );
      return;
    }

    final suggestion = result.suggestion;
    if (suggestion != null && suggestion.options.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Did you mean?'),
          content: Text(
            "Did you mean '${suggestion.romanized}' "
            '-> ${suggestion.options.first.khmer}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No, it's different"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      try {
        if (confirmed == true) {
          await ApiService.confirmAlias(
            result.input,
            suggestion.options.first.khmer,
          );
        } else if (confirmed == false) {
          await ApiService.rejectSuggestion(result.input, suggestion.romanized);
        } else {
          return;
        }
        await _handleTranslate();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not update this word')),
          );
        }
      }
      return;
    }

    final khmerController = TextEditingController();
    final khmer = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add "${result.input}"'),
        content: TextField(
          controller: khmerController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Correct Khmer script'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, khmerController.text.trim()),
            child: const Text('Add word'),
          ),
        ],
      ),
    );
    khmerController.dispose();

    if (khmer == null || khmer.isEmpty) {
      return;
    }
    try {
      await ApiService.addWord(result.input, khmer);
      await _handleTranslate();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add this word')),
        );
      }
    }
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
