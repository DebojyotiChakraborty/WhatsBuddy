import 'package:hive/hive.dart';
import 'message_history_model.dart';

class MessagingRepository {
  static const _historyBoxName = 'messageHistory';
  static const _maxHistoryItems = 10;

  static Future<void> addToHistory(String phoneNumber) async {
    final box = await Hive.openBox<MessageHistory>(_historyBoxName);
    final history = MessageHistory(
      phoneNumber: phoneNumber,
      timestamp: DateTime.now(),
    );

    // Add new item to beginning of list
    final items = box.values.toList();
    items.insert(0, history);

    // Keep only last 10 items
    if (items.length > _maxHistoryItems) {
      items.removeRange(_maxHistoryItems, items.length);
    }

    await box.clear();
    await box.addAll(items);
  }

  static Future<List<MessageHistory>> getHistory() async {
    final box = await Hive.openBox<MessageHistory>(_historyBoxName);
    return box.values.toList();
  }

  static Future<void> clearHistory() async {
    final box = await Hive.openBox<MessageHistory>(_historyBoxName);
    await box.clear();
  }
}
