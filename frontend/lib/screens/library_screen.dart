import 'package:flutter/material.dart';

import '../services/api_service.dart';
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
    return ValueListenableBuilder<List<LibraryWord>>(
      valueListenable: AppData.library,
      builder: (context, words, child) {
        final filteredWords = words.where((word) {
          return _query.isEmpty ||
              word.romanized.toLowerCase().contains(_query) ||
              word.khmer.contains(_query) ||
              word.aliases.any((alias) => alias.toLowerCase().contains(_query));
        }).toList();

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
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search words or translations',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _searchController.clear,
                          ),
                  ),
                ),
              ),
              Expanded(
                child: filteredWords.isEmpty
                    ? Center(
                        child: Text(
                          words.isEmpty
                              ? 'Loading library...'
                              : 'No words found',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: filteredWords.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final word = filteredWords[index];
                          final sourceIndex = words.indexOf(word);
                          return _WordTile(
                            word: word,
                            onEdit: () => _showWordDialog(
                              context,
                              index: sourceIndex,
                              word: word,
                            ),
                            onDelete: () =>
                                _confirmDelete(context, sourceIndex, word),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return IconButton(
      tooltip: 'Add word',
      icon: const Icon(Icons.add),
      onPressed: () => _showWordDialog(context),
    );
  }

  Future<void> _showWordDialog(
    BuildContext context, {
    int? index,
    LibraryWord? word,
  }) async {
    final romanizedController = TextEditingController(text: word?.romanized);
    final khmerController = TextEditingController(text: word?.khmer);
    final result = await showDialog<LibraryWord>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add word' : 'Edit word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: romanizedController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Romanized word'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: khmerController,
              decoration: const InputDecoration(labelText: 'Khmer translation'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final romanized = romanizedController.text.trim();
              final khmer = khmerController.text.trim();
              if (romanized.isNotEmpty && khmer.isNotEmpty) {
                Navigator.pop(
                  context,
                  LibraryWord(
                    romanized: romanized,
                    khmer: khmer,
                    aliases: word?.aliases ?? const [],
                  ),
                );
              }
            },
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
    romanizedController.dispose();
    khmerController.dispose();
    if (result == null) return;
    try {
      if (index == null) {
        await ApiService.addWord(result.romanized, result.khmer);
        AppData.addWord(result);
      } else {
        final previousWord = AppData.library.value[index];
        if (previousWord.romanized != result.romanized ||
            previousWord.khmer != result.khmer) {
          await ApiService.deleteWord(
            previousWord.romanized,
            previousWord.khmer,
          );
          await ApiService.addWord(result.romanized, result.khmer);
        }
        AppData.updateWord(index, result);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Could not sync this word with the translator'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    int index,
    LibraryWord word,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete word?'),
        content: Text('Remove ${word.romanized} from your library?'),
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
    if (confirmed != true) return;
    try {
      await ApiService.deleteWord(word.romanized, word.khmer);
      AppData.deleteWord(index);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete this word from the translator'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _WordTile extends StatelessWidget {
  final LibraryWord word;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WordTile({
    required this.word,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(
          word.romanized,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(word.khmer, style: const TextStyle(fontSize: 20)),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
