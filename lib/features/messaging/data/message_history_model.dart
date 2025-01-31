import 'package:hive/hive.dart';

part 'message_history_model.g.dart';

@HiveType(typeId: 2)
class MessageHistory {
  @HiveField(0)
  final String phoneNumber;

  @HiveField(1)
  final DateTime timestamp;

  MessageHistory({
    required this.phoneNumber,
    required this.timestamp,
  });
}
