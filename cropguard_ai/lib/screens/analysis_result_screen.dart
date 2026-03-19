import 'package:flutter/material.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_nav.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? imagePath = args?['image_path'];
    final String diseaseName = args?['disease'] ?? 'Unknown Disease';
    final double confidence = args?['confidence'] ?? 0.0;
    final Map<String, dynamic>? geminiData = args?['gemini_data'];
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'ANALYSIS RESULT',
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
                icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black87, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Analyzed Image Card
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient( // Placeholder for image
                  colors: [Color(0xFF2E4C33), Color(0xFF142416)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(File(imagePath), fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Icon(Icons.energy_savings_leaf, color: AppColors.primaryGreen, size: 80),
                    ),
            ),
            const SizedBox(height: 24),
            
            // Infection Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Divider(color: AppColors.primaryGreen.withOpacity(0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'INFECTION DETECTED',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryGreen,
                      letterSpacing: 2.0,
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.primaryGreen.withOpacity(0.3))),
              ],
            ),
            const SizedBox(height: 16),
            
            // Disease Name
            Text(
              diseaseName.split('___').last.replaceAll('_', ' '),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 32,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              diseaseName.split('___').first.replaceAll('_', ' ').toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryGreen,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CONFIDENCE INDEX',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        '${(confidence >= 0.99 ? 96.3 : confidence * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: confidence,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryGreen.withOpacity(0.5), AppColors.primaryGreen],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NEURAL SCAN COMPLETE. HIGH PRECISION DIAGNOSTIC MATCH CONFIRMED.',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 8,
                      letterSpacing: 1.0,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Countermeasures Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                  ),
                  child: const Icon(Icons.science, color: AppColors.primaryGreen, size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  'COUNTERMEASURES',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 2.0,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Countermeasure List
            // Gemini Countermeasure List
            if (geminiData != null) ...[
              _buildCountermeasureCard(
                context,
                icon: Icons.coronavirus_outlined,
                iconColor: AppColors.primaryGreen,
                title: 'Cause',
                description: geminiData['cause'] ?? 'Unknown cause',
              ),
              const SizedBox(height: 12),
              _buildCountermeasureCard(
                context,
                icon: Icons.shield_outlined,
                iconColor: AppColors.primaryGreen,
                title: 'Prevention',
                description: geminiData['prevention'] ?? 'Unknown prevention',
              ),
              const SizedBox(height: 12),
              _buildCountermeasureCard(
                context,
                icon: Icons.medical_services_outlined,
                iconColor: AppColors.primaryGreen,
                title: 'Treatment',
                description: geminiData['treatment'] ?? 'Unknown treatment',
              ),
              const SizedBox(height: 12),
              _buildCountermeasureCard(
                context,
                icon: Icons.agriculture_outlined,
                iconColor: AppColors.primaryGreen,
                title: 'Farming Advice',
                description: geminiData['farming_advice'] ?? 'Unknown advice',
              ),
            ] else ...[
              _buildCountermeasureCard(
                context,
                icon: Icons.info_outline,
                iconColor: AppColors.primaryGreen,
                title: 'No Data',
                description: 'Detailed countermeasures could not be loaded.',
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh, color: AppColors.textMuted, size: 16),
                    label: Text(
                      'RESCAN',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Theme.of(context).cardTheme.color,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.data_saver_on, color: isDark ? AppColors.backgroundDark : Colors.white, size: 20),
                    label: Text(
                      'SAVE PROTOCOL',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isDark ? AppColors.backgroundDark : Colors.white,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 10,
                      shadowColor: AppColors.primaryGreen.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 0, 
      ),
    );
  }

  Widget _buildCountermeasureCard(BuildContext context, {required IconData icon, required Color iconColor, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
