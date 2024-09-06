// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'urunler_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KategoriAdapter extends TypeAdapter<Kategori> {
  @override
  final int typeId = 0;

  @override
  Kategori read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Kategori(
      id: fields[0] as int,
      isim: fields[1] as String,
      resim: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Kategori obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isim)
      ..writeByte(2)
      ..write(obj.resim);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KategoriAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UrunAdapter extends TypeAdapter<Urun> {
  @override
  final int typeId = 1;

  @override
  Urun read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Urun(
      id: fields[0] as int,
      kategori: fields[1] as int,
      isim: fields[2] as String,
      resim: fields[3] as String,
      hayvanSayisi: fields[4] as int,
      dolulukOrani: fields[5] as String,
      kapasite: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Urun obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kategori)
      ..writeByte(2)
      ..write(obj.isim)
      ..writeByte(3)
      ..write(obj.resim)
      ..writeByte(4)
      ..write(obj.hayvanSayisi)
      ..writeByte(5)
      ..write(obj.dolulukOrani)
      ..writeByte(6)
      ..write(obj.kapasite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrunAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
