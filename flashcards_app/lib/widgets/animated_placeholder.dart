import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AnimatedPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final String? label;

  const AnimatedPlaceholder({
    super.key,
    this.width = 160,
    this.height = 160,
    this.label,
  });

  @override
  State<AnimatedPlaceholder> createState() => _AnimatedPlaceholderState();
}

class _AnimatedPlaceholderState extends State<AnimatedPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(_animation.value),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.animation,
                size: 48,
                color: AppColors.primary.withOpacity(_animation.value),
              ),
              if (widget.label != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: AppColors.neutral600.withOpacity(_animation.value),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
