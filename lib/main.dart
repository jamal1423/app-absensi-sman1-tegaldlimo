// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, unnecessary_string_interpolations, unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:io';
import 'package:app_presensi_smantegaldlimo/pages/page_login.dart';
import 'package:app_presensi_smantegaldlimo/pages/page_offline.dart';
// import 'package:app_presensi_smantegaldlimo/pages/page_splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Presensi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SMAN 1 TEGALDLIMO'),
    );
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'App Fluterku',
    //   home: SplashScreenPage(),
    // );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //cek koneksi internet
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  String string = '';

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
      setState(() {});
      // 3.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       string,
      //       style: TextStyle(fontSize: 14),
      //     ),
      //   ),
      // );

      if (string == 'Online') {
        Timer(
          const Duration(seconds: 4),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const PageLogin())));
      } else {
        Timer(
          const Duration(seconds: 4),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const PageOffline())));
      }
    });
  }

  @override
  void initState() {
    cekKoneksiInternet();
    super.initState();
    // Timer(
    //     const Duration(seconds: 6),
    //     () => Navigator.pushReplacement(context,
    //         MaterialPageRoute(builder: (context) => const PageLogin())));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
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
      child: Center(
        child: Image(
              image: AssetImage("assets/smanteg.png"),
              width: screenSize.width / 2,
              height: 100,
              // fit: BoxFit.fitWidth,
            ),
      )
    );
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