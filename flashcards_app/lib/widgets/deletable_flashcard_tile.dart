import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/flashcard_set.dart';
import '../utils/app_colors.dart';

class DeletableFlashcardTile extends StatefulWidget {
  final FlashcardSet flashcardSet;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final IconData icon;
  final Color iconColor;

  const DeletableFlashcardTile({
    super.key,
    required this.flashcardSet,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<DeletableFlashcardTile> createState() => _DeletableFlashcardTileState();
}

class _DeletableFlashcardTileState extends State<DeletableFlashcardTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100), // FASTER!
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(DeletableFlashcardTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            onLongPress: () {
              HapticFeedback.lightImpact();
              widget.onLongPress();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100), // FASTER!
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? AppColors.error.withOpacity(0.05)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isSelected 
                      ? AppColors.error 
                      : AppColors.neutral200,
                  width: widget.isSelected ? 2.0 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected 
                        ? AppColors.error.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: widget.isSelected ? 8 : 4,
                    spreadRadius: widget.isSelected ? 1 : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon (NO RED LINE BAR!)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.isSelected 
                            ? AppColors.error.withOpacity(0.1)
                            : widget.iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.isSelected ? AppColors.error : widget.iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.flashcardSet.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: widget.isSelected 
                                  ? AppColors.error 
                                  : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.flashcardSet.description,
                            style: TextStyle(
                              color: widget.isSelected 
                                  ? AppColors.error.withOpacity(0.7)
                                  : Colors.black,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.isSelected 
                                      ? AppColors.error.withOpacity(0.1)
                                      : AppColors.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.flashcardSet.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.isSelected 
                                        ? AppColors.error 
                                        : AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.isSelected 
                                      ? AppColors.error.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${widget.flashcardSet.totalCards} cards',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.isSelected 
                                        ? AppColors.error 
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // NO TRAILING TRASH ICON - just the play/learn icon
                    Icon(
                      widget.icon == Icons.quiz ? Icons.play_arrow : Icons.school,
                      size: 20,
                      color: widget.isSelected ? AppColors.error : widget.iconColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
