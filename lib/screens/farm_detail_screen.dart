import 'package:flutter/material.dart';
import 'package:flutter_proje/models/history.dart';
import 'package:flutter_proje/models/urunler_model.dart';
import 'package:flutter_proje/models/user.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FarmDetailScreen extends StatefulWidget {
  final Urun urun;
  final List<Urun> urunler;
  final Kategori kategori;

  const FarmDetailScreen({
    required this.urun,
    required this.urunler,
    required this.kategori,
    super.key,
  });

  @override
  _FarmDetailScreenState createState() => _FarmDetailScreenState();
}

User getCurrentUser() {
  final userBox =
      Hive.box<User>('userBox'); // Kullanıcılar için kullanılan Hive kutusu
  return userBox.getAt(0)
      as User; // Varsayılan olarak ilk kullanıcıyı almak, burada kendi yapına göre düzenle
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  late Urun urun;

  @override
  void initState() {
    super.initState();
    urun = widget.urun;
  }

  void _updateAnimalCount(int change) async {
    final int newAnimalCount = urun.hayvanSayisi + change;

    if (newAnimalCount > urun.kapasite) {
      _showSnackbar('Kapasiteyi aşamazsınız.');
      return;
    }

    if (newAnimalCount < 0) {
      _showSnackbar('Hayvan sayısı negatif olamaz.');
      return;
    }

    setState(() {
      urun = Urun(
        id: urun.id,
        kategori: urun.kategori,
        isim: urun.isim,
        resim: urun.resim,
        kapasite: urun.kapasite,
        hayvanSayisi: newAnimalCount,
        dolulukOrani: _calculateOccupancyRate(newAnimalCount, urun.kapasite),
      );
    });

    // Hive veritabanını güncelle
    final box = await Hive.openBox<Urun>('urunler');
    await box.put(urun.id, urun);

    // History kaydı oluşturma
    String action = change > 0 ? 'Hayvan Eklendi' : 'Hayvan Çıkarıldı';
    _logHistory(
        '$action: ${urun.isim}, Yeni Hayvan Sayısı: $newAnimalCount', 'Update');

    // Güncellenen veriyi geri döndür
    Navigator.pop(context, urun);

    // Bildirim göster
    _showSnackbar('Hayvan sayısı başarıyla güncellendi.');
  }

  void _updateCapacity(int newCapacity) async {
    if (newCapacity < urun.hayvanSayisi) {
      _showSnackbar('Yeni kapasite mevcut hayvan sayısından düşük olamaz.');
      return;
    }

    // Urun nesnesini güncelle
    setState(() {
      urun = Urun(
        id: urun.id,
        kategori: urun.kategori,
        isim: urun.isim,
        resim: urun.resim,
        kapasite: newCapacity,
        hayvanSayisi: urun.hayvanSayisi,
        dolulukOrani: _calculateOccupancyRate(urun.hayvanSayisi, newCapacity),
      );
    });

    // Hive veritabanını güncelle
    final urunBox = Hive.box<Urun>('urunBox');
    await urunBox.put(urun.id.toString(), urun);

    // Güncellenen veriyi geri döndür
    Navigator.of(context).pop(urun);

    _showSnackbar('Kapasite başarıyla güncellendi.');
  }

  String _calculateOccupancyRate(int animalCount, int capacity) {
    if (capacity == 0) return '0%';
    final rate = (animalCount / capacity).clamp(0.0, 1.0);
    return '${(rate * 100).toStringAsFixed(1)}%';
  }

  void _logHistory(String description, String action) async {
    final User currentUser = getCurrentUser();
    final history = History(
      id: DateTime.now().millisecondsSinceEpoch,
      description: description,
      username: currentUser.username,
      action: action,
      timestamp: DateTime.now(),
    );

    final historyBox = Hive.box<History>('historyBox');
    await historyBox.add(history);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showCapacityDialog() async {
    final TextEditingController _capacityController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni Kapasiteyi Girin'),
          content: TextField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Kapasite'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Güncelle'),
              onPressed: () {
                final int newCapacity =
                    int.tryParse(_capacityController.text) ?? 0;
                if (newCapacity > 0) {
                  _updateCapacity(newCapacity);
                  Navigator.of(context).pop();
                } else {
                  _showSnackbar('Geçerli bir kapasite girin.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showInputDialog(String action) async {
    final TextEditingController _inputController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$action Hayvan Sayısını Girin'),
          content: TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Hayvan Sayısı'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                final int inputValue = int.tryParse(_inputController.text) ?? 0;
                if (inputValue > 0) {
                  if (action == 'Ekle') {
                    _updateAnimalCount(inputValue);
                  } else {
                    _updateAnimalCount(-inputValue);
                  }
                }
                Navigator.of(context)
                    .pop(); // Güncellenmiş ekranın geri dönmesini sağla
                Navigator.pop(context, urun); // Güncellenmiş urunü geri döndür
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User currentUser = getCurrentUser(); // Mevcut kullanıcıyı al
    return Scaffold(
      appBar: AppBar(
        title: Text(urun.isim),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              "https://clipart-library.com/2023/selskoe-khoziaistvo-klipart-organicheskoe-zemledelie-ferma-p.jpg",
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              urun.isim,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _dolulukOraniGosterge(),
            const SizedBox(height: 16),
            _kapasiteBilgisi(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  onPressed: () => _showInputDialog('Ekle'),
                  child: const Text('Hayvan Ekle'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  onPressed: () => _showInputDialog('Çıkar'),
                  child: const Text('Hayvan Çıkar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: _showCapacityDialog,
              child: const Text('Kapasiteyi Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dolulukOraniGosterge() {
    double dolulukOrani = (urun.hayvanSayisi / urun.kapasite).clamp(0.0, 1.0);

    return Column(
      children: [
        const Text(
          "Doluluk Oranı",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 300, // Kart genişliğiyle uyumlu
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2), // Shadow position
              ),
            ],
          ),
          child: LinearProgressIndicator(
            value: dolulukOrani,
            minHeight: 12, // Daha belirgin yükseklik
            backgroundColor: Colors.grey[300],
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${(dolulukOrani * 100).toStringAsFixed(1)}%",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _kapasiteBilgisi() {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 300, // Maksimum genişlik
        ),
        child: Card(
          elevation: 4, // Reduced elevation for a subtler effect
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8), // Slightly smaller border radius
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Çiftlik Bilgisi",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Smaller font size
                      ),
                ),
                const SizedBox(height: 12), // Reduced spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kapasite:",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // Smaller font size
                          ),
                    ),
                    Text(
                      "${urun.kapasite} hayvan",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14, // Smaller font size
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(
                  thickness: 1,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Mevcut Hayvan:",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // Smaller font size
                          ),
                    ),
                    Text(
                      "${urun.hayvanSayisi} hayvan",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14, // Smaller font size
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
