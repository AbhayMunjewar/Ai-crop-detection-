import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScanHistoryService {
  static final List<Map<String, dynamic>> _scans = [];

  static List<Map<String, dynamic>> get scans => _scans;

  static void addScan({
    required String disease,
    required double confidence,
    required String imagePath,
  }) {
    // Format title
    String title = disease.split('___').last.replaceAll('_', ' ');

    // Determine category and status
    String category = 'DISEASED';
    Color statusColor = AppColors.statusDanger;
    IconData statusIcon = Icons.error_outline;

    if (disease.toLowerCase().contains('healthy')) {
      category = 'HEALTHY';
      statusColor = AppColors.statusSafe;
      statusIcon = Icons.check_circle_outline;
    }

    // Format date roughly like "OCT 24 • 09:45 AM"
    final now = DateTime.now();
    final monthNames = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    String month = monthNames[now.month - 1];
    int hour = now.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    String minute = now.minute.toString().padLeft(2, '0');
    
    String dateStr = '$month ${now.day} • ${hour.toString().padLeft(2, '0')}:$minute $period';

    _scans.insert(0, {
      'title': title,
      'date': dateStr,
      'confidence': confidence,
      'statusIcon': statusIcon,
      'statusColor': statusColor,
      'category': category,
      'image_path': imagePath,
    });
  }

  static void clearScans() {
    _scans.clear();
  }
}
