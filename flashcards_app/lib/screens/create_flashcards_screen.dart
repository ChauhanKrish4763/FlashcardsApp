import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../providers/flashcard_provider.dart';
import '../services/hive_service.dart';
import '../utils/app_colors.dart';
import '../widgets/flashcard_card.dart';
import '../widgets/flashcard_navigation.dart';

class CreateFlashcardsScreen extends ConsumerStatefulWidget {
  final FlashcardSet flashcardSet;

  const CreateFlashcardsScreen({super.key, required this.flashcardSet});

  @override
  ConsumerState<CreateFlashcardsScreen> createState() => _CreateFlashcardsScreenState();
}

class _CreateFlashcardsScreenState extends ConsumerState<CreateFlashcardsScreen> {
  List<Flashcard> flashcards = [];
  int currentFlashcardIndex = 0;
  bool isNavigationExpanded = false;

  @override
  void initState() {
    super.initState();
    _addNewFlashcard();
  }

  void _addNewFlashcard() {
    setState(() {
      flashcards.add(
        Flashcard(
          question: '',
          answer: '',
          setId: widget.flashcardSet.id,
        ),
      );
      currentFlashcardIndex = flashcards.length - 1;
    });
  }

  void _updateFlashcard(Flashcard updatedFlashcard) {
    int index = flashcards.indexWhere((card) => card.id == updatedFlashcard.id);
    if (index != -1) {
      setState(() {
        flashcards[index] = updatedFlashcard;
      });
    }
  }

  void _navigateToFlashcard(int index) {
    if (index >= 0 && index < flashcards.length) {
      setState(() {
        currentFlashcardIndex = index;
      });
    }
  }

  void _toggleNavigationMode() {
    setState(() {
      isNavigationExpanded = !isNavigationExpanded;
    });
  }

  Future<void> _saveFlashcards() async {
    try {
      // Save all flashcards
      for (final flashcard in flashcards) {
        await HiveService.saveFlashcard(flashcard);
      }

      // Update flashcard set with count
      final updatedSet = widget.flashcardSet;
      updatedSet.totalCards = flashcards.length;
      await HiveService.saveFlashcardSet(updatedSet);

      // Refresh the flashcard provider
      ref.read(flashcardProvider.notifier).loadFlashcardSets();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                // ADDED: Success Lottie animation in snackbar
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Lottie.asset(
                    'assets/animations/success_confetti.json',
                    repeat: false,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Flashcard set "${widget.flashcardSet.name}" saved successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                // ADDED: Error Lottie animation in snackbar
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Lottie.asset(
                    'assets/animations/error_occurred.json',
                    repeat: false,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Error saving flashcard set: $e'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Create Flashcards',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: _saveFlashcards,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: flashcards.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: ValueKey('flashcard_${flashcards[currentFlashcardIndex].id}'),
                    child: FlashcardCard(
                      key: ValueKey('card_${flashcards[currentFlashcardIndex].id}'),
                      flashcard: flashcards[currentFlashcardIndex],
                      onFlashcardUpdated: _updateFlashcard,
                    ),
                  ),
                ),
                FlashcardNavigation(
                  currentIndex: currentFlashcardIndex,
                  totalFlashcards: flashcards.length,
                  onIndexChanged: _navigateToFlashcard,
                  onAddFlashcard: _addNewFlashcard,
                  isExpanded: isNavigationExpanded,
                  onToggleExpanded: _toggleNavigationMode,
                ),
              ],
            ),
    );
  }
}
