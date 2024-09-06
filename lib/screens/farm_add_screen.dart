import 'package:flutter/material.dart';
import 'package:flutter_proje/models/history.dart';
import 'package:flutter_proje/models/urunler_model.dart';
import 'package:flutter_proje/models/user.dart';
import 'package:flutter_proje/screens/farm_detail_screen.dart';
import 'package:hive/hive.dart';

class FarmAddScreen extends StatelessWidget {
  final Function(Urun, Kategori) onFarmAdded;
  final List<Kategori> mevcutKategoriler;

  FarmAddScreen({
    required this.onFarmAdded,
    required this.mevcutKategoriler,
    super.key,
  });

  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _animalCountController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  Future<void> _logHistory(String description, String action) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Çiftlik Ekle'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.agriculture_rounded,
                        size: 80.0,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Çiftlik Bilgileri',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cityController,
                      label: 'Şehir',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _farmNameController,
                      label: 'Çiftlik Adı',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _animalCountController,
                      label: 'Hayvan Sayısı',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _capacityController,
                      label: 'Kapasite',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          String cityName = _cityController.text.trim();
                          String farmName = _farmNameController.text.trim();
                          final int animalCount = int.tryParse(
                                  _animalCountController.text.trim()) ??
                              0;
                          final int capacity =
                              int.tryParse(_capacityController.text.trim()) ??
                                  0;

                          if (cityName.isNotEmpty &&
                              farmName.isNotEmpty &&
                              animalCount > 0 &&
                              capacity > 0) {
                            // Kapasite kontrolü ekleyelim
                            if (animalCount > capacity) {
                              // Kapasiteden fazla hayvan sayısı kontrolü
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Geçersiz Veri'),
                                  content: const Text(
                                      'Hayvan sayısı kapasiteden fazla olamaz. Lütfen geçerli bir değer girin.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Tamam'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            cityName = cityName[0].toUpperCase() +
                                cityName.substring(1);
                            farmName = farmName[0].toUpperCase() +
                                farmName.substring(1);

                            Kategori mevcutKategori =
                                mevcutKategoriler.firstWhere(
                              (kategori) =>
                                  kategori.isim.toLowerCase() ==
                                  cityName.toLowerCase(),
                              orElse: () => Kategori(
                                id: DateTime.now().millisecondsSinceEpoch,
                                isim: cityName,
                                resim: 'city',
                              ),
                            );

                            if (!mevcutKategoriler.contains(mevcutKategori)) {
                              mevcutKategoriler.add(mevcutKategori);
                            }

                            final dolulukOrani =
                                ((animalCount / capacity) * 100)
                                        .toStringAsFixed(1) +
                                    '%';

                            final yeniUrun = Urun(
                              id: DateTime.now().millisecondsSinceEpoch,
                              kategori: mevcutKategori.id,
                              isim: farmName,
                              resim: 'farm',
                              dolulukOrani: dolulukOrani,
                              kapasite: capacity,
                              hayvanSayisi: animalCount,
                            );

                            onFarmAdded(yeniUrun, mevcutKategori);

                            // History kaydını ekleyin
                            await _logHistory(
                              'Yeni ekleme: $farmName çiftliği $cityName şehrine eklendi.',
                              'Ekleme',
                            );

                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Ekle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    );
  }
}
