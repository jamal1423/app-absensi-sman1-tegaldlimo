// ignore_for_file: unused_element

class DataMtShift {
  int? id;
  String? kodeShift;
  String? namaShift;
  String? jamMasukAwal;
  String? jamMasuk;
  String? jamPulang;
  String? jamPulangAkhir;

  DataMtShift({
    this.id,
    this.kodeShift,
    this.namaShift,
    this.jamMasukAwal,
    this.jamMasuk,
    this.jamPulang,
    this.jamPulangAkhir,
  });

  factory DataMtShift.fromJson(Map<String, dynamic> json) {
    return DataMtShift(
      id : json["id"],
      kodeShift : json["kode_shift"],
      namaShift : json["nama_shift"],
      jamMasukAwal : json["jam_masuk_awal"],
      jamMasuk : json["jam_masuk"],
      jamPulang : json["jam_pulang"],
      jamPulangAkhir : json["jam_pulang_akhir"],
    );
  }
}