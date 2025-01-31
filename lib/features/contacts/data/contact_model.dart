import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 0)
class Contact {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String number;

  @HiveField(2)
  final DateTime createdAt;

  Contact({
    required this.name,
    required this.number,
    required this.createdAt,
  });
}
