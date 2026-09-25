import 'package:flutter/material.dart';

import '../services/app_data.dart';
import '../theme/app_theme.dart';

class LibraryScreen extends StatefulWidget {
  final bool showAppBar;

  const LibraryScreen({super.key, this.showAppBar = true});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.darkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          backgroundColor: AppTheme.paper,
          appBar: widget.showAppBar
              ? AppBar(
                  title: const Text('Library'),
                  actions: [_buildAddButton(context)],
                )
              : null,
          floatingActionButton: widget.showAppBar
              ? null
              : _buildAddButton(context),
          body: _buildLibraryContent(context),
        );
      },
    );
  }

  Widget _buildLibraryContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: AppTheme.ink),
            decoration: InputDecoration(
              hintText: 'Search words or translations',
              prefixIcon: Icon(Icons.search, color: AppTheme.muted),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.clear, color: AppTheme.ink),
                      onPressed: _searchController.clear,
                    ),
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<List<LibraryWord>>(
            valueListenable: AppData.library,
            builder: (context, words, child) {
              final filteredWords = words.where((word) {
                if (_query.isEmpty) return true;
                return word.romanized.toLowerCase().contains(_query) ||
                    word.khmer.contains(_query) ||
                    word.aliases.any(
                      (alias) => alias.toLowerCase().contains(_query),
                    );
              }).toList();

              if (filteredWords.isEmpty) {
                return Center(
                  child: Text(
                    _query.isEmpty
                        ? 'Your library is empty'
                        : 'No words found matching "$_query"',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                itemCount: filteredWords.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final word = filteredWords[index];
                  final wordIndex = AppData.library.value.indexOf(word);
                  return _WordTile(
                    romanized: word.romanized,
                    khmer: word.khmer,
                    onEdit: () => _showWordDialog(
                      context,
                      wordIndex: wordIndex,
                      initialRomanized: word.romanized,
                      initialKhmer: word.khmer,
                    ),
                    onDelete: () => _confirmDelete(context, wordIndex, word),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return IconButton(
      tooltip: 'Add word',
      icon: Icon(Icons.add, color: AppTheme.ink),
      onPressed: () => _showWordDialog(context),
    );
  }

  Future<void> _showWordDialog(
    BuildContext context, {
    int? wordIndex,
    String? initialRomanized,
    String? initialKhmer,
  }) async {
    final romanizedController = TextEditingController(text: initialRomanized);
    final khmerController = TextEditingController(text: initialKhmer);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          wordIndex == null ? 'Add word' : 'Edit word',
          style: TextStyle(color: AppTheme.ink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: romanizedController,
              autofocus: true,
              style: TextStyle(color: AppTheme.ink),
              decoration: const InputDecoration(labelText: 'Romanized word'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: khmerController,
              style: TextStyle(color: AppTheme.ink),
              decoration: const InputDecoration(labelText: 'Khmer translation'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.ink)),
          ),
          FilledButton(
            onPressed: () {
              final romanized = romanizedController.text.trim();
              final khmer = khmerController.text.trim();
              if (romanized.isNotEmpty && khmer.isNotEmpty) {
                Navigator.pop(context, {
                  'romanized': romanized,
                  'khmer': khmer,
                });
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.yellow,
              foregroundColor: AppTheme.onYellow,
            ),
            child: Text(wordIndex == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    if (result == null) return;

    final word = LibraryWord(
      romanized: result['romanized']!,
      khmer: result['khmer']!,
    );
    if (wordIndex == null) {
      await AppData.addWord(word);
    } else {
      await AppData.updateWord(wordIndex, word);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    int wordIndex,
    LibraryWord word,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Delete word?', style: TextStyle(color: AppTheme.ink)),
        content: Text(
          'Remove ${word.romanized} from your library?',
          style: TextStyle(color: AppTheme.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.ink)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AppData.deleteWord(wordIndex);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _WordTile extends StatelessWidget {
  final String romanized;
  final String khmer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WordTile({
    required this.romanized,
    required this.khmer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(
          romanized,
          style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink),
        ),
        subtitle: Text(
          khmer,
          style: TextStyle(fontSize: 20, color: AppTheme.muted),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppTheme.ink),
          color: Theme.of(context).cardColor,
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit', style: TextStyle(color: AppTheme.ink)),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: AppTheme.ink)),
            ),
          ],
        ),
      ),
    );
  }
}
