import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_nav.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
              icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color ?? (isDarkMode ? Colors.white : Colors.black87), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'App Settings',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // App Header Profile
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_florist, // Potted plant analog
                        size: 50,
                        color: AppColors.primaryGreen,
                        shadows: [
                          Shadow(
                            color: AppColors.primaryGreen.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(8, 8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: theme.scaffoldBackgroundColor, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'GreenGuard AI',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'ENTERPRISE EDITION',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primaryGreenDark,
                letterSpacing: 2.0,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 40),
            
            // Display Experience
            _buildSectionHeader(context, 'DISPLAY EXPERIENCE'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: _buildIconFrame(context, Icons.dark_mode),
                title: Text('Dark Mode', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(isDarkMode ? 'ENABLED' : 'DISABLED', style: theme.textTheme.labelLarge?.copyWith(color: isDarkMode ? AppColors.textMuted : AppColors.textMutedLight, fontSize: 10, letterSpacing: 1.5)),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (val) {
                    CropGuardApp.setBrightness(
                      context, 
                      val ? Brightness.dark : Brightness.light,
                    );
                  },
                  activeThumbColor: AppColors.primaryGreen,
                  activeTrackColor: AppColors.primaryGreenDark.withOpacity(0.5),
                  inactiveThumbColor: AppColors.textLightLight,
                  inactiveTrackColor: AppColors.textMutedLight.withOpacity(0.3),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // System Information
            _buildSectionHeader(context, 'SYSTEM INFORMATION'),
            const SizedBox(height: 16),
            
            // About
            _buildListTile(
              context,
              icon: Icons.bar_chart,
              title: 'About AI Crop Detection',
              subtitle: 'Technology & Algorithms',
              trailing: Icon(Icons.chevron_right, color: isDarkMode ? AppColors.textMuted : AppColors.textMutedLight),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'GreenGuard AI',
                  applicationVersion: '4.2.0',
                  applicationIcon: const Icon(Icons.local_florist, size: 40, color: AppColors.primaryGreen),
                  children: [
                    const Text('Advanced crop disease detection using AI algorithms to help farmers protect their yield.')
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            
            // Contact
            _buildListTile(
              context,
              icon: Icons.help_outline,
              title: 'Contact Support',
              subtitle: '24/7 Expert Assistance',
              trailing: Icon(Icons.chevron_right, color: isDarkMode ? AppColors.textMuted : AppColors.textMutedLight),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact Support opens mail app (simulated).')),
                );
              },
            ),
            const SizedBox(height: 12),
            
            // Version
            _buildListTile(
              context,
              icon: Icons.verified,
              title: 'App Version',
              subtitle: 'Stable Build',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You are on the latest version.')),
                );
              },
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGreenDark),
                ),
                child: Text(
                  'V 4.2.0',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text('Sign Out', style: TextStyle(color: AppColors.statusDanger)),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: theme.cardTheme.color,
                  side: BorderSide(color: AppColors.statusDanger.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Sign Out Account',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.statusDanger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'ENCRYPTION ACTIVE • PRIVACY SECURED',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textMuted.withOpacity(0.5),
                fontSize: 10,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 3,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isDarkMode ? AppColors.textMuted : AppColors.textMutedLight,
          fontSize: 12,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildIconFrame(BuildContext context, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primaryGreen, size: 20),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: _buildIconFrame(context, icon),
        title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: theme.textTheme.labelLarge?.copyWith(color: isDarkMode ? AppColors.textMuted : AppColors.textMutedLight, fontSize: 10, letterSpacing: 0.5)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
