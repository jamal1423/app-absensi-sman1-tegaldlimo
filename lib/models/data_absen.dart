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
  String? deskripsi;
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
    this.deskripsi,
    this.tglIjinAwal,
    this.tglIjinAkhir,
    this.statusIjin,
    this.docIjin,
  });

  DataAbsen.fromJson(Map<String, dynamic> json) {
    id = json["id"].toString();
    username = json["username"].toString();
    namaPegawai = json["nama_pegawai"].toString();
    c_in = json["c_in"].toString();
    tgl_c_in = json["tgl_c_in"].toString();
    c_out = json["c_out"].toString();
    tgl_c_out = json["tgl_c_out"].toString();
    lateS = json["late"].toString();
    early = json["early"].toString();
    overtime = json["overtime"].toString();
    latitude = json["latitude"].toString();
    longitude = json["longitude"].toString();
    lokasi = json["lokasi"].toString();
    namaLokasi = json["nama_lokasi"].toString();
    ijin = json["ijin"].toString();
    ketIjin = json["ket_ijin"].toString();
    deskripsi = json["deskripsi"].toString();
    tglIjinAwal = json["tgl_ijin_awal"].toString();
    tglIjinAkhir = json["tgl_ijin_akhir"].toString();
    statusIjin = json["status_ijin"].toString();
    docIjin = json["doc_ijin"].toString();

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['id'] = id;
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
      data['deskripsi'] = deskripsi;
      data['tgl_ijin_awal'] = tglIjinAwal;
      data['tgl_ijin_akhir'] = tglIjinAkhir;
      data['status_ijin'] = statusIjin;
      data['doc_ijin'] = docIjin;
      return data;
    }
  }
}