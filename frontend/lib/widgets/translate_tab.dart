import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

class TranslateTab extends StatelessWidget {
  final TextEditingController controller;
  final List<WordResult> results;
  final Set<int> deletedResultIndexes;
  final bool loading;
  final String translatedSentence;
  final Future<void> Function() onTranslate;
  final Future<void> Function(WordResult) onWordSelected;
  final ValueChanged<int> onWordRemoved;
  final VoidCallback onCopy;
  final String Function(WordResult, int) wordLabel;

  const TranslateTab({
    super.key,
    required this.controller,
    required this.results,
    required this.deletedResultIndexes,
    required this.loading,
    required this.translatedSentence,
    required this.onTranslate,
    required this.onWordSelected,
    required this.onWordRemoved,
    required this.onCopy,
    required this.wordLabel,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1200;
    final labelSize = isMobile ? 11.0 : (isTablet ? 12.0 : 13.0);
    final outputSize = isMobile ? 20.0 : (isTablet ? 24.0 : 28.0);
    final buttonHeight = isMobile ? 48.0 : (isTablet ? 52.0 : 56.0);
    final padding = isMobile ? 14.0 : (isTablet ? 20.0 : 28.0);
    final spacing = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    final isDark = AppTheme.darkMode.value;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: spacing),
            _SectionLabel('ROMANIZED KHMER', fontSize: labelSize),
            SizedBox(height: spacing * 0.6),
            TextField(
              controller: controller,
              style: TextStyle(color: AppTheme.ink),
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
            SizedBox(height: spacing),
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
                onPressed: loading ? null : onTranslate,
                child: Text(
                  loading ? 'Translating...' : 'Translate',
                  style: TextStyle(
                    fontSize: isMobile ? 14.0 : (isTablet ? 16.0 : 18.0),
                    fontWeight: FontWeight.w900,
                    color: AppTheme.onYellow,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing * 1.5),
            if (results.isNotEmpty) ...[
              _SectionLabel('KHMER SCRIPT', fontSize: labelSize),
              SizedBox(height: spacing * 0.6),
              _TranslationOutput(
                results: results,
                deletedResultIndexes: deletedResultIndexes,
                sentence: translatedSentence,
                outputFontSize: outputSize,
                padding: padding,
                spacing: spacing,
                isMobile: isMobile,
                isDark: isDark,
                wordLabel: wordLabel,
                onWordSelected: onWordSelected,
                onWordRemoved: onWordRemoved,
                onCopy: onCopy,
              ),
            ] else if (!loading)
              _EmptyTranslationState(
                isMobile: isMobile,
                isTablet: isTablet,
                spacing: spacing,
              ),
          ],
        ),
      ),
    );
  }
}

class _TranslationOutput extends StatelessWidget {
  final List<WordResult> results;
  final Set<int> deletedResultIndexes;
  final String sentence;
  final double outputFontSize;
  final double padding;
  final double spacing;
  final bool isMobile;
  final bool isDark;
  final String Function(WordResult, int) wordLabel;
  final Future<void> Function(WordResult) onWordSelected;
  final ValueChanged<int> onWordRemoved;
  final VoidCallback onCopy;

  const _TranslationOutput({
    required this.results,
    required this.deletedResultIndexes,
    required this.sentence,
    required this.outputFontSize,
    required this.padding,
    required this.spacing,
    required this.isMobile,
    required this.isDark,
    required this.wordLabel,
    required this.onWordSelected,
    required this.onWordRemoved,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF292725) : Colors.white,
        border: Border.all(color: AppTheme.ink, width: 2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(alpha: isDark ? 0.35 : 0.85),
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
            children: results
                .asMap()
                .entries
                .where((entry) => !deletedResultIndexes.contains(entry.key))
                .map(
                  (entry) => _WordSegment(
                    result: entry.value,
                    index: entry.key,
                    label: wordLabel(entry.value, entry.key),
                    fontSize: outputFontSize,
                    isDark: isDark,
                    onSelected: onWordSelected,
                    onRemoved: onWordRemoved,
                  ),
                )
                .toList(),
          ),
          SizedBox(height: spacing),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppTheme.yellow.withValues(alpha: isDark ? 0.14 : 0.1),
              border: Border.all(color: AppTheme.ink, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              sentence,
              style: TextStyle(
                fontSize: outputFontSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: spacing),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.content_copy, color: AppTheme.ink),
                  iconSize: isMobile ? 20 : 24,
                  onPressed: onCopy,
                ),
                IconButton(
                  icon: Icon(Icons.share, color: AppTheme.ink),
                  iconSize: isMobile ? 20 : 24,
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.favorite_border, color: AppTheme.ink),
                  iconSize: isMobile ? 20 : 24,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WordSegment extends StatelessWidget {
  final WordResult result;
  final int index;
  final String label;
  final double fontSize;
  final bool isDark;
  final Future<void> Function(WordResult) onSelected;
  final ValueChanged<int> onRemoved;

  const _WordSegment({
    required this.result,
    required this.index,
    required this.label,
    required this.fontSize,
    required this.isDark,
    required this.onSelected,
    required this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final hasAlternates = result.found && result.candidates.length > 1;
    return InputChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppTheme.ink,
        ),
      ),
      onPressed: () => onSelected(result),
      onDeleted: () => onRemoved(index),
      deleteIcon: Icon(Icons.close, color: AppTheme.ink),
      avatar: hasAlternates
          ? Icon(Icons.more_horiz, color: AppTheme.ink)
          : null,
      backgroundColor: result.found
          ? (isDark ? const Color(0xFF191817) : Colors.white)
          : AppTheme.yellow.withValues(alpha: 0.2),
      side: BorderSide(color: AppTheme.ink, width: 1.5),
    );
  }
}

class _EmptyTranslationState extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final double spacing;

  const _EmptyTranslationState({
    required this.isMobile,
    required this.isTablet,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing * 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.translate,
              size: isMobile ? 56 : 64,
              color: AppTheme.muted.withValues(alpha: 0.35),
            ),
            SizedBox(height: spacing),
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final double fontSize;

  const _SectionLabel(this.text, {required this.fontSize});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: AppTheme.muted,
    ),
  );
}
