import 'package:hive/hive.dart';

part 'history.g.dart';

@HiveType(typeId: 2)
class History {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final String username;
  @HiveField(3)
  final String action;
  @HiveField(4)
  final DateTime timestamp;

  History({
    required this.id,
    required this.description,
    required this.username,
    required this.action,
    required this.timestamp,
  });
}
