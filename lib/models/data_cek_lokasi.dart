// ignore_for_file: non_constant_identifier_names

class DataCekLokasi {
  int? id;
  String? kode_lokasi;
  String? nama_lokasi;
  double? latitude;
  double? longitude;
  double? radius;
  String? nama_pegawai;
  String? jenis_kelamin;
  String? jenis_user;
  String? username;
  String? email;
  String? foto;
  String? lokasi_absen;

  DataCekLokasi({
    this.id,
    this.kode_lokasi,
    this.nama_lokasi,
    this.latitude,
    this.longitude,
    this.radius,
    this.nama_pegawai,
    this.jenis_kelamin,
    this.jenis_user,
    this.username,
    this.email,
    this.foto,
    this.lokasi_absen,
  });

  factory DataCekLokasi.fromJson(Map<String, dynamic> json) {
    return DataCekLokasi(
      id: json['id'],
      kode_lokasi: json['kode_lokasi'],
      nama_lokasi: json['nama_lokasi'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      nama_pegawai: json['nama_pegawai'],
      jenis_kelamin: json['jenis_kelamin'],
      jenis_user: json['jenis_user'],
      username: json['username'],
      email: json['email'],
      foto: json['foto'],
      lokasi_absen: json['lokasi_absen'],
    );
  }
}
