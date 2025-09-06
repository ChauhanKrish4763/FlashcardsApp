import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/app_colors.dart';
import 'library_screen.dart';
import 'create_flashcard_screen.dart';
import 'play_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    final screens = [
      const LibraryScreen(),
      const CreateFlashcardScreen(),
      const PlayScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
