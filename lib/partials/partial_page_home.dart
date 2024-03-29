// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, prefer_collection_literals, sort_child_properties_last, sized_box_for_whitespace, use_build_context_synchronously, prefer_if_null_operators, depend_on_referenced_packages, no_leading_underscores_for_local_identifiers, unnecessary_new, unused_local_variable, unnecessary_brace_in_string_interps, unnecessary_import, unnecessary_string_interpolations
import 'dart:convert';
import 'dart:io';
// import 'dart:io';
import 'dart:math';
// import 'package:app_presensi_smantegaldlimo/models/data_cek_lokasi.dart';
import 'package:app_presensi_smantegaldlimo/models/data_cek_absen.dart';
import 'package:app_presensi_smantegaldlimo/models/data_mt_shift.dart';
import 'package:app_presensi_smantegaldlimo/models/data_user.dart';
import 'package:app_presensi_smantegaldlimo/pages/page_home.dart';
import 'package:app_presensi_smantegaldlimo/pages/page_login.dart';
import 'package:app_presensi_smantegaldlimo/pages/page_offline.dart';
// import 'package:app_presensi_smantegaldlimo/globals/apiUrl.dart' as url_api;
// import 'package:app_presensi_smantegaldlimo/utils/util_card_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:safe_device/safe_device.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_presensi_smantegaldlimo/globals/apiUrl.dart' as url_api;

class PartPageHome extends StatefulWidget {
  const PartPageHome({super.key});

  @override
  State<PartPageHome> createState() => _PartPageHomeState();
}

class _PartPageHomeState extends State<PartPageHome> {
  
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  LatLng? _currentPosition;
  LatLng? initialLocation;
  LatLng staticLocation = LatLng(-8.495754591841902, 114.28139647893876);

  bool? _jailbroken;
  bool? _developerMode;

  final DateFormat formatterDate = DateFormat('dd-MM-yyyy H:m:s');

  final DateFormat formatterDate2 = DateFormat('EEEE, dd MMMM yyyy');

  String username = "";
  late Future<DataUser> futureDataUser;
  late Future<DataMtShift> futureMasterShift;

  //cek koneksi internet
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  String string = '';

  String? kodeLok;
  String? namaLok;
  double? latit = 0;
  double? longit = 0;
  double? radius = 0;
  String? namaPeg;
  String? jenisKel;
  String? jenisUsr;
  String? usernm;
  String? email;
  String? foto;
  String? lokasiAbsen;

  bool isLoading = true;
  bool nowAbsen = false;

  // LatLng? _positionNow;
  // bool _isLoading = true;
  late GoogleMapController mapController;

  double? latt = 0;
  double? longg = 0;

  bool canMockLocation = false;

  String _address = ""; // create this variable

  late Future<DataCekAbsen> futureDataAbsen;

  Future<void> initPlatformState() async {
    bool jailbroken;
    bool developerMode;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
      developerMode = await FlutterJailbreakDetection.developerMode;
    } on PlatformException {
      jailbroken = true;
      developerMode = true;
    }

    if (!mounted) return;
    // _developerMode==false
    // ?
    // null
    // :
    // notifFakeGps();

