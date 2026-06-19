import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class TileWidget extends StatelessWidget {
  final int? value;
  final bool isNew;

  const TileWidget({super.key, required this.value, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isNew ? 1.0 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.tileColor(value),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: value != null
            ? Text(
                '$value',
                style: TextStyle(
                  fontSize: AppTheme.tileFontSize(value),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.tileTextColor(value),
                ),
              )
            : null,
      ),
    );
  }
}
