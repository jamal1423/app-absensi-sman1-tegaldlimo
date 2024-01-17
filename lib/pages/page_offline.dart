// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:app_presensi_smantegaldlimo/main.dart';
import 'package:flutter/material.dart';

class PageOffline extends StatefulWidget {
  const PageOffline({super.key});

  @override
  State<PageOffline> createState() => _PageOfflineState();
}

class _PageOfflineState extends State<PageOffline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 50),
            Text("Perangkat Offline", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => MyApp(),
                  ),
                  (route) => false,
                );
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blue
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.refresh_rounded, color: Colors.white),
                      Text("Refresh", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}