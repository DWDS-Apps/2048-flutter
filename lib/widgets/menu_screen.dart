import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../services/storage_service.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback onPlay;

  const MenuScreen({super.key, required this.onPlay});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final StorageService _storage = StorageService();
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    final score = await _storage.loadBestScore();
    if (mounted) setState(() => _bestScore = score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '2048',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Best: $_bestScore',
              style: TextStyle(
                fontSize: 20,
                color: AppTheme.boardBackground,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: widget.onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.boardBackground,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Play',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
