import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/api_service.dart';
import '../services/keyboard_service.dart';
import '../services/app_data.dart';
import '../services/database_service.dart';
import '../widgets/translate_tab.dart';
import 'library_screen.dart';
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
  final Set<int> _deletedResultIndexes = {};
  final Map<String, int> _selectedCandidateIndexes = {};
  bool _loading = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    AppData.syncCloudLibrary();
  }

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
      _deletedResultIndexes.clear();
    });

    try {
      final results = await ApiService.convert(input);
      if (mounted) {
        setState(() {
          _results = results;
        });
        if (results.isNotEmpty) {
          AppData.addHistory(
            romanized: input,
            khmer: results.map(_sentenceWord).join(' '),
          );
        }

        final db = DatabaseService();
        final fullKhmerText = results.map((r) => _sentenceWord(r)).join(' ');
        if (fullKhmerText.trim().isNotEmpty) {
          await db.saveTranslation(input, fullKhmerText);
        }
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
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  return Padding(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the Settings tab (index 3)
                          setState(() => _selectedTab = 3);
                        },
                        child: CircleAvatar(
                          backgroundColor: AppTheme.yellow,
                          radius: isMobile ? 18 : 20,
                          child: user?.photoURL != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.photoURL!,
                                    width: isMobile ? 36 : 40,
                                    height: isMobile ? 36 : 40,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.person, color: AppTheme.onYellow),
                        ),
                      ),
                    ),
                  );
                },
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
                icon: Icon(Icons.menu_book),
                label: 'Library',
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

  Widget _buildTranslateTab() => TranslateTab(
    controller: _controller,
    results: _results,
    deletedResultIndexes: _deletedResultIndexes,
    loading: _loading,
    translatedSentence: _translatedSentence,
    onTranslate: _handleTranslate,
    onWordSelected: _handleWordResult,
    onWordRemoved: _removeTranslatedWord,
    onCopy: _copyTranslatedSentence,
    wordLabel: (result, index) => _sentenceWord(result, index: index),
  );

  Future<void> _copyTranslatedSentence() async {
    await Clipboard.setData(ClipboardData(text: _translatedSentence));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  String _sentenceWord(WordResult result, {int? index}) {
    if (result.found && result.candidates.isNotEmpty) {
      final selectedIndex = _selectedCandidateIndexes[result.input] ?? 0;
      return result
          .candidates[selectedIndex.clamp(0, result.candidates.length - 1)]
          .khmer;
    }
    if (result.suggestion?.options.isNotEmpty ?? false) {
      return result.suggestion!.options.first.khmer;
    }
    return result.patternFallback ?? result.input;
  }

  List<String> get _sentenceWords => _results
      .asMap()
      .entries
      .where((entry) => !_deletedResultIndexes.contains(entry.key))
      .map((entry) => _sentenceWord(entry.value))
      .toList();

  String get _translatedSentence => _sentenceWords.join('');

  void _removeTranslatedWord(int index) {
    setState(() {
      _deletedResultIndexes.add(index);
    });
  }

  Future<void> _handleWordResult(WordResult result) async {
    if (result.found && result.candidates.length > 1) {
      final selectedIndex = _selectedCandidateIndexes[result.input] ?? 0;
      final chosenIndex = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Alternate translations for ${result.input}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: result.candidates.asMap().entries.map((entry) {
              final index = entry.key;
              final candidate = entry.value;
              return ListTile(
                onTap: () => Navigator.pop(context, index),
                leading: Icon(
                  index == selectedIndex
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppTheme.ink,
                ),
                title: Text(candidate.khmer),
                subtitle: candidate.gloss?.isEmpty ?? true
                    ? null
                    : Text(candidate.gloss!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete this dictionary translation',
                  onPressed: () => _confirmDeleteDictionaryWord(
                    result.input,
                    candidate.khmer,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
      if (chosenIndex != null && mounted) {
        setState(() {
          _selectedCandidateIndexes[result.input] = chosenIndex;
        });
      }
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
          decoration: InputDecoration(
            hintText: 'Correct Khmer script',
            suffixIcon: IconButton(
              icon: const Icon(Icons.language),
              tooltip: 'Switch Keyboard',
              onPressed: () {
                // Allows user to easily switch back to default Khmer keyboard
                KeyboardService.showKeyboardPicker();
              },
            ),
          ),
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

  Future<void> _confirmDeleteDictionaryWord(
    String romanized,
    String khmer,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete dictionary translation?'),
        content: Text("Remove '$romanized' -> $khmer from the dictionary?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    try {
      await ApiService.deleteWord(romanized, khmer);
      if (!mounted) return;
      Navigator.pop(context);
      await _handleTranslate();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete dictionary word')),
        );
      }
    }
  }

  Widget _buildOtherTabs() {
    if (_selectedTab == 1) {
      return const HistoryScreen(showAppBar: false);
    } else if (_selectedTab == 2) {
      return const LibraryScreen(showAppBar: false);
    } else if (_selectedTab == 3) {
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
