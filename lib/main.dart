import 'package:flutter/material.dart';
import 'package:vdrivpartner/screens/assigned.dart';
import 'package:vdrivpartner/screens/language_selection.dart';
import 'package:vdrivpartner/screens/otp_verification_screen.dart';
import 'package:vdrivpartner/screens/trip_details.dart';
import 'package:vdrivpartner/screens/trip_started.dart';
import 'screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VDrive Partner',
      theme: ThemeData(
       primaryColor: const Color(0xFFFFD300),
      ),
      home: LoginScreen(),
    );
  }
}
