// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, prefer_collection_literals, sort_child_properties_last, sized_box_for_whitespace, use_build_context_synchronously, prefer_if_null_operators, depend_on_referenced_packages, no_leading_underscores_for_local_identifiers, unnecessary_new, unused_local_variable, unnecessary_brace_in_string_interps
import 'dart:convert';
// import 'dart:io';
import 'dart:math';
// import 'package:app_patroli_satpam/models/data_user.dart';
// import 'package:app_patroli_satpam/pages/page_home.dart';
// import 'package:app_patroli_satpam/pages/page_login.dart';
// import 'package:app_patroli_satpam/partials/partial_page_lokasi_scan.dart';
// import 'package:app_patroli_satpam/partials/partial_page_master_shift.dart';
// import 'package:app_patroli_satpam/utils/util_card_home.dart';
// import 'package:app_presensi_smantegaldlimo/models/data_cek_lokasi.dart';
import 'package:app_presensi_smantegaldlimo/models/data_cek_absen.dart';
import 'package:app_presensi_smantegaldlimo/models/data_mt_shift.dart';
import 'package:app_presensi_smantegaldlimo/models/data_user.dart';
import 'package:app_presensi_smantegaldlimo/pages/page_home.dart';
import 'package:app_presensi_smantegaldlimo/pages/page_login.dart';
// import 'package:app_presensi_smantegaldlimo/utils/util_card_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safe_device/safe_device.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class PartPageHome extends StatefulWidget {
  const PartPageHome({super.key});

  @override
  State<PartPageHome> createState() => _PartPageHomeState();
}

class _PartPageHomeState extends State<PartPageHome> {
  //sma

  //kosan
  // LatLng initialLocation = LatLng(-7.378822662421588, 112.646988897764);

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  LatLng? _currentPosition;
  LatLng? initialLocation;
  LatLng staticLocation = LatLng(-8.495754591841902, 114.28139647893876);

  final DateFormat formatterDate = DateFormat('dd-MM-yyyy H:m:s');

  final DateFormat formatterDate2 = DateFormat('EEEE, dd MMMM yyyy');

  String username = "";
  late Future<DataUser> futureDataUser;
  late Future<DataMtShift> futureMasterShift;

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

