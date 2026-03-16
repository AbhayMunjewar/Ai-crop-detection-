import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      });
      
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    
    _controller.forward().then((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon Placeholder (Dark rounded square with green leaf)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.energy_savings_leaf, 
                        size: 60, 
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36),
                      children: const [
                        TextSpan(text: 'AI Crop '),
                        TextSpan(
                          text: 'Disease\n',
                          style: TextStyle(color: AppColors.primaryGreen),
                        ),
                        TextSpan(text: 'Detection'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Subtitle / Tagline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 1, width: 30, color: AppColors.primaryGreen.withOpacity(0.3)),
                      const SizedBox(width: 12),
                      Text(
                        'SMART FARMING WITH AI',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(height: 1, width: 30, color: AppColors.primaryGreen.withOpacity(0.3)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bottom Loading Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hub, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Analyzing plant health data...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _animation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(2),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
