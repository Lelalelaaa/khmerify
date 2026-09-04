import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final bool showAppBar;

  const HistoryScreen({super.key, this.showAppBar = true});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Sample history data
  final List<HistoryItem> _history = [
    HistoryItem(
      romanizedText: 'Sop-dey',
      khmerText: 'សូស្វាគមន៍',
      timestamp: 'Today',
    ),
    HistoryItem(romanizedText: 'Khmer', khmerText: 'ខ្មែរ', timestamp: 'Today'),
    HistoryItem(
      romanizedText: 'Sop-dey',
      khmerText: 'សូស្វាគមន៍',
      timestamp: 'Yesterday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    // Responsive sizes
    final appBarTitleSize = isMobile
        ? 18.0
        : (screenSize.width >= 1200 ? 24.0 : 20.0);
    final dateHeaderSize = isMobile
        ? 10.0
        : (screenSize.width >= 1200 ? 12.0 : 11.0);
    final labelSize = isMobile ? 9.0 : (screenSize.width >= 1200 ? 11.0 : 10.0);
    final khmerTextSize = isMobile
        ? 16.0
        : (screenSize.width >= 1200 ? 20.0 : 18.0);
    final romanizedTextSize = isMobile
        ? 12.0
        : (screenSize.width >= 1200 ? 14.0 : 13.0);
    final horizontalPadding = isMobile
        ? 12.0
        : (screenSize.width >= 1200 ? 24.0 : 16.0);

    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.darkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          backgroundColor: AppTheme.paper,
          appBar: widget.showAppBar
              ? AppBar(
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
                )
              : null,
          body: _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: isMobile ? 56 : 64,
                        color: AppTheme.muted.withValues(alpha: 0.35),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'No translations yet',
                        style: TextStyle(
                          fontSize: isMobile
                              ? 14.0
                              : (screenSize.width >= 1200 ? 18.0 : 16.0),
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _history.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isMobile ? 8 : 12,
                  ),
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Column(
                      children: [
                        if (index == 0 ||
                            _history[index - 1].timestamp != item.timestamp)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 8 : 12,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item.timestamp,
                                style: TextStyle(
                                  fontSize: dateHeaderSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.muted,
                                ),
                              ),
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.ink, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.ink.withValues(
                                  alpha: isDark ? 0.35 : 0.85,
                                ),
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 12 : 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ROMANIZED KHMER',
                                            style: TextStyle(
                                              fontSize: labelSize,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.muted,
                                            ),
                                          ),
                                          SizedBox(height: isMobile ? 3 : 4),
                                          Text(
                                            item.romanizedText,
                                            style: TextStyle(
                                              fontSize: romanizedTextSize,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.content_copy,
                                        size: isMobile ? 18 : 20,
                                        color: AppTheme.ink,
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Copied to clipboard',
                                                ),
                                              ),
                                            );
                                      },
                                    ),
                                  ],
                                ),
                                Divider(height: isMobile ? 16 : 20),
                                Text(
                                  'KHMER SCRIPT',
                                  style: TextStyle(
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.muted,
                                  ),
                                ),
                                SizedBox(height: isMobile ? 3 : 4),
                                Text(
                                  item.khmerText,
                                  style: TextStyle(
                                    fontSize: khmerTextSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 10 : 14),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}

class HistoryItem {
  final String romanizedText;
  final String khmerText;
  final String timestamp;

  HistoryItem({
    required this.romanizedText,
    required this.khmerText,
    required this.timestamp,
  });
}