  void getLocation() async {
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
      initPlatformState();
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

  Future<void> initPlatformState() async {
    await Permission.location.request();
    if (await Permission.location.isPermanentlyDenied) {
      openAppSettings();
    }

    if (!mounted) return;
    try {
      canMockLocation = await SafeDevice.canMockLocation;
    } catch (error) {
      print(error);
    }

    setState(() {
      canMockLocation = canMockLocation;
    });
  }

  notifFakeGps() {
    Alert(
      context: context,
      style: const AlertStyle(
        isCloseButton: false,
        descStyle: TextStyle(fontSize: 14.0),
      ),
      type: AlertType.warning,
      title: "WARNING",
      desc: "Terdeteksi FAKE GPS, dimohon untuk mematikan aplikasi tersebut.",
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

    setState(() {
      _address = address;
    });
  }

  // 'username' => 'required',
  //               'latitude' => 'required',
  //               'longitude' => 'required',
  //               'lokasi' => 'required',
  //               'ijin' => '',
  //               'ket_ijin' => '',
  //               'tgl_ijin_awal' => '',
  //               'tgl_ijin_akhir' => '',
  //               'status_ijin' => '',
  //               'doc_ijin' => '',

  getData() async {
    //Codec<String, String> stringToBase64 = utf8.fuse(base64);
    //String encodedNis = stringToBase64.encode(nis);
    final prefs = await SharedPreferences.getInstance();
    var user = prefs.getString('username');
    final response = await http.get(
        Uri.parse(
            "https://smantegaldlimo.startdev.my.id/api/v1/get-data-user/$user"),
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
          title: 'Confirm',
          desc: 'Press OK untuk melanjutkan absen.',
          btnOkOnPress: () {
            postDataAbsen(_usernamePost, _latitPost, _longitPost, _lokasiPost);
          },
        ).show();
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
            ? 'https://smantegaldlimo.startdev.my.id/api/v1/update-absensi-user'
            : 'https://smantegaldlimo.startdev.my.id/api/v1/proses-absensi-user'),
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
      } else if(resp['status'] == 'noAccess'){
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
        title: 'Failed',
        desc: 'Absen gagal, silahkan ulangi proses.',
        btnOkOnPress: () {},
      ).show();
    }
  }

  var dtNow = new DateTime.now();

  @override
  void initState() {
    futureDataAbsen = fetchDataCekAbsen();
    getPref();
    getLocation();
    futureDataUser = fetchDatauser();
    futureMasterShift = fetchMasterShift();
    super.initState();
    // initPlatformState();
    //getPlace();
    addCustomIcon();
    dtNow;
  }

  @override
  dispose() {
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
                              "Selamat Datang",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 1),
                            Text(
                              "${snapshot.data!.nama_pegawai}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return const CircularProgressIndicator(
                        color: Color.fromARGB(255, 167, 168, 168),
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
                child: Text("Profile"),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text("Settings"),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text("Logout"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Ke Menu Profile'),
              ));
            } else if (value == 1) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Ke Menu Setting'),
              ));
            } else if (value == 2) {
              logOut();
            }
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
              backgroundColor: Color.fromARGB(255, 22, 45, 250),
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
      body: Container(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(0),
              height: screenSize.height / 3,
              child: displayMaps(),
            ),
            // SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: screenSize.height / 2.4,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    distancemeter >= 1000
                        ? Column(
                            children: [
                              Text(
                                "Lokasi Anda\n$_address\nJarak $distanceToStringKiloMeter KM dari $namaLok",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ),
                              distancemeter < radius!
                                  ? Text("(Didalam area absensi)")
                                  : Text("(Diluar area absensi)")
                            ],
                          )
                        : Column(
                            children: [
                              Text(
                                  "Lokasi Anda\n$_address\nJarak $distanceToStringMeter Meter dari $namaLok",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black)),
                              distancemeter < radius!
                                  ? Text("(Didalam area absensi)")
                                  : Text("(Diluar area absensi)")
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
                                                  : getData()
                                              : ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Sedang diluar area absen...")),
                                                );
                                        },
                                        child: Container(
                                          width: screenSize.width / 2.5,
                                          height: screenSize.height / 10,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.green),
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            children: [
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Icon(
                                                        Icons.login_rounded,
                                                        size: 25,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text("Clock-In",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              snapshot.data!.c_in == 'YES'
                                                  ? Column(
                                                      children: [
                                                        Text(
                                                            formatterDate.format(
                                                                DateTime.parse(
                                                                    "${snapshot.data!.tgl_c_in}")),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ],
                                                    )
                                                  : Column(
                                                      children: [
                                                        Text(
                                                            "---- / -- / -- --:--",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ],
                                                    )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 5),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          distancemeter < radius!
                                              ? snapshot.data!.c_out == 'YES'
                                                  ? null
                                                  : getData()
                                              : ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Sedang diluar area absen...")),
                                                );
                                        },
                                        child: Container(
                                          width: screenSize.width / 2.5,
                                          height: screenSize.height / 10,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.red),
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            children: [
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Icon(
                                                        Icons.logout_rounded,
                                                        size: 25,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text("Clock-Out",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              snapshot.data!.c_out == 'YES'
                                                  ? Column(
                                                      children: [
                                                        Text(
                                                            formatterDate.format(
                                                                DateTime.parse(
                                                                    "${snapshot.data!.tgl_c_out}")),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ],
                                                    )
                                                  : Column(
                                                      children: [
                                                        Text(
                                                            "---- / -- / -- --:--",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ],
                                                    )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text("Proses Clock-In")),
                                          );
                                        },
                                        child: Container(
                                          width: screenSize.width / 2.5,
                                          height: screenSize.height / 10,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.green),
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            children: [
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Icon(
                                                        Icons.login_rounded,
                                                        size: 25,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text("Clock-In",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Column(
                                                children: [
                                                  Text("---- / -- / -- --:--",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 5),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text("Proses Clock-Out")),
                                          );
                                        },
                                        child: Container(
                                          width: screenSize.width / 2.5,
                                          height: screenSize.height / 10,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.red),
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            children: [
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Icon(
                                                        Icons.logout_rounded,
                                                        size: 25,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text("Clock-Out",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Column(
                                                children: [
                                                  Text("---- / -- / -- --:--",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return const CircularProgressIndicator(
                              color: Colors.blue,
                              strokeWidth: 2,
                            );
                          }),
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        Center(
                          child: Text(formatterDate2.format(DateTime.parse("${dtNow}")),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
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
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize.width / 2.5,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 163, 161, 161)),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Center(
                                            child: Text(
                                                "${snapshot.data!.jamMasukAwal.toString()} - ${snapshot.data!.jamMasuk.toString()}",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
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
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize.width / 2.5,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 163, 161, 161)),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Center(
                                            child: Text(
                                                "${snapshot.data!.jamPulang} - ${snapshot.data!.jamPulangAkhir}",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
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
                              color: Colors.blue,
                              strokeWidth: 2,
                            );
                          }),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DataUser> fetchDatauser() async {
    final prefs = await SharedPreferences.getInstance();
    var ss = prefs.getString('username');
    final response = await http.get(
        Uri.parse(
            "https://smantegaldlimo.startdev.my.id/api/v1/get-data-user/$ss"),
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
          "https://smantegaldlimo.startdev.my.id/api/v1/get-cek-lokasi/$usr"));

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
            "https://smantegaldlimo.startdev.my.id/api/v1/cek-absensi-user/$ss"),
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
            "https://smantegaldlimo.startdev.my.id/api/v1/get-master-shift"),
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
