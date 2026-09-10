import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/api_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class LibraryScreen extends StatefulWidget {
  final bool showAppBar;

  const LibraryScreen({super.key, this.showAppBar = true});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;

        return ValueListenableBuilder<bool>(
          valueListenable: AppTheme.darkMode,
          builder: (context, isDark, child) {
            return Scaffold(
              backgroundColor: AppTheme.paper,
              appBar: widget.showAppBar
                  ? AppBar(
                      title: const Text('Library'),
                      actions: [
                        if (user != null) _buildAddButton(context),
                      ],
                    )
                  : null,
              floatingActionButton: widget.showAppBar || user == null
                  ? null
                  : _buildAddButton(context),
              body: user == null
                  ? _buildLoginPrompt(context)
                  : _buildLibraryContent(context),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: isMobile ? 56 : 64,
            color: AppTheme.muted.withValues(alpha: 0.5),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Sign in to build your personal library',
            style: TextStyle(
              fontSize: isMobile ? 14.0 : 16.0,
              color: AppTheme.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
          child: StreamBuilder<QuerySnapshot>(
            stream: _databaseService.getLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 56,
                        color: AppTheme.muted.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your library is empty',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add words to build your custom dictionary',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: AppTheme.muted.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Filter docs manually in memory (since Firestore text search is limited)
              final filteredDocs = docs.where((doc) {
                if (_query.isEmpty) return true;
                final data = doc.data() as Map<String, dynamic>;
                final romanized = (data['romanized'] as String?)?.toLowerCase() ?? '';
                final khmer = (data['khmer'] as String?) ?? '';
                final aliases = List<String>.from(data['aliases'] ?? []);
                
                return romanized.contains(_query) ||
                    khmer.contains(_query) ||
                    aliases.any((a) => a.toLowerCase().contains(_query));
              }).toList();

              if (filteredDocs.isEmpty) {
                return Center(
                  child: Text(
                    'No words found matching "$_query"',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                itemCount: filteredDocs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final docId = doc.id;
                  
                  final romanized = data['romanized'] as String? ?? '';
                  final khmer = data['khmer'] as String? ?? '';
                  
                  return _WordTile(
                    romanized: romanized,
                    khmer: khmer,
                    onEdit: () => _showWordDialog(
                      context,
                      docId: docId,
                      initialRomanized: romanized,
                      initialKhmer: khmer,
                    ),
                    onDelete: () => _confirmDelete(
                      context,
                      docId,
                      romanized,
                      khmer,
                    ),
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
    String? docId,
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
          docId == null ? 'Add word' : 'Edit word',
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
                Navigator.pop(
                  context,
                  {'romanized': romanized, 'khmer': khmer},
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.yellow,
              foregroundColor: AppTheme.onYellow,
            ),
            child: Text(docId == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
    
    if (result == null) return;
    
    try {
      if (docId == null) {
        // Add new
        await ApiService.addWord(result['romanized']!, result['khmer']!);
        await _databaseService.addLibraryWord(result['romanized']!, result['khmer']!, []);
      } else {
        // Edit existing
        if (initialRomanized != result['romanized'] || initialKhmer != result['khmer']) {
          await ApiService.deleteWord(initialRomanized!, initialKhmer!);
          await ApiService.addWord(result['romanized']!, result['khmer']!);
        }
        await _databaseService.updateLibraryWord(docId, result['romanized']!, result['khmer']!);
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
    String docId,
    String romanized,
    String khmer,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Delete word?', style: TextStyle(color: AppTheme.ink)),
        content: Text(
          'Remove $romanized from your library?',
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
    
    try {
      await ApiService.deleteWord(romanized, khmer);
      await _databaseService.deleteLibraryWord(docId);
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
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
        subtitle: Text(
          khmer,
          style: TextStyle(
            fontSize: 20,
            color: AppTheme.muted,
          ),
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
