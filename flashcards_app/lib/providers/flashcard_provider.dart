import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../services/hive_service.dart';

class FlashcardNotifier extends StateNotifier<AsyncValue<List<FlashcardSet>>> {
  FlashcardNotifier() : super(const AsyncValue.loading()) {
    loadFlashcardSets();
  }

  Future<void> loadFlashcardSets() async {
    try {
      state = const AsyncValue.loading();
      await Future.delayed(const Duration(seconds: 2)); // For wait screen
      
      // Get sorted sets (first created appears first - First Come First Serve)
      final sets = _getSortedFlashcardSets();
      
      // Update card counts
      for (final set in sets) {
        final flashcards = HiveService.getFlashcardsBySetId(set.id);
        set.totalCards = flashcards.length;
        set.learnedCards = flashcards.where((card) => card.isLearned).length;
        await HiveService.saveFlashcardSet(set);
      }
      
      state = AsyncValue.data(sets);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Sort flashcard sets by creation time (First Come First Serve - oldest first)
  List<FlashcardSet> _getSortedFlashcardSets() {
    final allSets = HiveService.getAllFlashcardSets();
    allSets.sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Ascending order
    return allSets;
  }

  Future<void> addFlashcardSet(FlashcardSet set) async {
    // Check for duplicate names (case-insensitive)
    final existingSets = HiveService.getAllFlashcardSets();
    final nameExists = existingSets.any(
      (existingSet) => existingSet.name.toLowerCase() == set.name.toLowerCase(),
    );
    
    if (nameExists) {
      throw Exception('A flashcard set with this name already exists');
    }
    
    await HiveService.saveFlashcardSet(set);
    await loadFlashcardSets();
  }

  Future<void> deleteFlashcardSet(String id) async {
    await HiveService.deleteFlashcardSet(id);
    await loadFlashcardSets();
  }

  // Helper method to check if name exists (for real-time validation)
  bool isNameTaken(String name) {
    final existingSets = HiveService.getAllFlashcardSets();
    return existingSets.any(
      (set) => set.name.toLowerCase() == name.toLowerCase(),
    );
  }
}

class FlashcardListNotifier extends StateNotifier<List<Flashcard>> {
  FlashcardListNotifier() : super([]);

  void loadFlashcards(String setId) {
    state = HiveService.getFlashcardsBySetId(setId);
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    await HiveService.saveFlashcard(flashcard);
    loadFlashcards(flashcard.setId);
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    flashcard.updatedAt = DateTime.now();
    await HiveService.saveFlashcard(flashcard);
    loadFlashcards(flashcard.setId);
  }

  Future<void> deleteFlashcard(String id, String setId) async {
    await HiveService.deleteFlashcard(id);
    loadFlashcards(setId);
  }

  Future<void> toggleLearned(String id, String setId) async {
    final flashcard = HiveService.getFlashcard(id);
    if (flashcard != null) {
      flashcard.isLearned = !flashcard.isLearned;
      flashcard.updatedAt = DateTime.now();
      await HiveService.saveFlashcard(flashcard);
      loadFlashcards(setId);
    }
  }
}

final flashcardProvider = StateNotifierProvider<FlashcardNotifier, AsyncValue<List<FlashcardSet>>>(
  (ref) => FlashcardNotifier(),
);

final flashcardListProvider = StateNotifierProvider<FlashcardListNotifier, List<Flashcard>>(
  (ref) => FlashcardListNotifier(),
);
