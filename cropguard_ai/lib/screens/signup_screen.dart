import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';

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
  bool _isLoading = false;
  String? _errorMessage;

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

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your full name';
      });
      return false;
    }

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return false;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return false;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a password';
      });
      return false;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return false;
    }

    return true;
  }

  Future<void> _handleSignup() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (result['success']) {
      // Save to singleton for display purposes
      final profile = UserProfile();
      profile.name = _nameController.text.trim();
      profile.email = _emailController.text.trim();
      if (_phoneController.text.isNotEmpty) {
        profile.phone = _phoneController.text.trim();
      }
      if (_locationController.text.isNotEmpty) {
        profile.location = _locationController.text.trim();
      }
      if (_cropController.text.isNotEmpty) {
        profile.crop = _cropController.text.trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please verify your email.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to OTP screen with dev OTP if available
      final devOtp = result['otp'] as String?;  // Development mode
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            email: _emailController.text.trim(),
            devOtp: devOtp,
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['error'] ?? 'Signup failed. Please try again.';
      });
    }
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
                const SizedBox(height: 32),

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Name Field
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: Colors.white),
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
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
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email *',
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
                  enabled: !_isLoading,
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
                  enabled: !_isLoading,
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
                  enabled: !_isLoading,
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
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Password *',
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
                    onPressed: _isLoading ? null : _handleSignup,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('CREATE ACCOUNT'),
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
                      onPressed: _isLoading
                          ? null
                          : () {
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
