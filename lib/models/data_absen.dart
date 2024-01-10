// ignore_for_file: non_constant_identifier_names

class DataAbsen {
  String? id;
  String? username;
  String? namaPegawai;
  String? c_in;
  String? tgl_c_in;
  String? c_out;
  String? tgl_c_out;
  String? lateS;
  String? early;
  String? overtime;
  String? latitude;
  String? longitude;
  String? lokasi;
  String? namaLokasi;
  String? ijin;
  String? ketIjin;
  String? tglIjinAwal;
  String? tglIjinAkhir;
  String? statusIjin;
  String? docIjin;

  DataAbsen({
    this.id,
    this.username,
    this.namaPegawai,
    this.c_in,
    this.tgl_c_in,
    this.c_out,
    this.tgl_c_out,
    this.lateS,
    this.early,
    this.overtime,
    this.latitude,
    this.longitude,
    this.lokasi,
    this.namaLokasi,
    this.ijin,
    this.ketIjin,
    this.tglIjinAwal,
    this.tglIjinAkhir,
    this.statusIjin,
    this.docIjin,
  });

  DataAbsen.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    username = json["username"];
    namaPegawai = json["nama_pegawai"];
    c_in = json["c_in"];
    tgl_c_in = json["tgl_c_in"];
    c_out = json["c_out"];
    tgl_c_out = json["tgl_c_out"];
    lateS = json["late"];
    early = json["early"];
    overtime = json["overtime"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    lokasi = json["lokasi"];
    namaLokasi = json["nama_lokasi"];
    ijin = json["ijin"];
    ketIjin = json["ket_ijin"];
    tglIjinAwal = json["tgl_ijin_awal"];
    tglIjinAkhir = json["tgl_ijin_akhir"];
    statusIjin = json["status_ijin"];
    docIjin = json["doc_ijin"];

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['username'] = username;
      data['nama_pegawai'] = namaPegawai;
      data['c_in'] = c_in;
      data['tgl_c_in'] = tgl_c_in;
      data['c_out'] = c_out;
      data['tgl_c_out'] = tgl_c_out;
      data['late'] = lateS;
      data['early'] = early;
      data['overtime'] = overtime;
      data['latitude'] = latitude;
      data['longitude'] = longitude;
      data['lokasi'] = lokasi;
      data['nama_lokasi'] = namaLokasi;
      data['ijin'] = ijin;
      data['ket_ijin'] = ketIjin;
      data['tgl_ijin_awal'] = tglIjinAwal;
      data['tgl_ijin_akhir'] = tglIjinAkhir;
      data['status_ijin'] = statusIjin;
      data['doc_ijin'] = docIjin;
      return data;
    }
  }
}