import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_nav.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _scans = [
    {
      'title': 'Tomato Late Blight',
      'date': 'OCT 24 • 09:45 AM',
      'confidence': 0.98,
      'statusIcon': Icons.error_outline,
      'statusColor': AppColors.statusDanger,
      'category': 'DISEASED',
    },
    {
      'title': 'Healthy Corn',
      'date': 'OCT 22 • 02:15 PM',
      'confidence': 0.99,
      'statusIcon': Icons.check_circle_outline,
      'statusColor': AppColors.statusSafe,
      'category': 'HEALTHY',
    },
    {
      'title': 'Powdery Mildew',
      'date': 'OCT 19 • 11:30 AM',
      'confidence': 0.85,
      'statusIcon': Icons.warning_amber_rounded,
      'statusColor': AppColors.statusWarning,
      'category': 'RISK',
    },
  ];

  List<Map<String, dynamic>> get _filteredScans {
    List<Map<String, dynamic>> filtered = _scans;

    if (_selectedFilter != 'ALL') {
      filtered = filtered.where((scan) => scan['category'] == _selectedFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((scan) =>
          scan['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'HISTORY',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        top: 16, left: 16, right: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search scans...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('ALL'),
                  const SizedBox(width: 8),
                  _buildFilterChip('HEALTHY'),
                  const SizedBox(width: 8),
                  _buildFilterChip('DISEASED'),
                  const SizedBox(width: 8),
                  _buildFilterChip('RISK'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Recent Scans',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text(
                  'OCTOBER 2023',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryGreen,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // List of Scans
            ..._filteredScans.map((scan) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildScanCard(
                context,
                title: scan['title'] as String,
                date: scan['date'] as String,
                confidence: scan['confidence'] as double,
                statusIcon: scan['statusIcon'] as IconData,
                statusColor: scan['statusColor'] as Color,
              ),
            )),
            
            const SizedBox(height: 8),
            
            // Load More Button
            Center(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                  backgroundColor: Theme.of(context).cardTheme.color,
                  side: BorderSide(color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.05)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LOAD MORE',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        letterSpacing: 2.0,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 2,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryGreen : Colors.grey.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildScanCard(BuildContext context, {
    required String title,
    required String date,
    required double confidence,
    required IconData statusIcon,
    required Color statusColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        boxShadow: statusColor == AppColors.statusDanger 
            ? [BoxShadow(color: statusColor.withOpacity(0.05), blurRadius: 20, spreadRadius: -5)]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Image Thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E4C33), Color(0xFF142416)],
                  ),
                ),
                child: const Center(child: Icon(Icons.eco, color: Colors.white30)),
              ),
              const SizedBox(width: 16),
              // Scan Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'CONFIDENCE',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primaryGreen,
                            fontSize: 8,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(confidence * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundDark : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: confidence,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/result');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : theme.primaryColor,
                    foregroundColor: isDark ? AppColors.backgroundDark : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ANALYSIS',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isDark ? AppColors.backgroundDark : Colors.white,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: Icon(Icons.share, color: isDark ? Colors.white70 : theme.primaryColor, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share functionality activated!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
