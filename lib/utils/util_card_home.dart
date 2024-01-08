// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class CardHome extends StatelessWidget {
  final IconData cardHome;
  const CardHome({Key? key, required this.cardHome}) : super(key: key) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 92, 92, 92),
        borderRadius: BorderRadius.circular(12)
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Icon(cardHome,
          size: 25,
          color: Colors.white,
        ),
      ),
    );
  }
}