import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  
  // Controllers
  final _nameController = TextEditingController(text: UserProfile().name);
  final _emailController = TextEditingController(text: UserProfile().email);
  final _phoneController = TextEditingController(text: UserProfile().phone);
  final _locationController = TextEditingController(text: UserProfile().location);
  final _cropController = TextEditingController(text: UserProfile().crop);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _cropController.dispose();
    super.dispose();
  }

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
          'USER PROFILE',
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
                icon: Icon(
                  _isEditing ? Icons.check : Icons.edit, 
                  color: isDark ? Colors.white : Colors.black87, 
                  size: 20
                ),
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      // Save action
                      final profile = UserProfile();
                      profile.name = _nameController.text;
                      profile.email = _emailController.text;
                      profile.phone = _phoneController.text;
                      profile.location = _locationController.text;
                      profile.crop = _cropController.text;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile details saved successfully!')),
                      );
                    }
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Avatar
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3), width: 3),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.eco, color: theme.scaffoldBackgroundColor, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _isEditing 
                ? TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                    decoration: const InputDecoration(border: UnderlineInputBorder()),
                  )
                : Text(
                    _nameController.text,
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  
            const SizedBox(height: 8),
            Text(
              'EXPERT FARMER',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.primaryGreen,
                letterSpacing: 2.0,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 40),
            
            // Info Cards
            _buildInfoCard(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.phone_outlined,
              label: 'Phone',
              controller: _phoneController,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.location_on_outlined,
              label: 'Location',
              controller: _locationController,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.agriculture_outlined,
              label: 'Primary Crop',
              controller: _cropController,
            ),
            
            const SizedBox(height: 40),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'TOTAL SCANS',
                    value: '142',
                    icon: Icons.document_scanner,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'MEMBER SINCE',
                    value: '2023',
                    icon: Icons.calendar_today,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String label, required TextEditingController controller}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                _isEditing
                    ? TextField(
                        controller: controller,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          border: UnderlineInputBorder(),
                        ),
                      )
                    : Text(
                        controller.text,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String label, required String value, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen.withOpacity(0.5), size: 24),
          const SizedBox(height: 16),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.displayMedium?.copyWith(
              color: AppColors.primaryGreen,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
