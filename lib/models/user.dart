import 'package:hive/hive.dart';

part 'user.g.dart'; // Otomatik olarak oluşturulacak dosya ismi

@HiveType(typeId: 10)
class User extends HiveObject {
  @HiveField(11)
  final String username;

  @HiveField(12)
  final String password;

  @HiveField(13)
  final String role; // 'admin' or 'user'

  User({
    required this.username,
    required this.password,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
}
