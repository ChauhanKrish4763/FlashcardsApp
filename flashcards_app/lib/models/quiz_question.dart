class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final List<QuizAnswer> answers;
  final DateTime completedAt;
  final Duration timeTaken;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.answers,
    required this.completedAt,
    required this.timeTaken,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;
}

class QuizAnswer {
  final String questionId;
  final int selectedIndex;
  final int correctIndex;
  final bool isCorrect;

  QuizAnswer({
    required this.questionId,
    required this.selectedIndex,
    required this.correctIndex,
    required this.isCorrect,
  });
}
