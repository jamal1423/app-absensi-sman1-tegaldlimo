// ignore_for_file: non_constant_identifier_names

class DataUser {
  int? id;
  String? username;
  String? nama_pegawai;
  String? jenis_user;
  String? lokasi_absen;
  String? foto;

  DataUser({
    this.id,
    this.username,
    this.nama_pegawai,
    this.jenis_user,
    this.lokasi_absen,
    this.foto,
  });

  factory DataUser.fromJson(Map<String, dynamic> json) {
    return DataUser(
      id: json['id'],
      username: json['username'],
      nama_pegawai: json['nama_pegawai'],
      jenis_user: json['jenis_user'],
      lokasi_absen: json['lokasi_absen'],
      foto: json['foto'],
    );
  }
}
