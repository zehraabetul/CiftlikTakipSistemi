import 'package:flutter/material.dart';
import 'package:flutter_proje/models/history.dart';
import 'package:flutter_proje/models/urunler_model.dart';
import 'package:flutter_proje/screens/farm_detail_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_proje/models/user.dart';

class FarmListScreen extends StatefulWidget {
  final List<Urun> urunler;
  final Kategori kategori;
  final User currentUser;

  const FarmListScreen({
    required this.urunler,
    required this.kategori,
    required this.currentUser,
    super.key,
  });

  @override
  _FarmListScreenState createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  late List<Urun> urunler;

  @override
  void initState() {
    super.initState();
    urunler = widget.urunler;
  }

  void _updateUrun(Urun updatedUrun) async {
    final urunBox = Hive.box<Urun>('urunBox');
    await urunBox.put(updatedUrun.id.toString(), updatedUrun);

    setState(() {
      final index = urunler.indexWhere((u) => u.id == updatedUrun.id);
      if (index != -1) {
        urunler[index] = updatedUrun;
      }
    });

    // Log history with detailed information including city
    _logHistory(
      'Çiftlik güncellendi: ${widget.kategori.isim}, ${updatedUrun.isim}, Hayvan sayısı: ${updatedUrun.hayvanSayisi}, Mevcut kapasite: ${updatedUrun.kapasite}',
      'Update',
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _showAddFarmDialog() async {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _capacityController = TextEditingController();
    final TextEditingController _animalCountController =
        TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni Çiftlik Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Çiftlik Adı'),
              ),
              TextField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Kapasite'),
              ),
              TextField(
                controller: _animalCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Hayvan Sayısı'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ekle'),
              onPressed: () {
                final String name =
                    _capitalizeFirstLetter(_nameController.text);
                final int capacity =
                    int.tryParse(_capacityController.text) ?? 0;
                final int animalCount =
                    int.tryParse(_animalCountController.text) ?? 0;

                if (name.isNotEmpty && capacity > 0) {
                  if (animalCount <= capacity) {
                    final newUrun = Urun(
                      id: DateTime.now().millisecondsSinceEpoch, // Geçici ID
                      kategori: widget.kategori.id,
                      isim: name,
                      resim: 'default_image',
                      kapasite: capacity,
                      hayvanSayisi: animalCount,
                      dolulukOrani:
                          _calculateOccupancyRate(animalCount, capacity),
                    );

                    _addUrun(newUrun);
                    Navigator.of(context).pop();
                  } else {
                    _showErrorDialog('Hayvan sayısı kapasiteyi aşmamalıdır.');
                  }
                } else {
                  _showErrorDialog(
                      'Geçerli bir çiftlik adı ve kapasite girin.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _logHistory(String description, String action) async {
    final historyBox = Hive.box<History>('historyBox');
    final newHistory = History(
      id: DateTime.now().millisecondsSinceEpoch, // Geçici ID
      description: description,
      username: widget.currentUser.username,
      action: action,
      timestamp: DateTime.now(),
    );

    await historyBox.add(newHistory);
  }

  void _addUrun(Urun urun) async {
    try {
      final urunBox = Hive.box<Urun>('urunBox');
      await urunBox.put(urun.id.toString(), urun);

      setState(() {
        urunler.add(urun);
      });
      // Add the following lines in _addUrun method
      _logHistory(
          '${widget.kategori.isim} şehrine yeni çiftlik eklendi: ${urun.isim} ',
          'Add');
    } catch (e) {
      print('Veri ekleme hatası: $e');
    }
  }

  String _calculateOccupancyRate(int animalCount, int capacity) {
    if (capacity == 0) return '0%';
    final rate = (animalCount / capacity).clamp(0.0, 1.0);
    return '${(rate * 100).toStringAsFixed(1)}%';
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hata'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(Urun urun) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Silme Onayı'),
          content:
              Text('${urun.isim} çiftliğini silmek istediğinize emin misiniz?'),
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
                  final urunBox = Hive.box<Urun>('urunBox');
                  await urunBox.delete(urun.id.toString());

                  setState(() {
                    urunler.removeWhere((u) => u.id == urun.id);
                  });

                  // Log history after deleting the urun
                  _logHistory(
                      '${widget.kategori.isim} şehrinde çiftlik silindi: ${urun.isim}',
                      'Delete');
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

  @override
  Widget build(BuildContext context) {
    Map<String, String> sehirResimleri = {
      'ankara':
          'https://img.freepik.com/premium-vector/map-ankara-turkey-vector-illustrationabraham_211056-22.jpg',
      'istanbul':
          'https://img.freepik.com/premium-vector/map-istanbul-turkey-vector-illustration_211056-40.jpg',
      'izmir':
          'https://www.shutterstock.com/image-vector/izmir-map-illustration-vector-city-260nw-2114769188.jpg',
      'konya':
          'https://img.freepik.com/premium-vector/konya-map-illustration-vector-city-turkey_211056-352.jpg',
      'mersin':
          'https://img.freepik.com/premium-vector/mersin-map-illustration-vector-city-turkey_211056-353.jpg',
      'trabzon':
          'https://www.shutterstock.com/image-vector/trabzon-map-illustration-vector-city-260nw-2114768285.jpg',
      'rize':
          'https://www.shutterstock.com/image-vector/turkeys-rize-province-map-260nw-2310840339.jpg',
      'antalya':
          'https://img.freepik.com/premium-vector/antalya-map-illustration-vector-city-turkey_211056-310.jpg',
    };

    String? sehirResmiUrl = sehirResimleri[widget.kategori.isim.toLowerCase()];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kategori.isim),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          sehirResmiUrl != null
              ? Image.network(
                  sehirResmiUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                )
              : Image.network(
                  'https://media.istockphoto.com/id/1253999735/tr/vekt%C3%B6r/modern-binalar-ve-bir-arka-plan-%C3%BCzerinde-%C3%B6zel-evler-ile-banliy%C3%B6s%C3%BCnde-kentsel-peyzaj-vekt%C3%B6r.jpg?s=170667a&w=0&k=20&c=ecv5owLIPsoYwmBPIHITSo_OOsF-xJm36k-s_1jZMFY=',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
          Expanded(
            child: ListView.builder(
              itemCount: urunler.length,
              itemBuilder: (context, index) {
                final urun = urunler[index];
                return Card(
                  child: ListTile(
                    title: Text(urun.isim),
                    leading: Icon(Icons.agriculture, color: Colors.green),
                    subtitle: Text("Doluluk Oranı: ${urun.dolulukOrani}"),
                    trailing: widget.currentUser.isAdmin
                        ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDelete(urun);
                            },
                          )
                        : null, // Admin değilse silme butonu gösterilmez
                    onTap: () async {
                      final updatedUrun = await Navigator.push<Urun>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FarmDetailScreen(
                            urun: urun,
                            urunler: urunler,
                            kategori: widget.kategori,
                          ),
                        ),
                      );

                      if (updatedUrun != null) {
                        _updateUrun(updatedUrun);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.currentUser.isAdmin
          ? SizedBox(
              width: 150.0,
              height: 60.0,
              child: FloatingActionButton(
                onPressed: _showAddFarmDialog,
                child: Text(
                  'Çiftlik Ekle',
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: Colors.teal,
                elevation: 6.0,
              ),
            )
          : null, // Eğer kullanıcı admin değilse FAB gösterilmez
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
