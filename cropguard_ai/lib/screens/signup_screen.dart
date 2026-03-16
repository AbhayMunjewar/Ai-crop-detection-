import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user_profile.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _cropController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _cropController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    // Save to singleton
    final profile = UserProfile();
    if (_nameController.text.isNotEmpty) profile.name = _nameController.text;
    if (_emailController.text.isNotEmpty) profile.email = _emailController.text;
    if (_phoneController.text.isNotEmpty) profile.phone = _phoneController.text;
    if (_locationController.text.isNotEmpty) profile.location = _locationController.text;
    if (_cropController.text.isNotEmpty) profile.crop = _cropController.text;

    Navigator.pushReplacementNamed(context, '/scan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Join the GreenGuard AI network.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Name Field
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Phone Field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Location Field
                TextField(
                  controller: _locationController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Crop Field
                TextField(
                  controller: _cropController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Primary Crop',
                    labelStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    prefixIcon: const Icon(Icons.agriculture_outlined, color: AppColors.primaryGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGreen),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Signup Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _handleSignup,
                    child: const Text('CREATE ACCOUNT'),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
