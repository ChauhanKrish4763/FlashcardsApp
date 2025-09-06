import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../models/quiz_question.dart';
import '../utils/app_colors.dart';
import 'quiz_play_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final FlashcardSet flashcardSet;
  final List<Flashcard> flashcards; // Add this parameter

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.flashcardSet,
    required this.flashcards, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    final percentage = result.percentage;
    String grade = 'F';
    Color gradeColor = AppColors.error;

    if (percentage >= 90) {
      grade = 'A+';
      gradeColor = AppColors.success;
    } else if (percentage >= 80) {
      grade = 'A';
      gradeColor = AppColors.success;
    } else if (percentage >= 70) {
      grade = 'B';
      gradeColor = AppColors.primary;
    } else if (percentage >= 60) {
      grade = 'C';
      gradeColor = AppColors.warning;
    } else if (percentage >= 50) {
      grade = 'D';
      gradeColor = AppColors.error;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Quiz Results',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradeColor.withOpacity(0.1),
                    gradeColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gradeColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    grade,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: gradeColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: gradeColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${result.correctAnswers} out of ${result.totalQuestions} correct',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quiz Statistics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Set Name', flashcardSet.name),
                  _buildStatRow('Total Questions', '${result.totalQuestions}'),
                  _buildStatRow('Correct Answers', '${result.correctAnswers}'),
                  _buildStatRow('Wrong Answers', '${result.totalQuestions - result.correctAnswers}'),
                  _buildStatRow('Time Taken', _formatDuration(result.timeTaken)),
                  _buildStatRow('Accuracy', '${percentage.toInt()}%'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neutral300,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // FIX: Use pushReplacement to avoid navigation stack issues
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => QuizPlayScreen(
                            flashcardSet: flashcardSet,
                            flashcards: flashcards,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Play Again',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
