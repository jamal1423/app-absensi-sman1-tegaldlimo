// ignore_for_file: non_constant_identifier_names

class DataCekAbsen {
  int? id;
  String? username;
  String? c_in;
  String? tgl_c_in;
  String? c_out;
  String? tgl_c_out;
  String? late_;
  String? early;
  String? overtime;
  String? latitude;
  String? longitude;
  String? lokasi;
  String? ijin;
  String? ket_ijin;
  String? tgl_ijin_awal;
  String? tgl_ijin_akhir;
  String? status_ijin;
  String? doc_ijin;

  DataCekAbsen({
    this.id,
    this.username,
    this.c_in,
    this.tgl_c_in,
    this.c_out,
    this.tgl_c_out,
    this.late_,
    this.early,
    this.overtime,
    this.latitude,
    this.longitude,
    this.lokasi,
    this.ijin,
    this.ket_ijin,
    this.tgl_ijin_awal,
    this.tgl_ijin_akhir,
    this.status_ijin,
    this.doc_ijin,
  });

  factory DataCekAbsen.fromJson(Map<String, dynamic> json) {
    return DataCekAbsen(
      id: json['id'],
      username: json['username'],
      c_in: json['c_in'],
      tgl_c_in: json['tgl_c_in'],
      c_out: json['c_out'],
      tgl_c_out: json['tgl_c_out'],
      late_: json['late'],
      early: json['early'],
      overtime: json['overtime'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lokasi: json['lokasi'],
      ijin: json['ijin'],
      ket_ijin: json['ket_ijin'],
      tgl_ijin_awal: json['tgl_ijin_awal'],
      tgl_ijin_akhir: json['tgl_ijin_akhir'],
      status_ijin: json['status_ijin'],
      doc_ijin: json['status_ijin'],
    );
  }
}