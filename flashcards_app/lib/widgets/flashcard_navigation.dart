import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FlashcardNavigation extends StatefulWidget {
  final int currentIndex;
  final int totalFlashcards;
  final Function(int) onIndexChanged;
  final VoidCallback onAddFlashcard;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final bool isAddButtonVisible; // NEW: Hide/show add button

  const FlashcardNavigation({
    super.key,
    required this.currentIndex,
    required this.totalFlashcards,
    required this.onIndexChanged,
    required this.onAddFlashcard,
    required this.onToggleExpanded,
    this.isExpanded = false,
    this.isAddButtonVisible = true, // Default true to not break existing code
  });

  @override
  State<FlashcardNavigation> createState() => _FlashcardNavigationState();
}

class _FlashcardNavigationState extends State<FlashcardNavigation>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    _slideController.forward();
    _buttonController.forward();

    if (widget.isExpanded) {
      _expandController.forward();
    }
  }

  @override
  void didUpdateWidget(FlashcardNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _buttonController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _handleAddFlashcard() {
    _buttonController.reset();
    _buttonController.forward();
    widget.onAddFlashcard();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: widget.onToggleExpanded,
                  child: Center(
                    child: Icon(
                      widget.isExpanded
                          ? Icons.expand_more
                          : Icons.expand_less,
                      color: Colors.black.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (widget.isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Flashcard ${widget.currentIndex + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                'of ${widget.totalFlashcards}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.primary.withOpacity(0.3),
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: widget.currentIndex.toDouble(),
                          min: 0,
                          max: (widget.totalFlashcards - 1).toDouble(),
                          divisions: widget.totalFlashcards > 1 
                              ? widget.totalFlashcards - 1 
                              : 1,
                          onChanged: (value) => widget.onIndexChanged(value.round()),
                        ),
                      ),
                    ],
                  ),
                ),
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.currentIndex > 0
                                  ? () => widget.onIndexChanged(widget.currentIndex - 1)
                                  : null,
                              icon: const Icon(Icons.arrow_back_ios_rounded, size: 12),
                              label: const Text('Prev', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.currentIndex > 0
                                    ? AppColors.secondary
                                    : Colors.grey.withOpacity(0.3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: widget.currentIndex > 0 ? 1 : 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.currentIndex < widget.totalFlashcards - 1
                                  ? () => widget.onIndexChanged(widget.currentIndex + 1)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.currentIndex < widget.totalFlashcards - 1
                                    ? AppColors.secondary
                                    : Colors.grey.withOpacity(0.3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: widget.currentIndex < widget.totalFlashcards - 1 ? 1 : 0,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Next', style: TextStyle(fontSize: 12)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 12),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Only show Add Flashcard button if isAddButtonVisible is true
                      if (widget.isAddButtonVisible) ...[
                        const SizedBox(height: 8),
                        ScaleTransition(
                          scale: _buttonAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _handleAddFlashcard,
                              icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                              label: const Text(
                                'Add Flashcard',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
