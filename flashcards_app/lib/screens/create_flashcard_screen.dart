import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';  // ADD THIS IMPORT
import '../models/flashcard_set.dart';
import '../providers/flashcard_provider.dart';
import '../utils/app_colors.dart';
import 'create_flashcards_screen.dart';

class CreateFlashcardScreen extends ConsumerStatefulWidget {
  const CreateFlashcardScreen({super.key});

  @override
  ConsumerState<CreateFlashcardScreen> createState() => _CreateFlashcardScreenState();
}

class _CreateFlashcardScreenState extends ConsumerState<CreateFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'General';
  
  // For real-time duplicate checking
  bool _isNameDuplicate = false;
  bool _isChecking = false;

  final List<String> _categories = [
    'General',
    'Math',
    'Science',
    'History',
    'Language',
    'Geography',
    'Literature',
    'Art',
    'Music',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_checkDuplicateName);
  }

  void _checkDuplicateName() {
    final name = _titleController.text.trim();
    
    if (name.isEmpty) {
      setState(() {
        _isNameDuplicate = false;
        _isChecking = false;
      });
      return;
    }

    setState(() {
      _isChecking = true;
    });

    // Debounce to avoid checking on every keystroke
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      final exists = ref.read(flashcardProvider.notifier).isNameTaken(name);
      setState(() {
        _isNameDuplicate = exists;
        _isChecking = false;
      });
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_checkDuplicateName);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_formKey.currentState!.validate() && !_isNameDuplicate) {
      try {
        final newSet = FlashcardSet(
          name: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
        );

        await ref.read(flashcardProvider.notifier).addFlashcardSet(newSet);

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateFlashcardsScreen(flashcardSet: newSet),
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
                  Text(e.toString().replaceAll('Exception: ', '')),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Set',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fill the details to get started',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),

                // REPLACED: AnimatedPlaceholder with Lottie animation
                Center(
                  child: Lottie.asset(
                    'assets/animations/create.json',  // Use your create animation
                    width: 120,
                    height: 120,
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.collections_bookmark,
                            size: 48,
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Set Image',
                            style: TextStyle(
                              color: AppColors.neutral600.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                const Text(
                  'Set Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Set Name',
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText: 'Enter flashcard set name',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white,
                    errorText: _isNameDuplicate ? 'A set with this name already exists' : null,
                    suffixIcon: _isChecking 
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _isNameDuplicate
                            ? Icon(Icons.error, color: AppColors.error)
                            : _titleController.text.trim().isNotEmpty && !_isNameDuplicate
                                ? Icon(Icons.check_circle, color: AppColors.success)
                                : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isNameDuplicate ? AppColors.error : AppColors.neutral200,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isNameDuplicate ? AppColors.error : AppColors.neutral200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isNameDuplicate ? AppColors.error : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a set name';
                    }
                    if (_isNameDuplicate) {
                      return 'A set with this name already exists';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText: 'Enter set description',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neutral200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neutral200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neutral200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neutral200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isNameDuplicate || 
                                 _isChecking || 
                                 _titleController.text.trim().isEmpty)
                        ? null
                        : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isNameDuplicate || 
                                       _isChecking || 
                                       _titleController.text.trim().isEmpty)
                          ? AppColors.neutral300
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isChecking
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Checking...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Continue',
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
      ),
    );
  }
}