    setState(() {
      _jailbroken = jailbroken;
      _developerMode = developerMode;

      _developerMode == null
          ? "Unknown"
          : _developerMode!
              ? notifFakeGps()
              : "NO";
    });
  }

  void getLocation() async {
    cekKoneksiInternet();
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double? lat = position.latitude;
    double? long = position.longitude;
    LatLng location = LatLng(lat, long);

    setState(() {
      _currentPosition = location;
      latt = _currentPosition!.latitude;
      longg = _currentPosition!.longitude;
      // _positionNow = LatLng(lat, long);
      // _isLoading = false;
      getPlace(latt, longg);
      // initPlatformState();
    });
  }

  double calculateDistance(lat1, lon1, lat, long) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat - lat1) * p) / 2 +
        c(lat1 * p) * c(lat * p) * (1 - c((long - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); //dikalikan 1000 untuk meter
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    controller.showMarkerInfoWindow(MarkerId("pusatAbsen"));
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(4, 4)), "assets/loc.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  notifFakeGps() {
    AwesomeDialog(
      context: context,
      dismissOnTouchOutside: false,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      btnOkColor: Colors.orange,
      title: 'Warning',
      desc:
          'Terdeteksi FAKE GPS / Developer Mode On, dimohon untuk mematikan fitur tersebut.\n Press OK untuk keluar aplikasi.',
      btnOkOnPress: () {
        exit(0);
      },
    ).show();
  }

  notifOutArea() {
    Alert(
      context: context,
      style: const AlertStyle(
        isCloseButton: false,
        descStyle: TextStyle(fontSize: 14.0),
      ),
      type: AlertType.warning,
      title: "WARNING",
      desc: "Anda sedang berada diluar area absensi.",
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.orange,
        ),
      ],
    ).show();
  }

  getPref() async {
    cekKoneksiInternet();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");
    if (islogin != null && islogin == true) {
      setState(() {
        username = pref.getString("username")!;
        // pref.setString('username', username);
        getDataLokasiUser(username);
      });
    } else {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const PageLogin(),
          ),
          (route) => false,
        );
      }
    }
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("is_login");
      preferences.remove("username");
      preferences.remove("fullname");
    });

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const PageLogin(),
        ),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          "Berhasil logout",
          style: TextStyle(fontSize: 16),
        )),
      );
    }
  }

  // get place
  void getPlace(lat, long) async {
    List<Placemark> newPlace =
        // await placemarkFromCoordinates(-7.440232, 112.613748);
        await placemarkFromCoordinates(lat, long);
    Placemark placeMark = newPlace[0];
    String subAdministrativeArea = placeMark.subAdministrativeArea.toString();
    String subLocality = placeMark.subLocality.toString();
    String locality = placeMark.locality.toString();
    // String administrativeArea = placeMark.administrativeArea.toString();
    // String postalCode = placeMark.postalCode.toString();
    // String country = placeMark.country.toString();
    String address = "$subLocality, $locality, $subAdministrativeArea";
    cekKoneksiInternet();
    setState(() {
      _address = address;
    });
  }

  getData() async {
    //Codec<String, String> stringToBase64 = utf8.fuse(base64);
    //String encodedNis = stringToBase64.encode(nis);
    final prefs = await SharedPreferences.getInstance();
    var user = prefs.getString('username');
    final response = await http.get(
        Uri.parse("${url_api.baseUrl}/api/v1/get-data-user/$user"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });

    Map<String, dynamic> temp = json.decode(response.body);
    String? _usernamePost = temp['username'];
    double? _latitPost = latt;
    double? _longitPost = longg;
    String? _lokasiPost = temp['lokasi_absen'];
    // String? _ijinPost = temp['nis'];
    // String? _ketIjinPost = temp['nis'];
    // String? _tglIjinAwalPost = temp['nis'];
    // String? _tglIjinAkhirPost = temp['nis'];
    // String? _statusIjinPost = temp['nis'];
    // String? _docIjinPost = temp['nis'];

    if (response.statusCode == 200) {
      if (_usernamePost.toString() == user.toString()) {
        AwesomeDialog(
                context: context,
                dismissOnTouchOutside: true,
                dialogType: DialogType.info,
                animType: AnimType.rightSlide,
                btnOkColor: Colors.blue,
                title: 'Konfirmasi',
                desc:
                    'Yakin sudah sesuai jadwal absen?\nPress YA untuk melanjutkan absen.',
                btnOkOnPress: () {
                  postDataAbsen(
                      _usernamePost, _latitPost, _longitPost, _lokasiPost);
                },
                btnCancelOnPress: () {},
                btnOkText: 'Ya',
                btnCancelText: 'Tidak')
            .show();
      } else {
        AwesomeDialog(
          context: context,
          dismissOnTouchOutside: false,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          btnOkColor: Colors.red,
          title: 'Error',
          desc: 'Absen gagal, ulangi proses!',
          btnOkOnPress: () {},
        ).show();
      }
      // return ScanData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data.');
    }
  }

  postDataAbsen(usernamePost, latitPost, longitPost, lokasiPost) async {
    final response = await http.post(
        Uri.parse(nowAbsen
            ? "${url_api.baseUrl}/api/v1/update-absensi-user"
            : "${url_api.baseUrl}/api/v1/proses-absensi-user"),
        body: {
          "username": usernamePost,
          "latitude": latitPost.toString(),
          "longitude": longitPost.toString(),
          "lokasi": lokasiPost
        });

    final resp = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (resp['status'] == 'success') {
        AwesomeDialog(
          context: context,
          dismissOnTouchOutside: false,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Sukses',
          desc: 'Absen berhasil',
          btnOkOnPress: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => PageHome(),
              ),
              (route) => false,
            );
          },
        ).show();
      } else if (resp['status'] == 'noAccess') {
        AwesomeDialog(
          context: context,
          dismissOnTouchOutside: false,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: 'Gagal absen, pastikan absen sesuai dengan jadwal.',
          btnOkColor: Colors.red,
          btnOkOnPress: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => PageHome(),
              ),
              (route) => false,
            );
          },
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dismissOnTouchOutside: false,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          btnOkColor: Colors.red,
          title: 'Failed',
          desc: 'Absen gagal, silahkan ulangi proses.',
          btnOkOnPress: () {},
        ).show();
      }
    } else {
      AwesomeDialog(
        context: context,
        dismissOnTouchOutside: false,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        btnOkColor: Colors.red,
        title: 'Failed',
        desc: 'Absen gagal, silahkan ulangi proses.',
        btnOkOnPress: () {},
      ).show();
    }
  }

  cekKoneksiInternet() {
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;
      print('source $_source');
      // 1.
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          string = _source.values.toList()[0] ? 'Online' : 'Offline';
          break;
        case ConnectivityResult.wifi:
          string = _source.values.toList()[0] ? 'Online' : 'Offline';
          break;
        case ConnectivityResult.none:
        default:
          string = 'Offline';
      }
      // 2.
      // setState(() {});
      // 3.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       string,
      //       style: TextStyle(fontSize: 14),
      //     ),
      //   ),
      // );
      if (string == 'Offline') {
        Timer(
            const Duration(seconds: 4),
            () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const PageOffline())));
      }
    });
  }

  //format tanggal Indo
  var dtNow = new DateTime.now();
  String hariIndo = '';
  String tanggalIndo = '';

  @override
  void initState() {
    cekKoneksiInternet();
    futureDataAbsen = fetchDataCekAbsen();
    futureDataUser = fetchDatauser();
    futureMasterShift = fetchMasterShift();
    getPref();
    getLocation();
    initPlatformState();
    //getPlace();
    addCustomIcon();
    dtNow;
    super.initState();

    String formatHari(String tanggal) {
      DateTime dateTime = DateFormat("yyyy-MM-dd").parse(tanggal);

      var day = DateFormat('EEEE').format(dateTime);
      var hari = "";
      switch (day) {
        case 'Sunday':
          {
            hari = "Minggu";
          }
          break;
        case 'Monday':
          {
            hari = "Senin";
          }
          break;
        case 'Tuesday':
          {
            hari = "Selasa";
          }
          break;
        case 'Wednesday':
          {
            hari = "Rabu";
          }
          break;
        case 'Thursday':
          {
            hari = "Kamis";
          }
          break;
        case 'Friday':
          {
            hari = "Jumat";
          }
          break;
        case 'Saturday':
          {
            hari = "Sabtu";
          }
          break;
      }
      return hari;
    }

    String formatTglIndo(String tanggal) {
      DateTime dateTime = DateFormat("yyyy-MM-dd").parse(tanggal);

      var m = DateFormat('MM').format(dateTime);
      var d = DateFormat('dd').format(dateTime).toString();
      var Y = DateFormat('yyyy').format(dateTime).toString();
      var month = "";
      switch (m) {
        case '01':
          {
            month = "Januari";
          }
          break;
        case '02':
          {
            month = "Februari";
          }
          break;
        case '03':
          {
            month = "Maret";
          }
          break;
        case '04':
          {
            month = "April";
          }
          break;
        case '05':
          {
            month = "Mei";
          }
          break;
        case '06':
          {
            month = "Juni";
          }
          break;
        case '07':
          {
            month = "Juli";
          }
          break;
        case '08':
          {
            month = "Agustus";
          }
          break;
        case '09':
          {
            month = "September";
          }
          break;
        case '10':
          {
            month = "Oktober";
          }
          break;
        case '11':
          {
            month = "November";
          }
          break;
        case '12':
          {
            month = "Desember";
          }
          break;
      }
      return "$d $month $Y";
    }

    hariIndo = formatHari(dtNow.toString());
    tanggalIndo = formatTglIndo(dtNow.toString());
  }

  @override
  dispose() {
    _networkConnectivity.disposeStream();
    super.dispose();
  }

  Widget displayMaps() {
    return initialLocation == null
        ? Container(child: Center(child: Text("Sedang memuat lokasi...")))
        : GoogleMap(
            onTap: (initialLocation) async {
              if (canMockLocation == true) {
                notifFakeGps();
              } else {
                // if(distance<100){
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (BuildContext context) => PageHome(),
                //   ),
                //   (route) => false,
                // );
                // }else{
                //   notifOutArea();
                // }
              }
            },
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(latit!, longit!),
              zoom: 17,
            ),
            markers: {
              Marker(
                markerId: MarkerId("pusatAbsen"),
                position: LatLng(latit!, longit!),
                draggable: true,
                onDragEnd: (value) {
                  // value is the new position
                },
                infoWindow: InfoWindow(
                  title: namaLok!,
                ),
                icon: markerIcon,
              ),
            },
            circles: Set.from([
              Circle(
                circleId: CircleId("Main Location"),
                center: initialLocation!,
                radius: radius!,
                strokeWidth: 3,
                strokeColor: Colors.blue,
                fillColor: const Color.fromARGB(75, 33, 149, 243),
              )
            ]),
          );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    var screenSize = MediaQuery.of(context).size;

    double? distance = calculateDistance(latit, longit, latt, longg);
    double? distancemeter = distance * 1000;

    String distanceToStringMeter = distancemeter.toStringAsFixed(0);
    String distanceToStringKiloMeter = distance.toStringAsFixed(0);

    // double aa = -8.495783716658607;
    // double bb = 114.28137237116434;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 250, 250, 252),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.black,
            height: 0.5,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(2),
                  child: FutureBuilder<DataUser>(
                    future: futureDataUser,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SMAN 1 TEGALDLIMO",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 1),
                            Text(
                              "${snapshot.data!.nama_pegawai}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return const CircularProgressIndicator(
                        color: Color.fromARGB(255, 168, 17, 156),
                        strokeWidth: 2,
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
        actionsIconTheme: IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("Keluar"),
              ),
              // const PopupMenuItem<int>(
              //   value: 1,
              //   child: Text("Settings"),
              // ),
              // const PopupMenuItem<int>(
              //   value: 2,
              //   child: Text("Logout"),
              // ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              logOut();
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //       builder: (BuildContext context) => PageOffline(),
              //     ),
              //     (route) => false,
              //   );
            }
            // else if (value == 1) {
            //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //     content: Text('Ke Menu Setting'),
            //   ));
            // } else if (value == 2) {
            //   logOut();
            // }
          }),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Color.fromARGB(255, 168, 17, 156),
              tooltip: 'Refresh Page',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => PageHome(),
                  ),
                  (route) => false,
                );
              },
              child: const Icon(Icons.refresh_outlined,
                  color: Colors.white, size: 25),
            ),
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topRight,
              colors: <Color>[
                Colors.white,
                Color.fromARGB(255, 211, 175, 187),
                Color.fromARGB(255, 99, 129, 153),
              ],
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    Container(
                      width: screenSize.width / 1,
                      height: screenSize.height / 3,
                      child: displayMaps(),
                    ),
                    Column(
                      children: [
                        SizedBox(height: 15),
                        distancemeter >= 1000
                            ? Column(
                                children: [
                                  // Text(
                                  //   "Lokasi Anda\n$_address\nJarak $distanceToStringKiloMeter KM dari $namaLok",
                                  //   textAlign: TextAlign.center,
                                  //   style: TextStyle(color: Colors.black),
                                  // ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.location_pin,
                                          color: const Color.fromARGB(
                                              255, 153, 12, 2),
                                          size: 15),
                                      Text(
                                        "Radius $distanceToStringKiloMeter KM dari $namaLok",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                      ),
                                    ],
                                  ),

                                  // distancemeter < radius!
                                  //     ? Text("(Didalam area absensi)")
                                  //     : Text("(Diluar area absensi)")
                                  SizedBox(height: 5),
                                ],
                              )
                            : Column(
                                children: [
                                  // Text(
                                  //     "Lokasi Anda\n$_address\nJarak $distanceToStringMeter Meter dari $namaLok",
                                  //     textAlign: TextAlign.center,
                                  //     style: TextStyle(color: Colors.black)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.location_pin,
                                          color: const Color.fromARGB(
                                              255, 153, 12, 2),
                                          size: 15),
                                      Text(
                                          "Radius $distanceToStringMeter Meter dari $namaLok",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                    ],
                                  ),

                                  // distancemeter < radius!
                                  //     ? Text("(Didalam area absensi)")
                                  //     : Text("(Diluar area absensi)")
                                  SizedBox(height: 5),
                                ],
                              ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: FutureBuilder<DataCekAbsen>(
                              future: futureDataAbsen,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              distancemeter < radius!
                                                  ? snapshot.data!.c_in == 'YES'
                                                      ? null
                                                      : snapshot.data!.ijin ==
                                                              'YES'
                                                          ? ScaffoldMessenger
                                                                  .of(context)
                                                              .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      "Tidak bisa absen, status Anda sedang ijin...")),
                                                            )
                                                          : getData()
                                                  : ScaffoldMessenger.of(
                                                          context)
                                                      .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              "Sedang diluar area absen...")),
                                                    );
                                            },
                                            child: Container(
                                              width: screenSize.width / 4,
                                              // height: screenSize.height / 8,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: Colors.green),
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                children: [
                                                  Column(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .fingerprint_rounded,
                                                        size: 40,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text("Clock-In",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          snapshot.data!.c_in == 'YES'
                                              ? Column(
                                                  children: [
                                                    Text(
                                                        formatterDate.format(
                                                            DateTime.parse(
                                                                "${snapshot.data!.tgl_c_in}")),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    Text("--/--/---- --:--",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ],
                                                )
                                        ],
                                      ),
                                      SizedBox(width: 5),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              distancemeter < radius!
                                                  ? snapshot.data!.c_out ==
                                                          'YES'
                                                      ? null
                                                      : snapshot.data!.ijin ==
                                                              'YES'
                                                          ? ScaffoldMessenger
                                                                  .of(context)
                                                              .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      "Tidak bisa absen, status Anda sedang ijin...")),
                                                            )
                                                          : nowAbsen
                                                              ? getData()
                                                              : ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          "Tidak bisa absen, Anda belum clock-in...")),
                                                                )
                                                  : ScaffoldMessenger.of(
                                                          context)
                                                      .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              "Sedang diluar area absen...")),
                                                    );
                                            },
                                            child: Container(
                                              width: screenSize.width / 4,
                                              // height: screenSize.height / 8,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: Colors.red),
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                children: [
                                                  Column(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .fingerprint_rounded,
                                                        size: 40,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text("Clock-Out",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          snapshot.data!.c_out == 'YES'
                                              ? Column(
                                                  children: [
                                                    Text(
                                                        formatterDate.format(
                                                            DateTime.parse(
                                                                "${snapshot.data!.tgl_c_out}")),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    Text("--/--/---- --:--",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ],
                                                )
                                        ],
                                      ),
                                    ],
                                  );
                                } else if (snapshot.hasError) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:[
                                      Text("Anda tidak dapat melakukan absen.", style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                                      Text("Terjadi kesalahan saat memuat data."),
                                      Text("Coba lagi, atau hubungi Administrator."),
                                      SizedBox(height: 20)
                                    ]
                                    );
                                }
                                return const CircularProgressIndicator(
                                  color: Color.fromARGB(255, 168, 17, 156),
                                  strokeWidth: 2,
                                );
                              }),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: [
                            Center(
                              // formatterDate2
                              //         .format(DateTime.parse("${tanggalIndo}")),
                              child: Text("${hariIndo}, ${tanggalIndo}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: FutureBuilder<DataMtShift>(
                              future: futureMasterShift,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Center(
                                            child: Container(
                                              child: Text("Jam Masuk",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                          Container(
                                            width: screenSize.width / 2.5,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: const Color.fromARGB(
                                                      255, 168, 17, 156)),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(3),
                                              child: Center(
                                                  child: Column(
                                                children: [
                                                  Text(
                                                      "${snapshot.data!.jamMasukAwal.toString()}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text("s/d",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      "${snapshot.data!.jamMasuk.toString()}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              )),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Column(
                                        children: [
                                          Center(
                                            child: Container(
                                              child: Text("Jam Pulang",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                          Container(
                                            width: screenSize.width / 2.5,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 168, 17, 156)),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(3),
                                              child: Center(
                                                  child: Column(
                                                children: [
                                                  Text(
                                                      "${snapshot.data!.jamPulang}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text("s/d",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      "${snapshot.data!.jamPulangAkhir}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              )),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  );
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }
                                return const CircularProgressIndicator(
                                  color: Color.fromARGB(255, 168, 17, 156),
                                  strokeWidth: 2,
                                );
                              }),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<DataUser> fetchDatauser() async {
    final prefs = await SharedPreferences.getInstance();
    var ss = prefs.getString('username');
    final response = await http.get(
        Uri.parse(
            "${url_api.baseUrl}/api/v1/get-data-user/$ss"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      return DataUser.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load User.');
    }
  }

  Future getDataLokasiUser(usr) async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      // var ss = prefs.getString('username');
      final response = await http.get(Uri.parse(
          "${url_api.baseUrl}/api/v1/get-cek-lokasi/$usr"));

      Map<String, dynamic> temp = json.decode(response.body);
      if (response.statusCode == 200) {
        if (context.mounted) {
          setState(() {
            kodeLok = temp['kode_lokasi'].toString();
            namaLok = temp['nama_lokasi'].toString();
            latit = double.parse(temp['latitude'].toString());
            longit = double.parse(temp['longitude'].toString());
            radius = double.parse(temp['radius'].toString());
            namaPeg = temp['nama_pegawai'].toString();
            jenisKel = temp['jenis_kelamin'].toString();
            jenisUsr = temp['jenis_user'].toString();
            usernm = temp['username'].toString();
            email = temp['email'].toString();
            foto = temp['foto'].toString();
            lokasiAbsen = temp['lokasi_absen'].toString();
            initialLocation = LatLng(latit!, longit!);
          });
        }
      }
    } catch (e) {
      Navigator.pop(context, '$e');
      debugPrint('$e');
    }
  }

  Future<DataCekAbsen> fetchDataCekAbsen() async {
    final prefs = await SharedPreferences.getInstance();
    var ss = prefs.getString('username');
    final response = await http.get(
        Uri.parse(
            "${url_api.baseUrl}/api/v1/cek-absensi-user/$ss"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });

    Map<String, dynamic> temp = json.decode(response.body);
    String? _nowClockIn = temp['c_in'];

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      if (_nowClockIn.toString() == 'YES') {
        setState(() {
          nowAbsen = true;
        });
      }
      return DataCekAbsen.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load User.');
    }
  }

  Future<DataMtShift> fetchMasterShift() async {
    final response = await http.get(
        Uri.parse(
            "${url_api.baseUrl}/api/v1/get-master-shift"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      return DataMtShift.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load User.');
    }
  }
}

//cek koneksi internet
class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;
  void initialise() async {
    ConnectivityResult result = await _networkConnectivity.checkConnectivity();
    _checkStatus(result);
    _networkConnectivity.onConnectivityChanged.listen((result) {
      print(result);
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}
