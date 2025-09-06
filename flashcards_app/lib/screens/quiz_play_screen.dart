import 'package:flashcards_app/screens/quiz_results_screen.dart';
import 'package:flashcards_app/widgets/animated_progess_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../models/quiz_question.dart';
import '../services/quiz_generator.dart';
import '../utils/app_colors.dart';

class QuizPlayScreen extends StatefulWidget {
  final FlashcardSet flashcardSet;
  final List<Flashcard> flashcards;

  const QuizPlayScreen({
    super.key,
    required this.flashcardSet,
    required this.flashcards,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  late List<QuizQuestion> quizQuestions;
  int currentQuestionIndex = 0;
  List<QuizAnswer> userAnswers = [];
  int? selectedOptionIndex;
  bool hasAnswered = false;
  late DateTime startTime;
  Timer? questionTimer;
  int timeRemaining = 30; // 30 seconds per question

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    try {
      quizQuestions = QuizGenerator.generateQuiz(
        flashcards: widget.flashcards,
        numberOfQuestions: 10,
      );
      _startTimer();
    } catch (e) {
      // Handle error if quiz generation fails
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
      });
    }
  }

  void _startTimer() {
    timeRemaining = 30;
    questionTimer?.cancel();
    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          timeRemaining--;
        });

        if (timeRemaining <= 0) {
          _timeUp();
        }
      }
    });
  }

  void _timeUp() {
    if (!hasAnswered) {
      _submitAnswer(-1); // -1 indicates no answer selected (time up)
    }
  }

  void _selectOption(int index) {
    if (!hasAnswered) {
      setState(() {
        selectedOptionIndex = index;
      });
    }
  }

  void _submitAnswer(int selectedIndex) {
    if (hasAnswered) return;

    questionTimer?.cancel();
    setState(() {
      hasAnswered = true;
    });

    final currentQuestion = quizQuestions[currentQuestionIndex];
    final isCorrect = selectedIndex == currentQuestion.correctIndex;

    userAnswers.add(QuizAnswer(
      questionId: currentQuestion.id,
      selectedIndex: selectedIndex,
      correctIndex: currentQuestion.correctIndex,
      isCorrect: isCorrect,
    ));

    // Show feedback for 2 seconds, then move to next question
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < quizQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOptionIndex = null;
        hasAnswered = false;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    questionTimer?.cancel();
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(startTime);
    final correctAnswers = userAnswers.where((answer) => answer.isCorrect).length;

    final result = QuizResult(
      totalQuestions: quizQuestions.length,
      correctAnswers: correctAnswers,
      answers: userAnswers,
      completedAt: endTime,
      timeTaken: timeTaken,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          result: result,
          flashcardSet: widget.flashcardSet,
          flashcards: widget.flashcards,
        ),
      ),
    );
  }

  @override
  void dispose() {
    questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (quizQuestions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = quizQuestions[currentQuestionIndex];
    // Calculate progress - starts from 0.0 for first question
    final progress = (currentQuestionIndex + 1) / quizQuestions.length;

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
                  color: timeRemaining > 10 
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${timeRemaining}s',
                  style: TextStyle(
                    color: timeRemaining > 10 ? AppColors.primary : AppColors.error,
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
          // Animated Progress bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'of ${quizQuestions.length}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Replace LinearProgressIndicator with AnimatedProgressBar
                AnimatedProgressBar(
                  progress: progress,
                  duration: const Duration(milliseconds: 600),
                ),
              ],
            ),
          ),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
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
                    child: Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options
                  ...List.generate(currentQuestion.options.length, (index) {
                    final option = currentQuestion.options[index];
                    final isSelected = selectedOptionIndex == index;
                    final isCorrect = index == currentQuestion.correctIndex;
                    final showFeedback = hasAnswered;

                    Color backgroundColor = Colors.white;
                    Color borderColor = AppColors.neutral200;
                    Color textColor = Colors.black;

                    if (showFeedback) {
                      if (isCorrect) {
                        backgroundColor = AppColors.success.withOpacity(0.1);
                        borderColor = AppColors.success;
                        textColor = AppColors.success;
                      } else if (isSelected && !isCorrect) {
                        backgroundColor = AppColors.error.withOpacity(0.1);
                        borderColor = AppColors.error;
                        textColor = AppColors.error;
                      }
                    } else if (isSelected) {
                      backgroundColor = AppColors.primary.withOpacity(0.1);
                      borderColor = AppColors.primary;
                      textColor = AppColors.primary;
                    }

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _selectOption(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: borderColor,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (showFeedback && isCorrect)
                                Icon(Icons.check_circle, color: AppColors.success),
                              if (showFeedback && isSelected && !isCorrect)
                                Icon(Icons.cancel, color: AppColors.error),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Submit button
                  if (!hasAnswered)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: selectedOptionIndex != null
                            ? () => _submitAnswer(selectedOptionIndex!)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedOptionIndex != null
                              ? AppColors.primary
                              : AppColors.neutral300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Submit Answer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
