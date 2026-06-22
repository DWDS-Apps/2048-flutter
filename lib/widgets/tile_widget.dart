import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class TileWidget extends StatefulWidget {
  final int? value;
  final bool isNew;
  final bool isMerged;

  const TileWidget({
    super.key,
    required this.value,
    this.isNew = false,
    this.isMerged = false,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>?_scaleAnim;
  Animation<double>?_fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    if (widget.isNew) {
      _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller.forward();
    } else if (widget.isMerged) {
      _scaleAnim = TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.15), weight: 40),
        TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0), weight: 40),
      ]).animate(_controller);
      _controller.forward();
    } else {
      _scaleAnim = Tween<double>(begin: 1.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.linear),
      );
    }
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isMerged && widget.isMerged) {
      _controller.reset();
      _scaleAnim = TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.15), weight: 40),
        TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0), weight: 40),
      ]).animate(_controller);
      _controller.forward();
    } else if (!oldWidget.isNew && widget.isNew) {
      _controller.reset();
      _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _scaleAnim?.value ?? 1.0;
        final opacity = _fadeAnim?.value ?? 1.0;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: _buildTileContent(),
    );
  }

  Widget _buildTileContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.tileColor(widget.value),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: widget.value != null
          ? Text(
              '${widget.value}',
              style: TextStyle(
                fontSize: AppTheme.tileFontSize(widget.value),
                fontWeight: FontWeight.bold,
                color: AppTheme.tileTextColor(widget.value, brightness: Theme.of(context).brightness),
              ),
            )
          : null,
    );
  }
}
