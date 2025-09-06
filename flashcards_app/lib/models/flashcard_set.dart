import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'flashcard_set.g.dart';

@HiveType(typeId: 1)
class FlashcardSet extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  int totalCards;

  @HiveField(7)
  int learnedCards;

  FlashcardSet({
    String? id,
    required this.name,
    required this.description,
    required this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.totalCards = 0,
    this.learnedCards = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progress => totalCards > 0 ? learnedCards / totalCards : 0.0;
}
