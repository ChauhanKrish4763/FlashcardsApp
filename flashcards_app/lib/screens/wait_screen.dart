import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_colors.dart';
import '../providers/flashcard_provider.dart';
import 'home_screen.dart';
import 'dart:math';

class WaitScreen extends ConsumerStatefulWidget {
  const WaitScreen({super.key});

  @override
  ConsumerState<WaitScreen> createState() => _WaitScreenState();
}

class _WaitScreenState extends ConsumerState<WaitScreen> {
  int _currentTipIndex = 0;
  final Random _random = Random();

  final List<String> _tips = [
    "Octopuses have three hearts! Two pump blood to the gills, one pumps to the rest of the body.",
    "A group of flamingos is called a \"flamboyance.\"",
    "Sloths can hold their breath longer than dolphins – up to 40 minutes underwater!",
    "Butterflies can taste with their feet.",
    "Sea otters hold hands while sleeping so they don't drift apart.",
    "Bananas are berries, but strawberries aren't.",
    "Sharks existed before trees – over 400 million years ago!",
    "Koalas have fingerprints almost identical to humans.",
    "A day on Venus is longer than a year on Venus.",
    "Wombat poop is cube-shaped!",
    "Penguins propose with pebbles. Male penguins give a pebble to a female they like.",
    "Some frogs can freeze and come back to life.",
    "Starfish don't have a brain, but they can still move and eat!",
    "Your stomach gets a new lining every 3-4 days so it doesn't digest itself.",
    "Honey never spoils – archaeologists found edible honey in 3,000-year-old tombs!",
  ];

  @override
  void initState() {
    super.initState();
    _currentTipIndex = _random.nextInt(_tips.length);
    _startTipRotation();
    _navigateToHome();
  }

  void _startTipRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentTipIndex = _random.nextInt(_tips.length);
        });
        _startTipRotation();
      }
    });
  }

  void _navigateToHome() {
    ref.read(flashcardProvider.notifier).loadFlashcardSets().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Setting up your playground',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // REPLACED: AnimatedPlaceholder with Lottie loading animation
                Lottie.asset(
                  'assets/animations/yay-jump.json',
                  width: 180,
                  height: 180,
                  repeat: true,
                ),
                
                const SizedBox(height: 48),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    key: ValueKey(_currentTipIndex),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _tips[_currentTipIndex],
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.neutral200,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
