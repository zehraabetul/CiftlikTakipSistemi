import 'package:flutter/material.dart';
import 'package:flutter_proje/models/history.dart';
import 'package:flutter_proje/models/urunler_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late Box<Urun> urunBox;
  List<Urun> urunler = [];

  @override
  void initState() {
    super.initState();
    _loadUrunler();
  }

  Future<void> _loadUrunler() async {
    try {
      urunBox = await Hive.openBox<Urun>('urunler');
      setState(() {
        urunler = urunBox.values.toList();
      });
      print('Urunler yüklendi: ${urunler.length}');
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  // UserScreen.dart
  void _logHistory(String description, String action) async {
    final historyBox = Hive.box<History>('historyBox');
    final newHistory = History(
      id: DateTime.now().millisecondsSinceEpoch, // Geçici ID
      description: description,
      username: 'System', // Default user for system logs
      action: action,
      timestamp: DateTime.now(),
    );

    await historyBox.add(newHistory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _showFarmList(context);
              },
              child: Text('Tüm Çiftlikler'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFarmList(BuildContext context) {
    if (urunler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıtlı çiftlik yok')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FarmListScreen(urunler: urunler),
      ),
    );
  }
}

class FarmListScreen extends StatelessWidget {
  final List<Urun> urunler;

  const FarmListScreen({required this.urunler});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Çiftlik Listesi'),
      ),
      body: ListView.builder(
        itemCount: urunler.length,
        itemBuilder: (context, index) {
          final urun = urunler[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.network(
                urun.resim,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(urun.isim),
              subtitle: Text(
                  'Kapasite: ${urun.kapasite} - Hayvan Sayısı: ${urun.hayvanSayisi}'),
              trailing: Text(
                _calculateOccupancyRate(urun.hayvanSayisi, urun.kapasite),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Ekstra işlevsellik ekleyebilirsiniz.
              },
            ),
          );
        },
      ),
    );
  }

  String _calculateOccupancyRate(int hayvanSayisi, int kapasite) {
    if (kapasite == 0) return '0%';
    final rate = (hayvanSayisi / kapasite).clamp(0.0, 1.0);
    return '${(rate * 100).toStringAsFixed(1)}%';
  }
}
