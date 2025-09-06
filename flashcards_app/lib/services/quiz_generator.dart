import 'dart:math';
import '../models/flashcard.dart';
import '../models/quiz_question.dart';

class QuizGenerator {
  static List<QuizQuestion> generateQuiz({
    required List<Flashcard> flashcards,
    int numberOfQuestions = 10,
  }) {
    if (flashcards.length < 4) {
      throw Exception('Need at least 4 flashcards to generate a quiz');
    }

    final random = Random();
    final List<QuizQuestion> quizQuestions = [];
    final usedQuestions = <String>{};

    // Shuffle flashcards to randomize question selection
    final shuffledCards = List<Flashcard>.from(flashcards)..shuffle(random);

    int questionsGenerated = 0;
    int attempts = 0;
    const maxAttempts = 100;

    while (questionsGenerated < numberOfQuestions && attempts < maxAttempts) {
      attempts++;
      
      // Pick a random flashcard for the question
      final questionCard = shuffledCards[random.nextInt(shuffledCards.length)];
      
      // Skip if we've already used this question
      if (usedQuestions.contains(questionCard.question)) {
        continue;
      }

      // Get other answers (wrong options)
      final otherCards = flashcards
          .where((card) => 
              card.id != questionCard.id && 
              card.answer.trim().isNotEmpty &&
              card.answer != questionCard.answer)
          .toList();

      // Need at least 3 other cards for wrong options
      if (otherCards.length < 3) {
        continue;
      }

      // Shuffle and select 3 wrong answers
      otherCards.shuffle(random);
      final wrongAnswers = otherCards
          .take(3)
          .map((card) => card.answer.trim())
          .toList();

      // Create options list with correct answer
      final options = <String>[
        questionCard.answer.trim(),
        ...wrongAnswers,
      ];

      // Shuffle options to randomize correct answer position
      options.shuffle(random);

      // Find the index of the correct answer
      final correctIndex = options.indexOf(questionCard.answer.trim());

      // Create quiz question
      final quizQuestion = QuizQuestion(
        id: questionCard.id,
        question: 'What is the answer for: "${questionCard.question}"?',
        options: options,
        correctIndex: correctIndex,
        explanation: 'The correct answer is: ${questionCard.answer}',
      );

      quizQuestions.add(quizQuestion);
      usedQuestions.add(questionCard.question);
      questionsGenerated++;
    }

    if (quizQuestions.isEmpty) {
      throw Exception('Could not generate quiz questions. Please add more flashcards.');
    }

    return quizQuestions;
  }
}
