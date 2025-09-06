// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_set.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashcardSetAdapter extends TypeAdapter<FlashcardSet> {
  @override
  final int typeId = 1;

  @override
  FlashcardSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlashcardSet(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as DateTime?,
      totalCards: fields[6] as int,
      learnedCards: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardSet obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.totalCards)
      ..writeByte(7)
      ..write(obj.learnedCards);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
