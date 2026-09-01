import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

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

  Future<void> _handleTranslate() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter text to translate'),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final result = await ApiService.convert(_controller.text);
      setState(() {
        _output = result;
      });
    } catch (e) {
      setState(() {
        _output = "Error: could not reach the server";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: could not reach the server'),
          ),
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
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final appBarTitleSize = isMobile ? 18.0 : (screenSize.width >= 1200 ? 24.0 : 20.0);
    
    return Scaffold(
      appBar: AppBar(
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
                color: Colors.grey,
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
                  backgroundColor: const Color(0xFF003DA5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _loading ? null : _handleTranslate,
                child: Text(
                  _loading ? 'Translating...' : 'Translate',
                  style: TextStyle(
                    fontSize: isMobile ? 14.0 : (isTablet ? 16.0 : 18.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: verticalSpacing * 0.6),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(horizontalPadding),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _output,
                      style: TextStyle(
                        fontSize: outputFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.content_copy),
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
                            icon: const Icon(Icons.share),
                            iconSize: isMobile ? 20 : 24,
                            onPressed: () {
                              // TODO: Implement share functionality
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
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
              SizedBox(height: verticalSpacing),
              // Ambiguity Resolution
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(horizontalPadding),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: isMobile ? 18 : 20,
                        ),
                        SizedBox(width: verticalSpacing * 0.5),
                        Expanded(
                          child: Text(
                            'Ambiguity found for "bar"',
                            style: TextStyle(
                              fontSize: isMobile ? 12.0 : (isTablet ? 13.0 : 14.0),
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing),
                    Text(
                      'Do you mean:',
                      style: TextStyle(
                        fontSize: isMobile ? 11.0 : (isTablet ? 12.0 : 13.0),
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 0.6),
                    Row(
                      children: [
                        Expanded(
                          child: _ambiguityButton('បារ (bar - hair)', 0),
                        ),
                        SizedBox(width: verticalSpacing * 0.5),
                        Expanded(
                          child: _ambiguityButton('បាទ (bar - yes)', 1),
                        ),
                      ],
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
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: verticalSpacing),
                      Text(
                        'Translation will appear here',
                        style: TextStyle(
                          fontSize: isMobile ? 14.0 : (isTablet ? 15.0 : 16.0),
                          color: Colors.grey[600],
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

  Widget _ambiguityButton(String text, int index) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.orange[300]!),
        padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        // TODO: Handle ambiguity resolution
      },
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isMobile ? 11.0 : (screenSize.width >= 1200 ? 13.0 : 12.0),
          color: Colors.orange[700],
          fontWeight: FontWeight.w500,
        ),
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