import 'package:flutter/material.dart';
import 'package:flutter_proje/models/history.dart';
import 'package:flutter_proje/models/user.dart';
import 'package:flutter_proje/screens/RoleBasedVisibility.dart';
import 'package:flutter_proje/screens/farm_add_screen.dart';
import 'package:flutter_proje/screens/farm_list_screen.dart';
import 'package:flutter_proje/models/urunler_model.dart';
import 'package:flutter_proje/screens/history_screen.dart';
import 'package:flutter_proje/screens/login_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'RoleBasedVisibility.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;

  const HomeScreen({
    required this.currentUser,
    super.key,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Urun> urunler = [];
  final List<Kategori> kategoriler = [];

  void _loadData() async {
    final kategoriBox = Hive.box<Kategori>('kategoriBox');
    final urunBox = Hive.box<Urun>('urunBox');

    setState(() {
      kategoriler.clear();
      urunler.clear();
      kategoriler.addAll(kategoriBox.values);
      urunler.addAll(urunBox.values);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _addFarm(Urun yeniUrun, Kategori yeniKategori) async {
    try {
      final kategoriBox = Hive.box<Kategori>('kategoriBox');
      final urunBox = Hive.box<Urun>('urunBox');

      await kategoriBox.put(yeniKategori.id.toString(), yeniKategori);
      await urunBox.put(yeniUrun.id.toString(), yeniUrun);

      setState(() {
        if (!kategoriler.any((kategori) => kategori.id == yeniKategori.id)) {
          kategoriler.add(yeniKategori);
        }
        urunler.add(yeniUrun);
      });
    } catch (e) {
      print('Veri ekleme hatası: $e');
    }
  }

  void _updateCategory(int kategoriId, List<Urun> updatedUrunler) async {
    setState(() {
      final index =
          kategoriler.indexWhere((kategori) => kategori.id == kategoriId);
      if (index != -1) {
        final kategori = kategoriler[index];

        for (var updatedUrun in updatedUrunler) {
          final urunIndex =
              urunler.indexWhere((urun) => urun.id == updatedUrun.id);
          if (urunIndex != -1) {
            urunler[urunIndex] = updatedUrun;
          } else {
            urunler.add(updatedUrun);
          }
        }
      }
    });

    final urunBox = Hive.box<Urun>('urunBox');
    for (var updatedUrun in updatedUrunler) {
      await urunBox.put(updatedUrun.id.toString(), updatedUrun);
    }
  }

  void _onFarmUpdated(List<Urun> updatedUrunler) {
    setState(() {
      for (var updatedUrun in updatedUrunler) {
        final index = urunler.indexWhere((u) => u.id == updatedUrun.id);
        if (index != -1) {
          urunler[index] = updatedUrun;
        } else {
          urunler.add(updatedUrun);
        }
      }
    });

    final urunBox = Hive.box<Urun>('urunBox');
    for (var updatedUrun in updatedUrunler) {
      urunBox.put(updatedUrun.id.toString(), updatedUrun);
    }

    _loadData();
  }

  void _onDeleteCity(Kategori kategori) {
    _confirmDelete(kategori);
  }

  Future<void> _confirmDelete(Kategori kategori) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Silme Onayı'),
          content: Text(
              '${kategori.isim} şehrini silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil'),
              onPressed: () async {
                try {
                  final kategoriBox = Hive.box<Kategori>('kategoriBox');
                  final urunBox = Hive.box<Urun>('urunBox');

                  // Şehre ait tüm çiftlikleri sil
                  final kategoriUrunler = urunler
                      .where((urun) => urun.kategori == kategori.id)
                      .toList();
                  for (var urun in kategoriUrunler) {
                    await urunBox.delete(urun.id.toString());
                  }

                  // Şehri sil
                  await kategoriBox.delete(kategori.id.toString());

                  // History kaydı ekle
                  await _logHistory(
                      '${kategori.isim} şehri ve içindeki çiftlikler silindi.',
                      'Şehir Silme');

                  setState(() {
                    urunler.removeWhere((urun) => urun.kategori == kategori.id);
                    kategoriler.remove(kategori);
                  });
                } catch (e) {
                  print('Silme hatası: $e');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logHistory(String description, String action) async {
    final historyBox = Hive.box<History>('historyBox');
    final newHistory = History(
      id: DateTime.now().millisecondsSinceEpoch,
      description: description,
      username: widget.currentUser.username,
      action: action,
      timestamp: DateTime.now(),
    );

    await historyBox.add(newHistory);
  }

  @override
  Widget build(BuildContext context) {
    _loadData();
    List<Kategori> sortedCategories = List.from(kategoriler);
    sortedCategories.sort((a, b) => a.isim.compareTo(b.isim));

    final User currentUser = widget.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ana Sayfa',
          style: TextStyle(fontSize: 22),
        ),
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(currentUser.role.toUpperCase()),
              accountEmail: Text(currentUser.role + "@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.teal, size: 40),
              ),
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.blue),
              title: Text('Ana Sayfa'),
              onTap: () {
                Navigator.pop(context); // Menü kapanır
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.orange),
              title: Text('Geçmiş'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Çıkış Yap'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Image.network(
            "https://media.istockphoto.com/id/929592454/tr/vekt%C3%B6r/t%C3%BCrkiye-haritas%C4%B1.jpg?s=612x612&w=0&k=20&c=AQpIQXVEPIEvW6Pe-nwpldCrytjFlkYlYnAXNRgNFAw=",
            width: 200,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FarmListScreen(
                        urunler: urunler,
                        kategori: Kategori(
                          id: 0,
                          isim: "Tüm Çiftlikler",
                          resim: 'farm',
                        ),
                        currentUser: currentUser,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Tüm Çiftlikler',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
          ),
          Expanded(
            child: sortedCategories.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.only(
                        bottom: 100.0), // FAB için boşluk bırakılır.

                    itemCount: sortedCategories.length,
                    itemBuilder: (context, index) {
                      final kategori = sortedCategories[index];
                      final kategoriUrunler = urunler
                          .where((urun) => urun.kategori == kategori.id)
                          .toList();

                      final occupancyRate =
                          _calculateOccupancyRate(kategoriUrunler);

                      return Card(
                        child: ListTile(
                          title: Text(kategori.isim),
                          leading:
                              Icon(Icons.location_city, color: Colors.teal),
                          subtitle: Text(
                              'Doluluk: ${occupancyRate.toStringAsFixed(1)}%'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RoleBasedVisibility(
                                user: currentUser,
                                isVisible: (user) => user.isAdmin,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDelete(kategori);
                                  },
                                ),
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: double.infinity,
                                        height: 40 * (occupancyRate / 100),
                                        color: occupancyRate > 75
                                            ? Color.fromARGB(255, 0, 255, 8)
                                            : occupancyRate > 50
                                                ? Color.fromARGB(
                                                    255, 178, 255, 150)
                                                : occupancyRate > 25
                                                    ? Color.fromARGB(
                                                        255, 68, 168, 83)
                                                    : Color.fromARGB(
                                                        255, 0, 109, 45),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -4,
                                    child: Container(
                                      width: 12,
                                      height: 4,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () async {
                            final updatedUrunler =
                                await Navigator.push<List<Urun>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FarmListScreen(
                                  urunler: kategoriUrunler,
                                  kategori: kategori,
                                  currentUser: currentUser,
                                ),
                              ),
                            );

                            if (updatedUrunler != null) {
                              _updateCategory(kategori.id, updatedUrunler);
                              _onFarmUpdated(updatedUrunler);
                              _loadData();
                              setState(() {});
                            }
                            _loadData();
                          },
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text('Henüz şehir eklenmemiş.'),
                  ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: currentUser.isAdmin,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmAddScreen(
                    onFarmAdded: _addFarm,
                    mevcutKategoriler: kategoriler,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.teal, // Buton üzerindeki metin rengi
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8.0), // Kenar köşe yuvarlama
              ),
              padding: EdgeInsets.symmetric(
                  vertical: 25, horizontal: 30), // İç boşluk
            ),
            child: Text(
              'Ekleme Yap',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateOccupancyRate(List<Urun> urunler) {
    final totalCapacity = urunler.fold(0.0, (sum, urun) => sum + urun.kapasite);
    final totalOccupied =
        urunler.fold(0.0, (sum, urun) => sum + urun.hayvanSayisi);
    if (totalCapacity == 0) return 0.0;
    return (totalOccupied / totalCapacity) * 100;
  }
}
