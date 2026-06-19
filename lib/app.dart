import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'widgets/menu_screen.dart';
import 'widgets/game_screen.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  bool _darkMode = false;

  void _toggleTheme() {
    setState(() => _darkMode = !_darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: _darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: MenuScreen(
        onPlay: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GameScreen(onToggleTheme: _toggleTheme, isDark: _darkMode),
            ),
          );
        },
      ),
    );
  }
}
