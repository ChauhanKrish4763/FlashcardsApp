import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../services/hive_service.dart';
import '../utils/app_colors.dart';
import '../widgets/flashcard_navigation.dart';

class LearnFlashcardsScreen extends ConsumerStatefulWidget {
  final FlashcardSet flashcardSet;

  const LearnFlashcardsScreen({super.key, required this.flashcardSet});

  @override
  ConsumerState<LearnFlashcardsScreen> createState() => _LearnFlashcardsScreenState();
}

class _LearnFlashcardsScreenState extends ConsumerState<LearnFlashcardsScreen> {
  late List<Flashcard> flashcards;
  int currentIndex = 0;
  bool isFrontVisible = true;
  bool isNavigationExpanded = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    flashcards = HiveService.getFlashcardsBySetId(widget.flashcardSet.id);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTapCard() {
    setState(() {
      isFrontVisible = !isFrontVisible;
    });
  }

  void _onPageChanged(int newIndex) {
    setState(() {
      currentIndex = newIndex;
      isFrontVisible = true;
    });
  }

  void _onNavChanged(int newIndex) {
    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleExpanded() {
    setState(() {
      isNavigationExpanded = !isNavigationExpanded;
    });
  }

  void _addCard() {
    // This function won't be called since we hide the add button
  }

  @override
  Widget build(BuildContext context) {
    if (flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.flashcardSet.name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // REPLACED: Placeholder icon with Lottie empty box animation
              Lottie.asset(
                'assets/animations/empty_box.json',
                width: 80,
                height: 80,
                repeat: true,
              ),
              const SizedBox(height: 24),
              const Text(
                'No cards in this set yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add some flashcards to start learning!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.flashcardSet.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${currentIndex + 1}/${flashcards.length}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hint text
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app,
                  color: AppColors.neutral400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap card to flip • Swipe to navigate',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: flashcards.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return Center(
                  child: GestureDetector(
                    onTap: _onTapCard,
                    child: FlipCard(
                      flashcard: flashcards[index],
                      showFront: index == currentIndex ? isFrontVisible : true,
                    ),
                  ),
                );
              },
            ),
          ),

          FlashcardNavigation(
            currentIndex: currentIndex,
            totalFlashcards: flashcards.length,
            onIndexChanged: _onNavChanged,
            onAddFlashcard: _addCard,
            isExpanded: isNavigationExpanded,
            onToggleExpanded: _toggleExpanded,
            isAddButtonVisible: false, // Hide add button in learn mode
          ),
        ],
      ),
    );
  }
}

// FlipCard widget remains the same as in your original file...
class FlipCard extends StatefulWidget {
  final Flashcard flashcard;
  final bool showFront;

  const FlipCard({super.key, required this.flashcard, required this.showFront});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    if (!widget.showFront) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFront != oldWidget.showFront) {
      if (widget.showFront) {
        _controller.reverse();
      } else {
        _controller.forward();
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
        final angle = _controller.value * 3.1415926535897932;
        final isFront = _controller.value < 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: Container(
            width: 340,
            height: 480,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: isFront ? Colors.white : AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Front side (Question)
                if (isFront)
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Question label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'QUESTION',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.flashcard.question.isNotEmpty
                                  ? widget.flashcard.question
                                  : 'No question set',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: widget.flashcard.question.isNotEmpty
                                    ? Colors.black
                                    : AppColors.neutral400,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        // Flip hint
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flip,
                              size: 16,
                              color: AppColors.neutral400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tap to reveal answer',
                              style: TextStyle(
                                color: AppColors.neutral400,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Back side (Answer)
                if (!isFront)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.1415926535897932),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // Answer label
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ANSWER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                widget.flashcard.answer.isNotEmpty
                                    ? widget.flashcard.answer
                                    : 'No answer set',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: widget.flashcard.answer.isNotEmpty
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.7),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Flip hint
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flip,
                                size: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tap to see question',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
