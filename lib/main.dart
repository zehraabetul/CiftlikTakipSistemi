import 'package:flutter/material.dart';
import 'package:flutter_proje/models/history.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_proje/models/urunler_model.dart';
import 'package:flutter_proje/models/user.dart';
import 'package:flutter_proje/screens/home_screen.dart';
import 'package:flutter_proje/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(KategoriAdapter());
  Hive.registerAdapter(UrunAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(HistoryAdapter());

  await Hive.openBox<History>('historyBox');
  await Hive.openBox<Kategori>('kategoriBox');
  await Hive.openBox<Urun>('urunBox');
  var userBox = await Hive.openBox<User>('userBox');

  // Admin kullanıcısını oluşturmak için
  if (userBox.values.isEmpty) {
    var adminUser =
        User(username: 'admin', password: 'admin123', role: 'admin');
    await userBox.add(adminUser);

    var normalUser = User(username: 'user', password: 'user123', role: 'user');
    await userBox.add(normalUser);
  }

  runApp(const Uygulamam());
}

class Uygulamam extends StatelessWidget {
  const Uygulamam({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Nunito",
        primaryColor: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          titleTextStyle: TextStyle(
            fontFamily: "Nunito",
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      home: LoginScreen(),
      routes: {},
    );
  }
}
