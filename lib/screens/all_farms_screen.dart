import 'package:flutter/material.dart';
import 'package:flutter_proje/models/urunler_model.dart';
import 'package:flutter_proje/models/user.dart';
import 'package:flutter_proje/screens/farm_detail_screen.dart';
import 'package:hive/hive.dart';
import 'package:flutter_proje/models/history.dart';

class AllFarmsScreen extends StatelessWidget {
  final User currentUser; // currentUser parametresi eklendi
  final List<Urun> urunler;
  final Kategori kategori;

  const AllFarmsScreen({
    required this.currentUser, // currentUser constructor'da da yer almalı
    required this.urunler,
    required this.kategori,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Kullanıcının admin olup olmadığını kontrol edin
    debugPrint('User isAdmin: ${currentUser.isAdmin}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Çiftlikler'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        itemCount: urunler.length,
        itemBuilder: (context, index) {
          final urun = urunler[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12.0),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              leading: Image.network(
                urun.resim,
                width: 75,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50,
                  );
                },
              ),
              title: Text(urun.isim),
              trailing: currentUser.isAdmin
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        // Çiftlik silme işlemi
                        urunler.removeAt(index);

                        // Hive'da History kaydı oluştur
                        final historyBox =
                            await Hive.openBox<History>('history');

                        final history = History(
                          id: DateTime.now()
                              .millisecondsSinceEpoch, // unique ID
                          description: '${urun.isim} çiftliği silindi',
                          username: currentUser.username, // Kullanıcı adı
                          action: 'delete',
                          timestamp: DateTime.now(),
                        );

                        await historyBox.add(history);

                        // Ekranı güncelle
                        (context as Element).markNeedsBuild();
                      },
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FarmDetailScreen(
                      urun: urun,
                      urunler: urunler,
                      kategori: kategori,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
