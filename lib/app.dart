import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'services/storage_service.dart';
import 'widgets/menu_screen.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  final StorageService _storage = StorageService();
  bool _darkMode = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final dark = await _storage.loadDarkMode();
    if (mounted) setState(() {
      _darkMode = dark;
      _loaded = true;
    });
  }

  void _toggleTheme() {
    setState(() {
      _darkMode = !_darkMode;
      _storage.saveDarkMode(_darkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: _darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: _loaded
          ? MenuScreen(
              onToggleTheme: _toggleTheme,
              isDark: _darkMode,
            )
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
