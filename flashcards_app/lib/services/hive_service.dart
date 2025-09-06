import 'package:hive_flutter/hive_flutter.dart';
import '../models/flashcard.dart';
import '../models/flashcard_set.dart';

class HiveService {
  static const String _flashcardSetsBoxName = 'flashcard_sets';
  static const String _flashcardsBoxName = 'flashcards';

  static Box<FlashcardSet> get _flashcardSetsBox =>
      Hive.box<FlashcardSet>(_flashcardSetsBoxName);

  static Box<Flashcard> get _flashcardsBox =>
      Hive.box<Flashcard>(_flashcardsBoxName);

  // FlashcardSet operations
  static Future<void> saveFlashcardSet(FlashcardSet set) async {
    await _flashcardSetsBox.put(set.id, set);
  }

  static List<FlashcardSet> getAllFlashcardSets() {
    return _flashcardSetsBox.values.toList();
  }

  static FlashcardSet? getFlashcardSet(String id) {
    return _flashcardSetsBox.get(id);
  }

  static Future<void> deleteFlashcardSet(String id) async {
    await _flashcardSetsBox.delete(id);
    final flashcards = getFlashcardsBySetId(id);
    for (final flashcard in flashcards) {
      await _flashcardsBox.delete(flashcard.id);
    }
  }

  // Flashcard operations
  static Future<void> saveFlashcard(Flashcard flashcard) async {
    await _flashcardsBox.put(flashcard.id, flashcard);
  }

  static List<Flashcard> getAllFlashcards() {
    return _flashcardsBox.values.toList();
  }

  static List<Flashcard> getFlashcardsBySetId(String setId) {
    return _flashcardsBox.values
        .where((flashcard) => flashcard.setId == setId)
        .toList();
  }

  static Flashcard? getFlashcard(String id) {
    return _flashcardsBox.get(id);
  }

  static Future<void> deleteFlashcard(String id) async {
    await _flashcardsBox.delete(id);
  }

  static Future<void> clearAll() async {
    await _flashcardSetsBox.clear();
    await _flashcardsBox.clear();
  }
}
