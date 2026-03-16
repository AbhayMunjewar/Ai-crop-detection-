import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
              ),
              child: const Icon(Icons.eco, color: AppColors.primaryGreen, size: 20),
            ),
          ),
        ),
        title: Text(
          'CROPGUARD AI',
          style: theme.textTheme.labelLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.notifications_none, color: isDark ? Colors.white : Colors.black87, size: 20),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NOTIFICATIONS',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: isDark ? Colors.white : Colors.black87,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.statusWarning.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.warning_amber_rounded, color: AppColors.statusWarning),
                              ),
                              title: const Text('Weather Alert'),
                              subtitle: const Text('Heavy rain expected tomorrow in your region.'),
                            ),
                            const Divider(),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen),
                              ),
                              title: const Text('Scan Complete'),
                              subtitle: const Text('Your recent corn leaf scan is processed. No disease detected.'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                children: const [
                  TextSpan(text: 'Hello, '),
                  TextSpan(
                    text: 'Farmer',
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Ecosystem status: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Stable',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Wheat Card
            Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B7355), Color(0xFF556B2F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    // In a real app, this would be an AssetImage or NetworkImage
                    child: const Center(child: Icon(Icons.agriculture, color: Colors.white30, size: 50)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.primaryGreen, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'ENVIRONMENTAL ALERT',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primaryGreen,
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Optimize Wheat Growth',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                            children: const [
                              TextSpan(text: 'Maintain soil moisture at '),
                              TextSpan(text: '60-80%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              TextSpan(text: '. Current atmospheric levels suggest a slight increase in irrigation needed for peak immunity.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/result');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : Colors.black87,
                              side: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.2)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Analysis Details', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Center(
              child: Text(
                'DIAGNOSTIC TOOL',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2.0,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Scanner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.scannerGradient,
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.document_scanner, color: AppColors.primaryGreen, size: 40),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Position your leaf within the frame\nfor real-time neural analysis.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            // Start Detection Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/scan');
                },
                icon: const Icon(Icons.camera),
                label: const Text('START AI DETECTION'),
              ),
            ),
            
            const SizedBox(height: 24),
            // Bottom Stats Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SCANS / 24H',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '12',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+2',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HEALTH INDEX',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '94',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                '%',
                                style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
      ),
    );
  }
}
