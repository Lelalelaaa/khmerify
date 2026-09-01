import 'package:flutter/material.dart';

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
    HistoryItem(
      romanizedText: 'Khmer',
      khmerText: 'ខ្មែរ',
      timestamp: 'Today',
    ),
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
    final appBarTitleSize = isMobile ? 18.0 : (screenSize.width >= 1200 ? 24.0 : 20.0);
    final dateHeaderSize = isMobile ? 10.0 : (screenSize.width >= 1200 ? 12.0 : 11.0);
    final labelSize = isMobile ? 9.0 : (screenSize.width >= 1200 ? 11.0 : 10.0);
    final khmerTextSize = isMobile ? 16.0 : (screenSize.width >= 1200 ? 20.0 : 18.0);
    final romanizedTextSize = isMobile ? 12.0 : (screenSize.width >= 1200 ? 14.0 : 13.0);
    final horizontalPadding = isMobile ? 12.0 : (screenSize.width >= 1200 ? 24.0 : 16.0);
    
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: const Color(0xFF003DA5),
        elevation: 0,
        title: Text(
          'Khmerify',
          style: TextStyle(
            fontSize: appBarTitleSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: isMobile ? 18 : 20,
                child: const Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ) : null,
      body: _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: isMobile ? 56 : 64,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Text(
                    'No translations yet',
                    style: TextStyle(
                      fontSize: isMobile ? 14.0 : (screenSize.width >= 1200 ? 18.0 : 16.0),
                      color: Colors.grey[600],
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
                    if (index == 0 || _history[index - 1].timestamp != item.timestamp)
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
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Colors.grey[200]!,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 10 : 12),
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
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: isMobile ? 3 : 4),
                                      Text(
                                        item.romanizedText,
                                        style: TextStyle(
                                          fontSize: romanizedTextSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.content_copy,
                                    size: isMobile ? 16 : 18,
                                    color: Colors.grey,
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
                            Divider(
                              height: isMobile ? 12 : 16,
                            ),
                            Text(
                              'KHMER SCRIPT',
                              style: TextStyle(
                                fontSize: labelSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: isMobile ? 3 : 4),
                            Text(
                              item.khmerText,
                              style: TextStyle(
                                fontSize: khmerTextSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                  ],
                );
              },
            )
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
