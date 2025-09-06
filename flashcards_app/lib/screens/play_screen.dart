import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../providers/flashcard_provider.dart';
import '../services/hive_service.dart';
import '../utils/app_colors.dart';
import '../widgets/deletable_flashcard_tile.dart';
import 'quiz_play_screen.dart';

class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen>
    with TickerProviderStateMixin {
  final Set<String> _selectedIds = <String>{};
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _appBarController;

  @override
  void initState() {
    super.initState();
    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _appBarController.dispose();
    super.dispose();
  }

  void _onTileTap(String id) {
    if (_selectedIds.isNotEmpty) {
      _toggleSelection(id);
    } else {
      final flashcardSetsAsync = ref.read(flashcardProvider);
      flashcardSetsAsync.whenData((sets) {
        final set = sets.firstWhere((s) => s.id == id);
        final flashcards = HiveService.getFlashcardsBySetId(set.id);
        
        if (flashcards.length < 4) {
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
                  const Text('Need at least 4 flashcards to start quiz'),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizPlayScreen(
              flashcardSet: set,
              flashcards: flashcards,
            ),
          ),
        );
      });
    }
  }

  void _onTileLongPress(String id) {
    _toggleSelection(id);
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });

    if (_selectedIds.isNotEmpty && _appBarController.status == AnimationStatus.dismissed) {
      _appBarController.forward();
    } else if (_selectedIds.isEmpty && _appBarController.status == AnimationStatus.completed) {
      _appBarController.reverse();
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
    _appBarController.reverse();
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Flashcard Sets'),
          content: Text(
            'Are you sure you want to delete ${_selectedIds.length} flashcard set${_selectedIds.length > 1 ? 's' : ''}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      HapticFeedback.mediumImpact();
      
      try {
        for (String id in _selectedIds) {
          await ref.read(flashcardProvider.notifier).deleteFlashcardSet(id);
        }

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
                  Text('${_selectedIds.length} flashcard set${_selectedIds.length > 1 ? 's' : ''} deleted'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
                  Text('Error deleting flashcard sets: $e'),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        _clearSelection();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flashcardSetsAsync = ref.watch(flashcardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _selectedIds.isEmpty
            ? const Text(
                'Play Quiz',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              )
            : Text(
                '${_selectedIds.length} selected',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: _selectedIds.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: [
          if (_selectedIds.isNotEmpty)
            IconButton(
              // REPLACED: Delete icon with Lottie trashcan animation
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Lottie.asset(
                  'assets/animations/trashcan.json',
                  repeat: false,
                ),
              ),
              onPressed: _deleteSelected,
            ),
        ],
      ),
      body: flashcardSetsAsync.when(
        loading: () => Center(
          // REPLACED: AnimatedPlaceholder with Lottie loading animation
          child: Lottie.asset(
            'assets/animations/yay-jump.json',
            width: 200,
            height: 200,
            repeat: true,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // REPLACED: Error icon with Lottie error animation
              Lottie.asset(
                'assets/animations/error_occurred.json',
                width: 64,
                height: 64,
                repeat: false,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error loading flashcard sets',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        data: (sets) {
          final playableSets = sets.where((set) => set.totalCards >= 4).toList();
          
          if (playableSets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // REPLACED: AnimatedPlaceholder with Lottie empty box animation
                  Lottie.asset(
                    'assets/animations/empty_box.json',
                    width: 120,
                    height: 120,
                    repeat: true,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No sets available for quiz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create flashcard sets with at least 4 cards to play quiz',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            key: _listKey,
            padding: const EdgeInsets.all(16),
            itemCount: playableSets.length,
            itemBuilder: (context, index) {
              final set = playableSets[index];
              final isSelected = _selectedIds.contains(set.id);

              return DeletableFlashcardTile(
                flashcardSet: set,
                isSelected: isSelected,
                onTap: () => _onTileTap(set.id),
                onLongPress: () => _onTileLongPress(set.id),
                icon: Icons.quiz,
                iconColor: AppColors.success,
              );
            },
          );
        },
      ),
    );
  }
}
