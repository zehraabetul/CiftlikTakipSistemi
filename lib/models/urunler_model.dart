import 'package:hive/hive.dart';

part 'urunler_model.g.dart';

@HiveType(typeId: 0)
class Kategori extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String isim;

  @HiveField(2)
  final String resim;

  Kategori({
    required this.id,
    required this.isim,
    required this.resim,
  });

  double calculateOccupancyRate(List<Urun> urunler) {
    final kategoriUrunler =
        urunler.where((urun) => urun.kategori == id).toList();

    if (kategoriUrunler.isEmpty) return 0.0;

    double totalOccupancy = 0;
    int totalCapacity = 0;

    for (var urun in kategoriUrunler) {
      totalOccupancy += urun.hayvanSayisi;
      totalCapacity += urun.kapasite;
    }

    return totalCapacity == 0 ? 0.0 : (totalOccupancy / totalCapacity) * 100;
  }
}

@HiveType(typeId: 1)
class Urun extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int kategori;

  @HiveField(2)
  final String isim;

  @HiveField(3)
  final String resim;

  @HiveField(4)
  final int hayvanSayisi;

  @HiveField(5)
  final String dolulukOrani;

  @HiveField(6)
  final int kapasite;

  Urun({
    required this.id,
    required this.kategori,
    required this.isim,
    required this.resim,
    required this.hayvanSayisi,
    required this.dolulukOrani,
    required this.kapasite,
  });
}
