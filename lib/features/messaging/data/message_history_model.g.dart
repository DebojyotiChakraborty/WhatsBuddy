// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageHistoryAdapter extends TypeAdapter<MessageHistory> {
  @override
  final int typeId = 2;

  @override
  MessageHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageHistory(
      phoneNumber: fields[0] as String,
      timestamp: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MessageHistory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.phoneNumber)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
