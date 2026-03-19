import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../services/scan_history_service.dart';
import '../services/api_service.dart';
import '../widgets/custom_bottom_nav.dart';
class UploadScanScreen extends StatefulWidget {
  const UploadScanScreen({super.key});

  @override
  State<UploadScanScreen> createState() => _UploadScanScreenState();
}

class _UploadScanScreenState extends State<UploadScanScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  bool _isAnalyzing = false;

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final imageBytes = await _selectedImage!.readAsBytes();
      final result = await ApiService.predictDisease(
        imageBytes,
        _selectedImage!.path.split('/').last,
      );

      if (!mounted) return;

      if (result['success']) {
        ScanHistoryService.addScan(
          disease: result['disease'],
          confidence: result['confidence'],
          imagePath: _selectedImage!.path,
          geminiData: result['gemini_data'],
        );

        Navigator.pushReplacementNamed(
          context,
          '/result',
          arguments: {
            'image_path': _selectedImage!.path,
            'disease': result['disease'],
            'confidence': result['confidence'],
            'gemini_data': result['gemini_data'],
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Analysis failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Text(
          'UPLOAD IMAGE',
          style: theme.textTheme.labelLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Identify Disease',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 12),
            Text(
              'Place the leaf in the center for the most accurate diagnosis.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            
            // Upload Area
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.5),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.cloud_upload, color: AppColors.primaryGreen, size: 40),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Scan Leaf',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'TAP TO BROWSE OR DROP FILE',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.5,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // Camera Button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                ),
                title: Text(
                  'Camera',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'INSTANT CAPTURE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodyMedium?.color),
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Gallery Button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, color: AppColors.primaryGreen),
                ),
                title: Text(
                  'Gallery',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'CHOOSE EXISTING',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodyMedium?.color),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _selectedImage != null && !_isAnalyzing
                    ? () => _analyzeImage()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor: theme.cardTheme.color?.withOpacity(0.5) ?? AppColors.cardBackground.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isAnalyzing 
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Text(
                      'Continue',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _selectedImage != null ? (isDark ? AppColors.backgroundDark : Colors.white) : AppColors.textMuted.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Step Indicator
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(2))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'STEP 1 OF 3',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 1,
      ),
    );
  }
}
